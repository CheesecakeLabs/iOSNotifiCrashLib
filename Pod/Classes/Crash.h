//
//  Crash.h
//  Pods
//
//  Created by Cheesecake Labs on 2/20/15.
//
//

#import <Foundation/Foundation.h>


@interface Crash : NSObject

@property (strong, nonatomic) NSString *crashName;
@property (strong, nonatomic) NSString *crashReason;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSString *lineNumber;
@property (strong, nonatomic) NSString *cause;
@property (strong, nonatomic) NSString *timestamp;

@end
