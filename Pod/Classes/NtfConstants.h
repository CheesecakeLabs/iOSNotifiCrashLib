//
//  Constants.h
//  Pods
//
//  Created by Cheesecake Labs on 3/9/15.
//
//

#ifndef Pods_Constants_h
#define Pods_Constants_h

#pragma mark - Static constants

static NSString* const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
static NSString* const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";

static volatile int32_t UncaughtExceptionCount = 0;
static const int32_t UncaughtExceptionMaximum = 10;

static NSString* const AlertTitle = @"Unhandled exception";
static NSString* const AlertMessage = @"An error occurred and requires your app to be closed";
static NSString* const AlertButton = @"Quit";

#endif
