//
//  OSSpinLockBusniess.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/21.
//

#import "OSSpinLockBusniess.h"
#import <libkern/OSAtomic.h>

@interface OSSpinLockBusniess()

@property (nonatomic, assign) OSSpinLock moneyLock;
@property (nonatomic, assign) OSSpinLock ticketLock;

@end

@implementation OSSpinLockBusniess

- (instancetype)init {
    if (self = [super init]) {
        self.moneyLock = OS_SPINLOCK_INIT;
        self.ticketLock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)drawMoney {
    OSSpinLockLock(&_moneyLock);
    
    [super drawMoney];
    
    OSSpinLockUnlock(&_moneyLock);
}

- (void)saveMoney {
    OSSpinLockLock(&_moneyLock);
    
    [super saveMoney];
    
    OSSpinLockUnlock(&_moneyLock);
}

- (void)saleTicket {
    OSSpinLockLock(&_ticketLock);
    
    [super saleTicket];
    
    OSSpinLockUnlock(&_ticketLock);
}

@end
