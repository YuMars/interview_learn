//
//  ViewController.m
//  NSThreadDemo
//
//  Created by Red-Fish on 2021/8/16.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) NSInteger ticketSurplusCount;
@property (nonatomic, strong) NSThread *ticketSaleWindow1;
@property (nonatomic, strong) NSThread *ticketSaleWindow2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTicketSaleSave];
}

/// 创建和启动线程
- (void)nsthread {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(nsthreadRun) object:nil];
    [thread start];
}

/// 创建和自动启动线程
- (void)nsthreadAutoStart {
    [NSThread detachNewThreadSelector:@selector(nsthreadRun) toTarget:self withObject:nil];
}

/// 隐式创建和启动线程
- (void)implicitAutoStart {
    [self performSelectorInBackground:@selector(nsthreadRun) withObject:nil];
}

- (void)nsthreadRun {
    NSLog(@"current Thread ----- %@", [NSThread currentThread]);
}

/// 创建一个线程下载图片
- (void)downloadImageOnSubThread {
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
}

/// 下载图片
- (void)downloadImage {
    NSLog(@"current Thread ----- %@", [NSThread currentThread]);
    
    NSURL *imageUrl = [NSURL URLWithString:@"https://csdnimg.cn/release/blogv2/dist/pc/img/npsFeel2.png"];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    [self performSelectorOnMainThread:@selector(refreshOnMainThread:) withObject:image waitUntilDone:YES];
}

/// 回到主线程刷新
- (void)refreshOnMainThread:(UIImage *)image {
    NSLog(@"current Thread ----- %@", [NSThread currentThread]);
    NSLog(@"%@", image);
}

/// 非线程安全
- (void)initTicketSaleNotSave {
    self.ticketSurplusCount = 50;
    
    self.ticketSaleWindow1 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    self.ticketSaleWindow1.name = @"售票窗口1";
    
    self.ticketSaleWindow2 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    self.ticketSaleWindow2.name = @"售票窗口2";
    
    [self.ticketSaleWindow1 start];
    [self.ticketSaleWindow2 start];
}

/// 卖火车票
- (void)saleTicketNotSafe {
    while (1) {
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread].name]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"火车票卖完了");
            break;
        }
    }
}

/// 线程安全
- (void)initTicketSaleSave {
    self.ticketSurplusCount = 50;
    
    self.ticketSaleWindow1 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow1.name = @"售票窗口1";
    
    self.ticketSaleWindow2 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow2.name = @"售票窗口2";
    
    [self.ticketSaleWindow1 start];
    [self.ticketSaleWindow2 start];
}

/// 卖火车票
- (void)saleTicketSafe {
    while (1) {
        
        @synchronized (self) {
            if (self.ticketSurplusCount > 0) {
                self.ticketSurplusCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            } else {
                NSLog(@"火车票卖完了");
                break;
            }
        }
    }
}

@end
