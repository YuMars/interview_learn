//
//  UIButton+RepeatClick.m
//  RunTime
//
//  Created by Red-Fish on 2021/9/1.
//

#import "UIButton+RepeatClick.h"
#import <objc/runtime.h>

@interface UIButton ()

@property (nonatomic, assign) NSTimeInterval swizzled_acceptEventInterval;
@property (nonatomic, assign) NSTimeInterval swizzled_lastTimeClick;

@end

@implementation UIButton (RepeatClick)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(sendAction:to:forEvent:);
        SEL swizzledSeelctor = @selector(swizzled_sendAction:to:forEvent:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSeelctor);
        
        if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod(class, swizzledSeelctor, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)swizzled_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.swizzled_acceptEventInterval <= 0) {
        self.swizzled_acceptEventInterval = 0.4;
    }
    
    BOOL needSendAction = (NSDate.date.timeIntervalSince1970 - self.swizzled_lastTimeClick) >= self.swizzled_acceptEventInterval;
    
    // 更新上一次点击时间戳
    if (self.swizzled_acceptEventInterval > 0) {
        self.swizzled_lastTimeClick = NSDate.date.timeIntervalSince1970;
    }
    
    // 两次点击的时间间隔小于设定的时间间隔时，才执行响应事件
    if (needSendAction) {
        [self swizzled_sendAction:action to:target forEvent:event];
    }
}

- (NSTimeInterval)swizzled_acceptEventInterval {
    return [objc_getAssociatedObject(self, @"UIButton_acceptEvenInterval") doubleValue];
}

- (void)setSwizzled_acceptEventInterval:(NSTimeInterval)swizzled_acceptEventInterval {
    objc_setAssociatedObject(self, @"UIButton_acceptEvenInterval", @(swizzled_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)swizzled_lastTimeClick {
    return [objc_getAssociatedObject(self, @"UIButton_lastTimeClick") doubleValue];
}

- (void)setSwizzled_lastTimeClick:(NSTimeInterval)swizzled_lastTimeClick {
    objc_setAssociatedObject(self, @"UIButton_lastTimeClick", @(swizzled_lastTimeClick), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
