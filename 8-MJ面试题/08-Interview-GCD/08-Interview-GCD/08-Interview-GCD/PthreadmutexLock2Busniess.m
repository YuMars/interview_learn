//
//  PthreadmutexLock2Busniess.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "PthreadmutexLock2Busniess.h"
#import <pthread.h>

@interface PthreadmutexLock2Busniess ()

@property (nonatomic, assign) pthread_mutex_t lock;

@end

@implementation PthreadmutexLock2Busniess

- (void)initLock:(pthread_mutex_t *)mutex {
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(mutex, &attr);
    pthread_mutexattr_destroy(&attr);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initLock:&_lock];
    }
    return self;
}

- (void)otherTest {
    pthread_mutex_lock(&_lock);
    NSLog(@"%s", __func__);
    [self otherTest2];
    pthread_mutex_unlock(&_lock);
}

- (void)otherTest2 {
    pthread_mutex_lock(&_lock);
    NSLog(@"%s", __func__);
    pthread_mutex_unlock(&_lock);
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}


@end
