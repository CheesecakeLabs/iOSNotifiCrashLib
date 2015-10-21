//
//  NotifiCrash.h
//  Pods
//
//  Created by Cheesecake Labs on 2/12/15.
//
//

#import <Foundation/Foundation.h>
#import "Configuration.h"

@interface NotifiCrash : NSObject
{
    BOOL dismissed;
}

+ (Configuration*)configuration;
+ (void)initWithSerialNumber:(NSString*)serialNumber;
+ (void)addExtra:(NSString*)key value:(NSString*)value;
@end
