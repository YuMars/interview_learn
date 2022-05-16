//
//  GCDTimer.m
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import "GCDTimer.h"

static NSMutableDictionary *timerDict;

@implementation GCDTimer

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerDict = [[NSMutableDictionary alloc] init];
    });
}

- (NSString *)excuteTask:(void(^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeat:(BOOL)repeat asnyc:(BOOL)async {
    
    if (start <= 0 || interval <= 0) { return nil; }
    
    static int i = 0;
    NSString *name = [NSString stringWithFormat:@"%d", i++];
    
    dispatch_queue_t queue = async ? dispatch_queue_create("timer", DISPATCH_QUEUE_CONCURRENT) : dispatch_queue_create("timer", DISPATCH_QUEUE_SERIAL);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(timer, ^{
        if (task) { task(); }
        
        if (!repeat) {
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
    timerDict[name] = timer;
    
    return name;
}

- (void)cancelTask:(NSString *)task {
    
    if (task.length == 0) { return; }
    
    dispatch_source_t timer = timerDict[task];
    if (timer) {
        dispatch_source_cancel(timer);
        [timerDict removeObjectForKey:task];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        NSTimeInterval start = 2.0;// 2s后开始执行
        NSTimeInterval interval = 1.0; // 每隔1s开始执行
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
        
        dispatch_source_set_event_handler(timer, ^{
            NSLog(@"1");
        });
        dispatch_resume(timer);
    }
    return self;
}

@end
