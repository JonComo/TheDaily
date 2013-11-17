//
//  TDReminderView.h
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    TDModeDay,
    TDModeNight
} TDMode;

@interface TDReminderView : UIView

@property (nonatomic, strong) NSString *name; //if new
@property (nonatomic, strong) UILocalNotification *notification; //if already scheduled

@property (nonatomic, assign) TDMode mode;

@property (nonatomic, strong) NSString *timeFormatted;

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL enlarge;

+(TDReminderView *)reminderAtPoint:(CGPoint)point;

@end