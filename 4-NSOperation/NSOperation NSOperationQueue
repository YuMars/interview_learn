NSOperation NSOperationQueue

1.NSOperation NSOperationQueue

	是基于GCD的更高一层封装，面向对象，比GCD更简单易用，代码可读性更高
	1.可添加完成的代码块，在操作完成之后
	2.添加操作之后的依赖关系，方便控制执行顺序。
	3.设定操作执行的优先级
	4.可以很方便的取消一个操作
	5.使用KVO观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled

2.NSOperation NSOperationQueue操作和操作队列
	操作：
		Operation 线程中执行的代码	
		在GCD中放在Block。在NSOperation中，使用子类NSInvocationOperation、NSBlockOperation，或者自定义子类来封装操作。

	操作队列：
		·不同于GCD中的调度队列FIFO（先进先出），NSOperationQueue对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的开始执行顺序（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性）。
		·操作队列通过设置最大并发操作数来控制并发、串行。
		·NSOperationQueue提供了两种队列：主队列和自定义队列。主队列运行在主线程之上，自定义队列在后台执行。

3.NSOperation NSOperationQueue 使用步骤
	NSOperation多线程使用步骤分为三步：
	1.创建操作：先将需要执行的操作封装到一个NSOperation对象中
	2.创建队列：创建NSOperationQueue对象
	3.将操作加入到队列中：将NSOperation对象添加在NSOperationQueue对象中。

4.NSOperation NSOperationQueue 基本使用
	NSOperation是个抽象类，不能用来封装操作，我们只有使用它的子来封装操作。
	1.使用子类NSInvocationOperation
	2.使用子类NSBlockOperation
	3.自定义继承自NSOperation的子类，通过实现内部相应的方法来封装操作

		4.1.1 NSInvoationOperation
		4.1.2 NSBlockOperation
		4.1.3 NSOperation

	4.2 创建队列
		·主队列 
			凡是添加到主队列中的操作，都会放到主线程中执行（不包括addExecutionBlock：）
		·自定义队列
			添加到这个队列中的操作，就会自动放到子线程中执行
			同时包含串行、并发

	4.3 将操作加入队列中
		addOperation
		addOperationWithBlock 以上都是并发

5.NSOperationQueue 控制串行执行、并发执行
	maxConcurrentOperationCount

6.NSOperation 操作依赖
	NSOperation、NSOperationQueue 最吸引人的地方是它能添加操作之间的依赖关系。通过操作依赖，我们可以很方便的控制操作之间的执行先后顺序
	addDependency:		添加依赖，使当前操作依赖入参操作
	removeDependency:	移除依赖，取消当前操作对入参的依赖
	dependencies 在当前操作开始执行之前完成执行的所有操作对象组

7.NSOperation 优先级
	·queuePriority 属性决定了进入准备就绪状态下的操作之间的开始执行顺序。并且，优先级不能取代依赖关系。
	·如果一个队列中既包含高优先级操作，又包含低优先级操作，并且两个操作都已经准备就绪，那么队列先执行高优先级操作。比如上例中，如果 op1 和 op4 是不同优先级的操作，那么就会先执行优先级高的操作。
	·如果，一个队列中既包含了准备就绪状态的操作，又包含了未准备就绪的操作，未准备就绪的操作优先级比准备就绪的操作优先级高。那么，虽然准备就绪的操作优先级低，也会优先执行。优先级不能取代依赖关系。如果要控制操作间的启动顺序，则必须使用依赖关系。

8.NSOperation、NSOperation 线程间的通信

9.NSOperation、NSOperationQueue 线程同步和线程安全

	9.1 NSOperation、NSOperationQueue 非线程安全
	9.1 NSOperation、NSOperationQueue 线程安全










https://www.jianshu.com/p/4b1d77054b35