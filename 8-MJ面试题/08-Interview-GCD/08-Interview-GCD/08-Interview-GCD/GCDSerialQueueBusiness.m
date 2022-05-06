//
//  GCDSerialQueueBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "GCDSerialQueueBusiness.h"

@interface GCDSerialQueueBusiness()

@property (nonatomic, strong) dispatch_queue_t moneyQueue;
@property (nonatomic, strong) dispatch_queue_t ticketQueue;

@end

@implementation GCDSerialQueueBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        self.moneyQueue = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
        self.ticketQueue = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)saleTicket {
    dispatch_sync(self.ticketQueue, ^{
        [super saleTicket];
    });
}

- (void)saveMoney {
    dispatch_sync(self.moneyQueue, ^{
        [super saveMoney];
    });
}

- (void)drawMoney {
    dispatch_sync(self.moneyQueue, ^{
        [super drawMoney];
    });
}

@end
