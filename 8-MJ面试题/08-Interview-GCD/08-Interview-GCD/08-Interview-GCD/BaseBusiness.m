//
//  BaseBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/21.
//

#import "BaseBusiness.h"

@interface BaseBusiness ()

@property (nonatomic, assign) int money;
@property (nonatomic, assign) int totalTicketCount;

@end

@implementation BaseBusiness

- (void)otherTest {
    
}

// 存取钱
- (void)businessBank {
    self.money = 500;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i< 10; i++) {
            [self saveMoney];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i< 10; i++) {
            [self drawMoney];
        }
    });
}

// 存钱
- (void)saveMoney {
    int money = self.money;
    money += 50;
    sleep(0.2);
    self.money = money;
    
    NSLog(@"++++++存钱后剩余：%d", self.money);
}

// 取钱
- (void)drawMoney {
    int money = self.money;
    money -= 20;
    sleep(0.2);
    self.money = money;
    
    NSLog(@"------取钱后剩余：%d", self.money);
}

// 卖一张票
- (void)saleTicket {
    int oldTicket = self.totalTicketCount;
    oldTicket --;
    sleep(0.2);
    self.totalTicketCount = oldTicket;
    
    NSLog(@"tickets: %d", self.totalTicketCount);
}

- (void)saleTickets {
    self.totalTicketCount = 30;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
}

@end
