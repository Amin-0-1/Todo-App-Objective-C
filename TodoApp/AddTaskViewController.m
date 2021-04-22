//
//  AddTaskViewController.m
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import "AddTaskViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <ProgressHUD/ProgressHUD.h>
@interface AddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *uiNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *uiDescriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *uiAddTaskBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *uiPrioritySegment;
@property (weak, nonatomic) IBOutlet UIDatePicker *uiDatePicker;
@property NSMutableArray *arrayData;
@end

bool isGrantedNotificationAccess;
@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isGrantedNotificationAccess = false;
    [self roundTextFields];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert +UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            isGrantedNotificationAccess = granted;
    }];
    
    [self getArrayData];
    _uiAddTaskBtn.layer.cornerRadius = _uiAddTaskBtn.layer.frame.size.height/2;
    
}
-(void) getArrayData{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"Tasks.plist"];
    NSMutableArray *allData = [NSMutableArray arrayWithContentsOfFile:filePath];
    _arrayData = [NSMutableArray new];
    for (NSDictionary *dict in allData) {
        [_arrayData addObject:[dict objectForKey:@"name"]];
    }
}

-(void)roundTextFields{
    _uiNameTextField.layer.cornerRadius = _uiNameTextField.layer.frame.size.height/2;
    _uiNameTextField.clipsToBounds = YES;
    _uiNameTextField.layer.borderWidth = 1;
        
    _uiDescriptionTextField.layer.cornerRadius = _uiDescriptionTextField.layer.frame.size.height/2;
    _uiDescriptionTextField.clipsToBounds = YES;
    _uiDescriptionTextField.layer.borderWidth = 1;
}
- (IBAction)uiCloseWindow:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)uiAddTask:(id)sender {
    
    
    
    if(![_uiNameTextField.text isEqual:@""] && ![_uiDescriptionTextField.text isEqual:@""] && ![_arrayData containsObject:_uiNameTextField.text]){

        NSString *priority = @"high";
        
        if(_uiPrioritySegment.selectedSegmentIndex == 1){
            priority = @"mid";
        }else if(_uiPrioritySegment.selectedSegmentIndex == 2){
            priority = @"low";
        }
        
        NSDictionary *dict = @{ @"name" : _uiNameTextField.text, @"description" : _uiDescriptionTextField.text, @"priority":priority ,@"date": [_uiDatePicker date] ,@"status":@"todo"};

        Boolean addOrNot = [self notification:dict];
        if(addOrNot == YES){
            [_delegate receiveTask:dict];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else if([_arrayData containsObject:_uiNameTextField.text]){
        [ProgressHUD colorHUD:[UIColor grayColor]];
        [ProgressHUD showError:@"It's not allowed to add tasks with same names"];

    }else{

        [ProgressHUD colorHUD:[UIColor grayColor]];
        [ProgressHUD showError:@"Please Fill in The blanks"];
        
        
    }
}

-(Boolean)notification:(NSDictionary *)dict{
    if(isGrantedNotificationAccess){
        
        if(_uiDatePicker.date.timeIntervalSinceNow > 0){
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"Todo";
            content.subtitle = [dict objectForKey:@"name"];
            content.body = @"It is todo time";
            content.sound = [UNNotificationSound defaultSound];
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:_uiDatePicker.date.timeIntervalSinceNow repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:_uiNameTextField.text content:content trigger:trigger];

            // add notification for current notification centre
            [center addNotificationRequest:request withCompletionHandler:nil];
            return YES;
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Date Status" message:@"Please assign a vlid date" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return NO;
        }
    }
    return NO;
}
- (IBAction)uiValueChanged:(id)sender {
//    NSLog(@"%f",[sender duration]);
}

@end
