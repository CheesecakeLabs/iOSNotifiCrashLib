//
//  CheeseBug.h
//  Pods
//
//  Created by Cheesecake Labs on 2/12/15.
//
//

#import <Foundation/Foundation.h>
#import "Configuration.h"

@interface CheeseBug : NSObject {
    BOOL dismissed;
}

+ (Configuration*)configuration;
+ (void)initCheeseBug:(NSString*)serialNumber;

@end
