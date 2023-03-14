//
//  HitTestView.m
//  TouchEvent
//
//  Created by Red-Fish on 2023/3/13.
//

#import "HitTestView.h"

@implementation HitTestView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 1.视图可交互、未隐藏
    if (self.userInteractionEnabled == NO ||
        self.hidden == YES ||
        self.alpha <= 0.01) {
        return nil;
    }
    
    // 2.判断点击事件在视图内
    if ([self pointInside:point withEvent:event] == NO) {
        return nil;
    }
    
    // 3.已经确定当前视图可以响应的前提下，询问子视图
    NSUInteger count = self.subviews.count;
    for (int i = 0; i < count; i++) {
        UIView *childV = self.subviews[i];
        CGPoint childPoint = [self convertPoint:point toView:childV];
        UIView *fitView = [childV hitTest:childPoint withEvent:event];
        
        if (fitView) {
            return fitView;
        }
    }
    
    return self;
}

@end
