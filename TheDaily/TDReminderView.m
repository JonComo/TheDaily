//
//  TDReminderView.m
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDReminderView.h"

#import "UILocalNotification+DailyNotification.h"

#define SIZE_SELECTED CGSizeMake(140, 140)
#define SIZE_DESELECTED CGSizeMake(40, 40)

@implementation TDReminderView
{
    UILabel *labelName;
    UIButton *buttonRemove;
    UILabel *labelTime;
}

+(TDReminderView *)reminderAtPoint:(CGPoint)point
{
    TDReminderView *reminderView = [[TDReminderView alloc] initWithFrame:CGRectMake(point.x, point.y, SIZE_SELECTED.width, SIZE_SELECTED.height)];
    
    reminderView.primary = [UIColor colorWithRed:1 green:0.2 blue:0 alpha:1];
    reminderView.selected = YES;
    
    return reminderView;
}

-(void)cancel:(UIButton *)sender
{
    [self.notification cancel];
    
    [self removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        
        labelName = [self whiteLabelTextSize:18];
        labelTime = [self whiteLabelTextSize:16];
        buttonRemove = [self button];
        
        [buttonRemove setTitle:@"-remove" forState:UIControlStateNormal];
        
        [buttonRemove addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:labelName];
        [self addSubview:buttonRemove];
    }
    
    return self;
}

-(UILabel *)whiteLabelTextSize:(int)size
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [label setFont:[UIFont systemFontOfSize:size]];
    
    return label;
}

-(UIButton *)button
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    
    return button;
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    _primary = [UIColor colorWithRed:1 green:0.2 blue:0 alpha:1];
    
    float xOffset = 0;
    float yOffset = 0;
    
    CGSize size = selected ? SIZE_SELECTED : SIZE_DESELECTED;
    
    if (selected)
    {
        xOffset = (self.bounds.size.width - size.width)/2;
        yOffset = (self.bounds.size.height - size.height)/2;
    }else{
        xOffset = (size.width - self.bounds.size.width)/-2;
        yOffset = (size.height - self.bounds.size.height)/-2;
    }
    
    self.frame = CGRectMake(self.frame.origin.x + xOffset, self.frame.origin.y + yOffset, size.width, size.height);
    
    [self showDetails:selected];
    
    [self setNeedsDisplay];
}

-(void)showDetails:(BOOL)show
{
    CGSize size = self.bounds.size;
    CGSize nameSize = CGSizeMake(size.width, 80);
    CGSize timeSize = CGSizeMake(size.width/2, 40);
    
    if (show) {
        //show
        
        labelName.frame = CGRectMake(0, size.height/2 - nameSize.height/2, nameSize.width, nameSize.height);
        buttonRemove.frame = CGRectMake(size.width/2 - timeSize.width/2, size.height - timeSize.height, timeSize.width, timeSize.height);
        labelTime.frame = CGRectMake(size.width/2 - timeSize.width/2, 2, timeSize.width, timeSize.height);
        
        [self addSubview:labelTime];
        [self addSubview:buttonRemove];
    }else{
        //hide
        
        labelName.frame = CGRectMake(0, 0, size.width, size.height);
        
        [labelTime removeFromSuperview];
        [buttonRemove removeFromSuperview];
    }
}

-(void)setName:(NSString *)name
{
    _name = name;
    
    labelName.text = name;
}

-(void)setTimeFormatted:(NSString *)timeFormatted
{
    _timeFormatted = timeFormatted;
    
    labelTime.text = timeFormatted;
}

-(void)setPrimary:(UIColor *)primary
{
    _primary = primary;
    
    [self setNeedsDisplay];
}

-(void)setNotification:(UILocalNotification *)notification
{
    _notification = notification;
    
    self.name = notification.userInfo[@"name"];
    
    labelName.text = notification.userInfo[@"name"];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //// Color Declarations
    UIColor* primary = _primary;
    
    //// Frames
    CGRect frame = rect;
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6)];
    [primary setFill];
    [ovalPath fill];
}

@end
