#  Runloop

{
    什么是Runloop
    在运行过程中循环做一些事情
    
    应用范畴
    1.定时器
    2.GCD Async Main Queue
    3.事件响应、手势识别、界面刷新
    4.网络请求
    5.Autoreleasepool
    
    
    Runloop的伪代码
    do {
        // 睡眠中等待消息
        int message = sleep_and_wait()
        // 处理消息
        retVal = process_message();
    } while (0 == retVal);
    
    Runloop的基本作用
    1.保持程序的基本运行
    2.处理app的各种事件(触摸、定时器)
    3.节省cpu资源，提高程序性能：该做事时做事、该休息时休息
}
    
{
    Runloop
    
    Foundation:NSRunLoop
    
    Cor Foundation:CFRunLoopRef
    
    1.每条线程有唯一的一个与之对应的Runloop对象
    2.Runloop保存在一个全局的Dictionary里，线程作为key，runloop作为value
    3.线程刚创建时并没有Runloop对象，Runloop会在第一次获取它时创建
    4.Runloop会先线程结束时销毁
    5.主线程的Runloop已经自动创建，子线程默认没有开启runloop
    
    
}

{
    struct __CFRunLoop {
        CFRuntimeBase _base;
        pthread_mutex_t _lock; // locked for  accessing mode list */
        __CFPort _wakeUpPort;  // used for CFRunLoopWakeUp 
        Boolean _unused;
        volatile _per_run_data *_perRunData; // reset for runs of the run loop
        pthread_t _pthread;
        uint32_t _winthread;
        CFMutableSetRef _commonModes;
        CFMutableSetRef _commonModeItems;
        CFRunLoopModeRef _currentMode; // 当前模式
        CFMutableSetRef _modes;        // 模式集合
        struct _block_item *_blocks_head;
        struct _block_item *_blocks_tail;
        CFAbsoluteTime _runTime;
        CFAbsoluteTime _sleepTime;
        CFTypeRef _counterpart;
    };
    
    struct __CFRunLoopMode {
        CFRuntimeBase _base;
        pthread_mutex_t _lock;// must have the run loop locked before locking this
        CFStringRef _name;
        Boolean _stopped;
        char _padding[3];
        CFMutableSetRef _sources0;  // CFRunloopSourceRef 
        CFMutableSetRef _sources1;  // CFRunloopSourceRef
        CFMutableArrayRef _observers; // CFRunloopObserverRef 
        CFMutableArrayRef _timers; // CFRunloopTimerRef 定时器
        CFMutableDictionaryRef _portToV1SourceMap;
        __CFPortSet _portSet;
        CFIndex _observerMask;
}

{
    CFRunloopModeRef:
        1.CFRunloopModeRef代表Runloop的运行模式
        2.一个Runloop包含若干个Mode，每个Mode又包含若干个Souce0、Souce1、Timer、Observer
        3.Runloop启动时只能选择一个Mode，作为currentMode
        4.如果需要切换Mode、只能退出当前Loop、再重新进入一个Mode
        5.不同组的source0、source1、timer、obserber能分隔开
        
        如果Mode里没有任何source0、source1、timer、obserber，Runloop会立马退出
         
    常见的2中Mode：
        DefaultMode
        TrackingRunloop
        
    运行逻辑：
        1.source0：
            触摸事件处理
            
        2.source1：
            基于Port的线程间通信
            系统时间捕捉(发送给source0处理)
        
        3.timer
        
        4.observer
            监听Runloop状态
            autoreleasepool
}

{
    Runloop的运行逻辑
        1.通知Observer：进入Runloop
        2.通知Observer：即将处理timer
        3.通知Observer：即将处理sources
        4.处理blocks(CFRunLoopPerformBlock)
        5.处理Source0(可能会再次处理Blocks)
        6.如果存在source1，就跳转到第8步
        7.通知Observer是：开始休眠  （切换到内核态层面sleep）
        8.通知observers:结束休眠（被某个消息唤醒）
            处理Timer
            处理GCD Async to Main Queue
            处理Source1
        9.处理Blocks
        10.根据前面的执行结果，决定如何做
            回到第2步
        11.通知Observers:退出Runloop
}

{
    Runloop在实际开发中的应用
        1.控制线程生命周期（线程保活）
        2.解决NSTimer在滑动时停止工作 (NSRunLoopCommonModes)
        3.监控卡顿
        4.性能优化 
        
    // [[NSRunLoop currentRunLoop] run]无法被停止，适用于用不销毁的线程
    
    // 控制Runloop
    while (shoulStop && [[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]]) {
        
    }
}

{
    //Q: 讲讲 RunLoop，项目中有用到吗？
    //A: 
    
    //Q: runloop内部实现逻辑？
    //A: 
    
    //Q: runloop和线程的关系？
    //A: 
    
    //Q: timer 与 runloop 的关系？
    //A: 
    
    //Q: 程序中添加每3秒响应一次的NSTimer，当拖动tableview时timer可能无法响应要怎么解决？
    //A: 
    
    //Q: runloop 是怎么响应用户操作的， 具体流程是什么样的？
    //A: 
    
    //Q: 说说runLoop的几种状态
    //A: 
    
    //Q: runloop的mode作用是什么？
    //A: 
}
