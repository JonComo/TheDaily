//
//  TDTemplateCollectionView.h
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TDDayViewController;

@interface TDTemplateCollectionView : UICollectionView

@property (nonatomic, weak) TDDayViewController *dayViewController;

@end
