//
//  SynchronizedBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "SynchronizedBusiness.h"

@implementation SynchronizedBusiness

- (void)drawMoney {
    @synchronized (self) {
        [super drawMoney];
    }
}

- (void)saveMoney {
    @synchronized (self) {
        [super saveMoney];
    }
}

- (void)saleTickets {
    @synchronized (self) {
        [super saleTickets];
    }
}

@end
