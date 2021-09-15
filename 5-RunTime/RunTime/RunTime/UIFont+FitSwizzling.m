//
//  UIFont+FitSwizzling.m
//  RunTime
//
//  Created by Red-Fish on 2021/9/1.
//

#import "UIFont+FitSwizzling.h"
#import <objc/runtime.h>

@implementation UIFont (FitSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(systemFontOfSize:);
        SEL swizzledSelector = @selector(swizzling_systemFontSize:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else{
            method_exchangeImplementations(class_getInstanceMethod(class, originalSelector), swizzledMethod);
        }
    });
}

+ (UIFont *)swizzling_systemFontSize:(CGFloat)fontSize {
    UIFont *font = [UIFont swizzling_systemFontSize:fontSize * [UIScreen mainScreen].bounds.size.width / 375.0];
    return font;
}

@end
