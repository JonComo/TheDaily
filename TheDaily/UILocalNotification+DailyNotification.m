//
//  UILocalNotification+DailyNotification.m
//  TheDaily
//
//  Created by Jon Como on 11/12/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "UILocalNotification+DailyNotification.h"

@implementation UILocalNotification (DailyNotification)

-(void)cancel
{
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]){
        if ([notification.userInfo[@"id"] isEqualToString:self.userInfo[@"id"]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

@end