//
//  InitialView.h
//  NotifiCrash
//
//  Created by Cheesecake Labs on 2/11/15.
//  Copyright (c) 2015 Cheesecake Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Delegate to handle the button action
 */
@protocol InitialViewDelegate <NSObject>

/**
 * Purposeful crash.
 * @params sender Which button has been pressed
 */
- (void)divideByZero:(UIButton *)sender;
- (void)accessOutOfBoundsIndex:(UIButton *)sender;

@end

@interface InitialView : UIView

@property(strong, nonatomic) UIButton *divideByZeroButton;
@property(strong, nonatomic) UIButton *outOfBoundsButton;
@property(assign) id <InitialViewDelegate> delegate;

@end
