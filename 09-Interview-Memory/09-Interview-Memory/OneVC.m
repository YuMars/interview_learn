//
//  OneVC.m
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import "OneVC.h"
#import "Proxy.h"

@interface OneVC ()

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation OneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 以下代码会有循环引用
    {
//        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkTest)];
//        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTest) userInfo:nil repeats:YES];
    }
    
    // Proxy解决
    {
        self.link = [CADisplayLink displayLinkWithTarget:[Proxy proxyWithTarget:self] selector:@selector(linkTest)];
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[Proxy proxyWithTarget:self] selector:@selector(timerTest) userInfo:nil repeats:YES];
    }
    
}

- (void)linkTest {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)timerTest {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)dealloc {
    [self.link invalidate];
    [self.timer invalidate];
    self.timer = nil;
}


@end
