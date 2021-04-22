//
//  TodoViewController.m
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import "TodoViewController.h"
#import "AddTaskViewController.h"
#import "DetailsViewController.h"

@interface TodoViewController ()

    @property (weak, nonatomic) IBOutlet UINavigationItem *uiNavBar;
    @property (weak, nonatomic) IBOutlet UISearchBar *uiSearch;
    @property (weak, nonatomic) IBOutlet UITableView *uiTableView;

@end

@implementation TodoViewController

NSMutableArray *arrayData;
NSMutableArray *todoData;
NSMutableArray *filteredData;
NSString *filePath;
Boolean isFiltered;
Boolean loggedIn;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    isFiltered = NO;
    loggedIn = [self checkFirstTimeUser];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addTaskSelector)];
    _uiNavBar.rightBarButtonItem = barBtn;
    
    UIBarButtonItem *clear = [[UIBarButtonItem alloc]initWithTitle:@"Clear all" style:UIBarButtonItemStyleDone target:self action:@selector(clearAll)];
    _uiNavBar.leftBarButtonItem = clear;
    
    [self getPlistData];
    [self clearBtnState];
    
}

-(void)clearBtnState{
    if (arrayData.count == 0) {
        [_uiNavBar.leftBarButtonItem setEnabled:false];
    }else{
        [_uiNavBar.leftBarButtonItem setEnabled:true];
    }
}
-(Boolean)checkFirstTimeUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *state = [defaults objectForKey:@"loggedIn"];
    if(state == nil){
        printf("not logged in----------------------------------");
        [defaults setObject:@"true" forKey:@"loggedIn"];
        return NO;
    }else{
        return YES;
    }
}
-(void)addTaskSelector{
    AddTaskViewController *addVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTaskViewController"];
    addVC.delegate = self;
    
    addVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:addVC animated:YES completion:nil];
}

-(void)clearAll{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Tasks" message:@"Are you Sure you want to delete all Tasks ?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        printf("Clear all");
        [arrayData removeAllObjects];
        [arrayData writeToFile:filePath atomically:YES];
        
        [todoData removeAllObjects];
        [self->_uiTableView reloadData];
        [self clearBtnState];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:yes completion:nil];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // search in table view and reload
    if(searchText.length != 0){
        isFiltered = YES;
        
        filteredData = [NSMutableArray new];
        for (int i=0; i<todoData.count; i++) {
            NSString *name = [[todoData objectAtIndex:i] objectForKey:@"name"];
            NSString *state = [[todoData objectAtIndex:i] objectForKey:@"status"];
            if([name containsString:searchText] && [state isEqualToString:@"todo"]){
                [filteredData addObject:[todoData objectAtIndex:i]];
            }
        }
    }else{
        isFiltered = NO;
        [filteredData removeAllObjects];
    }
    [_uiTableView reloadData];
}

-(void) addDictinaryToPlist{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@"mahmoud" forKey:@"name"];
    [dict setObject:@"this is desc" forKey:@"description"];
    [dict setObject:@"low" forKey:@"priority"];
    [dict setObject:@"2000" forKey:@"date"];
    [dict setObject:@"todo" forKey:@"status"];
    arrayData = [NSMutableArray new];
    [arrayData addObject:dict];
    [arrayData writeToFile:filePath atomically:YES];
    [arrayData removeObject:arrayData.firstObject];
    [arrayData writeToFile:filePath atomically:YES];
    loggedIn = YES;
}
-(void)getPlistData{
    // plist path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    filePath = [documentFolder stringByAppendingFormat:@"Tasks.plist"];
        
    if(!loggedIn){
        [self addDictinaryToPlist]; // first time using the app
    }
    
    
    // load data in array
    arrayData = [NSMutableArray arrayWithContentsOfFile:filePath];
    todoData = [[NSMutableArray alloc] initWithArray:arrayData];
    
    //     remove from the array any dict which status isn't 'todo'
    for (NSDictionary *dict in arrayData) {
        if(![[dict objectForKey:@"status"] isEqualToString:@"todo"]){
            [todoData removeObject:dict];
        }
    }
    
}


#pragma mark:: SendDataBackwared_addTask
- (void)receiveTask:(NSDictionary *)newTask{   

    [arrayData addObject:newTask];
    [todoData addObject:newTask];
        
    [arrayData writeToFile:filePath atomically:YES];
    [_uiTableView reloadData];
    [self getPlistData];
    [self clearBtnState];
}

- (void)recieveUpdateTask:(NSDictionary *)updatedTask withID:(NSInteger)Id andSection:(NSInteger)section{
    if(isFiltered){
        
        NSDictionary *dict =  [filteredData objectAtIndex:Id];
        NSString *str = [dict objectForKey:@"name"];
        
       
        for (NSDictionary *dic in arrayData) {
            if([[dic objectForKey:@"name"] isEqualToString:str]){
                printf("will be deleted");
                [arrayData removeObject:dic];
                
                break;
            }
        }
        
        [filteredData removeObject:dict];
        [filteredData addObject:updatedTask];
        
        // if updated to progress or done , not add in array
        if([[updatedTask objectForKey:@"status"] isEqualToString:@"todo"]){
            [todoData addObject:updatedTask];
        }
        
    }else{

        NSDictionary *dict =  [todoData objectAtIndex:Id];
        NSString *str = [dict objectForKey:@"name"];
        
        for (NSDictionary *d in arrayData) {
            if([[d objectForKey:@"name"] isEqualToString:str]){
                printf("will be deleted");
                [arrayData removeObject:d];
                break;
            }
        }
        
        [todoData removeObjectAtIndex:Id];
        [arrayData addObject:updatedTask];
        
        if([[updatedTask objectForKey:@"status"] isEqualToString:@"todo"]){
            [todoData addObject:updatedTask];
        }
        
    }
    
    [_uiTableView reloadData];
    [arrayData writeToFile:filePath atomically:YES];
}


#pragma mark: TableViewMethods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(isFiltered)
        return filteredData.count;
    else
        return todoData.count;
//        return arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIView *view = [cell viewWithTag:1];
    view.layer.cornerRadius = view.layer.frame.size.height/2;
    
    NSString *state;
    if(isFiltered){
        cell.textLabel.text = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"name"];
        state = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"priority"];
        printf("is filtered 130 %s\n",[state UTF8String]);
    }else{
        cell.textLabel.text = [[todoData objectAtIndex:indexPath.row] objectForKey:@"name"];
        state = [[todoData objectAtIndex:indexPath.row] objectForKey:@"priority"];
        printf("is not filtered 134 %s\n",[state UTF8String]);
    }
    
    if([state isEqualToString:@"high"]){
        view.backgroundColor = [UIColor redColor];
    }else if([state isEqualToString:@"mid"]){
        view.backgroundColor = [UIColor blueColor];
    }else{
        view.backgroundColor = [UIColor greenColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"delete Task" message:@"Are you Sure you want to delete this task ?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            printf("delete");
            
            if (isFiltered) {
                
                NSDictionary *obj = [filteredData objectAtIndex:indexPath.row];
                NSString *str = [obj objectForKey:@"name"];
            
                
                for (NSDictionary *dict in todoData) {
                    if([[dict objectForKey:@"name"] isEqualToString:str]){
                        [todoData removeObject:dict];
                    }
                }
                
                for (NSDictionary *dict in arrayData) {
                    if([[dict objectForKey:@"name"] isEqualToString:str]){
                        [arrayData removeObject:dict];
                    }
                }
                
                [filteredData removeObject:obj];
            }else{
                
            
                NSDictionary *dict =  [todoData objectAtIndex:indexPath.row];
                NSString *str = [dict objectForKey:@"name"];
                
                [todoData removeObjectAtIndex:indexPath.row];
                               
                for (NSDictionary *dic in arrayData) {
                    if([[dic objectForKey:@"name"] isEqualToString:str]){
                        [arrayData removeObject:dic];
                        break;
                    }
                }

            }
            
            [arrayData writeToFile:filePath atomically:YES];
            [self->_uiTableView reloadData];
            [self clearBtnState];
        }];
        
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            printf("no delete");
        }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [self presentViewController:alert animated:yes completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailsViewController *detailsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    detailsVc.delegate = self;
    detailsVc.caller = todo;
    if(isFiltered){
        detailsVc.data = [filteredData objectAtIndex:indexPath.row];
        detailsVc.Id = indexPath.row ;
    }else{
        detailsVc.data = [todoData objectAtIndex:indexPath.row];
        detailsVc.Id = indexPath.row;
    }
    [self presentViewController:detailsVc animated:YES completion:nil];
}




@end

