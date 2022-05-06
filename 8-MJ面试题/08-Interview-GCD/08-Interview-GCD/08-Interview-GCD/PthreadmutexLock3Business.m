//
//  PthreadmutexLock3Business.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "PthreadmutexLock3Business.h"
#import <pthread.h>

@interface PthreadmutexLock3Business()

@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic, assign) pthread_cond_t condition;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation PthreadmutexLock3Business

- (void)initLock:(pthread_mutex_t *)mutex {
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(mutex, &attr);
    pthread_mutexattr_destroy(&attr);
    
    pthread_cond_init(&_condition, NULL);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataArray = [[NSMutableArray alloc] init];
        [self initLock:&_lock];
    }
    return self;
}

- (void)otherTest {
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(removeObject) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(addObject) object:nil] start];
}


- (void)removeObject {
    pthread_mutex_lock(&_lock);
    if (self.dataArray.count == 0) { // 等待
        pthread_cond_wait(&_condition, &_lock); // 等待信号
    }
    
    sleep(1);
    [self.dataArray removeLastObject];
    NSLog(@"删除了元素");
    pthread_mutex_unlock(&_lock);
}

- (void)addObject {
    pthread_mutex_lock(&_lock);
    sleep(1);
    [self.dataArray addObject:@"11"];
    NSLog(@"添加了元素");
    pthread_cond_signal(&_condition); // 发送信号
    pthread_mutex_unlock(&_lock);
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
    pthread_cond_destroy(&_condition);
}

@end
