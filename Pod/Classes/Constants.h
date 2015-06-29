//
// Created by Marko Arsic on 6/26/15.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - Static constants

extern NSString *const UncaughtExceptionHandlerSignalExceptionName;
extern NSString *const UncaughtExceptionHandlerSignalKey;

extern volatile int32_t UncaughtExceptionCount;
extern const int32_t UncaughtExceptionMaximum;

extern NSString *const NBEncodedUrl;

extern NSString *const AlertTitle;
extern NSString *const AlertMessage;
extern NSString *const AlertButton;

@end
