//
//  InProgressViewController.m
//  TodoApp
//
//  Created by Amin on 06/04/2021.
//

#import "InProgressViewController.h"
#import "DetailsViewController.h"
#import "MyStatus.h"
#import <ProgressHUD/ProgressHUD.h>
@interface InProgressViewController ()
    @property (weak, nonatomic) IBOutlet UISwitch *uiSortSwitch;
    @property (weak, nonatomic) IBOutlet UITableView *uiTableView;
    @property NSMutableArray *arrayData;
    @property NSMutableArray *progressData;

    @property NSMutableArray *highPriority;
    @property NSMutableArray *lowPriority;
    @property NSMutableArray *midPriority;

    @property NSString *filePath;
@end

@implementation InProgressViewController

Boolean isSectionEnabled;

- (void)viewDidLoad {
    [super viewDidLoad];
    isSectionEnabled = NO;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self getPlistData];
}

-(void)getPlistData{
    // plist path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    _filePath = [documentFolder stringByAppendingFormat:@"Tasks.plist"];
    _arrayData = [[NSMutableArray alloc] initWithContentsOfFile:_filePath];
    _progressData = [NSMutableArray arrayWithArray:_arrayData];

    for (NSDictionary *dict in _arrayData) {
        if(![[dict objectForKey:@"status"] isEqualToString:@"progress"]){
            [_progressData removeObject:dict];
        }
    }
    
    
    _lowPriority = [NSMutableArray new];
    _midPriority = [NSMutableArray new];
    _highPriority = [NSMutableArray new];
    for (NSDictionary *dict in _progressData) {
        if([[dict objectForKey:@"priority"] isEqualToString:@"low"]){
            [_lowPriority addObject:dict];
        }else if([[dict objectForKey:@"priority"] isEqualToString:@"mid"]){
            [_midPriority addObject:dict];
        }else if([[dict objectForKey:@"priority"] isEqualToString:@"high"]){
            [_highPriority addObject:dict];
        }
    }
    
    
    [_uiTableView reloadData];

}

- (IBAction)uiSortSwitchTapped:(id)sender {
    isSectionEnabled = !isSectionEnabled;
    [_uiTableView reloadData];
}


- (void)recieveUpdateTask:(NSDictionary *)updatedTask withID:(NSInteger)Id andSection:(NSInteger)section{
    printf("received");
    
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentFolder = [path objectAtIndex:0];
//    NSString *filePath = [documentFolder stringByAppendingFormat:@"Tasks.plist"];
    
    NSDictionary *dict;
    NSString *str;
    if(isSectionEnabled){
        switch (section) {
            case 0:
                
                dict =  [_highPriority objectAtIndex:Id];
                str = [dict objectForKey:@"name"];
                
                [self removeTaskFromArrayWithName:str];
                
                [_highPriority removeObjectAtIndex:Id];
                [_arrayData addObject:updatedTask];
                
                if([[updatedTask objectForKey:@"status"] isEqualToString:@"progress"]){
                    [_highPriority addObject:updatedTask];
                    [_progressData addObject:updatedTask];
                }
                
                for (NSDictionary *dict in self->_progressData) {
                    if([[dict objectForKey:@"name"] isEqualToString:str]){
                        [self->_progressData removeObject:dict];
                        break;
                    }
                }
                
                break;
            case 1:
                
                dict =  [_midPriority objectAtIndex:Id];
                str = [dict objectForKey:@"name"];
                
                [self removeTaskFromArrayWithName:str];
                
                [_midPriority removeObjectAtIndex:Id];
                [_arrayData addObject:updatedTask];
                
                if([[updatedTask objectForKey:@"status"] isEqualToString:@"progress"]){
                    [_midPriority addObject:updatedTask];
                    [_progressData addObject:updatedTask];
                }
                for (NSDictionary *dict in self->_progressData) {
                    if([[dict objectForKey:@"name"] isEqualToString:str]){
                        [self->_progressData removeObject:dict];
                        break;
                    }
                }
                break;
            case 2:
                dict =  [_lowPriority objectAtIndex:Id];
                str = [dict objectForKey:@"name"];
                
                [self removeTaskFromArrayWithName:str];
                
                [_lowPriority removeObjectAtIndex:Id];
                [_arrayData addObject:updatedTask];
                
                if([[updatedTask objectForKey:@"status"] isEqualToString:@"progress"]){
                    [_lowPriority addObject:updatedTask];
                    [_progressData addObject:updatedTask];
                }
                for (NSDictionary *dict in self->_progressData) {
                    if([[dict objectForKey:@"name"] isEqualToString:str]){
                        [self->_progressData removeObject:dict];
                        break;
                    }
                }
                break;
                
            default:
                break;
        }
    }else{
        NSDictionary *dict =  [_progressData objectAtIndex:Id];
        NSString *str = [dict objectForKey:@"name"];
        
        for (NSDictionary *d in _arrayData) {
            if([[d objectForKey:@"name"] isEqualToString:str]){
                printf("will be deleted");
                [_arrayData removeObject:d];
                break;
            }
        }
        
        [_progressData removeObjectAtIndex:Id];
        [_arrayData addObject:updatedTask];
        
        if([[updatedTask objectForKey:@"status"] isEqualToString:@"progress"]){
            [_progressData addObject:updatedTask];
        }
        
        if([[updatedTask objectForKey:@"priority"] isEqualToString:@"high"]){
            [_highPriority addObject:updatedTask];
        }
        if([[updatedTask objectForKey:@"priority"] isEqualToString:@"mid"]){
            [_midPriority addObject:updatedTask];
        }
        if([[updatedTask objectForKey:@"priority"] isEqualToString:@"low"]){
            [_lowPriority addObject:updatedTask];
        }
    }
    
    if([[updatedTask objectForKey:@"status"] isEqualToString:@"done"]){
        [ProgressHUD colorHUD:[UIColor grayColor]];
        [ProgressHUD showSuccess:@"Well Done"];
        
    }
    
    [_uiTableView reloadData];
    [_arrayData writeToFile:_filePath atomically:YES];
    
}



#pragma mark : TableViewMethods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(isSectionEnabled){
        printf("three sections");
        return 3;
    }else{
        printf("one section");
        return 1;
    }
        
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(isSectionEnabled){
        switch (section) {
            case 0:
                return @"High Priority";
                break;
            case 1 :
                return @"Medium Priority";
                break;;
            case 2:
                return @"Low Priority";
                break;
            default:
                break;
        }
    }else{
        return @"All Tasks";
    }
    return @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(isSectionEnabled){
        switch (section) {
            case 0:
                return _highPriority.count;
                break;
            case 1:
                return _midPriority.count;
                break;
            case 2:
                return _lowPriority.count;
                break;
            default:
                break;
        }
    }
    
    return _progressData.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    UIView *view = [cell viewWithTag:1];
    view.layer.cornerRadius = view.layer.frame.size.height/2;

    if(isSectionEnabled){
        switch (indexPath.section) {
            case 0:
                view.backgroundColor = [UIColor redColor];
                cell.textLabel.text = [[_highPriority objectAtIndex:indexPath.row] objectForKey:@"name"];
                break;
            case 1:
                view.backgroundColor = [UIColor blueColor];
                cell.textLabel.text = [[_midPriority objectAtIndex:indexPath.row] objectForKey:@"name"];
                break;
            case 2:
                view.backgroundColor = [UIColor greenColor];
                cell.textLabel.text = [[_lowPriority objectAtIndex:indexPath.row] objectForKey:@"name"];

                break;
            default:
                break;
        }
    }else{
        NSString *state;
        cell.textLabel.text = [[_progressData objectAtIndex:indexPath.row] objectForKey:@"name"];
        state = [[_progressData objectAtIndex:indexPath.row] objectForKey:@"priority"];
        
        if([state isEqualToString:@"high"]){
            view.backgroundColor = [UIColor redColor];
        }else if([state isEqualToString:@"mid"]){
            view.backgroundColor = [UIColor blueColor];
        }else{
            view.backgroundColor = [UIColor greenColor];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"delete Task" message:@"Are you Sure you want to delete this task ?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            NSDictionary *dict;
            NSString *str;
            
            if(isSectionEnabled){
                switch (indexPath.section) {
                    case 0:
                        dict = [self->_highPriority objectAtIndex:indexPath.row];
                        str = [dict objectForKey:@"name"];
                        [self removeTaskFromArrayWithName:str];
                        [self->_highPriority removeObjectAtIndex:indexPath.row];
                        for (NSDictionary *dict in self->_progressData) {
                            if([[dict objectForKey:@"name"] isEqualToString:str]){
                                [self->_progressData removeObject:dict];
                                break;
                            }
                        }
                        break;
                    case 1:
                        dict = [self->_midPriority objectAtIndex:indexPath.row];
                        str = [dict objectForKey:@"name"];
                        [self removeTaskFromArrayWithName:str];
                        [self->_midPriority removeObjectAtIndex:indexPath.row];
                        for (NSDictionary *dict in self->_progressData) {
                            if([[dict objectForKey:@"name"] isEqualToString:str]){
                                [self->_progressData removeObject:dict];
                                break;
                            }
                        }
                        break;
                    case 2:
                        dict = [self->_lowPriority objectAtIndex:indexPath.row];
                        str = [dict objectForKey:@"name"];
                        [self removeTaskFromArrayWithName:str];
                        [self->_lowPriority removeObjectAtIndex:indexPath.row];
                        for (NSDictionary *dict in self->_progressData) {
                            if([[dict objectForKey:@"name"] isEqualToString:str]){
                                [self->_progressData removeObject:dict];
                                break;
                            }
                        }
                        break;
                    default:
                        break;
                }
            }else{
                printf("section not enabled");
                dict =  [self->_progressData objectAtIndex:indexPath.row];
                str = [dict objectForKey:@"name"];
                               
                [self removeTaskFromArrayWithName:str];
                [self->_progressData removeObjectAtIndex:indexPath.row];
                
                NSString *prior = [dict objectForKey:@"priority"];
                if([prior isEqualToString:@"high"]){
                    for (NSDictionary *d in self->_highPriority) {
                        if([[d objectForKey:@"priority"] isEqualToString:prior]){
                            [self->_highPriority removeObject:d];
                            break;
                        }
                    }
                }else if([prior isEqualToString:@"mid"]){
                    for (NSDictionary *d in self->_midPriority) {
                        if([[d objectForKey:@"priority"] isEqualToString:prior]){
                            [self->_highPriority removeObject:d];
                            break;
                        }
                    }
                }else if([prior isEqualToString:@"low"]){
                    for (NSDictionary *d in self->_lowPriority) {
                        if([[d objectForKey:@"priority"] isEqualToString:prior]){
                            [self->_highPriority removeObject:d];
                            break;
                        }
                    }
                }
            }
            [self->_arrayData writeToFile:self->_filePath atomically:YES];
            [self->_uiTableView reloadData];
        }];

        
        
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            printf("no delete");
        }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [self presentViewController:alert animated:yes completion:nil];

    }
}

-(void)removeTaskFromArrayWithName:(NSString*) str{
    for (NSDictionary *dic in self->_arrayData) {
        if([[dic objectForKey:@"name"] isEqualToString:str]){
            [self->_arrayData removeObject:dic];
            break;
        }
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    DetailsViewController *detailsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    detailsVc.delegate = self;
    detailsVc.caller = progress;
    detailsVc.Id = indexPath.row;
    detailsVc.section = indexPath.section;
    
    
    if(isSectionEnabled){
        switch (indexPath.section) {
            case 0:
                detailsVc.data = [_highPriority objectAtIndex:indexPath.row];
                break;
            case 1:
                detailsVc.data = [_midPriority objectAtIndex:indexPath.row];
                break;
            case 2:
                detailsVc.data = [_lowPriority objectAtIndex:indexPath.row];
                break;
            default:
                break;
        }
    }else{
        detailsVc.data = [_progressData objectAtIndex:indexPath.row];
    }
    [self presentViewController:detailsVc animated:YES completion:nil];
}

@end
