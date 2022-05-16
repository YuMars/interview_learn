#  Architecture
{
    MVC、MVVM、MVP
    
    MVC:
        M:Model
        V:View
        C:Controller
    优点：View，Controller可重用度高
    缺点：Controller过于臃肿
    
    MVC变种：View控制Model的显示
    优点：Controller一定瘦身，将View内部进行封装，外部不需要知道View内部具体实现
    缺点：View依赖Model
    
    
    MVP:
        P:Presenter 将Controller里面的跳转，给View赋值，点击放在Presenter里面
        
    MVVM:
        M:Model
        V:View(监听ViewModel赋值改变)
        VM:ViewModel(请求数据，跳转，)
          
}

{
    设计模式
        创建型模式：对象实例化的模式，用于解耦对象的实例化过程
            单例模式：
            工厂方法模式：
        结构型模式：把类或者对象结合在一起形成一个更大的结构
            代理模式：
            适配器模式：
            组合模式：
            装饰模式：
        行为型模式：类或对象之间如何监护，及划分责任和算法
            观察者模式：
            命令模式：
            责任链模式：
}
