//
//  AppDelegate.h
//  SUNSET
//
//  Created by Lindemann on 03.07.13.
//  Copyright (c) 2013 Lindemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorScheme.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ColorScheme *colorScheme;
@property (strong, nonatomic) ViewController *viewController;

@end
