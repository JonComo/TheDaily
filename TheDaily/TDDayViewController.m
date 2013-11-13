//
//  TDDayViewController.m
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDDayViewController.h"

#import "TDReminderTemplateCell.h"
#import "TDReminderView.h"
#import "TDTemplateCollectionView.h"

#import "JCMath.h"

#import "UILocalNotification+DailyNotification.h"

#import "TDAppDelegate.h"

#define REMINDER_TEMPLATES @"reminderTemplates"

@interface TDDayViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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
    
    BOOL didDrag;
    BOOL wasDeselected;
}

@end

@implementation TDDayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    reminderTemplates = [[NSUserDefaults standardUserDefaults] objectForKey:REMINDER_TEMPLATES];
    
    if (!reminderTemplates){
        reminderTemplates = [NSMutableArray array];
        //make default one
        NSDictionary *template = @{@"name": @"test"};
        
        [reminderTemplates addObject:template];
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
    
    [self showScheduledReminders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)receivedNotification:(UILocalNotification *)note
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local note" message:@"message" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
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
    
    int seconds = [self secondsForPosition:reminder.frame.origin];
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
    
    // angle += currentTime;
    
    CGPoint offset = [JCMath pointFromPoint:center pushedBy:distance inDirection:angle];
    
    return offset;
}

-(int)secondsForPosition:(CGPoint)position
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    float angle = [JCMath angleFromPoint:center toPoint:position] - 90.0;
    
    int seconds = [self secondsFromAngle:angle];
    
    return seconds;
}

-(float)angleFromSeconds:(NSTimeInterval)seconds
{
    float timeRatio = (float)seconds / 86400;
    
    float angle = timeRatio * 360;
    
    return angle;
}

-(int)secondsFromAngle:(float)angle
{
    float angleRatio = angle/360;
    
    int seconds = 86400 * angleRatio;
    
    return seconds;
}

- (IBAction)showTemplates:(id)sender
{
    if (!templatesView)
    {
        UIEdgeInsets insets = UIEdgeInsetsMake(100, 40, 100, 40);
        
        templatesView = [[UIView alloc] initWithFrame:CGRectMake(insets.left, insets.top, self.view.bounds.size.width - insets.left - insets.right, self.view.bounds.size.height - insets.top - insets.bottom)];
        
        templatesView.backgroundColor = [UIColor greenColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize = CGSizeMake(300, 44);
        
        templatesCollectionView = [[TDTemplateCollectionView alloc] initWithFrame:CGRectMake(0, 0, templatesView.bounds.size.width, templatesView.bounds.size.height) collectionViewLayout:layout];
        
        templatesCollectionView.dayViewController = self;
        
        templatesCollectionView.delegate = self;
        templatesCollectionView.dataSource = self;
        
        templatesCollectionView.backgroundColor = [UIColor purpleColor];
        
        [templatesCollectionView registerNib:[UINib nibWithNibName:@"reminderTemplateCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"reminderTemplateCell"];
        
        [templatesView addSubview:templatesCollectionView];
    }
    
    [templatesCollectionView reloadData];
    [self.view addSubview:templatesView];
    
    templatesView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        templatesView.alpha = 1;
    }];
}

-(void)hideTemplates
{
    if (!templatesView.superview) return;
    
    [UIView animateWithDuration:0.3 animations:^{
        templatesView.alpha = 0;
    } completion:^(BOOL finished) {
        //[templatesView removeFromSuperview];
    }];
}

-(void)removeTemplates
{
    [templatesView removeFromSuperview];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPosition = [touch locationInView:self.view];
    
    didDrag = NO;
    
    if (shouldAddReminder){
        shouldAddReminder = NO;
        
        reminderViewActive = [self newReminderAtPosition:touchPosition];
        
        return;
    }
    
    if (!reminderViewActive)
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
    
    wasDeselected = !reminderViewActive.selected;
    
    if (reminderViewActive)
    {
        [self deselectAllReminders];
        reminderViewActive.selected = YES;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPosition = [touch locationInView:self.view];
    
    didDrag = YES;
    
    reminderViewActive.frame = CGRectMake(touchPosition.x - reminderViewActive.frame.size.width/2, touchPosition.y - reminderViewActive.frame.size.height/2, reminderViewActive.frame.size.width, reminderViewActive.frame.size.height);
    
    if (reminderViewActive){
        NSTimeInterval seconds = [self secondsForPosition:CGPointMake(reminderViewActive.frame.origin.x + reminderViewActive.frame.size.width/2, reminderViewActive.frame.origin.y + reminderViewActive.frame.size.height/2)];
        NSString *timeString = [formatter stringFromDate:[self dateOffsetBySeconds:seconds]];
        
        reminderViewActive.timeFormatted = timeString;
    }
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
    if (!reminderViewActive)
    {
        [self deselectAllReminders];
        return;
    }
    
    if (didDrag){
        reminderViewActive.selected = NO;
    }
    
    if (!wasDeselected)
    {
        reminderViewActive.selected = NO;
    }
    
    [self scheduleReminderForReminderView:reminderViewActive];
    
    [self removeTemplates];
    reminderViewActive = nil;
}

-(NSDate *)dateOffsetBySeconds:(NSTimeInterval)seconds
{
    return [NSDate dateWithTimeInterval:seconds sinceDate:scheduleDay];
}

-(TDReminderView *)newReminderAtPosition:(CGPoint)position
{
    [self hideTemplates];
    
    TDReminderView *reminder = [TDReminderView reminderAtPoint:position];
    
    reminder.name = newReminderName;
    
    reminder.frame = CGRectMake(position.x - reminder.bounds.size.width/2, position.y - reminder.bounds.size.height/2, reminder.frame.size.width, reminder.frame.size.height);
    
    [self.view addSubview:reminder];
    
    return reminder;
}

-(void)deselectAllReminders
{
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[TDReminderView class]])
        {
            TDReminderView *reminder = (TDReminderView *)view;
            reminder.selected = NO;
        }
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *template = reminderTemplates[indexPath.row];
    
    TDReminderTemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reminderTemplateCell" forIndexPath:indexPath];
    
    cell.reminderTemplate = template;
    
    if (cell.buttonAdd.allTargets.count == 0)
    {
        //add new
        //[cell.buttonAdd addTarget:self action:@selector(addNewReminder) forControlEvents:UIControlEventTouchDown];
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

@end
