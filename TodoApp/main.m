//
//  main.m
//  TodoApp
//
//  Created by Amin on 05/04/2021.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
