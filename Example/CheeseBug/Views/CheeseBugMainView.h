//
//  CheeseBugMainView.h
//  CheeseBug
//
//  Created by Cheesecake Labs on 2/11/15.
//  Copyright (c) 2015 Cheesecake Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Delegate to handle the button action
 */
@protocol CheeseBugMainViewDelegate <NSObject>

/**
 * Proposital crash.
 * @params sender Which button has been pressed
 */
- (void)divideByZero:(UIButton *)sender;

@end

@interface CheeseBugMainView : UIView

@property (strong, nonatomic) UIButton *crashButton;
@property (assign) id <CheeseBugMainViewDelegate> delegate;

@end
