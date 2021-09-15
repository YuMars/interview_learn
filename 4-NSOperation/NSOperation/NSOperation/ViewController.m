//
//  ViewController.m
//  NSOperation
//
//  Created by Red-Fish on 2021/8/20.
//

#import "ViewController.h"

#import "YJTOperation.h"

@interface ViewController ()

@property (nonatomic, assign) NSInteger ticketSurplusCount;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self userInvocationOperation];
//    [NSThread detachNewThreadSelector:@selector(userInvocationOperation) toTarget:self withObject:nil];
//    [self useBlockOperation];
    // [self useNSOperation];
    // [self addOperationToQueue];
    
    // [self addOperationWithBlockToQueue];
    
    // [self setMaxConcurrentOpreationCount];
    
    // [self addDependency];
    
    // [self operationQueueCommunication];
    
    [self initTicketStatusSave];
}

- (void)initTicketStatusSave {
    NSLog(@"1 ----- %@", [NSThread currentThread]);
    
    self.ticketSurplusCount = 50;
    
    self.lock = [[NSLock alloc] init];
    
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *blockO1 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    
    NSBlockOperation *blockO2 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    
    [queue1 addOperation:blockO1];
    [queue2 addOperation:blockO2];
}

- (void)saleTicketSafe {
    while (1) {
        
        // 加锁
        [self.lock lock];
        
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        
        // 解锁
        [self.lock unlock];
        
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

- (void)initTicketStatusNotSave {
    NSLog(@"1 ----- %@", [NSThread currentThread]);
    
    self.ticketSurplusCount = 50;
    
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *blockO1 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketNotSafe];
    }];
    
    NSBlockOperation *blockO2 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketNotSafe];
    }];
    
    [queue1 addOperation:blockO1];
    [queue2 addOperation:blockO2];
}

- (void)saleTicketNotSafe {
    while (1) {

           if (self.ticketSurplusCount > 0) {
               //如果还有票，继续售卖
               self.ticketSurplusCount--;
               NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
               [NSThread sleepForTimeInterval:0.2];
           } else {
               NSLog(@"所有火车票均已售完");
               break;
           }
       }
}

- (void)operationQueueCommunication {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1 ----- %@", [NSThread currentThread]);
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            for (int i = 0; i < 3; i++) {
                [NSThread sleepForTimeInterval:1.0];
                NSLog(@"2 ----- %@", [NSThread currentThread]);
            }
        }];
    }];
}

- (void)addDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *blockO1 = [[NSBlockOperation alloc] init];
    [blockO1 addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1 ----- %@", [NSThread currentThread]);
        }
    }];
    
    NSBlockOperation *blockO2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"2 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [blockO1 addDependency:blockO2];
    
    [queue addOperation:blockO1];
    [queue addOperation:blockO2];
}

- (void)setMaxConcurrentOpreationCount {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 7;
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"2 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"3 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"4 ----- %@", [NSThread currentThread]);
        }
    }];
}

- (void)addOperationWithBlockToQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"2 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"3 ----- %@", [NSThread currentThread]);
        }
    }];
}

- (void)addOperationToQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationQueueInvacationOperation1) object:nil];
    NSInvocationOperation *invocationOperation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationQueueInvacationOperation2) object:nil];
    
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"3 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation1 addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"4 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [queue addOperation:invocationOperation];
    [queue addOperation:invocationOperation2];
    [queue addOperation:blockOperation1];
}

- (void)operationQueueInvacationOperation1 {
    for (int i = 0; i < 3; i++) {
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"1 ----- %@", [NSThread currentThread]);
    }
}

- (void)operationQueueInvacationOperation2 {
    for (int i = 0; i < 3; i++) {
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"2 ----- %@", [NSThread currentThread]);
    }
}

- (void)useNSOperation {
    YJTOperation *operation = [[YJTOperation alloc] init];
    [operation start];
}

- (void)useBlockOperation {
    
    NSLog(@"1");
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"2----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"3----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"4----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"5----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"6----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"7----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"8----%@", [NSThread currentThread]);
        }
    }];
    
    [blockOperation start];
    
    NSLog(@"2");
}

- (void)userInvocationOperation {
    
    NSLog(@"1");
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationFunc) object:nil];
    [operation start];
    
    NSLog(@"2");
}

- (void)invocationOperationFunc {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@", [NSThread currentThread]);
    }
}


@end
