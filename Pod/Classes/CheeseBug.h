//
//  CheeseBug.h
//  Pods
//
//  Created by Cheesecake Labs on 2/12/15.
//
//

#import <Foundation/Foundation.h>

@interface CheeseBug : NSObject {
    BOOL dismissed;
}

+ (void)initCheeseBug;

@end

void InstallUncaughtExceptionHandler();
