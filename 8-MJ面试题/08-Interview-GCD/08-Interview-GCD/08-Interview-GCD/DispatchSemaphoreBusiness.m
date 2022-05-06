//
//  DispatchSemaphoreBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "DispatchSemaphoreBusiness.h"

@interface DispatchSemaphoreBusiness()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) dispatch_semaphore_t moneySemaphore;
@property (nonatomic, strong) dispatch_semaphore_t ticketSemaphore;
@end

@implementation DispatchSemaphoreBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(5);
        self.moneySemaphore = dispatch_semaphore_create(1);
        self.ticketSemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)otherTest {
    for (int i = 0; i < 20; i++) {
        [[[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil] start];
    }
}

- (void)test {
    
    // 如果信号量的值 > 0，就让信号量的值减1，然后继续往下执行代码
    // 如果信号量的值<= 0，就会休眠等待,知道信号量的值>0，让信号量的值-1，继续执行
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER) ;
    
    sleep(2);
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    dispatch_semaphore_signal(self.semaphore);
}

- (void)saleTicket {
    dispatch_semaphore_wait(self.ticketSemaphore, DISPATCH_TIME_FOREVER);
    
    [super saleTicket];
    
    dispatch_semaphore_signal(self.ticketSemaphore);
}

- (void)saveMoney {
    dispatch_semaphore_wait(self.moneySemaphore, DISPATCH_TIME_FOREVER);
    [super saveMoney];
    dispatch_semaphore_signal(self.moneySemaphore);
}

- (void)drawMoney {
    dispatch_semaphore_wait(self.moneySemaphore, DISPATCH_TIME_FOREVER);
    [super drawMoney];
    dispatch_semaphore_signal(self.moneySemaphore);
}


@end
