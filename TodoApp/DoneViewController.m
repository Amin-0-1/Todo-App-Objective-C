//
//  DoneViewController.m
//  TodoApp
//
//  Created by Amin on 06/04/2021.
//

#import "DoneViewController.h"
#import "DetailsViewController.h"

@interface DoneViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *uiTableView;
    @property NSMutableArray *arrayData;
    @property NSMutableArray *doneData;
    @property NSString *filePath;
    @property Boolean isSectionEnabled;

    @property NSMutableArray *highPriority;
    @property NSMutableArray *lowPriority;
    @property NSMutableArray *midPriority;

@end

@implementation DoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isSectionEnabled = NO;
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
    _doneData = [NSMutableArray arrayWithArray:_arrayData];

    for (NSDictionary *dict in _arrayData) {
        if(![[dict objectForKey:@"status"] isEqualToString:@"done"]){
            [_doneData removeObject:dict];
        }
    }
    [_uiTableView reloadData];

}

- (IBAction)uiSwitch:(id)sender {
    _isSectionEnabled = !_isSectionEnabled;
    
    if(_isSectionEnabled){
        _lowPriority = [NSMutableArray new];
        _midPriority = [NSMutableArray new];
        _highPriority = [NSMutableArray new];
        for (NSDictionary *dict in _doneData) {
            if([[dict objectForKey:@"priority"] isEqualToString:@"low"]){
                [_lowPriority addObject:dict];
            }else if([[dict objectForKey:@"priority"] isEqualToString:@"mid"]){
                [_midPriority addObject:dict];
            }else if([[dict objectForKey:@"priority"] isEqualToString:@"high"]){
                [_highPriority addObject:dict];
            }
        }
    }
    [_uiTableView reloadData];
}


#pragma mark: TableViewMethods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_isSectionEnabled){
        return 3;
    }else
        return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(_isSectionEnabled){
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
    if(_isSectionEnabled){
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
    
    return _doneData.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [[_doneData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    UIView *view = [cell viewWithTag:1];
    view.layer.cornerRadius = view.layer.frame.size.height/2;
    
    if(_isSectionEnabled){
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
        state = [[_doneData objectAtIndex:indexPath.row] objectForKey:@"priority"];
        
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
            printf("delete");
            NSDictionary *dict;
            NSString *str;
            
            if(self->_isSectionEnabled){
                switch (indexPath.section) {
                    case 0:
                        dict = [self->_highPriority objectAtIndex:indexPath.row];
                        str = [dict objectForKey:@"name"];
                        [self removeTaskFromArrayWithName:str];
                        [self->_highPriority removeObjectAtIndex:indexPath.row];
                        for (NSDictionary *dict in self->_doneData) {
                            if([[dict objectForKey:@"name"] isEqualToString:str]){
                                [self->_doneData removeObject:dict];
                                break;
                            }
                        }
                        break;
                    case 1:
                        dict = [self->_midPriority objectAtIndex:indexPath.row];
                        str = [dict objectForKey:@"name"];
                        [self removeTaskFromArrayWithName:str];
                        [self->_midPriority removeObjectAtIndex:indexPath.row];
                        for (NSDictionary *dict in self->_doneData) {
                            if([[dict objectForKey:@"name"] isEqualToString:str]){
                                [self->_doneData removeObject:dict];
                                break;
                            }
                        }
                        break;
                    case 2:
                        dict = [self->_lowPriority objectAtIndex:indexPath.row];
                        str = [dict objectForKey:@"name"];
                        [self removeTaskFromArrayWithName:str];
                        [self->_lowPriority removeObjectAtIndex:indexPath.row];
                        for (NSDictionary *dict in self->_doneData) {
                            if([[dict objectForKey:@"name"] isEqualToString:str]){
                                [self->_doneData removeObject:dict];
                                break;
                            }
                        }
                        break;
                    default:
                        break;
                }
            }else{
                printf("section not enabled");
                dict =  [self->_doneData objectAtIndex:indexPath.row];
                str = [dict objectForKey:@"name"];
                               
                [self removeTaskFromArrayWithName:str];
                [self->_doneData removeObjectAtIndex:indexPath.row];
                
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
    detailsVc.caller = done;
    detailsVc.data = [_doneData objectAtIndex:indexPath.row];
    detailsVc.Id = indexPath.row;
    

    [self presentViewController:detailsVc animated:YES completion:nil];
}



@end
