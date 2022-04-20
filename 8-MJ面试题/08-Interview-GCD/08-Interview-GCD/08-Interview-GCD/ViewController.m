//
//  ViewController.m
//  08-Interview-GCD
//
//  Created by Red-Fish on 2022/4/20.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        NSLog(@"1");
        // 往runloop里面添加timer
        [self performSelector:@selector(test) withObject:nil afterDelay:0.0];
        NSLog(@"3");
        
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode: NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });
    
    // 1 3 performSelector:withObject:afterDelay本质是往runloop添加定时器
}

- (void)test {
    NSLog(@"2");
}

- (void)interview1 {
    NSLog(@"执行任务1");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"执行任务2");
    });
    NSLog(@"执行任务3");
    
    // 死锁
}

- (void)interview2 {
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
    });
    NSLog(@"执行任务3");
    
    // 1 3 2
}

- (void)interview3 {
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
        
        dispatch_sync(queue, ^{
            NSLog(@"执行任务3");
        });
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
    
    // 1 5 2 死锁
}

- (void)interview4 {
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
        
        dispatch_sync(queue2, ^{
            NSLog(@"执行任务3");
        });
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
    
    // 1 5 2 3 4
}


@end
