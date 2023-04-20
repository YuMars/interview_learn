//
//  ViewController.m
//  19-卡顿优化
//
//  Created by Red-Fish on 2023/4/19.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) CFRunLoopRef runloop;
@property (nonatomic, assign) CFRunLoopObserverRef enterObserver;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRunloopObserver];
    
    // 创建观察者
//        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
//            NSLog(@"监听到RunLoop发生改变---%zd",activity);
//        });
//
//        // 添加观察者到当前RunLoop中
//        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
//
//        // 释放observer，最后添加完需要释放掉
//        CFRelease(observer);
}

- (void)setupRunloopObserver{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.runloop = CFRunLoopGetCurrent();
        
        self.enterObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                                     kCFRunLoopAllActivities,
                                               true,
                                               -0x7FFFFFFF,
                                               BBRunloopObserverCallBack, NULL);
        CFRunLoopAddObserver(self.runloop, self.enterObserver, kCFRunLoopCommonModes);
//        CFRelease(enterObserver);
    });
}

static void BBRunloopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry: {
            NSLog(@"enter runloop...");
        }
            break;
        case kCFRunLoopExit: {
            NSLog(@"leave runloop...");
        }
            break;
        default: break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"");
}

@end
