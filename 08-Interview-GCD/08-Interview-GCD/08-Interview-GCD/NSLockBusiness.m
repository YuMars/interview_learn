//
//  NSLockBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "NSLockBusiness.h"

@interface NSLockBusiness()

@property (nonatomic, strong) NSLock *moneyLock;
@property (nonatomic, strong) NSLock *ticketLock;

@end

@implementation NSLockBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        self.moneyLock = [[NSLock alloc] init];
        self.ticketLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)saleTicket {
    
[self.ticketLock lock];

[super saleTicket];

[self.ticketLock unlock];
}

- (void)saveMoney {
    
    [self.moneyLock lock];
    
    [super saveMoney];
    
    [self.moneyLock unlock];
}

- (void)drawMoney {
    [self.moneyLock lock];
    
    [super drawMoney];
    
    [self.moneyLock unlock];
}

@end
