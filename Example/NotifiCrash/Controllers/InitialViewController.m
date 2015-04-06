//
//  InitialViewController.m
//  NotifiCrash
//
//  Created by Cheesecake Labs on 2/11/15.
//  Copyright (c) 2015 Cheesecake Labs. All rights reserved.
//

#import "InitialViewController.h"
#import <KeepLayout.h>

@interface InitialViewController ()

@property(strong, nonatomic) InitialView *initialView;

@end

@implementation InitialViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.initialView = [[InitialView alloc] init];
    [self.initialView setUserInteractionEnabled:YES];
    [self.initialView setDelegate:self];

    [self.view addSubview:self.initialView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.initialView.keepInsets.equal = 0;
}

#pragma mark - User Interaction

- (void)divideByZero:(UIButton *)sender
{
    int a = 1;
    int b = 0;
    NSLog(@"%d", a/b);
}

- (void)accessOutOfBoundsIndex:(UIButton *)sender
{
    NSArray *array = @[@1, @2, @3];
    NSLog(@"%@",array[3]);
}

@end
