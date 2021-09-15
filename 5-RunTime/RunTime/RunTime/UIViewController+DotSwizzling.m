//
//  UIViewController+DotSwizzling.m
//  RunTime
//
//  Created by Red-Fish on 2021/9/1.
//

#import "UIViewController+DotSwizzling.h"
#import <objc/runtime.h>

@implementation UIViewController (DotSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(swizzling_viewwillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)swizzling_viewwillAppear:(BOOL)aniamated {
    if ([self isKindOfClass:[UIViewController class]]) {
        NSLog(@"页面统计");
    }
    
    [self swizzling_viewwillAppear:aniamated];
}

@end
