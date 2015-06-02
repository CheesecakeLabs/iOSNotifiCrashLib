//
// Created by Marko Arsic on 5/28/15.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"

@interface NotifiBug : NSObject {
    BOOL dismissed;
}

+ (void)initWithSerialNumber:(NSString *)serialNumber;

@end
