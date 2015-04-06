//
//  InitialView.m
//  NotifiCrash
//
//  Created by Cheesecake Labs on 2/11/15.
//  Copyright (c) 2015 Cheesecake Labs. All rights reserved.
//

#import "InitialView.h"
#import <KeepLayout.h>

@implementation InitialView

- (id)init
{
    self = [super init];
    if (self) {
        [self loadView];
        [self setupConstraints];
    }
    return self;
}

/**
* Loads UI elements on the view.
**/
- (void)loadView
{
    self.divideByZeroButton = [[UIButton alloc] init];
    [self.divideByZeroButton addTarget:self.delegate action:@selector(divideByZero:) forControlEvents:UIControlEventTouchUpInside];
    [self.divideByZeroButton setBackgroundColor:[UIColor grayColor]];
    [self.divideByZeroButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.divideByZeroButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.divideByZeroButton setTitle:@"Divide by zero" forState:UIControlStateNormal];
    [self addSubview:self.divideByZeroButton];

    self.outOfBoundsButton = [[UIButton alloc] init];
    [self.outOfBoundsButton addTarget:self.delegate action:@selector(accessOutOfBoundsIndex:) forControlEvents:UIControlEventTouchUpInside];
    [self.outOfBoundsButton setBackgroundColor:[UIColor grayColor]];
    [self.outOfBoundsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.outOfBoundsButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.outOfBoundsButton setTitle:@"Array out of bounds" forState:UIControlStateNormal];

    [self addSubview:self.divideByZeroButton];
    [self addSubview:self.outOfBoundsButton];
}

/**
 * Builds all layout constraints using KeepLayout framework.
 **/
- (void)setupConstraints
{
    self.divideByZeroButton.keepTopInset.equal = 80;
    self.divideByZeroButton.keepHorizontalInsets.equal = 30;
    self.divideByZeroButton.keepHeight.equal = 50;

    self.outOfBoundsButton.keepTopOffsetTo(self.divideByZeroButton).equal = 30;
    self.outOfBoundsButton.keepHorizontalInsets.equal = 30;
    self.outOfBoundsButton.keepHeight.equal = 50;
}

@end
