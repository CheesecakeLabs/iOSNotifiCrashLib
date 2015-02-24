//
//  CheeseBug.h
//  Pods
//
//  Created by Cheesecake Labs on 2/12/15.
//
//

#import "CheeseBug.h"
#import "Crash.h"
#import "AFNetworking.h"
#import "Configuration.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

@interface CheeseBug ()

@property (strong, nonatomic) Configuration *config;

- (void)initCheeseBug;
- (void)validateAndSaveCriticalApplicationData:(NSException *)exception;

@end

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation CheeseBug

- (id)init {
    self = [super init];
    
    if (self) {
        [self initCheeseBug];
    }
    
    return self;
}

- (void)initCheeseBug {
    InstallUncaughtExceptionHandler();
    [self setupConfiguration];
}

- (void)setupConfiguration {
    self.config = [[Configuration alloc] init];
    self.config.host = @"http://10.0.1.5:8000/core/crashes/";
    self.config.serialNumber = @"8723c5n23857cn23n52nc2138cn231";
}

+ (NSArray*)backtrace {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
    dismissed = YES;
}

- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {
    
    // Creates a crash object which contains the data log.
    Crash *crash = [[Crash alloc] init];
    crash.crashName = exception.name;
    crash.crashReason = exception.reason;
    crash.time = [NSDate date];
    
    // Fill the dictionary with data regarding the crash itself.
    NSMutableDictionary *crashParametersJSON = [[NSMutableDictionary alloc] init];
    [crashParametersJSON setObject:crash.crashName forKey:@"exception_name"];
    [crashParametersJSON setObject:crash.crashReason forKey:@"exception_reason"];
    [crashParametersJSON setObject:[crash getStringTime] forKey:@"exception_time"];
    
    // Fill the dictionary which corresponds the full JSON sent to the server.
    NSMutableDictionary *crashJSON = [[NSMutableDictionary alloc] init];
    [crashJSON setObject:self.config.serialNumber forKey:@"serial_number"];
    [crashJSON setObject:crashParametersJSON forKey:@"crash"];
    
    // Performs the HTTP POST setting the serializer to deal with JSON types.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager POST:self.config.host parameters:crashJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)handleException:(NSException *)exception {
    [self validateAndSaveCriticalApplicationData:exception];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unhandled exception"
                                                    message:[NSString stringWithFormat:@"\nDebug details follow:\n%@\n%@",
                                                             [exception reason],
                                                             [exception userInfo][UncaughtExceptionHandlerAddressesKey]]
                                                   delegate:self
                                          cancelButtonTitle:@"Quit"
                                          otherButtonTitles:nil, nil];
    
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray*)allModes) {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[exception userInfo][UncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

@end

void HandleException(NSException *exception) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSArray *callStack = [CheeseBug backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    userInfo[UncaughtExceptionHandlerAddressesKey] = callStack;
    
    [[[CheeseBug alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                               withObject: [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo]
                                            waitUntilDone:YES];
}

void SignalHandler(int signal) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo = [@{UncaughtExceptionHandlerSignalKey : @(signal)} mutableCopy];
    
    NSArray *callStack = [CheeseBug backtrace];
    userInfo[UncaughtExceptionHandlerAddressesKey] = callStack;
    
    [[[CheeseBug alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject:
     [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                             reason: [NSString stringWithFormat:@"Signal %d was raised.", signal]
                           userInfo: @{UncaughtExceptionHandlerSignalKey : @(signal)}]
                                            waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler() {
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}
