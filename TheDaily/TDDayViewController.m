//
//  TDDayViewController.m
//  TheDaily
//
//  Created by Jon Como on 11/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "TDDayViewController.h"

@import SpriteKit;

#import "TDDayScene.h"
#import "TDReminderTemplateCell.h"

#import "TDReminderView.h"

#import "TDTemplateCollectionView.h"

#import "JCMath.h"

#define REMINDER_TEMPLATES @"reminderTemplates"

@interface TDDayViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet SKView *viewDaily;
    TDDayScene *dayScene;
    
    NSMutableArray *reminderTemplates; //dictionaries in userdefaults
    
    UIView *templatesView;
    TDTemplateCollectionView *templatesCollectionView;
    
    TDReminderView *reminderViewActive;
    CGPoint touchPosition;
    CGPoint touchOffset;
    
    BOOL shouldAddReminder;
    
    NSDate *scheduleDay;
    
    NSDateFormatter *formatter;
    NSCalendar *calendar;
    
    NSString *newReminderName;
    
    NSTimeInterval currentTime;
}

@end

@implementation TDDayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    
    dayScene = [[TDDayScene alloc] initWithSize:viewDaily.bounds.size];
    dayScene.scaleMode = SKSceneScaleModeAspectFit;
    [viewDaily presentScene:dayScene];
    
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
    
    //NSTimer *timer;
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    
    currentTime = 0;
    
    [self showScheduledReminders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        reminder.notification = note;
        reminder.labelTime.text = [formatter stringFromDate:note.fireDate];
        
        CGPoint location = [self positionForReminder:reminder];
        reminder.frame = CGRectMake(location.x, location.y, reminder.frame.size.width, reminder.frame.size.height);
        
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
    NSArray *scheduled = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in scheduled){
        if ([notification.userInfo[@"id"] isEqualToString:reminder.notification.userInfo[@"id"]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
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
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    
    [self showScheduledReminders];
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]){
        NSLog(@"Note: %@", notification);
    }
}

-(void)update:(NSTimer *)timer
{
    currentTime += 1;
    [self positionReminders];
}

-(void)positionReminders
{
    for (UIView *subview in self.view.subviews)
    {
        if (![subview isKindOfClass:[TDReminderView class]]) continue;
        if (subview == reminderViewActive) continue;
        
        TDReminderView *reminder = (TDReminderView *)subview;
        
        //[UIView animateWithDuration:0.3 animations:^{
            CGPoint position = [self positionForReminder:reminder];
            reminder.frame = CGRectMake(position.x, position.y, reminder.frame.size.width, reminder.frame.size.height);
        //}];
    }
}

-(CGPoint)positionForReminder:(TDReminderView *)reminder
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    float angle = [reminder.notification.userInfo[@"angle"] floatValue];
    float distance = [reminder.notification.userInfo[@"distance"] floatValue];
    
    //angle += currentTime;
    
    CGPoint offset = [JCMath pointFromPoint:center pushedBy:distance inDirection:angle];
    
    return offset;
}

-(int)secondsForPosition:(CGPoint)position
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    float angle = [JCMath angleFromPoint:center toPoint:position] + 180;
    
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
        templatesView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 150, self.view.bounds.size.height/2 - 200, 300, 400)];
        
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
    touchPosition = [touch locationInView:self.view];
    
    if (shouldAddReminder)
    {
        shouldAddReminder = NO;
        reminderViewActive = [self newReminderAtPosition:touchPosition];
        
        touchOffset = CGPointMake(touchPosition.x - reminderViewActive.frame.origin.x, touchPosition.y - reminderViewActive.frame.origin.y);
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
                
                touchOffset = CGPointMake(touchPosition.x - subview.frame.origin.x, touchPosition.y - subview.frame.origin.y);
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPosition = [touch locationInView:self.view];
    
    CGPoint translation = CGPointMake(touchPosition.x - touchOffset.x, touchPosition.y - touchOffset.y);
    
    reminderViewActive.frame = CGRectMake(translation.x, translation.y, reminderViewActive.frame.size.width, reminderViewActive.frame.size.height);
    
    if (reminderViewActive){
        NSTimeInterval seconds = [self secondsForPosition:reminderViewActive.frame.origin];
        NSString *timeString = [formatter stringFromDate:[self dateOffsetBySeconds:seconds]];
        
        reminderViewActive.labelTime.text = timeString;
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
    if (!reminderViewActive) return;
    
    //make reminder with seconds and userinfo of distance of the view
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
    
    TDReminderView *reminder = [TDReminderView reminder];
    
    reminder.name = newReminderName;
    
    reminder.frame = CGRectMake(position.x - reminder.bounds.size.width/2, position.y - reminder.bounds.size.height/2, reminder.frame.size.width, reminder.frame.size.height);
    
    [self.view addSubview:reminder];
    
    return reminder;
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
