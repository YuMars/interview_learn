//
//  ViewController.m
//  07-Interview-Runloop
//
//  Created by Red-Fish on 2022/4/18.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSThread *thread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self initRunloop];
    // [self timerOptimize];
    [self threadKeepAlive];
    
    [self performSelector:@selector(funRun) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)threadKeepAlive {
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(testRun) object:nil];
    [self.thread start];
}

- (void)testRun {
    NSLog(@"%@ %@ ", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // 添加source0、source1、timer、observer
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"end");
}



- (void)funRun {
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer
    * _Nonnull timer) {
     NSLog(@"timer 定时任务");
    }];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runloop run];
}

// NStimer在滑动时候优化
- (void)timerOptimize {
    static int count = 0;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"%d", ++count);
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    // UITrackingRunLoopMode、NSDefaultRunLoopMode是真正的模式
    // NSRunLoopCommonModes不是真正的模式，只是一个标记,表示在上面两种模式下运行
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    // 直接开启定时器
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"%d", ++count);
    }];
}

/// 初始化、使用runloop
- (void)initRunloop {
    // 当前线程
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    CFRunLoopRef ref = CFRunLoopGetCurrent();
    
    // 主线程runloop
    [NSRunLoop mainRunLoop];
    CFRunLoopGetMain();
    // 创建observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, runLoopObserverCallBack, NULL);
    
    // 添加observer
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    CFRelease(observer);
    
    // RunLoop
    
//    CFRunLoopPerformBlock(<#CFRunLoopRef rl#>, <#CFTypeRef mode#>, <#^(void)block#>)
}

void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry: NSLog(@"kCFRunLoopEntry"); break;
        case kCFRunLoopBeforeTimers: NSLog(@"kCFRunLoopBeforeTimers"); break;
        case kCFRunLoopBeforeSources: NSLog(@"kCFRunLoopBeforeSources"); break;
        case kCFRunLoopBeforeWaiting: NSLog(@"kCFRunLoopBeforeWaiting"); break;
        case kCFRunLoopAfterWaiting: NSLog(@"kCFRunLoopAfterWaiting"); break;
        case kCFRunLoopExit: NSLog(@"kCFRunLoopExit"); break;
        default: break;
    }
}


@end
