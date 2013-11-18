//
//  TDDayViewController.m
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDDayViewController.h"

#import "TDAppDelegate.h"

#import "TDReminderTemplateCell.h"
#import "TDReminderView.h"
#import "TDTemplateCollectionView.h"

#import "MBProgressHUD.h"

#import "JCMath.h"
#import "NSDate+AngularTime.h"

#import "TDDayView.h"

#import "UILocalNotification+DailyNotification.h"

#import "TDAppDelegate.h"

#define REMINDER_TEMPLATES @"reminderTemplates"

@interface TDDayViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>
{
    NSMutableArray *reminderTemplates; //dictionaries in userdefaults
    
    UIView *templatesView;
    TDTemplateCollectionView *templatesCollectionView;
    
    TDReminderView *reminderViewActive;
    
    BOOL shouldAddReminder;
    
    NSDate *scheduleDay;
    
    NSDateFormatter *formatter;
    NSCalendar *calendar;
    
    NSString *newReminderName;
    
    NSTimeInterval currentTime;
    
    IBOutlet TDDayView *viewDay;
    
    BOOL didDrag;
}

@end

@implementation TDDayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    
    reminderTemplates = [[NSUserDefaults standardUserDefaults] objectForKey:REMINDER_TEMPLATES];
    
    if (!reminderTemplates){
        reminderTemplates = [NSMutableArray array];
        //make default ones
        
        [reminderTemplates addObject:@{@"name": @"Drink Water"}];
        [reminderTemplates addObject:@{@"name": @"Go for a run"}];
        [reminderTemplates addObject:@{@"name": @"Take a break"}];
    }
    
    //calendar stuff
    calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:1];
    [components setMonth:1];
    [components setYear:2001];
    
    [components setTimeZone:[NSTimeZone defaultTimeZone]];
    [components setHour:0];
    [components setMinute:0];
    
    scheduleDay = [calendar dateFromComponents:components];
    
    currentTime = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:LOCAL_NOTE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ENTER_BG object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (reminderTemplates)
        {
            [[NSUserDefaults standardUserDefaults] setObject:reminderTemplates forKey:REMINDER_TEMPLATES];
        }
    }];
    
    NSTimer *updateDayView;
    updateDayView = [NSTimer scheduledTimerWithTimeInterval:1 target:viewDay selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    
    [self showScheduledReminders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)receivedNotification:(UILocalNotification *)note
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TheDaily" message:note.userInfo[@"name"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alert show];
}

- (IBAction)clear:(id)sender {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self showScheduledReminders];
}

-(void)showScheduledReminders
{
    for (UIView *subview in self.view.subviews)
    {
        if (![subview isKindOfClass:[TDReminderView class]]) continue;
        
        TDReminderView *reminder = (TDReminderView *)subview;
        
        [reminder removeFromSuperview];
        reminder = nil;
    }
    
    for (UILocalNotification *note in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        TDReminderView *reminder = [self newReminderAtPosition:CGPointZero];
        
        reminder.selected = NO;
        reminder.notification = note;
        reminder.timeFormatted = [formatter stringFromDate:note.fireDate];

        [self positionReminders];
    }
}

-(void)scheduleReminderForReminderView:(TDReminderView *)reminder
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    int seconds = [self secondsForPosition:CGPointMake(reminder.frame.origin.x + reminder.frame.size.width/2, reminder.frame.origin.y + reminder.frame.size.height/2)];
    
    float angle = [JCMath angleFromPoint:center toPoint:reminder.frame.origin];
    float distance = [JCMath distanceBetweenPoint:reminder.frame.origin andPoint:center sorting:NO];
    
    //remove already scheduled
    for (UILocalNotification *note in [[UIApplication sharedApplication] scheduledLocalNotifications]){
        if ([note.userInfo[@"id"] isEqualToString:reminder.notification.userInfo[@"id"]]){
            [note cancel];
        }
    }
    
    //schedule new
    //find date
    
    NSDate *fireDate = [self dateOffsetBySeconds:seconds];
    
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    
    localNote.alertAction = @"Hey";
    localNote.alertBody = @"Do it yea!";
    localNote.soundName = UILocalNotificationDefaultSoundName;
    
    localNote.timeZone = [NSTimeZone defaultTimeZone];
    localNote.repeatInterval = NSCalendarUnitDay;
    
    localNote.fireDate = fireDate;
    
    localNote.userInfo = @{@"name": reminder.name, @"distance": @(distance), @"id": [NSString stringWithFormat:@"%@%i", reminder.name, seconds], @"angle": @(angle)};
    
    reminderViewActive.notification = localNote;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    
    //[self showScheduledReminders];
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]){
        NSLog(@"Note: %@", notification);
    }
}

-(void)positionReminders
{
    for (UIView *subview in self.view.subviews)
    {
        if (![subview isKindOfClass:[TDReminderView class]]) continue;
        if (subview == reminderViewActive) continue;
        
        TDReminderView *reminder = (TDReminderView *)subview;
        
        CGPoint position = [self positionForReminder:reminder];
        
        reminder.frame = CGRectMake(position.x, position.y, reminder.frame.size.width, reminder.frame.size.height);
    }
}

-(CGPoint)positionForReminder:(TDReminderView *)reminder
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    float angle = [reminder.notification.userInfo[@"angle"] floatValue];
    float distance = [reminder.notification.userInfo[@"distance"] floatValue];
    
    CGPoint offset = [JCMath pointFromPoint:center pushedBy:distance inDirection:angle];
    
    return offset;
}

-(int)secondsForPosition:(CGPoint)position
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    float angle = [JCMath angleFromPoint:center toPoint:position] - 90.0;
    
    int seconds = [NSDate secondsFromAngle:angle];
    
    return seconds;
}

- (IBAction)showTemplates:(id)sender
{
    if (!templatesView)
    {
        UIEdgeInsets insets = UIEdgeInsetsMake(100, 40, 100, 40);
        CGSize buttonSize = CGSizeMake(120, 44);
        
        templatesView = [[UIView alloc] initWithFrame:CGRectMake(insets.left, insets.top, self.view.bounds.size.width - insets.left - insets.right, self.view.bounds.size.height - insets.top - insets.bottom)];
        
        templatesView.layer.cornerRadius = 6;
        
        templatesView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize = CGSizeMake(templatesView.bounds.size.width, 48);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        templatesCollectionView = [[TDTemplateCollectionView alloc] initWithFrame:CGRectMake(0, 0, templatesView.bounds.size.width, templatesView.bounds.size.height - buttonSize.height) collectionViewLayout:layout];
        
        templatesCollectionView.dayViewController = self;
        
        templatesCollectionView.delegate = self;
        templatesCollectionView.dataSource = self;
        
        templatesCollectionView.alwaysBounceVertical = YES;
        
        templatesCollectionView.backgroundColor = [UIColor clearColor];
        
        [templatesCollectionView registerNib:[UINib nibWithNibName:@"reminderTemplateCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"reminderTemplateCell"];
        
        [templatesView addSubview:templatesCollectionView];
        
        UIButton *addNew = [UIButton buttonWithType:UIButtonTypeSystem];
        
        addNew.frame = CGRectMake(templatesView.bounds.size.width - buttonSize.width, templatesView.bounds.size.height - buttonSize.height, buttonSize.width, buttonSize.height);
        
        [addNew setTitle:@"New Template" forState:UIControlStateNormal];
        [addNew setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [addNew addTarget:self action:@selector(createNewTemplate:) forControlEvents:UIControlEventTouchUpInside];
        
        [templatesView addSubview:addNew];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
        
        cancel.frame = CGRectMake(0, templatesView.bounds.size.height - buttonSize.height, buttonSize.width*3/5, buttonSize.height);
        
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [cancel addTarget:self action:@selector(removeTemplates) forControlEvents:UIControlEventTouchUpInside];
        
        [templatesView addSubview:cancel];
    }
    
    templatesCollectionView.scrollEnabled = YES;
    
    [templatesCollectionView reloadData];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeCustomView];
    
    hud.color = [UIColor clearColor];
    hud.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    hud.customView = templatesView;
}

-(void)hideTemplates
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        hud.alpha = 0;
    }];
}

-(void)removeTemplates
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:hud.alpha == 1];
}

-(void)createNewTemplate:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Reminder" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.placeholder = @"Name";
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //added new reminder
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSString *reminderName = textField.text;
        
        [reminderTemplates addObject:@{@"name": reminderName}];
        [templatesCollectionView reloadData];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPosition = [touch locationInView:self.view];
    
    if (shouldAddReminder){
        shouldAddReminder = NO;
        
        reminderViewActive = [self newReminderAtPosition:touchPosition];
        
        reminderViewActive.selected = NO;
        reminderViewActive.enlarge = YES;
        
        reminderViewActive.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
        [UIView animateWithDuration:0.2 animations:^{
            reminderViewActive.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
        
        return;
    }
    
    if (!reminderViewActive && ![MBProgressHUD HUDForView:self.view])
    {
        for (UIView *subview in self.view.subviews)
        {
            if (![subview isKindOfClass:[TDReminderView class]]) continue;

            float difX = touchPosition.x - subview.frame.origin.x;
            float difY = touchPosition.y - subview.frame.origin.y;
            
            if (difX > 0 && difX < subview.frame.size.width && difY > 0 && difY < subview.frame.size.height)
            {
                reminderViewActive = (TDReminderView *)subview;
            }
        }
    }
    
    if (reminderViewActive)
    {
        if (!reminderViewActive.selected)
        {
            reminderViewActive.enlarge = YES;
            
            reminderViewActive.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
            
            [UIView animateWithDuration:0.2 animations:^{
                reminderViewActive.layer.transform = CATransform3DMakeScale(1, 1, 1);
            }];
        }
        
        [self.view bringSubviewToFront:reminderViewActive];
    }
    
    didDrag = NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPosition = [touch locationInView:self.view];
    
    reminderViewActive.frame = CGRectMake(touchPosition.x - reminderViewActive.frame.size.width/2, touchPosition.y - reminderViewActive.frame.size.height/2, reminderViewActive.frame.size.width, reminderViewActive.frame.size.height);
    
    reminderViewActive.enlarge = YES;
    [self showFormattedTimeOnReminder:reminderViewActive];
    [reminderViewActive setNeedsDisplay];
    
    didDrag = YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded];
}

-(void)touchesEnded
{
    if (!reminderViewActive){
        [self deselectAllReminders];
        return;
    }
    
    reminderViewActive.enlarge = NO;
    
    if (!didDrag && reminderViewActive)
    {
        if (reminderViewActive.selected)
        {
            reminderViewActive.selected = NO;
            
            reminderViewActive.layer.transform = CATransform3DMakeScale(2, 2, 1);
            
            [UIView animateWithDuration:0.2 animations:^{
                reminderViewActive.layer.transform = CATransform3DMakeScale(1, 1, 1);
            }];
        }else{
            reminderViewActive.selected = YES;
        }
        
        
    }else{
        if (!reminderViewActive.selected)
        {
            reminderViewActive.enlarge = NO;
            
            reminderViewActive.layer.transform = CATransform3DMakeScale(2, 2, 1);
            [UIView animateWithDuration:0.2 animations:^{
                reminderViewActive.layer.transform = CATransform3DMakeScale(1, 1, 1);
            }];
        }
    }
    
    [self scheduleReminderForReminderView:reminderViewActive];
    
    [self removeTemplates];
    reminderViewActive = nil;
}

-(void)showFormattedTimeOnReminder:(TDReminderView *)reminder
{
    NSTimeInterval seconds = [self secondsForPosition:CGPointMake(reminder.frame.origin.x + reminder.frame.size.width/2, reminder.frame.origin.y + reminder.frame.size.height/2)];
    NSString *timeString = [formatter stringFromDate:[self dateOffsetBySeconds:seconds]];
    
    reminder.timeFormatted = timeString;
}

-(NSDate *)dateOffsetBySeconds:(NSTimeInterval)seconds
{
    return [NSDate dateWithTimeInterval:seconds sinceDate:scheduleDay];
}

-(TDReminderView *)newReminderAtPosition:(CGPoint)position
{
    [self hideTemplates];
    
    templatesCollectionView.scrollEnabled = NO;
    
    TDReminderView *reminder = [TDReminderView reminderAtPoint:position];
    
    reminder.name = newReminderName;
    reminder.frame = CGRectMake(position.x - reminder.bounds.size.width/2, position.y - reminder.bounds.size.height/2, reminder.frame.size.width, reminder.frame.size.height);
    
    [self showFormattedTimeOnReminder:reminder];
    
    [self.view addSubview:reminder];
    
    return reminder;
}

-(void)deleteReminder:(UIButton *)sender
{
    int index = (int)sender.tag; //cheap but works! haha
    
    [reminderTemplates removeObjectAtIndex:index];
    [templatesCollectionView reloadData];
}

-(void)deselectAllReminders
{
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[TDReminderView class]])
        {
            TDReminderView *reminder = (TDReminderView *)view;
            reminder.selected = NO;
            reminderViewActive.enlarge = NO;
        }
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *template = reminderTemplates[indexPath.row];
    
    TDReminderTemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reminderTemplateCell" forIndexPath:indexPath];
    
    cell.reminderTemplate = template;
    cell.buttonAdd.tag = indexPath.row;
    
    if (cell.buttonAdd.allTargets.count == 0)
    {
        //add new
        [cell.buttonAdd addTarget:self action:@selector(deleteReminder:) forControlEvents:UIControlEventTouchDown];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    shouldAddReminder = YES;
    
    TDReminderTemplateCell *cell = (TDReminderTemplateCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    newReminderName = cell.reminderTemplate[@"name"];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return reminderTemplates.count;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
