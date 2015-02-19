//
//  CheeseBugMainView.m
//  CheeseBug
//
//  Created by Cheesecake Labs on 2/11/15.
//  Copyright (c) 2015 Cheesecake Labs. All rights reserved.
//

#import "CheeseBugMainView.h"
#import "CheeseBugMainViewController.h"
#import <KeepLayout.h>

@implementation CheeseBugMainView

- (id)init {
    self = [super init];
    if (self) {
        [self loadView];
        [self setupConstraints];
    }
    return self;
}

/**
 * Builds all layout constraints using KeepLayout framework.
 **/
- (void)setupConstraints {
    self.crashButton.keepHeight.equal = 60;
    self.crashButton.keepWidth.equal = 150;
    [self.crashButton keepHorizontallyCentered];
    [self.crashButton keepVerticallyCentered];
}

/**
 * Loads UI elements on the view.
 **/
- (void)loadView {
    
    // Initiates the crash button.
    self.crashButton = [[UIButton alloc] init];
    [self.crashButton addTarget:self.delegate action:@selector(divideByZero:) forControlEvents:UIControlEventTouchUpInside];
    [self.crashButton setBackgroundColor:[UIColor grayColor]];
    [self.crashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.crashButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.crashButton setTitle:@"Push for Crash" forState:UIControlStateNormal];
    [self addSubview:self.crashButton];
}

@end
