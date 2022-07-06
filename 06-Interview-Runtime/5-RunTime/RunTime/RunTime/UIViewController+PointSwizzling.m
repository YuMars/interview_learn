//
//  UIViewController+PointSwizzling.m
//  RunTime
//
//  Created by Red-Fish on 2021/8/31.
//

#import "UIViewController+PointSwizzling.h"

#import <objc/runtime.h>

typedef IMP *IMPPointer;

/// 交换方法函数
static void MethodSwizzle(id self, SEL _cmd, id arg1);

/// 原始方法函数指针
static void (*MethodOriginal)(id self, SEL _cmd, id arg1);

/// 交换方法
static void MethodSwizzle(id self, SEL _cmd, id arg1) {
    NSLog(@"swizzling");
    MethodOriginal(self, _cmd, arg1);
}

BOOL class_swizzleMethodAndStore(Class class, SEL originalSelector, IMP replacement, IMPPointer store) {
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, originalSelector);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, originalSelector, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    if (imp && store) {
        *store = imp;
    }
    return (imp != NULL);
}

@implementation UIViewController (PointSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzle:@selector(originalFunc) with:(IMP)MethodSwizzle store:(IMP *)&MethodOriginal];
    });
}

+ (BOOL)swizzle:(SEL)original with:(IMP)replacement store:(IMPPointer)store {
    return class_swizzleMethodAndStore(self, original, replacement, store);
}

- (void)originalFunc {
    NSLog(@"111%@", NSStringFromSelector(_cmd));
}

@end
