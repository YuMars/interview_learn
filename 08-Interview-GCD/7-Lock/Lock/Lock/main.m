//
//  main.m
//  Lock
//
//  Created by Red-Fish on 2021/10/27.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        @synchronized (appDelegateClassName) {
            
        }
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
