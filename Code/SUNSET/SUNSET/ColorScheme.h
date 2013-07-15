//
//  ColorScheme.h
//  SUNSET
//
//  Created by Lindemann on 08.07.13.
//  Copyright (c) 2013 Lindemann. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TURQUOISE_GRAY,
    GREEN_WHITE
} Type;

@interface ColorScheme : NSObject

@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) UIColor *mainColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic) UIStatusBarStyle statusbarStyle;

@property (nonatomic) Type type;

@end
