//
//  Crash.m
//  Pods
//
//  Created by Cheesecake Labs on 2/20/15.
//
//

#import "Crash.h"

@implementation Crash

- (id)init {
    self = [super init];
    return self;
}

- (NSString*)getStringTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, yyyy MMM dd HH:mm:ss ZZZ"];
    
    return [dateFormatter stringFromDate:self.time];
}

@end
