//
//  DetailsViewController.h
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import <UIKit/UIKit.h>
#import "IAddTask.h"
#import "MyStatus.h"
NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController <IAddTask>
    @property NSDictionary *data;
    @property NSInteger Id;
    @property NSInteger section;
    @property Caller caller;
    @property id <IAddTask> delegate;
@end

NS_ASSUME_NONNULL_END
