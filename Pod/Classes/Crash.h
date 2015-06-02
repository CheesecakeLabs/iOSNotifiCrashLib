//
//  Crash.h
//  Pods
//
//  Created by Cheesecake Labs on 2/20/15.
//
//

#import <Foundation/Foundation.h>


@interface Crash : NSObject

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *reason;
@property(strong, nonatomic) NSString *time;
@property(strong, nonatomic) NSString *appVersion;
@property(strong, nonatomic) NSString *osVersion;
@property(strong, nonatomic) NSString *deviceModel;
@property(strong, nonatomic) NSString *className;
@property(strong, nonatomic) NSString *method;
@property(strong, nonatomic) NSString *lineNumber;
@property(strong, nonatomic) NSString *stackTrace;

@end
