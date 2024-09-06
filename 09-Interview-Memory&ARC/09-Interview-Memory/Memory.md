#  Memory

{
    CADisplayLink、NSTimer 使用注意
    
    CADisplayLink、NSTimer会对target产生强引用，如果target又对它们产生强引用，那么就会发生循环引用
    
    CADisplayLink：保证使用频率和刷新频率一致
}

{
    内存中的几大区域
    
        低地址 ->   高地址
            保留
            代码段（__TEXT）
                编译之后的代码
            数据段 (__DATA)
                字符串常量：
                已初始化数据：已初始化的全局变量、静态变量
                未初始化的数据：未初始化的全局变量、静态变量
            堆(heap)
                通过alloc，malloc，calloc等动态分配的空间
            栈(stack)
                函数调用的开销：局部变量,内存分配从高到低
            内核区
            
}

{
    Tagged Pointer (指针的最高有效位是1)
        `从64bit开始，iOS引入了Tagged Pointer技术，用于优化NSNumber、NSDate、NSString等小对象的存储
        在没有Tagged Pointer之前，NSNumber等对象需要动态分配内存、维护引用技术等，NSNumber指针存储的是堆中NSNumber对象的地址值
        使用Tagged Pointer之后，NSNumber指针里面存储的数据变成了：Tag+Data，也就是将数据直接存储在指针中
        当对象指针的最低有效位是1，则该指针为Tagged Pointer
        当指针不够存储数据时，才会使用动态分配的方式来存储数据
        objc_msgSend能识别Tagged Pointer，比如NSNumber和intValue，直接从指针提取数据，节省了以前的调用开销`
}

{
    OC对象的内存管理
    
    在iOS中，使用引用计数器来管理OC对象的内存
    一个新创建的OC对象引用计数默认是1,当引用计数为0的时候，OC对象就会销毁，释放起占用的内存空间
    调用retain会让OC对象的引用计数+1，调用release会让OC对象的引用计数-1
    
    内存管理的经验总结
        当调用alloc、new、copy、mutableCopy方法返回了一个对象，在不需要这个对象时，要条用release或者autorelease释放它
        想拥有某个对象，就让它的引用计数+1，不想拥有某个对象，就让它的引用计数-1
        可以通过extern void _objc_autireleasePoolPrint(void)查看释放池的情况
}

{
    copy
    
    NSString *str1;
    NSArray *arr;
    NSDictionary *dic;
    
    1.copy          不可变拷贝，产生不可变副本
    2.mutableCopy   可变拷贝，产生可变副本
    
    深拷贝、浅拷贝
    1.深拷贝：内容拷贝，产生新对象
    2.浅拷贝：指针拷贝，没有产生新对象 
    
                    NSString        NSMutableString         NSArray     NSMutableArray      NSDictionary        NSMutableDictionary
    copy            NSString            NSString            NSArray          NSArray        NSDictionary            NSDictionary
                     浅                   深拷贝                浅              深拷贝              浅                   深拷贝
    mutableCopy  NSMutableString    NSMutableString      NSMutableArray NSMutableArray    NSMutableDictionary   NSMutableDictionary
                     深拷贝                深拷贝             深拷贝             深拷贝             深拷贝                 深拷贝
}

{
    weak指针的实现原理(解读源码看看， 释放原理)
    
    
}

{
    autorelease原理(解读源码看看， 释放原理)
}

{
    autorelease在什么时候被释放
    在所属的那次runloop，休眠之前释放
}
