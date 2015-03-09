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

#include <libkern/OSAtomic.h>
#include <execinfo.h>

#pragma mark - Static constants

static NSString* const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
static NSString* const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
static NSString* const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

static volatile int32_t UncaughtExceptionCount = 0;
static const int32_t UncaughtExceptionMaximum = 10;

static const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
static const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation CheeseBug

#pragma mark - Library setup

// Represents a configuration that contains some useful information for the library to work.
static Configuration *_config = nil;


/*
 * Gets the library configuration object.
 */
+ (Configuration*)configutation {
    if(_config == nil) {
        _config = [[Configuration alloc] init];
    }
    
    return _config;
}

/*
 * Initializes the library for the given application serial. 
 * This function implements the Facade Patter by being the 
 * interface between the library and the app which uses it.
 */
+ (void)initCheeseBug:(NSString*)serialNumber {
    [CheeseBug setupConfiguration:serialNumber];
    [CheeseBug installUncaughtExceptionHandler];
}

/*
 * Sets up the configuration regarding the endpoint server and the serial to authentication.
 */
+ (void)setupConfiguration:(NSString*)serialNumber {
    [[CheeseBug configutation] setHost:@"http://52.11.209.25/core/crashes/"];
    [[CheeseBug configutation] setSerialNumber:serialNumber];
}

/*
 * Performs the installation of the handlers for eventual crashes in the application.
 */
+ (void)installUncaughtExceptionHandler {
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL,  signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGFPE,  signalHandler);
    signal(SIGBUS,  signalHandler);
    signal(SIGPIPE, signalHandler);
}

/*
 * Deals how the app will bahaviour in the moment right before it crashes for good.
 */
- (void)handleException:(NSException *)exception {
    [self notifyCriticalApplicationData:exception];
    
    // Raises an alert informing the user about the crash.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unhandled exception"
                                                    message:@"An error occurred and requires your app to be closed"
                                                   delegate:self
                                          cancelButtonTitle:@"Quit"
                                          otherButtonTitles:nil, nil];
    
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    // Keeps the app locked until the user clicks the "Quit" button.
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

/*
 * Function pointed by the UncaughtExceptionHandler at the library instalation.
 */
static void exceptionHandler(NSException *exception) {
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

/*
 * Function pointed for the system to deal with critical signals emmited.
 */
static void signalHandler(int signal) {
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

/*
 * Get data about the error occurred.
 */
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

/*
 * Releases the alert window and allow the application to finish.
 */
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
    dismissed = YES;
}

/*
 * Performs the installation of the handlers for eventual crashes in the application.
 */
- (void)notifyCriticalApplicationData:(NSException *)exception {
    
    // Creates a crash object which contains the data log.
    Crash *crash = [[Crash alloc] init];
    crash.crashName = exception.name;
    crash.crashReason = exception.reason;
    
    // Fill the dictionary with data regarding the crash itself.
    NSMutableDictionary *crashParametersJSON = [[NSMutableDictionary alloc] init];
    [crashParametersJSON setObject:crash.crashName forKey:@"exception_name"];
    [crashParametersJSON setObject:crash.crashReason forKey:@"exception_reason"];
    
    // Fill the dictionary which corresponds the full JSON sent to the server.
    NSMutableDictionary *crashJSON = [[NSMutableDictionary alloc] init];
    [crashJSON setObject:[[CheeseBug configutation] serialNumber] forKey:@"serial_number"];
    [crashJSON setObject:crashParametersJSON forKey:@"crash"];
    
    // Performs the HTTP POST setting the serializer to deal with JSON types.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager POST:[[CheeseBug configutation] host] parameters:crashJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
