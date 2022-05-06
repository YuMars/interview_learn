//
//  ViewController.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/20.
//

#import "ViewController.h"
#import "BaseBusiness.h"
#import "OSSpinLockBusniess.h"
#import "OSUnfairLockBusiness.h"
#import "PthreadmutexLockBusiness.h"
#import "PthreadmutexLock3Business.h"
#import "NSConditionLockBusiniess.h"

@interface ViewController ()

@property (nonatomic, strong) NSThread *thread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    BaseBusiness *demo = [[BaseBusiness alloc] init];
//    [demo businessBank];
//    [demo saleTickets];
    
    NSConditionLockBusiniess *demo = [[NSConditionLockBusiniess alloc] init];
    [demo otherTest];
    
//    self.thread = [[NSThread alloc] initWithBlock:^{
//        NSLog(@"1111");
//
//
//        sleep(10);
//        NSLog(@"222");
//    }];
//    [self.thread start];
    
//        self.thread = [[NSThread alloc] initWithBlock:^{
//            NSLog(@"1111");
//
//
//            [self performSelector:@selector(doNothing) withObject:nil afterDelay:5.0];
//            NSLog(@"222");
//        }];
//        [self.thread start];
}

- (void)doNothing {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //[self interview5];
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO]; // 无法执行。哪怕sleep
    
    //[self interview6];
   
    //[self dispatchGroup];
}

- (void)dispatchGroup {
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务1------%@",[NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务2------%@",[NSThread currentThread]);
        }
    });
    
    // 任务1、2执行完后再执行任务3
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务3------%@",[NSThread currentThread]);
        }
    });
}

- (void)test {
    NSLog(@"2");
}

- (void)interview6 {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1");
    }];
    
    [thread start];
    [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
    // 1 然后崩溃，原因是thread线程已经退出
}

- (void)interview5 {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        NSLog(@"1");
        // 往runloop里面添加timer
        [self performSelector:@selector(test) withObject:nil afterDelay:0.0];
        NSLog(@"3");
        
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode: NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });
    
    // 1 3 performSelector:withObject:afterDelay本质是往runloop添加定时器
}

- (void)interview1 {
    NSLog(@"执行任务1");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"执行任务2");
    });
    NSLog(@"执行任务3");
    
    // 死锁
}

- (void)interview2 {
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
    });
    NSLog(@"执行任务3");
    
    // 1 3 2
}

- (void)interview3 {
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
        
        dispatch_sync(queue, ^{
            NSLog(@"执行任务3");
        });
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
    
    // 1 5 2 死锁
}

- (void)interview4 {
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
        
        dispatch_sync(queue2, ^{
            NSLog(@"执行任务3");
        });
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
    
    // 1 5 2 3 4
}


@end
