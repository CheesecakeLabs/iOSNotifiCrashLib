//
// Created by Marko Arsic on 5/28/15.
//

#import "Constants.h"

@implementation Constants

#pragma mark - Static constants

NSString *const NBEncodedUrl = @"aHR0cDovL25vdGlmaWNyYXNoLmNrbC5pby9hcGkvY3Jhc2hlcy8=";

NSString *const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString *const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

NSString *const AlertTitle = @"Unhandled exception";
NSString *const AlertMessage = @"An error occurred and requires your app to be closed";
NSString *const AlertButton = @"Quit";

@end