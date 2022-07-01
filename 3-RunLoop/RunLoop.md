RunLoop

1.RunLoop简介
	1.1 什么是RunLoop：运行时
		
		1.1.1 实际上是一个对象，这个对象在循环中用来处理程序过程中出现的各种事件（比如触摸，UI刷新，定时器，selector），保持程序的持续运行。
		1.1.2 RunLoop在没有事件处理的时候，会使线程进入睡眠模式，从而节省cpu资源，提高程序性能

	1.2 RunLoop和线程
		RunLoop和线程是息息相关的，我们知道线程的作用是用来执行特定的一个或多个线程，在默认情况下线程执行完之后就会退出，不能在执行任务。这时需要采用一种方式来让线程能够不断的处理任务，并不退出，就有了RunLoop。
		1.2.1 一条线程对应一个RunLoop对象，每条线程都有唯一一个与之对应的RunLoop对象。
		1.2.2 RunLoop并不保证线程安全。我们只能在当前线程内部操作当前线程的RunLoop对象，而不能在当前线程内部去操作其他线程的RunLoop对象方法。
		1.2.3 RunLoop对象在第一次获取RunLoop时创建，销毁则是在线程结束的时候。
		1.2.4 主线程的RunLoop对象系统自动帮助我们创建好，而子线程的RunLoop对象需要我们主动创建和维护。

	1.3 默认情况下主线程的RunLoop原理
		启动iOS程序的时候，系统会创建自动生成一个main.m文件，UIApplicationMain开启了主线程的RunLoop。
		RunLoop是线程中的一个循环，RunLoop会在循环中不断检测，通过Input sources（输入源）和 Timer sources（定时源）两种来源等待接受事件，然后对接受到的时间通知线程进行处理，并在没有时间的时候让线程进行休息。

2.RunLoop相关类
	1.CFRunLoopRef: 代表RunnLoop对象
	2.CFRunLoopModeRef: 代表RunLoopd的运行模式
	3.CFRunLoopSourceRef: RunLoop模型图中提到的输入源、事件源
	4.CFRunLoopTimerRef: RunLoop模型图中提到的定时器
	5.CFRunLoopObserverRef: 观察者，监听RunLoop的状态改变

	一个RunLoop对象（RunLoopRef）中包含若干运行模式（CFRunLoopModeRef）。而每一个运行模式下又包含若干个输入源（CFRunLoopSourceRef），定时源（CFRunLoopTimerRef），观察者（CFRunLoopObserverRef）。
		1.每次RunLoop启动时，只能指定其中一个模式（CFRunLoopModeRef），这个运行模式（CFRunLoopModeRef）被称作当前运行模式（CurrentMode）
		2.如果需要切换运行模式（CFRunLoopModeRef），只能退出当前Loop，再重新指定一个运行模式（CFRunLoopModeRef）进入。
		3.主要是为了分隔开不同组的输入源（CFRunLoopSourceRef），定时源（CFRunLoopTimerRef），观察者（CFRunLoopObserverRef），让其互不影响

	2.1 CFRunLoopRef
		CFRunLoopRef是Core Foundation下的RunLoop对象。
		Core Foundation：
			CFRunLoopGetCurrent(); // 获取当前线程的RunLoop对象
			CFRunLoopGetMain(); // 获取主线程的RunLoop对象
		Foundation：
			[NSRunLoop CurrentRunLoop];  // 获取当前线程的RunLoop对象
			[NSRunLoop mainRunLoop]; // 获取主线程的RunLoop对象

	2.2 CFRunLoopModeRef:
		1.kCFRunLoopDefaultMode：App的默认运行模式，通常主线程是在这个运行模式下运行
		2.UITrackingRunLoopMode：跟踪用户交互事件（用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他Mode影响）
		3.UIInitializationRunLoopMode：在刚启动App时第进入的第一个 Mode，启动完成后就不再使用
		4.GSEventReceiveRunLoopMode：接受系统内部事件，通常用不到
		5.kCFRunLoopCommonModes：伪模式，不是一种真正的运行模式（后边会用到）
		6.其中kCFRunLoopDefaultMode、UITrackingRunLoopMode、kCFRunLoopCommonModes是我们开发中需要用到的模式，具体使用方法我们在 2.3 CFRunLoopTimerRef 中结合CFRunLoopTimerRef来演示说明。

	2.3 CFRunLoopTimerRef: 定时源

	2.4 CFRunLoopSourceRef:
		CFRunLoopSourceRef是事件源（RunLoop模型图中提到过），CFRunLoopSourceRef有两种分类方法。
		第一种按照官方文档来分类（就像RunLoop模型图中那样）：
			Port-Based Sources（基于端口）
			Custom Input Sources（自定义）
			Cocoa Perform Selector Sources
		第二种按照函数调用栈来分类：
			Source0 ：非基于Port
			Source1：基于Port，通过内核和其他线程通信，接收、分发系统事件

	2.5 CFRunLoopObserverRef
		typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    		kCFRunLoopEntry = (1UL << 0),               // 即将进入Loop：1
    		kCFRunLoopBeforeTimers = (1UL << 1),        // 即将处理Timer：2    
    		kCFRunLoopBeforeSources = (1UL << 2),       // 即将处理Source：4
    		kCFRunLoopBeforeWaiting = (1UL << 5),       // 即将进入休眠：32
    		kCFRunLoopAfterWaiting = (1UL << 6),        // 即将从休眠中唤醒：64
   			kCFRunLoopExit = (1UL << 7),                // 即将从Loop中退出：128
    		kCFRunLoopAllActivities = 0x0FFFFFFFU       // 监听全部状态改变  
		};


3.RunLoop原理
	1.通知观察者RunLoop已经启动
	2.通知观察者即将要开始的定时器
	3.通知观察者任何即将启动的非基于端口的源
	4.启动任何准备好的非基于端口的源
	5.如果基于端口的源准备好并处于等待状态，立即启动；并进入步骤9
	6.通知观察者线程进入休眠状态
	7.将线程置于休眠知道任一下面的事件发生：
		·某一事件到达基于端口的源
		·定时器启动
		·RunLoop设置的时间已经超时
		·RunLoop被显示唤醒
	8.通知观察者线程将被唤醒
	9.处理未处理的事件
		·如果用户定义的定时器启动，处理定时器事件并重启RunLoop。进入步骤2
		·如果输入源启动，传递相应的消息
		·如果RunLoop被显示唤醒而且时间还没超时，重启RunLoop。进入步骤2
	10.通知观察者RunLoop结束。

4.RunLoop实战应用
	4.1 UIImageView推迟显示
	4.2 后台常驻线程




https://www.jianshu.com/p/d260d18dd551