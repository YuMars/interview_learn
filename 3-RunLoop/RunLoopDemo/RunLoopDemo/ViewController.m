//
//  ViewController.m
//  RunLoopDemo
//
//  Created by Red-Fish on 2021/8/16.
//

#import "ViewController.h"
#import <CoreFoundation/CoreFoundation.h>
@interface ViewController ()

@property (nonatomic, strong) NSThread *thread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100.0, 100.01, 100.01, 100.0)];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
//    [self runFun];
//    [self sameTimer];
    
//    [self runloopObserver];
    [self threadResident];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(run2) onThread:self.thread withObject:nil waitUntilDone:NO];
}

/// 线程常驻
- (void)threadResident {
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadResidentFunc) object:nil];
    [self.thread start];
}

- (void)threadResidentFunc {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"%@ did Start", NSStringFromSelector(_cmd));
}

- (void)run2 {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)runloopObserver {
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到Observer：%@的活动：%lu", observer, activity);
    });
    
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    CFRelease(observer);
}

- (void)buttonAction {
    NSLog(@"buttonAction");
}

- (void)runFun {
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(runTimer) userInfo:nil repeats:YES];
    
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)runTimer {
    NSLog(@"runnnnnn");
}

- (void)walkTimer {
    NSLog(@"walkkkk");
}

- (void)sameTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(walkTimer) userInfo:nil repeats:YES];
}

@end
