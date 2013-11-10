//
//  TDReminderTemplateCell.h
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDReminderTemplateCell : UICollectionViewCell

@property (nonatomic, weak) NSDictionary *reminderTemplate;

@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;

@end
