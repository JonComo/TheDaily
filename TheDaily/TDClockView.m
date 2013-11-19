//
//  TDClockView.m
//  TheDaily
//
//  Created by Jon Como on 11/18/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDClockView.h"

#import "JCMath.h"
#import "NSDate+AngularTime.h"

@implementation TDClockView

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    UIColor *sky = [UIColor blueColor];
    UIColor *night = [UIColor blackColor];
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    //draw red line depicting time itself
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
    
    UIBezierPath *timeline = [UIBezierPath new];
    
    [timeline moveToPoint:center];
    timeline.lineWidth = 3;
    timeline.lineCapStyle = kCGLineCapRound;
    
    float angle = [NSDate angleFromSeconds:[NSDate seconds]] + 90;
    
    [timeline addLineToPoint:[JCMath pointFromPoint:center pushedBy:800 inDirection:angle]];
    
    if (angle > 180 && angle < 360)
    {
        [night setStroke];
        [night setFill];
    }else{
        [sky setStroke];
        [sky setFill];
    }
    
    [timeline stroke];
    
    CGSize nibSize = CGSizeMake(10, 10);
    CGContextFillEllipseInRect(ref, CGRectMake(center.x - nibSize.width/2, center.y - nibSize.height/2, nibSize.width, nibSize.height));
    
}

@end
