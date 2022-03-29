#  KVC

    KVC全称Key-Value Coding，俗称"键值编码"，可以通过一个key来访问某个属性
    setValue:forKey:
    setValue:forKeyPath:     
    valueForKey:
    valueForKeyPath:
    
        [self.person setValue:value forKeyPath:@"cat.age"]
    
    
    Q: 通过KVC修改属性会触发KVO吗
    A: 会触发(通过KVC修改成员变量也会触发)
    
    setValue:forKey:顺序
        1.setKey: _setKey:顺序查找方法
        2.accessInstanceVariablesDirectly(是否允许直接访问成员变量)  ->第一种没找的情况
            2.1 设置No后，会调用setValue:forUndefinedKey:
            2.2 设置YES后，按照_key,_isKey,key,isKey的顺序查找成员变量，失败后会调用setValue:forUndefinedKey:
    {
        setKey:
        _setKey:
        
        _key
        _isKey
        key
        isKey
    }
    
    valueForKey:顺序
        1.getKey,key,isKey,_key顺序查找方法
        2.accessInstanceVariablesDirectly(是否允许直接访问成员变量) -> 第一种没找到的情况
            2.1 设置NO后，会调用valueForUndefinedKey:
            2.2 设置YES后，按照_key, _isKey, key, isKey的顺序查找成员变量
    
    {
        getKey:
        key:
        isKey:
        _key:
        
        _key
        _isKey
        key
        isKey
    }
    
    Q: KVC赋值的过程是什么？原理是什么？
    A: 上面的顺序
