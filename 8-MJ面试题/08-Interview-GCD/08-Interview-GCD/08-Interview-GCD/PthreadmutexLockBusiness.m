//
//  PthreadmutexLockBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/21.
//

#import "PthreadmutexLockBusiness.h"
#import <pthread.h>

@interface PthreadmutexLockBusiness ()

@property (nonatomic, assign) pthread_mutex_t moneyLock;
@property (nonatomic, assign) pthread_mutex_t ticketLock;

@end

@implementation PthreadmutexLockBusiness

- (void)initLock:(pthread_mutex_t *)mutex {
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
    pthread_mutex_init(mutex, &attr);
    pthread_mutexattr_destroy(&attr);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initLock:&_moneyLock];
        [self initLock:&_ticketLock];
    }
    return self;
}

- (void)saleTicket {
    
    pthread_mutex_lock(&_ticketLock);
    
    [super saleTicket];
    
    pthread_mutex_unlock(&_ticketLock);
}

- (void)saveMoney {
    
    pthread_mutex_lock(&_moneyLock);
    
    [super saveMoney];
    
    pthread_mutex_unlock(&_moneyLock);
}

- (void)drawMoney {
    pthread_mutex_lock(&_moneyLock);
    
    [super drawMoney];
    
    pthread_mutex_unlock(&_moneyLock);
}

- (void)dealloc {
    pthread_mutex_destroy(&_moneyLock);
    pthread_mutex_destroy(&_ticketLock);
}

@end
