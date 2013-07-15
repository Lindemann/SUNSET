//
//  SunFacts.h
//  SUNSET
//
//  Created by Lindemann on 11.07.13.
//  Copyright (c) 2013 Lindemann. All rights reserved.
//

typedef enum {
    DAY,
    NIGHT
} Daytime;

#import <Foundation/Foundation.h>

@protocol SunFactsDelegate;

@interface SunFacts : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *timeTillSunset;
@property (strong, nonatomic) NSString *timeTillSunrise;
@property (nonatomic) int secondsTillSunset;
@property (nonatomic) int secondsTillSunrise;
@property (nonatomic) Daytime daytime;
@property (nonatomic, weak) id <SunFactsDelegate> delegate;

@end

@protocol SunFactsDelegate <NSObject>

- (void)sunFactsDidUpdateData;
- (void)sunFactsDidFail;

@end