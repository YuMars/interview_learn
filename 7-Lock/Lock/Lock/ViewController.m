//
//  ViewController.m
//  Lock
//
//  Created by Red-Fish on 2021/10/27.
//

#import "ViewController.h"
#import "pthread.h"
#import <libkern/OSAtomic.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self synchronizedLock];
    //[self dispatchSemaphoreLock];
    //[self nsLock];
    //[self recursiveLock];
    //[self conditionLock];
    //[self pthreadmutexLock];
    //[self pthreadmutexRecursive];
    //[self osspinLock];
    
    //[self metex];
}

- (void)metex {
    // 初始化
    // pthread_mutex_init(<#pthread_mutex_t *restrict _Nonnull#>, <#const pthread_mutexattr_t *restrict _Nullable#>);
    
    // 注销一个互斥锁
    // pthread_mutex_destroy(<#pthread_mutex_t * _Nonnull#>)
    
    // pthread_mutex_lock(<#pthread_mutex_t * _Nonnull#>)
    // pthread_mutex_unlock(<#pthread_mutex_t * _Nonnull#>)
    // pthread_mutex_trylock(<#pthread_mutex_t * _Nonnull#>)
    
    // 读写锁
    // pthread_rwlock_init(<#pthread_rwlock_t *restrict _Nonnull#>, <#const pthread_rwlockattr_t *restrict _Nullable#>)
    // pthread_rwlock_destroy(<#pthread_rwlock_t * _Nonnull#>)
}

- (void)synchronizedLock {
    NSObject *obj = [[NSObject alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (obj) {
            NSLog(@"需要线程同步的操作1 开始");
            sleep(1);
            NSLog(@"需要线程同步的操作1 结束");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        @synchronized (obj) {
            NSLog(@"需要线程同步的操作2");
        }
    });
}

- (void)dispatchSemaphoreLock {
    dispatch_semaphore_t signal = dispatch_semaphore_create(1);
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@", signal);
        dispatch_semaphore_wait(signal, overTime);
        NSLog(@"%@", signal);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(1);
        NSLog(@"需要线程同步的操作1 结束");
        dispatch_semaphore_signal(signal);
        NSLog(@"%@", signal);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_semaphore_wait(signal, overTime);
        NSLog(@"需要线程同步的操作2");
        dispatch_semaphore_signal(signal);
    });
}

- (void)nsLock {
    NSLock *lock = [[NSLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lockBeforeDate:[NSDate date]];
        
        NSLog(@"需要线程同步的操作1 开始");
        sleep(2);
        NSLog(@"需要线程同步的操作1 结束");
        
        [lock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        
        if ([lock tryLock]) { // 尝试获取锁
            NSLog(@"锁可用");
        } else {
            NSLog(@"锁不可用");
        }
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        if ([lock lockBeforeDate:date]) {
            NSLog(@"没有超时，获得锁");
            [lock unlock];
        } else {
            NSLog(@"超时，没有获得锁");
        }
    });
}

/// 递归锁
- (void)recursiveLock {
//    NSLock *lock = [[NSLock alloc] init];
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void(^recursiveMethod)(int);
        
        recursiveMethod = ^(int value){
            [lock lock];
            if (value > 0) {
                NSLog(@"value = %d", value);
                sleep(1);
                recursiveMethod(value - 1);
            }
            [lock unlock];
        };
        
        recursiveMethod(5);
    });
}

/// 条件锁
- (void)conditionLock {
    NSConditionLock *lock = [[NSConditionLock alloc] init];
    NSMutableArray *products = [NSMutableArray array];
    
    NSInteger HAS_DATA = 3;
    NSInteger NO_DATA = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [lock lockWhenCondition:NO_DATA];
            [products addObject:[[NSObject alloc] init]];
            NSLog(@"produce a product,总量:%zi",products.count);
            [lock unlockWithCondition:HAS_DATA];
            sleep(1);
        }
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            NSLog(@"wait for product");
            [lock lockWhenCondition:HAS_DATA];
            if (products.count > 0) {
                [products removeObjectAtIndex:0];
            }
            NSLog(@"custome a product");
            [lock unlockWithCondition:NO_DATA];
        }
        
    });
}


- (void)pthreadmutexLock {
    __block pthread_mutex_t theLock;
    pthread_mutex_init(&theLock, NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&theLock);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(3);
        NSLog(@"需要线程同步的操作1 结束");
        pthread_mutex_unlock(&theLock);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        pthread_mutex_lock(&theLock);
        NSLog(@"需要线程同步的操作2");
        pthread_mutex_unlock(&theLock);
    });
}

/// 递归锁
- (void)pthreadmutexRecursive {
    __block pthread_mutex_t lock;
    //pthread_mutex_init(&lock, NULL);
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&lock, &attr);
    pthread_mutexattr_destroy(&attr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void(^RecursiveMethod)(int);
        
        RecursiveMethod = ^(int value) {
            pthread_mutex_lock(&lock);
            if (value > 0) {
                NSLog(@"value = %d", value);
                sleep(1);
                RecursiveMethod(value - 1);
            }
            
            pthread_mutex_unlock(&lock);
        };
        
        RecursiveMethod(5);
    });
}

- (void)osspinLock {
    __block OSSpinLock lock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&lock);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(3);
        NSLog(@"需要线程同步的操作1 结束");
        OSSpinLockUnlock(&lock);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&lock);
        sleep(1);
        NSLog(@"需要线程同步的操作2");
        OSSpinLockUnlock(&lock);
    });
    
}

@end
