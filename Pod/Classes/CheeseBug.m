//
//  CheeseBug.h
//  Pods
//
//  Created by Cheesecake Labs on 2/12/15.
//
//

#import "CheeseBug.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

@interface CheeseBug ()

- (void)initCheeseBug;
- (void)validateAndSaveCriticalApplicationData;

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

- (void)validateAndSaveCriticalApplicationData {
    // Create the request.
    NSMutableURLRequest *request =
            [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://cheesebug.herokuapp.com/reports"]];

    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";

    // This is how we set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    // Convert your data and set your request's HTTPBody property
    NSString *stringData = @"thread=some&cause=unknown";
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;

    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)handleException:(NSException *)exception {
    [self validateAndSaveCriticalApplicationData];

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
