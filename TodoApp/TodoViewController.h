//
//  TodoViewController.h
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import <UIKit/UIKit.h>
#import "IAddTask.h"
NS_ASSUME_NONNULL_BEGIN

@interface TodoViewController : UIViewController <UISearchBarDelegate,UITabBarDelegate,UITableViewDelegate,UITableViewDataSource,IAddTask>

@end

NS_ASSUME_NONNULL_END
