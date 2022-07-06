//
//  GCDReadWrite.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/5/10.
//

#import "GCDReadWrite.h"
#import "pthread.h"

@interface GCDReadWrite()

@property (nonatomic, assign) pthread_rwlock_t lock;

@end

@implementation GCDReadWrite

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_rwlock_init(&_lock, NULL);
    }
    return self;
}

- (void)read {
    pthread_rwlock_rdlock(&_lock);
    NSLog(@"%@", NSStringFromSelector(_cmd));
    pthread_rwlock_rdlock(&_lock);
}

- (void)write {
    
    pthread_rwlock_wrlock(&_lock);
    NSLog(@"%@", NSStringFromSelector(_cmd));
    pthread_rwlock_unlock(&_lock);
}

- (void)read1 {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)write2 {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
