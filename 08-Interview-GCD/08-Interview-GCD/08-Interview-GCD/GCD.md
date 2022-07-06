#  GCD-多线程

{
    // Q: 你理解的多线程？

    // Q: iOS的多线程方案有哪几种？你更倾向于哪一种？

    // Q:你在项目中用过 GCD 吗？

    // Q: GCD 的队列类型

    // Q: 说一下 OperationQueue 和 GCD 的区别，以及各自的优势

    // Q: 线程安全的处理手段有哪些？

    // Q: OC你了解的锁有哪些？在你回答基础上进行二次提问；
        追问一：自旋和互斥对比？
        追问二：使用以上锁需要注意哪些？
        追问三：用C/OC/C++，任选其一，实现自旋或互斥？口述即可！

}

{
    1.pthread：C语言，程序员管理（几乎不用）
        一套通用的多线程API
        适用Unix、Linux、Windows
        跨平台、移植
        
    2.NSThread:OC ，程序员管理（偶尔使用）
        使用更加面相对象
        简单易用、可以直接操作线程对象
        
    3.GCD：C 自动管理（经常使用）
        旨在替代NSThread等线程技术
        充分利用设备的多核
        
    4.NSOpeartion：OC 自动管理（经常使用）
        基于GCD
        比GCD多了一些更简单实用的功能
        使用更加面相对象
    
}

{
    GCD的队列可以分为2大类
        1.并发队列
            可以让多个任务并发（同时）执行
            并发功能只有在一步函数下才有效
            
        2.串行队列
            让任务一个接着一个执行
            
    同步、异步、并发、串行
    
    同步(snyc)和异步(asnyc)主要影响：能不能开新的线程
        同步：在当前线程中执行任务、不具备开启新线程的能力
        异步：在新得线程中执行任务、具备开启新线程的能力
    
    串行和并发主要影响：任务的执行方式
        并发：多个任务并发执行
        串行：一个任务执行后，再执行下一个任务
        
        
            并发队列      串行队列          主队列
    同步  没有开启新线程   没有开启新线程    没有开启新县城
         串行执行任务     串行执行队列      串行执行队列
         
         开启新线程       开启新线程        没有开启新线程
    异步  并行执行任务    串行执行任务        串行执行任务
}

{
    线程安全问题 
    OSSpinLock
    os_unfair_lock
    pthread_mutex
    dispatch_Semaphore
    dispatch_queue(DISPATCH_QUEUE_SERIAL)
    NSLock
    NSRecursivelock
    NSCondition 
    NSConditionLock
    @synchronized
    
    OSSpinLock:
        自旋锁，等待锁的线程会处于忙等状态，一直占用cpu
        
        优先级反转：自己实现
            线程1（优先级高，后进来，cpu分配的资源在此线程）、线程2（优先级低，先进来）、线程3（时间片轮转调度算法）
            
    (low level lock)
    os_unfair_lock:
    pthread_mutex:
        互斥锁
        
    递归锁：允许对同一线程进行重复加锁(实现原理是什么？)
    
    NSLock是对mutex普通锁的封装
    
    semaphore叫做”信号量”
    信号量的初始值，可以用来控制线程并发访问的最大数量
    信号量的初始值为1，代表同时只允许1条线程访问资源，保证线程同步
    
    @synchronized原理是递归锁，通过传入的obj生成的key取唯一对应的hashmap value
    
    iOS线程同步方案性能比较
    
    1.os_unfair_lock
    2.OSSpinlock
    3.dispatch_semaphore
    4.pthread_mutex
    5.dispatch_queue
    6.NSLock
    7.NSCondition
    8.pthread_mutex
    9.NSRecursiveLock
    10.NSConditionLock
    11.@synchronized

}       

{
    自旋锁、互斥锁比较
    
    什么情况下用自旋锁
    预计线程等待锁的时间很短
    加锁的代码（临界区）经常被调用，但竞争情况很少发生
    CPU资源不紧张
    多核处理
    
    什么情况使用互斥锁
    预计线程等待时间较长
    单核处理
    临界区有IO操作
    临界区代码比较复杂或者循环量大
    临界区竞争强烈
}

{
    atomic
    
    给属性加上atomic修饰，可以保证属性的setter和getter都是原子性操作，也就是保证setter和getter内部是线程同步的
}

{
    多读单写
    
    pthread_rwlock:读写锁
    
    dispatch_barraier_async:  异步栅栏读写
        传入的并发队列必须是自己通过dispatch_queue_cretate创建的
        如果传入的是一个串行或是一个全局的并发队列，那这个函数便等同于dispatch_asnyc
}
