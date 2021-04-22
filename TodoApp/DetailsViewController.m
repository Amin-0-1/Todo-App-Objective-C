//
//  DetailsViewController.m
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *uiTaskName;
@property (weak, nonatomic) IBOutlet UITextField *uiTaskDesc;
@property (weak, nonatomic) IBOutlet UISegmentedControl *uiPrioritySegment;
@property (weak, nonatomic) IBOutlet UIDatePicker *uiDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *uiUpdateBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *uiStatusSegment;

@end

@implementation DetailsViewController

Boolean isEditing;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    isEditing = NO;
    [self roundTextfields];
    
    if(_caller == todo){
        [_uiStatusSegment setEnabled:NO forSegmentAtIndex:2];
    }else if(_caller == progress){
        [_uiStatusSegment setEnabled:NO forSegmentAtIndex:0];
        [_uiStatusSegment setSelectedSegmentIndex:1];
    }else if(_caller == done){
        [_uiStatusSegment setEnabled:NO forSegmentAtIndex:0];
        [_uiStatusSegment setEnabled:NO forSegmentAtIndex:1];
        [_uiStatusSegment setEnabled:NO forSegmentAtIndex:2];
        [_uiStatusSegment setSelectedSegmentIndex:2];
        [_uiUpdateBtn setHidden:YES];
    }
    _uiUpdateBtn.layer.cornerRadius = _uiUpdateBtn.layer.frame.size.height/2;
    
    
    _uiTaskDesc.text = [_data objectForKey:@"description"];
    _uiTaskName.text = [_data objectForKey:@"name"];
    
    if([[_data objectForKey:@"priority"]  isEqual: @"low"]){
        [_uiPrioritySegment setSelectedSegmentIndex:2];

    }else if([[_data objectForKey:@"priority"] isEqual:@"high"]){
        [_uiPrioritySegment setSelectedSegmentIndex:0];

    }else{
        [_uiPrioritySegment setSelectedSegmentIndex:1];
    }
    
}

-(void)roundTextfields{
    _uiTaskName.layer.cornerRadius = _uiTaskName.layer.frame.size.height/2;
    _uiTaskName.clipsToBounds = YES;
    _uiTaskName.layer.borderWidth = 1;
    
    _uiTaskDesc.layer.cornerRadius = _uiTaskDesc.layer.frame.size.height/2;
    _uiTaskDesc.clipsToBounds = YES;
    _uiTaskDesc.layer.borderWidth = 1;
}
- (IBAction)uiCloseWindow:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uiUpdateBtn:(id)sender {
    isEditing = !isEditing;
    
    if(isEditing){
        _uiTaskName.enabled = true;
        _uiTaskDesc.enabled = true;
        _uiPrioritySegment.enabled = true;
        _uiStatusSegment.enabled = true;
        _uiDatePicker.enabled = true;
        [_uiUpdateBtn setTitle:@"save" forState:UIControlStateNormal];
    }else{
        
        if(![_uiTaskName.text isEqual:@""] && ![_uiTaskDesc.text isEqual:@""]){

            
            NSString *priority = @"high";
            NSString *status = @"todo";
            
            if(_uiPrioritySegment.selectedSegmentIndex == 1){
                priority = @"mid";
            }else if(_uiPrioritySegment.selectedSegmentIndex == 2){
                priority = @"low";
            }
            
            if(_uiStatusSegment.selectedSegmentIndex == 1){
                status = @"progress";
            }else if(_uiStatusSegment.selectedSegmentIndex == 2){
                status = @"done";
            }
            
            NSDictionary *dict = @{ @"name" : _uiTaskName.text, @"description" : _uiTaskDesc.text, @"priority":priority ,@"date": [_uiDatePicker date],@"status":status};
            
            [_delegate recieveUpdateTask:dict withID:_Id andSection:_section];
            [self dismissViewControllerAnimated:YES completion:nil];
            _uiTaskName.enabled = false;
            _uiTaskDesc.enabled = false;
            _uiPrioritySegment.enabled = false;
            _uiStatusSegment.enabled = false;
            _uiDatePicker.enabled = false;
            [_uiUpdateBtn setTitle:@"Update" forState:UIControlStateNormal];
                
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Task" message:@"please fill in the blanks" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

@end
