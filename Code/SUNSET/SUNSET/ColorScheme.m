//
//  ColorScheme.m
//  SUNSET
//
//  Created by Lindemann on 08.07.13.
//  Copyright (c) 2013 Lindemann. All rights reserved.
//

#import "ColorScheme.h"

// TURQUOISE_GRAY
#define TURQUOISE [UIColor colorWithRed:0.18f green:0.86f blue:0.58f alpha:1.00f]
#define DARKGRAY [UIColor colorWithRed:0.13f green:0.17f blue:0.21f alpha:1.00f]
#define LIGHTGRAY [UIColor colorWithRed:0.21f green:0.29f blue:0.36f alpha:1.00f]

@implementation ColorScheme

- (UIColor*)accentColor {
    if (self.type == TURQUOISE_GRAY) {
        return TURQUOISE;
    }
    return nil;
}

- (UIColor*)mainColor {
    if (self.type == TURQUOISE_GRAY) {
        return DARKGRAY;
    }
    return nil;
}

- (UIColor*)secondaryColor {
    if (self.type == TURQUOISE_GRAY) {
        return LIGHTGRAY;
    }
    return nil;
}

- (UIColor*)fontColor {
    if (self.type == TURQUOISE_GRAY) {
        return [UIColor whiteColor];
    }
    return nil;
}

- (UIStatusBarStyle)statusbarStyle {
    if (self.type == TURQUOISE_GRAY) {
        return UIStatusBarStyleLightContent;
    }
    return 100;
}

@end
