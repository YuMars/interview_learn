//
//  UIViewController+Swizzling.m
//  RunTime
//
//  Created by Red-Fish on 2021/8/31.
//

#import "UIViewController+Swizzling.h"

#import <objc/runtime.h>

@implementation UIViewController (Swizzling)
 
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(originalSelector);
        SEL swizzlingSelector = @selector(swizzlingSelector);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzlingMehthod = class_getInstanceMethod(class, swizzlingSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzlingMehthod), method_getTypeEncoding(swizzlingMehthod));
        
        if (didAddMethod) {
            class_replaceMethod(class, swizzlingSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzlingMehthod);
        }
    });
}

- (void)originalSelector {
    NSLog(@"11111%@", NSStringFromSelector(_cmd));
}

- (void)swizzlingSelector {
    NSLog(@"22222%@", NSStringFromSelector(_cmd));
}

@end
