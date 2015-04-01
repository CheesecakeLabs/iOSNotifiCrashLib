//
//  NotifiCrashMainView.h
//  NotifiCrash
//
//  Created by Cheesecake Labs on 2/11/15.
//  Copyright (c) 2015 Cheesecake Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Delegate to handle the button action
 */
@protocol NotifiCrashMainViewDelegate <NSObject>

/**
 * Proposital crash.
 * @params sender Which button has been pressed
 */
- (void)divideByZero:(UIButton *)sender;

@end

@interface NotifiCrashMainView : UIView

@property (strong, nonatomic) UIButton *crashButton;
@property (assign) id <NotifiCrashMainViewDelegate> delegate;

@end
