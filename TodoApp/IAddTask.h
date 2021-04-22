//
//  IAddTask.h
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IAddTask <NSObject>
-(void) receiveTask:(NSDictionary *) newTask;
-(void) recieveUpdateTask:(NSDictionary *) updatedTask withID:(NSInteger)Id andSection:(NSInteger)section;
@end

NS_ASSUME_NONNULL_END
