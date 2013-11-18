//
//  TDDayView.m
//  TheDaily
//
//  Created by Jon Como on 11/12/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDDayView.h"

#import "NSDate+AngularTime.h"
#import "JCMath.h"

@implementation TDDayView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    //// Frames
    CGRect frame = CGRectMake(0, (rect.size.height - 568)/2, 320, 568);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* sky = [UIColor colorWithRed: 0.571 green: 0.857 blue: 1 alpha: 1];
    UIColor* night = [UIColor colorWithRed: 0.067 green: 0 blue: 0.2 alpha: 1];
    UIColor* sun = [UIColor colorWithRed: 1 green: 1 blue: 0.114 alpha: 1];
    UIColor* moon = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* gradientColor = [UIColor colorWithRed: 1 green: 0.543 blue: 0 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)sky.CGColor,
                               (id)[UIColor colorWithRed: 0.786 green: 0.7 blue: 0.5 alpha: 1].CGColor,
                               (id)gradientColor.CGColor,
                               (id)[UIColor colorWithRed: 0.533 green: 0.272 blue: 0.1 alpha: 1].CGColor,
                               (id)night.CGColor,
                               (id)night.CGColor, nil];
    CGFloat gradientLocations[] = {0.25, 0.48, 0.5, 0.52, 0.75, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Subframes
    CGRect drawing = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 320, CGRectGetHeight(frame));
    
    
    //// drawing
    {
        //// Rectangle Drawing
        CGRect rectangleRect = CGRectMake(CGRectGetMinX(drawing) + floor(CGRectGetWidth(drawing) * 0.00000 + 0.5), CGRectGetMinY(drawing) + floor(CGRectGetHeight(drawing) * 0.00000 + 0.5), floor(CGRectGetWidth(drawing) * 1.00000 + 0.5) - floor(CGRectGetWidth(drawing) * 0.00000 + 0.5), floor(CGRectGetHeight(drawing) * 1.00000 + 0.5) - floor(CGRectGetHeight(drawing) * 0.00000 + 0.5));
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rectangleRect];
        CGContextSaveGState(context);
        [rectanglePath addClip];
        CGContextDrawLinearGradient(context, gradient,
                                    CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMinY(rectangleRect)),
                                    CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMaxY(rectangleRect)),
                                    0);
        CGContextRestoreGState(context);
        
        
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
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.58885 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.69995 * CGRectGetHeight(drawing))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.58885 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.79829 * CGRectGetHeight(drawing)) controlPoint1: CGPointMake(CGRectGetMinX(drawing) + 0.63705 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.72710 * CGRectGetHeight(drawing)) controlPoint2: CGPointMake(CGRectGetMinX(drawing) + 0.63705 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.77114 * CGRectGetHeight(drawing))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.41624 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.79937 * CGRectGetHeight(drawing)) controlPoint1: CGPointMake(CGRectGetMinX(drawing) + 0.54129 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.82509 * CGRectGetHeight(drawing)) controlPoint2: CGPointMake(CGRectGetMinX(drawing) + 0.46458 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.82545 * CGRectGetHeight(drawing))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.54197 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.78245 * CGRectGetHeight(drawing)) controlPoint1: CGPointMake(CGRectGetMinX(drawing) + 0.45903 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.80725 * CGRectGetHeight(drawing)) controlPoint2: CGPointMake(CGRectGetMinX(drawing) + 0.50796 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.80161 * CGRectGetHeight(drawing))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.54197 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.68410 * CGRectGetHeight(drawing)) controlPoint1: CGPointMake(CGRectGetMinX(drawing) + 0.59018 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.75529 * CGRectGetHeight(drawing)) controlPoint2: CGPointMake(CGRectGetMinX(drawing) + 0.59018 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.71126 * CGRectGetHeight(drawing))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.54001 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.68302 * CGRectGetHeight(drawing)) controlPoint1: CGPointMake(CGRectGetMinX(drawing) + 0.54132 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.68374 * CGRectGetHeight(drawing)) controlPoint2: CGPointMake(CGRectGetMinX(drawing) + 0.54067 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.68338 * CGRectGetHeight(drawing))];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(drawing) + 0.58885 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.69995 * CGRectGetHeight(drawing)) controlPoint1: CGPointMake(CGRectGetMinX(drawing) + 0.55787 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.68631 * CGRectGetHeight(drawing)) controlPoint2: CGPointMake(CGRectGetMinX(drawing) + 0.57465 * CGRectGetWidth(drawing), CGRectGetMinY(drawing) + 0.69195 * CGRectGetHeight(drawing))];
        [bezierPath closePath];
        [moon setFill];
        [bezierPath fill];
    }
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    //draw red line depicting time itself
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    
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
