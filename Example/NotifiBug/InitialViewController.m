//
//  InitialViewController.m
//  NotifiBug
//
//  Created by Marko Arsic on 05/28/2015.
//  Copyright (c) 2014 Marko Arsic. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)raiseException:(id)sender
{
    [NSException raise:@"Invalid value" format:@"Something is invalid"];
}

- (IBAction)divideByZero:(id)sender
{
    int a = 1;
    int b = 0;
    int c = a/b;

    NSLog(@"%d", c);
}

- (IBAction)outOfBounds:(id)sender
{
    NSArray *array = @[@1, @2, @3];
    NSLog(@"%@", array[3]);
}

- (IBAction)customException:(id)sender
{
    @throw ([NSException exceptionWithName:@"Custom" reason:@"Strange" userInfo:nil]);
}

@end
