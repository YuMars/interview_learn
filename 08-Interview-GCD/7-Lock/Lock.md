锁

1.锁的分类
	互斥锁
	自旋锁

	1.1 自旋锁
		线程反复检查锁变量是否可用。用于线程在这一过程中保持执行，因此是一种 『忙等』。一旦获取了自旋锁，线程会一直保持该锁，直至显示释放自旋锁。自旋锁避免了进程上下文的调度开销，因此对于线程只会阻塞很短时间的场合是很有效的

	自旋锁 = 互斥锁 + 忙等

	1.2 互斥锁
		是一种用于多线程编程中，防止两条线程同时对同一公共资源进行读写的机制。该目的通过将代码切片成一个一个的临时区域而达成。
		在Posix Thread 中定义有一套专门用于线程同步的mutex函数，mutex用于保证在任何时刻，都只能有一个线程访问该对象。当获取锁操作失败时，线程会进入睡眠，等待锁释放时被唤醒

		互斥锁分为递归锁、非递归锁

		递归锁：
		@synchronized:多线程可递归
		NSRecursiveLock：不支持多线程可递归
		pthread_mutex_t(recursive):多线程可递归

		非递归：
		NSLock
		pthread_mutex
		dispatch_semaphore
		os_unfair_lock

		条件锁：
		NSCondition:
		NSConditionLock:

		信号量：
		dispatch_semaphore
		


https://www.jianshu.com/p/8f8e5f0d0b23
https://www.jianshu.com/p/a816e8cf3646