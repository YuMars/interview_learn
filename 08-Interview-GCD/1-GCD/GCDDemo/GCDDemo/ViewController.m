//
//  ViewController.m
//  GCDDemo
//
//  Created by Red-Fish on 2021/8/3.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) int ticketSurplusCount;
@property (nonatomic, strong) dispatch_semaphore_t semaphoreLock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTicketStatusSave];
}

/// 同步执行+并发队列
- (void)syncWithConcurrentQueue {
    
    NSLog(@"currentThread %@", [NSThread currentThread]);
    
    NSLog(@"sync concurrent start.");
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.gcd.concurrentQuquq", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 %@", [NSThread currentThread]);
    });
    
    NSLog(@"4");
}

/// 同步执行+串行队列
- (void)syncWithSerialQueue {
    NSLog(@"currentThread %@", [NSThread currentThread]);
    
    NSLog(@"sync concurrent start.");
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.gcd.concurrentQuquq", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 %@", [NSThread currentThread]);
    });
    
    NSLog(@"4");
}

/// 异步执行+串行队列
- (void)asyncWithSerialQueue {
    NSLog(@"currentThread %@", [NSThread currentThread]);
    
    NSLog(@"sync concurrent start.");
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.gcd.concurrentQuquq", DISPATCH_QUEUE_SERIAL);
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 %@", [NSThread currentThread]);
    });
    
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 %@", [NSThread currentThread]);
    });
    
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 %@", [NSThread currentThread]);
    });
    
    NSLog(@"4");
}

/// 异步执行+并发队列
- (void)asyncWithConcurrentQueue {
    NSLog(@"currentThread %@", [NSThread currentThread]);
    
    NSLog(@"sync concurrent start.");
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.gcd.concurrentQuquq", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 %@", [NSThread currentThread]);
    });
    
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 %@", [NSThread currentThread]);
    });
    
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 %@", [NSThread currentThread]);
    });
    
    NSLog(@"4");
}

/// 同步执行+主队列
- (void)snycWithMainQueue {
    NSLog(@"currentThread %@", [NSThread currentThread]);
    
    NSLog(@"sync concurrent start.");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 %@", [NSThread currentThread]);
    });
    
    NSLog(@"4");
}

/// 异步主线程
- (void)asyncMain {
    NSLog(@"currentThread %@", [NSThread currentThread]);
    
    NSLog(@"sync concurrent start.");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 %@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 %@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 %@", [NSThread currentThread]);
    });
    
    NSLog(@"4");
}

/// 线程间通信
- (void)threadCommunication {
    // 全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1 ----- %@", [NSThread currentThread]);
        
        dispatch_async(mainQueue, ^{
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2 ----- %@", [NSThread currentThread]);
        });
    });
}

/// 栅栏方法 dispatch_barrier_async
- (void)barrier {
    dispatch_queue_t queue = dispatch_queue_create("com.test.gcd", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 ---- %@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 ---- %@", [NSThread currentThread]);
    });
    
    dispatch_barrier_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 ---- %@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"4 ---- %@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"5 ---- %@", [NSThread currentThread]);
    });
}

/// 延时执行方法
- (void)dispatchAfter {
    NSLog(@"currentThread --- %@", [NSThread currentThread]);
    
    NSLog(@"1");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"2 ----- %@", [NSThread currentThread]);
    });
    
    NSLog(@"3");
}

- (void)dispatchOnce {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"1");// 只执行一次
    });
}

- (void)dispatchApply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"1");
    
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd --- %@", index, [NSThread currentThread]);
    });
    
    NSLog(@"2");
}

- (void)dispatchGroupNotify {
    NSLog(@"currentThread ----- %@", [NSThread currentThread]);
    
    NSLog(@"1");
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 ----- %@", [NSThread currentThread]);
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 ----- %@", [NSThread currentThread]);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"4 ----- %@", [NSThread currentThread]);
    });
    
    NSLog(@"5");
}

/// 队列组
- (void)dispatchGroupWait {
    NSLog(@"currentThread ----- %@", [NSThread currentThread]);
    
    NSLog(@"1");
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 ---- %@", [NSThread currentThread]);
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 ---- %@", [NSThread currentThread]);
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"4");
}

/// 队列组
- (void)dispatchEnterAndLeave {
    NSLog(@"currentThread ----- %@", [NSThread currentThread]);
    
    NSLog(@"1");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 ----- %@", [NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"3 ----- %@", [NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"4 ----- %@", [NSThread currentThread]);
    });
    
    NSLog(@"5");
}

/// semaphore 线程同步
- (void)semaphoreSync {
    NSLog(@"currentThread ----- %@", [NSThread currentThread]);
    
    NSLog(@"1");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block int num = 0;
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        
        NSLog(@"2 ----- %@", [NSThread currentThread]);
        
        num = 100;
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"3 ----, num = %d", num);
}

/// 非线程安全：不使用semaphore
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread ----- %@", [NSThread currentThread]);
    
    NSLog(@"1");
    
    self.ticketSurplusCount = 50;
    
    // queue1 窗口1卖火车票
    dispatch_queue_t queue1 = dispatch_queue_create("com.test.gcd1", DISPATCH_QUEUE_SERIAL);
    
    // queue2 窗口2卖火车票
    dispatch_queue_t queue2 = dispatch_queue_create("com.test.gcd2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketNotSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketNotSafe];
    });
}

/**
 * 售卖火车票（非线程安全）
 */
- (void)saleTicketNotSafe {
    while (1) {
        if (self.ticketSurplusCount > 0) {  // 如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { // 如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
        
    }
}

/// 线程安全
- (void)initTicketStatusSave {
    NSLog(@"currentThread ----- %@", [NSThread currentThread]);
    
    NSLog(@"1");
    _semaphoreLock = dispatch_semaphore_create(1);
    
    self.ticketSurplusCount = 50;
    
    dispatch_queue_t queue1 = dispatch_queue_create("com.test.gcd1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.test.gcd2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafe];
    });
}

- (void)saleTicketSafe {
    while (1) {
        dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"所有火车票均已售完");
            
            // 相当于解锁
            dispatch_semaphore_signal(_semaphoreLock);
            break;
        }
        
        // 相当于解锁
        dispatch_semaphore_signal(_semaphoreLock);
    }
}

@end
