//
//  main.m
//  RunLoopDemo
//
//  Created by Red-Fish on 2021/8/16.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

int lieMian(int argc, char * argv[]) {
    BOOL running = YES;
    do {
        
    } while (running);
    
    return 0;
}
