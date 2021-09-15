//
//  URLSessionTaskSwizzling.h
//  RunTime
//
//  Created by Red-Fish on 2021/8/31.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

static inline void _swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline bool _addMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector, method_getImplementation(method), method_getTypeEncoding(method));
}

@interface URLSessionTaskSwizzling : NSObject

@end

NS_ASSUME_NONNULL_END
