//
//  AddTaskViewController.h
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import <UIKit/UIKit.h>
#import "IAddTask.h"
NS_ASSUME_NONNULL_BEGIN

@interface AddTaskViewController : UIViewController
    @property id <IAddTask> delegate;
@end

NS_ASSUME_NONNULL_END
