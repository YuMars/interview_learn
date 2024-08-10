/*
 * Copyright (c) 2004-2007 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */
/*
  Implementation of the weak / associative references for non-GC mode.
*/


#include "objc-private.h"
#include <objc/message.h>
#include <map>
#include "DenseMapExtras.h"

// expanded policy bits.

enum {
    OBJC_ASSOCIATION_SETTER_ASSIGN      = 0,
    OBJC_ASSOCIATION_SETTER_RETAIN      = 1,
    OBJC_ASSOCIATION_SETTER_COPY        = 3,            // NOTE:  both bits are set, so we can simply test 1 bit in releaseValue below.
    OBJC_ASSOCIATION_GETTER_READ        = (0 << 8),
    OBJC_ASSOCIATION_GETTER_RETAIN      = (1 << 8),
    OBJC_ASSOCIATION_GETTER_AUTORELEASE = (2 << 8)
};

spinlock_t AssociationsManagerLock;

namespace objc {

class ObjcAssociation {
    uintptr_t _policy;
    id _value;
public:
    ObjcAssociation(uintptr_t policy, id value) : _policy(policy), _value(value) {}
    ObjcAssociation() : _policy(0), _value(nil) {}
    ObjcAssociation(const ObjcAssociation &other) = default;
    ObjcAssociation &operator=(const ObjcAssociation &other) = default;
    ObjcAssociation(ObjcAssociation &&other) : ObjcAssociation() {
        swap(other);
    }

    inline void swap(ObjcAssociation &other) {
        std::swap(_policy, other._policy);
        std::swap(_value, other._value);
    }

    inline uintptr_t policy() const { return _policy; }
    inline id value() const { return _value; }

    inline void acquireValue() {
        if (_value) {
            switch (_policy & 0xFF) {
            case OBJC_ASSOCIATION_SETTER_RETAIN:
                _value = objc_retain(_value);
                break;
            case OBJC_ASSOCIATION_SETTER_COPY:
                _value = ((id(*)(id, SEL))objc_msgSend)(_value, @selector(copy));
                break;
            }
        }
    }

    inline void releaseHeldValue() {
        if (_value && (_policy & OBJC_ASSOCIATION_SETTER_RETAIN)) {
            objc_release(_value);
        }
    }

    inline void retainReturnedValue() {
        if (_value && (_policy & OBJC_ASSOCIATION_GETTER_RETAIN)) {
            objc_retain(_value);
        }
    }

    inline id autoreleaseReturnedValue() {
        if (slowpath(_value && (_policy & OBJC_ASSOCIATION_GETTER_AUTORELEASE))) {
            return objc_autorelease(_value);
        }
        return _value;
    }
};

typedef DenseMap<const void *, ObjcAssociation> ObjectAssociationMap;
typedef DenseMap<DisguisedPtr<objc_object>, ObjectAssociationMap> AssociationsHashMap;

// class AssociationsManager manages a lock / hash table singleton pair.
// Allocating an instance acquires the lock

class AssociationsManager {
    using Storage = ExplicitInitDenseMap<DisguisedPtr<objc_object>, ObjectAssociationMap>;
    static Storage _mapStorage;

public:
    AssociationsManager()   { AssociationsManagerLock.lock(); }
    ~AssociationsManager()  { AssociationsManagerLock.unlock(); }

    AssociationsHashMap &get() {
        return _mapStorage.get();
    }

    static void init() {
        _mapStorage.init();
    }
};

AssociationsManager::Storage AssociationsManager::_mapStorage;

} // namespace objc

using namespace objc;

void
_objc_associations_init()
{
    AssociationsManager::init();
}

id _object_get_associative_reference(id object, const void *key) {
    ObjcAssociation association{};

    {
        AssociationsManager manager;
        
        // manager.associations() 返回的是一个 `AssociationsHashMap` 对象(*_map)
        // 所以这里 `&associations` 中用了 `&`
        
        AssociationsHashMap &associations(manager.get());
        AssociationsHashMap::iterator i = associations.find((objc_object *)object);
        
        // intptr_t 是为了兼容平台，在64位的机器上，intptr_t和uintptr_t分别是long、int、unsigned long int的别名;在32位的机器上，intptr_t和uintptr_t分别是int、unsigned int的别名
        
        // DISGUISE 内部对指针做了 ~ 取反操作，“伪装”?
        if (i != associations.end()) {
            
            //refs当前对象的，找到后根据key取当前属性的（通过迭代器遍历获取）
            ObjectAssociationMap &refs = i->second;
            ObjectAssociationMap::iterator j = refs.find(key);
            if (j != refs.end()) {
                //赋值给association
                association = j->second;
                //如果关联策略包含retain, 这里就会retain一下。
                association.retainReturnedValue();
            }
        }
    }

    return association.autoreleaseReturnedValue();
}

void _object_set_associative_reference(id object, const void *key, id value, uintptr_t policy) {
    // This code used to work when nil was passed for object and key. Some code
    // probably relies on that to not crash. Check and handle it explicitly.
    // rdar://problem/44094390
    if (!object && !value) return;

    if (object->getIsa()->forbidsAssociatedObjects())
        _objc_fatal("objc_setAssociatedObject called on instance (%p) of class %s which does not allow associated objects", object, object_getClassName(object));

    DisguisedPtr<objc_object> disguised{(objc_object *)object};
    ObjcAssociation association{policy, value}; // <- association (policy, value)
 
    // retain the new value (if any) outside the lock.
    association.acquireValue();

    {
        //AssociationsManager是一个关联对象管理类，内部_mapStorage是个静态变量。
        //manager在这里是利用构造函数、析构函数特性来自动加锁、解锁，manager.get()从_mapStorage中读出所有的关联表associations。
        
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.get()); // <- AssociationsHashMap

        if (value) { //如果新的关联值不为空
            
            //根据disguised查找一个对应的ObjectAssociationMap，没有的话会创建一个并插入到associations中。
            auto refs_result = associations.try_emplace(disguised, ObjectAssociationMap{}); // disguised 和 ObjectAssociationMap
            if (refs_result.second) {
                object->setHasAssociatedObjects();
            }

            // 建立或者替换association（关联）
            auto &refs = refs_result.first->second;
            //根据key查找对应的bucket(key和association的封装)，替换掉原有的或插入新的association，并设置关联策略
            auto result = refs.try_emplace(key, std::move(association)); // <- key 和 association
            if (!result.second) {
                association.swap(result.first->second);
            }
        } else {
            //如果新的关联值为空，查找该对象的对应的ObjectAssociationMap，返回查找的迭代器。
            auto refs_it = associations.find(disguised);
            if (refs_it != associations.end()) {
                auto &refs = refs_it->second;
                auto it = refs.find(key);//通过key去refs中查找该属性的ObjectAssociation，返回查找的迭代器
                if (it != refs.end()) {
                    association.swap(it->second);
                    refs.erase(it);
                    
                    //如果refs也没有该对象的其他关联属性的话，直接从associations中移除该对象对应的refs_it。
                    if (refs.size() == 0) {
                        associations.erase(refs_it);
                    }
                }
            }
        }
    }

    // release the old value (outside of the lock).
    association.releaseHeldValue();
}

// Unlike setting/getting an associated reference,
// this function is performance sensitive because of
// raw isa objects (such as OS Objects) that can't track
// whether they have associated objects.
void
_object_remove_assocations(id object)
{
    ObjectAssociationMap refs{};

    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.get());
        AssociationsHashMap::iterator i = associations.find((objc_object *)object);
        if (i != associations.end()) {
            refs.swap(i->second);
            associations.erase(i);
        }
    }

    // release everything (outside of the lock).
    for (auto &i: refs) {
        i.second.releaseHeldValue();
    }
}
