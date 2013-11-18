//
//  NSDate+AngularTime.m
//  TheDaily
//
//  Created by Jon Como on 11/17/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "NSDate+AngularTime.h"

@implementation NSDate (AngularTime)

+(int)secondsFromAngle:(float)angle
{
    float angleRatio = angle/360;
    
    float seconds = 86400 * angleRatio;
    
    seconds = roundf((float)seconds / ( 60 * 5)) * 60 * 5;
    
    return (int)seconds;
}

+(float)angleFromSeconds:(NSTimeInterval)seconds
{
    float timeRatio = (float)seconds / 86400;
    
    float angle = timeRatio * 360;
    
    return angle;
}

+(int)seconds
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    
    int seconds = [[calendar components:NSCalendarUnitSecond fromDate:date] second];
    int minutes = [[calendar components:NSCalendarUnitMinute fromDate:date] minute];
    int hours = [[calendar components:NSCalendarUnitHour fromDate:date] hour];
    
    int totalSeconds = hours * 60 * 60 + minutes * 60 + seconds;
    
    return totalSeconds;
}

@end