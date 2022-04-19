//
//  ViewController.m
//  07-Interview-Runloop
//
//  Created by Red-Fish on 2022/4/18.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
