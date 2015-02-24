//
//  CheeseBugMainViewController.m
//  CheeseBug
//
//  Created by Cheesecake Labs on 2/11/15.
//  Copyright (c) 2015 Cheesecake Labs. All rights reserved.
//

#import "CheeseBugMainViewController.h"
#import <KeepLayout.h>

@interface CheeseBugMainViewController ()

@property(strong, nonatomic) CheeseBugMainView *cheeseBugMainView;

@end

@implementation CheeseBugMainViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cheeseBugMainView = [[CheeseBugMainView alloc] init];
    [self.cheeseBugMainView setUserInteractionEnabled:YES];
    [self.cheeseBugMainView setDelegate:self];
    
    [self.view addSubview:self.cheeseBugMainView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.cheeseBugMainView.keepInsets.equal = 0;
}

#pragma mark - User Interaction

- (void)divideByZero:(UIButton *)sender {
//    int a = 1;
//    int b = 0;
//    NSLog(@"%d", a/b);

    NSArray *array = @[@1, @2, @3];
    NSLog(@"%@",array[3]);
}

@end
