//
//  ViewController.m
//  SUNSET
//
//  Created by Lindemann on 03.07.13.
//  Copyright (c) 2013 Lindemann. All rights reserved.
//

#import "ViewController.h"
#import "ColorScheme.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
            
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = appDelegate.colorScheme.mainColor;
    
    self.circleView = [[CircleView alloc] initWithSuperView:self.view];
    [self.view addSubview:self.circleView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.colorScheme.statusbarStyle;
}

@end
