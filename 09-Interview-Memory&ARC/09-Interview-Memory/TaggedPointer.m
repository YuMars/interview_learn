//
//  TaggedPointer.m
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import "TaggedPointer.h"

@interface TaggedPointer()

@property (nonatomic, copy) NSString *name;

@end

@implementation TaggedPointer


- (instancetype)init {
    self = [super init];
    if (self) {
        
        dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
        for (int i = 0; i < 1000; i++) {
            
            dispatch_async(queue, ^{
                // 加锁
                self.name = [NSString stringWithFormat:@"asdjfklasdjflkasjdf"];
                // 解锁
                
                /*
                 // MRC
                 - (void)setName:(NSString *)name {
                     if (name != _name) {
                         [_name release];
                         _name = [name retain];
                     }
                 }
                 */
                
            });
        }
        
        dispatch_queue_t queue2 = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
        for (int i = 0; i < 1000; i++) {
            
            dispatch_async(queue2, ^{
                self.name = [NSString stringWithFormat:@"asf"];
            });
        }
        
    }
    return self;
}

@end
