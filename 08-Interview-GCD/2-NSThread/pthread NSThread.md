pthread NSThread

1.pthread
 1.1简介：
 	pthread 是一套通用的多线程的 API，可以在Unix / Linux / Windows 等系统跨平台使用，使用 C 语言编写，需要程序员自己管理线程的生命周期，使用难度较大，我们在 iOS 开发中几乎不使用 pthread，但是还是来可以了解一下的。
 1.2使用方法
 	头文件 #import "pthread.h"

 	pthread_t thread;
 	pthread_create(&thread, NULL, run ,NULL);
 	pthread_detach(thread);
 	void * run(void *param) {  // 新线程调用方法，里边为需要执行的任务
 		NSLog(@"%@", [NSThread currentThread]);
    	return NULL;
	}

	第一个参数&thread是线程对象，指向线程标识符的指针
	第二个是线程属性，可赋值NULL
	第三个run表示指向函数的指针(run对应函数里是需要在新线程中执行的任务)
	第四个是运行函数的参数，可赋值NULL
1.3 pthread 其他相关方法
	pthread_create() 创建一个线程
	pthread_exit() 终止当前线程
	pthread_cancel() 中断另外一个线程的运行
	pthread_join() 阻塞当前的线程，直到另外一个线程运行结束
	pthread_attr_init() 初始化线程的属性
	pthread_attr_setdetachstate() 设置脱离状态的属性（决定这个线程在终止时是否可以被结合）
	pthread_attr_getdetachstate() 获取脱离状态的属性
	pthread_attr_destroy() 删除线程的属性
	pthread_kill() 向线程发送一个信号

2.NSThread
	2.1 创建线程、启动线程
	2.2 线程相关用法
	2.3 线程状态控制方法
	2.4 线程之间的通信
	2.5 NSThread线程安全和线程同步
		2.5.1 非线程安全
		2.5.2 线程安全
	2.6 线程状态转换
		创建一条线程后，系统会把线程对象放入可调度线程池
		如果CPU现在调度当前线程对象，则当前线程对象进入运行状态，如果CPU调度其他线程对象，则当前线程对象回到就绪状态。
		如果CPU在运行当前线程对象的时候调用了sleep方法\等待同步锁，则当前线程对象就进入了阻塞状态，等到sleep到时\得到同步锁，则回到就绪状态。
		如果CPU在运行当前线程对象的时候线程任务执行完毕\异常强制退出，则当前线程对象进入死亡状态。

https://www.jianshu.com/p/cbaeea5368b1













