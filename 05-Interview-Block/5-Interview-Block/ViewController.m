//
//  ViewController.m
//  5-Interview-Block
//
//  Created by Red-Fish on 2021/12/17.
//

#import "ViewController.h"

typedef void(^BlockAuto)(void);

@interface Person : NSObject

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) void(^block)(void);

@end

@implementation Person

- (void)dealloc {
    NSLog(@"%@1 --- dealloc", [self class]);
}

@end

@interface Teacher : Person

@end

@implementation Teacher

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%@ - %@ - %@", [self class], [super class], [self superclass]);
    }
    return self;
}

@end

@interface ViewController ()

@property (nonatomic, copy) BlockAuto blockAuto;

@end

struct __block_impl {
  void *isa; // 指针
  int Flags;
  int Reserved;
  void *FuncPtr;
};


struct __ViewController__viewDidLoad_block_impl_0 { // 函数实现
  struct __block_impl impl;
  struct __ViewController__viewDidLoad_block_desc_0* Desc; // block描述
  int num;
    
// 构造函数
    /*__ViewController__viewDidLoad_block_impl_0(void *fp, struct __ViewController__viewDidLoad_block_desc_0 *desc, int _num, int flags=0) : num(_num) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
    }*/
};

struct __ViewController__viewDidLoad_block_desc_0 { // 函数描述
  size_t reserved;
  size_t Block_size; // 内存
} __ViewController__viewDidLoad_block_desc_0_DATA = {
    0,
    sizeof(struct __ViewController__viewDidLoad_block_impl_0) // 计算占用内存空间
};

// block内部实现
static void __ViewController__viewDidLoad_block_func_0(struct __ViewController__viewDidLoad_block_impl_0 *__cself, int a, int b) {
  int num = __cself->num; // bound by copy

//        NSLog((NSString *)&__NSConstantStringImpl__var_folders_h6_5t3f7nb176g5jy6p602g48f80000gn_T_ViewController_36b3f2_mi_0, num);
//        NSLog((NSString *)&__NSConstantStringImpl__var_folders_h6_5t3f7nb176g5jy6p602g48f80000gn_T_ViewController_36b3f2_mi_1, a, b);
    }



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Teacher *t = [[Teacher alloc] init];
    // Q:Block的原理是什么？本质是什么？
    
//    ^{
//        NSLog(@"a block");
//    }();
    
//    void(^block)(void) = ^ {
//        NSLog(@"a named block");
//    };
//
//    block();
    
    ///!  0.cpp
//    int num = 1;
//    int d = 2;
//
//    void(^parameterBlock)(int, int) = ^(int a, int b){
//        NSLog(@"%d", num);
//        NSLog(@"a parameterBlock block: a:%d b:%d", a, b);
//    };
//
//    parameterBlock(num, d);
    
    
    /*
     struct __block_impl { // 函数方法
       void *isa;
       int Flags;
       int Reserved;
       void *FuncPtr; // 指向要执行的block内部的地址
     };
     */
    
    /*
     A:block 也是一个OC对象，它内部也有isa指针
     block是封装了函数调用已经函数调用环境的的OC对象
     
     */
    
    //struct __ViewController__viewDidLoad_block_impl_0 *blockStruct = (__bridge struct __ViewController__viewDidLoad_block_impl_0 *)parameterBlock;
    
    //void *ptr = blockStruct->impl.FuncPtr;
    
    // 定义block变量
    // void(*block)(int, int) = ((void (*)(int, int))&__ViewController__viewDidLoad_block_impl_0((void *)__ViewController__viewDidLoad_block_func_0, &__ViewController__viewDidLoad_block_desc_0_DATA, num));
    
    // 简化
    //void(*block)(int, int) = &__ViewController__viewDidLoad_block_impl_0(__ViewController__viewDidLoad_block_func_0, // block内函数实现
    //                                                                     &__ViewController__viewDidLoad_block_desc_0_DATA, // 函数描述
    //                                                                     num);
    
    // 声明block，会生成一个struct函数指针 __ViewController__viewDidLoad_block_impl_0
    // 传入block内部实现 __ViewController__viewDidLoad_block_func_0 和 __ViewController__viewDidLoad_block_desc_0_DATA 的地址
    
    // 执行block内部代码
    // ((void (*)(__block_impl *, int, int))(block)->FuncPtr)((__block_impl *)parameterBlock, num, d);
    // __block_impl下 FuncPtr 调用，impl.FuncPtr = fp;， *fp = __ViewController__viewDidLoad_block_func_0
    
    // 简化
    // ((block)->FuncPtr)(parameterBlock, num, d);
    
    /*
     auto变量的捕获(auto：离开作用域自动销毁)
     */
    
    ///!  1.cpp
//    void(^block2)(int , int) = ^(int a, int b) {
//        NSLog(@"%d %d", a ,b);
//    };
    
    ///! 2.cpp
    int a = 10;
    static int b = 11;
    void(^block3)(void) = ^{
        NSLog(@"block3：%d %d", a, b);
    };
    a = 20;
    b = 21;
    block3(); // 结果：a = 10;
    
//    int a = 10;
//    static int b = 11;
//    void(*block3)(void) = ((void (*)())&__ViewController__viewDidLoad_block_impl_0((void *)__ViewController__viewDidLoad_block_func_0, &__ViewController__viewDidLoad_block_desc_0_DATA, a, &b));
//    a = 20;
//    b = 21;
//    ((void (*)(__block_impl *))((__block_impl *)block3)->FuncPtr)((__block_impl *)block3);
    
    
//    struct __ViewController__viewDidLoad_block_impl_0 {
//      struct __block_impl impl;
//      struct __ViewController__viewDidLoad_block_desc_0* Desc;
//      int a;
//      int *b;
//      __ViewController__viewDidLoad_block_impl_0(void *fp, struct __ViewController__viewDidLoad_block_desc_0 *desc, int _a, int *_b, int flags=0) : a(_a), b(_b) {
//        impl.isa = &_NSConcreteStackBlock;
//        impl.Flags = flags;
//        impl.FuncPtr = fp;
//        Desc = desc;
//      }
//    };
    
    /*
     变量类型                            捕获到block内部                   访问方式
     局部变量 auto(离开作用域自动销毁)             ∫                          值传递
            static                            ∫                          指针传递
            (register,很少用到)
      全局变量                                 X                          直接访问
     */
    
    /// ! 会进行捕获self:是auto局部变量  (Class *self, SEL _cmd)传入block中
//    void(^block4)(void) = ^{
//        NSLog(@"%@", self);
//    };
    
    /*
     _NSGlobalBlock__       没有访问auto变量（在数据段上）
     _NSStackBlock__        访问了auto变量 (在栈上)
     _NSMallocBlock__       NSStackBlock调用了copy（在堆上）
     
     在ARC环境下，编译器会根据情况自动将栈上的block复制到堆上
     1.block作为函数返回值的时候
     2.将block赋值给强指针的时候
     3.block作为cocoa API中方法名含有usingBlock的方法参数
     4.block作为GCD API的方法参数
     */
    
    void(^globalBlock)(void) = ^{
        NSLog(@"");
    };
    
    NSLog(@"globalBlock:%@", [globalBlock class]);
    NSLog(@"globalBlock:%@", [[globalBlock class] superclass]);
    NSLog(@"globalBlock:%@", [[[globalBlock class] superclass] superclass]);
    NSLog(@"globalBlock:%@", [[[[globalBlock class] superclass] superclass] superclass]);
    
    /*
     对象类型的auto变量
     
     typedef void (Block)(void);
     
     Person *p = [Person alloc] init];
     p.age = 10;
     
     Block block = ^{
        NSLog(@" %d", p.age);
     };
     
     */
    
    
//    BlockAuto autoblock;
//
//    {
//        Person *p = [[Person alloc] init];
//        p.age = 10;
//
//        autoblock = ^{
//           NSLog(@" %ld", p.age);
//        };
//    }

    //Person未释放
    NSLog(@"----");
    
    BlockAuto autoblock;

    {
        Person *p = [[Person alloc] init];
        p.age = 10;

        __weak Person *weakP = p;
        autoblock = ^{
           NSLog(@" %ld", weakP.age);
        };
    }
    
    /*
     当block内部访问了对象类型的auto变量时
     ·如果block是在栈上（stack）
        将不会对auto变量产生引用
     
     ·如果block在堆上（malloc）
        会调用block内部的copy函数
        copy函数内部会调用_block_object_assign函数
        _block_object_assignd函数会根据auto变量的修饰符（__strong, __weak, __unsafe_unretained）做出相应的操作，类似与retain（形成强引用，弱引用）
     
     ·如果block从堆上移除
        会调用block内部的dispose函数
        dispose函数内部会调用_block_object_dispose函数
        _block_object_dispose函数会自动释放引用的auto变量，类似与release
     
     copy函数 ->  栈上的block复制到堆时
     dispose函数 -> 堆上的block被废弃时
     
     
     */
    
    // Person释放
    NSLog(@"----");
    
    // 修改变量
    
    __block int num1 = 3;
    
    BlockAuto block11 = ^ {
        num1 = 2;
        NSLog(@"%d", num1);
    };
    
    /*
     ·当__block变量在栈上时，不会对指向的对象产生强引用
     ·当__block变量被copy到堆上时
        1.会调用__block变量内部的copy函数
        2.copy函数内部会调用_Block_object_assign函数
        3._Block_object_assign函数会根据所指向对象的修饰符（__strong, __weak, __unsafe_unretained）做出相应的操作，形成强（弱）引用(ARC会retain，MRC不会retain)
     
     ·如果__block变量从堆上移除
        1.会调用__block变量的dispose函数
        2.dispose函数会调用内部的_Block_object_dispose函数
        3._Block_object_dispose函数会自动释放所指向的对象
     */
    
    // 无法修改的原因：block内部会生产一个结构体带入num1的值，是指向了结构体内部的num1，无法改变外部的num1值
    
    // Q:block的原理是什么？本质是什么？
    
    // A:A:block 也是一个OC对象，它内部也有isa指针
    // block是封装了函数调用已经函数调用环境的的OC对象
    
    // Q:__block的作用是什么？有什么使用注意点
    
    // A:用__block修饰的变量包装成一个对象（有指针的结构体）
    // 解决block内部无法修改auto变量值的问题
    // 内存管理：循环引用要注意，用__weak解决，或者用__block内部把对象赋值 = nil
    
    // Q:block的属性修饰符为什么是copy，使用block有哪些使用注意
    
    // A:block一旦copy，就会copy到堆上，可以控制生命周期
    
    // Q:block在修改NSMutableArray,需不需要添加__block
    
    // A:不需要
    
    // [self test0]; // 死锁
    // [self test1]; // 0 1 2
    // [self test2]; // 0 1
    
    __block Person *blockPerson = [[Person alloc] init];
    blockPerson.age = 10;
    blockPerson.block = ^{
        blockPerson.age;
    };
    
    blockPerson.block();
}

- (void)test0 {
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"0");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"1");
        });
        NSLog(@"2");
    });
}

- (void)test1 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"0");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"1");
        });
        NSLog(@"2");
    });
}

- (void)test2 {
    NSLog(@"0");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self performSelector:@selector(doPerform) withObject:nil afterDelay:1];
        NSLog(@"1");
    });
    
}

- (void)doPerform {
    NSLog(@"2");
}

@end
