//
//  TDDayView.m
//  TheDaily
//
//  Created by Jon Como on 11/12/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDDayView.h"

@implementation TDDayView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //// Frames
    CGRect frame = CGRectMake(0, (rect.size.height - 568)/2, 320, 568);
    
    //// Color Declarations
    UIColor* sky = [UIColor colorWithRed: 0.571 green: 0.857 blue: 1 alpha: 1];
    UIColor* night = [UIColor colorWithRed: 0.067 green: 0 blue: 0.2 alpha: 1];
    UIColor* sun = [UIColor colorWithRed: 1 green: 1 blue: 0.114 alpha: 1];
    UIColor* moon = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Subframes
    CGRect drawing = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 320, CGRectGetHeight(frame));
    
    //// drawing
    {
        //// daySky Drawing
        UIBezierPath* daySkyPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(drawing) + floor(CGRectGetWidth(drawing) * 0.00000 + 0.5), CGRectGetMinY(drawing) + floor(CGRectGetHeight(drawing) * 0.00000 + 0.5), floor(CGRectGetWidth(drawing) * 1.00000 + 0.5) - floor(CGRectGetWidth(drawing) * 0.00000 + 0.5), floor(CGRectGetHeight(drawing) * 0.50000 + 0.5) - floor(CGRectGetHeight(drawing) * 0.00000 + 0.5))];
        [sky setFill];
        [daySkyPath fill];
        
        
        //// nightSky Drawing
        UIBezierPath* nightSkyPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(drawing) + floor(CGRectGetWidth(drawing) * 0.00000 + 0.5), CGRectGetMinY(drawing) + floor(CGRectGetHeight(drawing) * 0.50000 + 0.5), floor(CGRectGetWidth(drawing) * 1.00000 + 0.5) - floor(CGRectGetWidth(drawing) * 0.00000 + 0.5), floor(CGRectGetHeight(drawing) * 1.00000 + 0.5) - floor(CGRectGetHeight(drawing) * 0.50000 + 0.5))];
        [night setFill];
        [nightSkyPath fill];
        
        
        //// moonCircle Drawing
        UIBezierPath* moonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(drawing) + floor(CGRectGetWidth(drawing) * 0.37812 + 0.5), CGRectGetMinY(drawing) + floor(CGRectGetHeight(drawing) * 0.67958 + 0.5), floor(CGRectGetWidth(drawing) * 0.62500 + 0.5) - floor(CGRectGetWidth(drawing) * 0.37812 + 0.5), floor(CGRectGetHeight(drawing) * 0.81866 + 0.5) - floor(CGRectGetHeight(drawing) * 0.67958 + 0.5))];
        [moon setFill];
        [moonCirclePath fill];
        
        
        //// moonShadow Drawing
        UIBezierPath* moonShadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(drawing) + floor(CGRectGetWidth(drawing) * 0.33125 + 0.5), CGRectGetMinY(drawing) + floor(CGRectGetHeight(drawing) * 0.66373 + 0.5), floor(CGRectGetWidth(drawing) * 0.57812 + 0.5) - floor(CGRectGetWidth(drawing) * 0.33125 + 0.5), floor(CGRectGetHeight(drawing) * 0.80282 + 0.5) - floor(CGRectGetHeight(drawing) * 0.66373 + 0.5))];
        [night setFill];
        [moonShadowPath fill];
        
        
        //// sunShape Drawing
        UIBezierPath* sunShapePath = [UIBezierPath bezierPath];
        [sunShapePath moveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.50156 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.14613 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.53546 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.18997 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.60902 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.16563 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.59030 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.21223 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.67543 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.21668 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.61125 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.24824 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.67543 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.27979 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.59030 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.28425 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.60902 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.33085 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.53546 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.30651 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.50156 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.35035 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.46767 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.30651 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.39411 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.33085 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.41282 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.28425 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.32770 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.27979 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.39188 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.24824 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.32770 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.21668 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.41282 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.21223 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.39411 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.16563 * CGRectGetHeight(drawing))];
        [sunShapePath addLineToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.46767 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.18997 * CGRectGetHeight(drawing))];
        [sunShapePath closePath];
        [sun setFill];
        [sunShapePath fill];
    }

}


@end
