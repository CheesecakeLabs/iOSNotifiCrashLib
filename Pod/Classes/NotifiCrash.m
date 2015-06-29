//
//  NotifiCrash.m
//  Pods
//
//  Created by Cheesecake Labs on 2/12/15.
//
//

#import "NotifiCrash.h"
#import "Crash.h"
#import "Constants.h"
#include <libkern/OSAtomic.h>
#import <sys/utsname.h>

static NSString *const TIMESTAMP_FORMAT = @"yyyy-MM-dd'T'HH:mm:ssZ";

static NSString *const APP_SERIAL_NUMBER = @"application";

static NSString *const CRASH_NAME = @"name";
static NSString *const CRASH_TIMESTAMP = @"time";
static NSString *const CRASH_REASON = @"reason";
static NSString *const CRASH_APP_VERSION = @"app_version";
static NSString *const CRASH_OS_VERSION = @"os_version";
static NSString *const CRASH_DEVICE_MODEL = @"device_model";
static NSString *const CRASH_CLASS = @"class_name";
static NSString *const CRASH_LINE = @"line_number";
static NSString *const CRASH_METHOD = @"method_name";
static NSString *const CRASH_STACKTRACE = @"stack_trace";

NSString *deviceModel();


@implementation NotifiCrash

#pragma mark - Library setup

// Represents a configuration that contains some useful information for the library to work.
static Configuration *_config = nil;

// Represents a crash that might happen in the app.
static Crash *_crash = nil;

// Third party exception that must coexist with NotifiBug.
static NSUncaughtExceptionHandler *thirdPartyExceptionHandler = nil;

/*
 * Gets the library configuration object.
 */
+ (Configuration *)configuration
{
    if (!_config) {
        _config = [[Configuration alloc] init];
    }

    return _config;
}

/*
 * Gets the crash object.
 */
+ (Crash *)crash
{
    if (!_crash) {
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
    [NotifiCrash saveThirdPartyHandler];
    [NotifiCrash installUncaughtExceptionHandler];
}

/*
 * Checks if there is some other uncaught exception handler set previously
 * and stores it in a variable, so that it can run after NotifiCrash's handler.
 */
+ (void)saveThirdPartyHandler
{
    thirdPartyExceptionHandler = NSGetUncaughtExceptionHandler();
}

/*
 * Sets up the configuration regarding the endpoint server and the serial to authentication.
 */
+ (void)setupConfiguration:(NSString *)serialNumber
{
    [[NotifiCrash configuration] setHost:[self decodeUrl:NBEncodedUrl]];
    [[NotifiCrash configuration] setSerialNumber:serialNumber];
}

/*
 * Function pointed by the UncaughtExceptionHandler at the library installation.
 */
static void exceptionHandler(NSException *exception)
{
    if ([NotifiCrash reachMaximum]) {
        return;
    }

    NSArray *stack = [exception callStackSymbols];
    [[NotifiCrash crash] setStackTrace:[stack componentsJoinedByString:@"\n"]];

    [NotifiCrash handlerError:nil name:[exception name] reason:[exception reason]];
}

/*
 * Function pointed for the system to deal with critical signals emitted.
 */
static void signalHandler(int signal)
{
    if ([NotifiCrash reachMaximum]) {
        return;
    }

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
                                                 withObject:[NSException exceptionWithName:name
                                                                                    reason:reason
                                                                                  userInfo:userInfo]
                                              waitUntilDone:YES];
}

/*
 * Deals how the app will behaviour in the moment right before it crashes for good.
 */
- (void)handleException:(NSException *)exception
{
    [self captureCrashDataFromException:exception];
    [self attemptSendingCrash];

    // Raises an alert informing the user about the crash.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AlertTitle
                                                    message:AlertMessage
                                                   delegate:self
                                          cancelButtonTitle:AlertButton
                                          otherButtonTitles:nil];
    [alert show];

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

    // Releases the default handler and reset it to any other existing.
    NSSetUncaughtExceptionHandler(thirdPartyExceptionHandler);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);

    // Calls the third party handler to handle the exception by its own way.
    if (thirdPartyExceptionHandler != nil) {
        thirdPartyExceptionHandler(exception);
    }

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
- (void)attemptSendingCrash
{

    NSData *postData = [NSJSONSerialization dataWithJSONObject:[self requestData:[NotifiCrash crash]] options:0 error:nil];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[NotifiCrash configuration] host]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                               if (![data length] && !error) {
                                   NSLog(@"Crash successfully posted");
                               } else if (error) {
                                   NSLog(@"There was a upload error");
                               }
                           }];
}

- (void)captureCrashDataFromException:(NSException *)exception
{
    // Fills the crash object with important data to post to the server.
    [[NotifiCrash crash] setName:exception.name];
    [[NotifiCrash crash] setReason:exception.reason];
    [[NotifiCrash crash] setTime:[self timeStamp]];
    [[NotifiCrash crash] setAppVersion:[self appVersionData]];
    [[NotifiCrash crash] setDeviceModel:deviceModel()];
    [[NotifiCrash crash] setOsVersion:[self osVersionData]];
}

- (NSMutableDictionary *)requestData:(Crash *)crash
{
    // Fill the dictionary with data regarding the crash itself.
    NSMutableDictionary *postJSONData = [[NSMutableDictionary alloc] init];

    postJSONData[APP_SERIAL_NUMBER] = [[NotifiCrash configuration] serialNumber];
    postJSONData[CRASH_NAME] = [crash name];
    postJSONData[CRASH_REASON] = [crash reason];
    postJSONData[CRASH_TIMESTAMP] = [crash time];
    postJSONData[CRASH_APP_VERSION] = [crash appVersion];
    postJSONData[CRASH_OS_VERSION] = [crash osVersion];
    postJSONData[CRASH_DEVICE_MODEL] = [crash deviceModel];
    postJSONData[CRASH_STACKTRACE] = [crash stackTrace];

    return postJSONData;
}

#pragma mark - Internal helpers

- (NSString *)timeStamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:interval];
    [dateFormatter setDateFormat:TIMESTAMP_FORMAT];

    return [dateFormatter stringFromDate:timestamp];
}

NSString *deviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (NSString *)appVersionData
{
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    return [NSString stringWithFormat:@"%@ (%@)", appVersionString, appBuildString];
}

- (NSString *)osVersionData
{
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    return [NSString stringWithFormat:@"%@", osVersion];
}

+ (NSString *)decodeUrl:(NSString *)encodedUrl
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedUrl options:0];
    NSString *apiEndpointUrl = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];

    return apiEndpointUrl;
}

@end