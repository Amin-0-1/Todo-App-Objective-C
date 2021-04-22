//
//  InProgressViewController.h
//  TodoApp
//
//  Created by Amin on 06/04/2021.
//

#import <UIKit/UIKit.h>
#import "IAddTask.h"
NS_ASSUME_NONNULL_BEGIN

@interface InProgressViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,IAddTask>

@end

NS_ASSUME_NONNULL_END
