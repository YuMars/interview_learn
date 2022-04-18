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

