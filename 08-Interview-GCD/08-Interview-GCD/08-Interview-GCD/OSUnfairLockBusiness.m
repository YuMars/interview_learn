//
//  OSUnfairLockBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/21.
//

#import "OSUnfairLockBusiness.h"
#import <os/lock.h>

@interface OSUnfairLockBusiness()

@property (nonatomic, assign) os_unfair_lock moneyLock;
@property (nonatomic, assign) os_unfair_lock ticketLock;

@end

@implementation OSUnfairLockBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        self.moneyLock = OS_UNFAIR_LOCK_INIT;
        self.ticketLock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

- (void)saleTicket {
    
    os_unfair_lock_lock(&_ticketLock);
    
    [super saleTicket];
    
    os_unfair_lock_unlock(&_ticketLock);
}

- (void)saveMoney {
    
    os_unfair_lock_lock(&_moneyLock);
    
    [super saveMoney];
    
    os_unfair_lock_unlock(&_moneyLock);
}

- (void)drawMoney {
    os_unfair_lock_lock(&_moneyLock);
    
    [super drawMoney];
    
    os_unfair_lock_unlock(&_moneyLock);
}
@end
