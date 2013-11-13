//
//  TDReminderView.h
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDReminderView : UIView

@property (nonatomic, strong) NSString *name; //if new
@property (nonatomic, strong) UILocalNotification *notification; //if already scheduled

@property (nonatomic, strong) NSString *timeFormatted;

@property (nonatomic, strong) UIColor *primary;
@property (nonatomic, assign) BOOL selected;

+(TDReminderView *)reminderAtPoint:(CGPoint)point;

@end