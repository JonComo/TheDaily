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
#define SIZE_DESELECTED CGSizeMake(44, 44)

@implementation TDReminderView
{
    UILabel *labelName;
    UIButton *buttonRemove;
    UILabel *labelTime;
    
    UIColor *primary;
}

+(TDReminderView *)reminderAtPoint:(CGPoint)point
{
    TDReminderView *reminderView = [[TDReminderView alloc] initWithFrame:CGRectMake(point.x, point.y, SIZE_SELECTED.width, SIZE_SELECTED.height)];
    
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
        
        [labelTime setFont:[UIFont fontWithName:@"Helvetica Bold" size:16]];
        
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
    
    [label setLineBreakMode:NSLineBreakByCharWrapping];
    
    label.numberOfLines = 3;
    
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

-(void)setEnlarge:(BOOL)enlarge
{
    _enlarge = enlarge;
    
    [self determineSize];
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    [self determineSize];
}

-(void)determineSize
{
    float xOffset = 0;
    float yOffset = 0;
    
    BOOL isBig = _selected || _enlarge;
    
    CGSize size = isBig ? SIZE_SELECTED : SIZE_DESELECTED;
    
    if (isBig)
    {
        xOffset = (self.bounds.size.width - size.width)/2;
        yOffset = (self.bounds.size.height - size.height)/2;
    }else{
        xOffset = (size.width - self.bounds.size.width)/-2;
        yOffset = (size.height - self.bounds.size.height)/-2;
    }
    
    self.frame = CGRectMake(self.frame.origin.x + xOffset, self.frame.origin.y + yOffset, size.width, size.height);
    
    [self showDetails:isBig];
    
    [self setNeedsDisplay];
}

-(void)showDetails:(BOOL)show
{
    CGSize size = self.bounds.size;
    CGSize nameSize = CGSizeMake(size.width*3/4, 80);
    CGSize timeSize = CGSizeMake(size.width/2, 40);
    
    if (show) {
        //show
        
        labelName.frame = CGRectMake(size.width/2 - nameSize.width/2, size.height/2 - nameSize.height/2, nameSize.width, nameSize.height);
        buttonRemove.frame = CGRectMake(size.width/2 - timeSize.width/2, size.height - timeSize.height, timeSize.width, timeSize.height);
        labelTime.frame = CGRectMake(size.width/2 - timeSize.width/2, 6, timeSize.width, timeSize.height);
        
        [self addSubview:labelTime];
        [self addSubview:buttonRemove];
    }else{
        //hide
        int inset = 6;
        labelName.frame = CGRectMake(inset, inset, size.width - inset*2, size.height- inset*2);
        
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

-(void)setNotification:(UILocalNotification *)notification
{
    _notification = notification;
    
    self.name = notification.userInfo[@"name"];
    
    labelName.text = notification.userInfo[@"name"];
}

-(void)setMode:(TDMode)mode
{
    _mode = mode;
    
    UIColor *interfaceColor;
    
    if (self.mode == TDModeDay)
    {
        primary = [UIColor colorWithRed:1.000 green:0.839 blue:0.000 alpha:1.000];
        interfaceColor = [UIColor whiteColor];
    }else{
        primary = [UIColor whiteColor];
        interfaceColor = [UIColor blackColor];
    }
    
    labelName.textColor = interfaceColor;
    labelTime.textColor = interfaceColor;
    [buttonRemove setTitleColor:interfaceColor forState:UIControlStateNormal];
}

-(void)determineMode
{
    if (self.frame.origin.y + self.frame.size.height/2 > self.superview.frame.size.height/2)
    {
        self.mode = TDModeNight;
    }else{
        self.mode = TDModeDay;
    }
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //// Frames
    [self determineMode];
    
    if (self.selected || self.enlarge)
    {
        //// Color Declarations
        UIColor* color = primary;
        
        //// Frames
        CGRect frame = rect;
        
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [color setFill];
        [ovalPath fill];
        
        return;
    }
    
    if (self.mode == TDModeDay)
    {
        //// Color Declarations
        UIColor* fillColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0 alpha: 1];
        
        //// Star Drawing
        UIBezierPath* starPath = [UIBezierPath bezierPath];
        [starPath moveToPoint: CGPointMake(22, 0)];
        [starPath addLineToPoint: CGPointMake(27.79, 8.01)];
        [starPath addLineToPoint: CGPointMake(37.56, 6.44)];
        [starPath addLineToPoint: CGPointMake(35.99, 16.21)];
        [starPath addLineToPoint: CGPointMake(44, 22)];
        [starPath addLineToPoint: CGPointMake(35.99, 27.79)];
        [starPath addLineToPoint: CGPointMake(37.56, 37.56)];
        [starPath addLineToPoint: CGPointMake(27.79, 35.99)];
        [starPath addLineToPoint: CGPointMake(22, 44)];
        [starPath addLineToPoint: CGPointMake(16.21, 35.99)];
        [starPath addLineToPoint: CGPointMake(6.44, 37.56)];
        [starPath addLineToPoint: CGPointMake(8.01, 27.79)];
        [starPath addLineToPoint: CGPointMake(0, 22)];
        [starPath addLineToPoint: CGPointMake(8.01, 16.21)];
        [starPath addLineToPoint: CGPointMake(6.44, 6.44)];
        [starPath addLineToPoint: CGPointMake(16.21, 8.01)];
        [starPath closePath];
        [fillColor setFill];
        [starPath fill];
    }else{
        //Night
        //// Color Declarations
        UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
        
        //// Star 2 Drawing
        UIBezierPath* star2Path = [UIBezierPath bezierPath];
        [star2Path moveToPoint: CGPointMake(22, 0)];
        [star2Path addLineToPoint: CGPointMake(29.52, 14.48)];
        [star2Path addLineToPoint: CGPointMake(44, 22)];
        [star2Path addLineToPoint: CGPointMake(29.52, 29.52)];
        [star2Path addLineToPoint: CGPointMake(22, 44)];
        [star2Path addLineToPoint: CGPointMake(14.48, 29.52)];
        [star2Path addLineToPoint: CGPointMake(0, 22)];
        [star2Path addLineToPoint: CGPointMake(14.48, 14.48)];
        [star2Path closePath];
        [fillColor setFill];
        [star2Path fill];
    }
}

@end
