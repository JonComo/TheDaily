//
//  TDReminderView.m
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDReminderView.h"

@implementation TDReminderView
{
    __weak IBOutlet UILabel *labelName;
}

-(void)setNoteInfo:(NSDictionary *)noteInfo
{
    _noteInfo = noteInfo;
    
    NSString *name = noteInfo[@"name"];
    
    labelName.text = name;
}

+(TDReminderView *)reminder
{
    TDReminderView *reminderView = (TDReminderView *)[[NSBundle mainBundle] loadNibNamed:@"reminderView" owner:self options:nil][0];
    
    return reminderView;
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
