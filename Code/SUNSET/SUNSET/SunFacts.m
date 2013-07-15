//
//  SunFacts.m
//  SUNSET
//
//  Created by Lindemann on 11.07.13.
//  Copyright (c) 2013 Lindemann. All rights reserved.
//

#import "SunFacts.h"
#import "EDSunriseSet.h"

@implementation SunFacts

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        //Location Manager get startrd by the CircleView
//        [self.locationManager startUpdatingLocation];
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    self.location = [NSString stringWithFormat:@"%.f°N %.f°E", location.coordinate.latitude, location.coordinate.longitude];
    
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];    
    EDSunriseSet *sun = [EDSunriseSet sunrisesetWithTimezone:localTime latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [sun calculate:[NSDate date]];
    
    NSDate *currentDate = [NSDate date];
    NSDate *sunset = sun.sunset;
    NSDate *sunrise = sun.sunrise;
    
    // Morning before sunrise
    if ([currentDate compare:sunrise] == NSOrderedAscending) {
        self.daytime = NIGHT;
        self.secondsTillSunrise = [sunrise timeIntervalSinceDate:currentDate];
        self.timeTillSunrise = [self stringFromTimeInterval:self.secondsTillSunrise];
    }
    // Day between sunrise and sunset
    if ([currentDate compare:sunrise] == NSOrderedDescending && [currentDate compare:sunset] == NSOrderedAscending) {
        self.daytime = DAY;
        self.secondsTillSunset = [sunset timeIntervalSinceDate:currentDate];
        self.timeTillSunset = [self stringFromTimeInterval:self.secondsTillSunset];
    }
    // Night after sunset
     else if ([currentDate compare:sunset] == NSOrderedDescending) {
        self.daytime = NIGHT;
         [sun calculate:[self nextDayForCurrentDay:[NSDate date]]];
         sunset = sun.sunset;
         sunrise = sun.sunrise;
         self.secondsTillSunrise = [sunrise timeIntervalSinceDate:currentDate];
         self.timeTillSunrise = [self stringFromTimeInterval:self.secondsTillSunrise];
     }
    [self.delegate sunFactsDidUpdateData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.delegate sunFactsDidFail];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    int timeInterval = (NSInteger)interval;
    int minutes = (timeInterval / 60) % 60;
    int hours = (timeInterval / 3600);
    return [NSString stringWithFormat:@"%02i:%02i", hours, minutes];
}

- (NSDate*)nextDayForCurrentDay:(NSDate*)currentDay {
    // Source: http://stackoverflow.com/a/1081711/647644
    // start by retrieving day, weekday, month and year components for yourDate
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:currentDay];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    // now build a NSDate object for yourDate using these components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    // now build a NSDate object for the next day
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    return nextDate;
}

@end
