//
//  NSDate+AngularTime.h
//  TheDaily
//
//  Created by Jon Como on 11/17/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (AngularTime)

+(int)secondsFromAngle:(float)angle;
+(float)angleFromSeconds:(NSTimeInterval)seconds;
+(int)seconds;

@end
