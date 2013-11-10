//
//  TDReminderView.h
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDReminderView : UIView

@property (nonatomic, strong) NSDictionary *noteInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;

+(TDReminderView *)reminder;

@end