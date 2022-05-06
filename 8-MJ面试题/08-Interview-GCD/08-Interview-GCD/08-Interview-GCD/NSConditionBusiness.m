//
//  NSRecursiveLockBusiness.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/22.
//

#import "NSConditionBusiness.h"

@interface NSConditionBusiness ()

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation NSConditionBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        self.condition = [[NSCondition alloc] init];
    }
    return self;
}

- (void)otherTest {
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(removeObject) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(addObject) object:nil] start];
}


- (void)removeObject {
    [self.condition lock];
    if (self.dataArray.count == 0) { // 等待
        [self.condition wait]; // 等待信号
    }
    
    sleep(1);
    [self.dataArray removeLastObject];
    NSLog(@"删除了元素");
    [self.condition unlock];
}

- (void)addObject {
    [self.condition lock];
    sleep(1);
    [self.dataArray addObject:@"11"];
    NSLog(@"添加了元素");
    [self.condition unlock]; // 最好先解锁，后面的信号才能发出去
    [self.condition signal]; // 发送信号
}

@end
