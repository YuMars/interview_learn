//
//  NSConditionLockBusiniess.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "NSConditionLockBusiniess.h"

@interface NSConditionLockBusiniess()

@property (nonatomic, strong) NSConditionLock *conditionLock;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation NSConditionLockBusiniess

- (instancetype)init {
    self = [super init];
    if (self) {
        self.conditionLock = [[NSConditionLock alloc] initWithCondition:1];
    }
    return self;
}

- (void)otherTest {
    [[[NSThread alloc] initWithTarget:self selector:@selector(addObject) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(removeObject) object:nil] start];
}


- (void)removeObject {
    [self.conditionLock lockWhenCondition:1];
    
    sleep(1);
    [self.dataArray removeLastObject];
    NSLog(@"删除了元素");
    [self.conditionLock unlockWithCondition:2];
}

- (void)addObject {
    [self.conditionLock lockWhenCondition:2];
    sleep(1);
    [self.dataArray addObject:@"11"];
    NSLog(@"添加了元素");
    [self.conditionLock unlock]; // 最好先解锁，后面的信号才能发出去
}

@end
