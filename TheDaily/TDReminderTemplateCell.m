//
//  TDReminderTemplateCell.m
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDReminderTemplateCell.h"

@implementation TDReminderTemplateCell
{
    __weak IBOutlet UILabel *labelName;
}

-(void)setReminderTemplate:(NSDictionary *)reminderTemplate
{
    _reminderTemplate = reminderTemplate;
    
    labelName.text = reminderTemplate[@"name"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
