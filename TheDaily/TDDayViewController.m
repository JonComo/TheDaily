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
        NSDictionary *template = @{@"name": @"test", @"seconds" : @(2000), @"distance": @(200)};
        
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
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showScheduledReminders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showScheduledReminders
{
    for (UILocalNotification *note in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        NSLog(@"Recalled: %@", note.userInfo);
        
        float distance = [note.userInfo[@"distance"] floatValue];
        
        int seconds = [note.userInfo[@"seconds"] integerValue];
        
        float timeRatio = (float)seconds / 86400.0f;
        
        float rotation = timeRatio * 360 + 180;
        
        CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        
        CGPoint offsetPoint = [JCMath pointFromPoint:center pushedBy:distance inDirection:rotation];
        
        TDReminderView *reminder = [self newReminderAtPosition:offsetPoint noteInfo:note.userInfo];
        
        reminder.labelTime.text = [formatter stringFromDate:note.fireDate];
    }
}

-(void)scheduleReminderForReminderView:(TDReminderView *)reminder
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    int seconds = [self secondsForPosition:reminder.frame.origin];
    float distance = [JCMath distanceBetweenPoint:reminder.frame.origin andPoint:center sorting:NO];
    
    //remove already scheduled
    NSArray *scheduled = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in scheduled){
        if ([notification.userInfo[@"id"] isEqualToString:reminder.noteInfo[@"id"]]){
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
    
    reminder.noteInfo = @{@"name": @"testy", @"distance": @(distance), @"seconds": @(seconds), @"id": [NSString stringWithFormat:@"%@%i", @"testy", seconds]};
    
    NSLog(@"Saved: %@", reminder.noteInfo);
    
    localNote.userInfo = reminder.noteInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]){
        NSLog(@"Note: %@", notification);
    }
}

-(void)update:(NSTimer *)timer
{
    [self positionReminders];
}

-(void)positionReminders
{
    for (UIView *subview in self.view.subviews)
    {
        if (![subview isKindOfClass:[TDReminderView class]]) continue;
        if (subview == reminderViewActive) continue;
        
        TDReminderView *reminder = (TDReminderView *)subview;
        
//        [UIView animateWithDuration:0.3 animations:^{
//            reminder.frame = CGRectMake(arc4random()%200, arc4random()%200, reminder.frame.size.width, reminder.frame.size.height);
//        }];
    }
}

-(float)angleOfPoint:(CGPoint)point
{
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    float angle = [JCMath angleFromPoint:center toPoint:point] + 180;
    
    return angle;
}

-(int)secondsForPosition:(CGPoint)position
{
    float angle = [self angleOfPoint:position];
    
    float angleRatio = angle/360;
    
    int seconds = 86400 * angleRatio;
    
    NSLog(@"seconds: %i", seconds);
    
    return seconds;
}

-(float)angleFromSeconds:(NSTimeInterval)seconds
{
    float timeRatio = (float)seconds / 86400;
    
    float angle = timeRatio * 360;
    
    return angle;
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
        reminderViewActive = [self newReminderAtPosition:touchPosition noteInfo:@{@"name": @"test"}];
        
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

-(TDReminderView *)newReminderAtPosition:(CGPoint)position noteInfo:(NSDictionary *)noteInfo
{
    [self hideTemplates];
    
    TDReminderView *reminder = [TDReminderView reminder];
    
    reminder.noteInfo = noteInfo;
    
    reminder.frame = CGRectMake(position.x - reminder.bounds.size.width/2, position.y - reminder.bounds.size.height/2, reminder.frame.size.width, reminder.frame.size.height);
    
    //[reminder setUserInteractionEnabled:NO];
    
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
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return reminderTemplates.count;
}

@end
