//
//  NotifiCrash.m
//  Pods
//
//  Created by Cheesecake Labs on 2/12/15.
//
//

#import "NotifiCrash.h"
#import "Crash.h"
#import "NTFConstants.h"
#include <libkern/OSAtomic.h>

@implementation NotifiCrash

#pragma mark - Library setup

// Represents a configuration that contains some useful information for the library to work.
static Configuration *_config = nil;
static Crash *_crash = nil;

/*
 * Gets the library configuration object.
 */
+ (Configuration *)configuration
{
    if (_config == nil) {
        _config = [[Configuration alloc] init];
    }

    return _config;
}

/*
 * Gets the crash object.
 */
+ (Crash *)crash
{
    if (_crash == nil) {
        _crash = [[Crash alloc] init];
    }

    return _crash;
}

/*
 * Initializes the library for the given application serial. 
 * This function implements the Facade Patter by being the 
 * interface between the library and the app which uses it.
 */
+ (void)initWithSerialNumber:(NSString *)serialNumber
{
    [NotifiCrash setupConfiguration:serialNumber];
    [NotifiCrash installUncaughtExceptionHandler];
}

/*
 * Sets up the configuration regarding the endpoint server and the serial to authentication.
 */
+ (void)setupConfiguration:(NSString *)serialNumber
{
    [[NotifiCrash configuration] setHost:Host];
    [[NotifiCrash configuration] setSerialNumber:serialNumber];
}

/*
 * Function pointed by the UncaughtExceptionHandler at the library installation.
 */
static void exceptionHandler(NSException *exception)
{
    if ([NotifiCrash reachMaximum])
        return;

    [NotifiCrash crash].stackSymbols = [exception callStackSymbols];

    [NotifiCrash handlerError:nil name:[exception name] reason:[exception reason]];
}

/*
 * Function pointed for the system to deal with critical signals emitted.
 */
static void signalHandler(int signal)
{
    if ([NotifiCrash reachMaximum])
        return;

    NSString *reason = [NSString stringWithFormat:@"Signal %d was raised.", signal];

    [NotifiCrash handlerError:nil name:UncaughtExceptionHandlerSignalExceptionName reason:reason];
}

/*
 * Checks if the signal/exception occurred is known by the system.
 */
+ (BOOL)reachMaximum
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    return exceptionCount > UncaughtExceptionMaximum;
}

/*
 * Calls the functions which will deal with the application ending passing some useful information regarding the crash.
 */
+ (void)handlerError:(NSMutableDictionary *)userInfo name:(NSString *)name reason:(NSString *)reason
{
    [[[NotifiCrash alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                 withObject:[NSException exceptionWithName:name reason:reason userInfo:userInfo]
                                              waitUntilDone:YES];
}

/*
 * Deals how the app will behaviour in the moment right before it crashes for good.
 */
- (void)handleException:(NSException *)exception
{
    [self notifyCriticalApplicationData:exception];

    // Raises an alert informing the user about the crash.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AlertTitle
                                                    message:AlertMessage
                                                   delegate:self
                                          cancelButtonTitle:AlertButton
                                          otherButtonTitles:nil];

    [alert show];

    // Forces the app to close in a maximum of 5 seconds.
    [self performSelector:@selector(closeAlert) withObject:nil afterDelay:5];

    // Loop the thread enters and uses to run event handlers
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);

    // Keeps the app locked until the user clicks the "Quit" button.
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *) allModes) {
            CFRunLoopRunInMode((__bridge CFStringRef) mode, 0.001, false);
        }
    }

    CFRelease(allModes);

    // Releases the default handlers before killing the application.
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);

    // Finishes the application, either killing the process in case of a signal or raising an exception.
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[exception userInfo][UncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

/*
 * Performs the installation of the handlers for eventual crashes in the application.
 */
+ (void)installUncaughtExceptionHandler
{
    // exceptionHandler and signalHandler are pointer for functions which will handle exceptions and signals respectively.
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGFPE, signalHandler);
    signal(SIGBUS, signalHandler);
    signal(SIGPIPE, signalHandler);
}

/*
 * Releases the alert window and allow the application to finish.
 */
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    [self closeAlert];
}

- (void)closeAlert
{
    dismissed = YES;
}

/*
 * Performs the installation of the handlers for eventual crashes in the application.
 */
- (void)notifyCriticalApplicationData:(NSException *)exception
{
    // Fills the crash object with important data to post to the server.
    [NotifiCrash crash].crashName = exception.name;
    [NotifiCrash crash].crashReason = exception.reason;

    [self printCrashInfo];

    // Fill the dictionary with data regarding the crash itself.
    NSMutableDictionary *crashParametersJSON = [[NSMutableDictionary alloc] init];
    crashParametersJSON[@"exception_name"] = [[NotifiCrash crash] crashName];
    crashParametersJSON[@"exception_reason"] = [[NotifiCrash crash] crashReason];
    crashParametersJSON[@"stack_trace"] = [[[NotifiCrash crash] stackSymbols] componentsJoinedByString:@"\n"];
    
    // Fill the dictionary which corresponds the full JSON sent to the server.
    NSMutableDictionary *crashJSON = [[NSMutableDictionary alloc] init];
    crashJSON[@"serial_number"] = [[NotifiCrash configuration] serialNumber];
    crashJSON[@"crash"] = crashParametersJSON;
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:crashJSON options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[NotifiCrash configuration] host]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] == 0 && error == nil) {
            NSLog(@"Crash successfully posted");
        } else if (error != nil) {
            NSLog(@"There was a download error");
        }
    }];
}

/*
 * Prints the information about the crash for the developer.
 */
- (void)printCrashInfo
{
    NSLog(@"############################ CRASH REPORT ######################################");
    NSLog(@"Crash name: %@", [NotifiCrash crash].crashName);
    NSLog(@"Crash reason: %@", [NotifiCrash crash].crashReason);
    NSLog(@"%@", [NotifiCrash crash].stackSymbols);
    NSLog(@"################################################################################");
}

@end
