#  PerformanceOptimiztion

{
    卡顿产生的原因
        CPU:数据计算
            Center Processing Unit,中央处理器
            对象的创建和销毁，对象属性的调整，布局计算、文本计算和排班、图片的格式转换和解码、图像的绘制
        
        GPU:渲染数据
            Graphics Processing Unit，图形处理器
            纹理的渲染
        VSync:垂直同步信号
        
        在iOS中是双缓存机制、有前帧缓存、后帧缓存
    卡顿解决的主要思路
        尽可能较少CPU，GPU消耗资源
        
        
    卡顿优化-CPU
        1.尽量使用轻量级的对象
            用不到事件处理的地方，可以用CALayer取代UIView
        2.不要频繁调用UIView的相关属性，比如frame、bounds、transform
        3.提前计算好布局，在有需要时一次性调整对应的属性，不要多次修改
        4.Autolayout会不直接设置frame消耗更多的CPU资源
        5.图片的size最好跟UIImageView的size保持一致
        6.控制线程的最大并发量
        7.尽量把耗时的操作放到子线程
            1.文字size计算
            2.图片处理（解码，绘制）
        
    卡顿优化-GPU
        1.尽量减少视图数量和层次
        2.GPU最大尺寸是4096x4096,超过会需要CPU占用资源进行处理
        3.减少透明度的视图
        4.减少出现离屏渲染
    
    离屏渲染
        在OpenGL中，GPU有2种渲染方式
        On-Screen Rendering:当前屏幕渲染,在当前用于显示的屏幕缓冲区进行渲染操作
        Off-Screen Rendering:离屏渲染，在当前屏幕缓冲区以外新开辟一个缓冲区进行渲染操作
        
        离屏渲染消耗性能的原因：
            1.需要创建新的缓冲区
            2.离屏渲染的整个过程，需要多次切换上下文环境，先是从当前屏幕(On-Screen)切换到离屏(Off-Screen),等到离屏渲染结束后，将离屏缓冲区的渲染结果显示到屏幕上,又需要将上下文环境从离屏切换到当前屏幕
            
        离屏渲染的发生情况
            1.光栅化
            2.遮罩
            3.圆角
            4.阴影
            
    卡顿检测：LXDAppFluecyMonitor（理解一下卡顿的函数调用栈）
}

{
    耗电的优化
        耗电的原因
        1.CPU
        2.网络
        3.定位
        4.图像
        
        优化
        1.降低CPU、GPU消耗
        2.少用计时器
        3.优化I/O操作
        4.网络优化
}

{
    APP的启动时间优化
        APP的启动分为2种:冷启动（从0开始启动app）热启动（app已经在内存中，在后台存在着）
        1.dyld:加载app可执行文件，加载所有依赖的动态库
        2.runtime
            1.调用map_images
            2.load_images中调用call_load_methods，调用Class，Category的+load
            3.进行objc结构的初始化（注册Objc类，初始化类对象）
            4.调用C++静态初始化器和__attribute__((constructor))
        3.main
}
