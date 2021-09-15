//
//  NSObject+Model.m
//  RunTime
//
//  Created by Red-Fish on 2021/9/9.
//

#import "NSObject+Model.h"
#import <objc/runtime.h>

@implementation NSObject (Model)

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    id object = [[self alloc] init];
    
    unsigned int count;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    
    // 遍历propertyList中所有属性，以其属性名为key，在字典中查找value
    for (int i = 0; i < count; i++) {
        
        objc_property_t property = propertyList[i]; // 获取属性
        const char *propertyName = property_getName(property);
        
        NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
        
        // 获取json中属性value
        id value = [dictionary objectForKey:propertyNameString];
        
        // 获取属性所属类名
        NSString *propertyType;
        unsigned int attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (int j = 0; j < attrCount; j++) {
            switch (attrs[j].name[0]) {
                case 'T':
                    if (attrs[i].value) {
                        propertyType = [NSString stringWithUTF8String:attrs[j].value];
                        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"@" withString:@""];
                    } break;
                    
                default: break;
            }
        }
        
        // 对特殊属性进行处理
        // 判断当前类是否实现了协议方法，获取协议方法中规定的特殊属性的处理方法
        NSDictionary *propertyTypeDict;
        if ([self respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
            propertyTypeDict = [self performSelector:@selector(modelContainerPropertyGenericClass)];
        }
        
        // 处理：字典的 key 与模型属性不匹配的问题，如 id -> uid
        id anotherName = propertyTypeDict[propertyNameString];
        if (anotherName && [anotherName isKindOfClass:[NSString class]]) {
            value = dictionary[anotherName];
        }
        
        // 处理：模型嵌套模型的情况
        if ([value isKindOfClass:[NSDictionary class]] && ![propertyType hasPrefix:@"NS"]) {
            Class modelClass = NSClassFromString(propertyType);
            if (modelClass != nil) {
                // 将被嵌套字典数据也转化成Model
                value = [modelClass modelWithDictionary:value];
            }
        }
        
        // 处理：模型嵌套模型数组的情况
        // 判断当前 value 是一个数组，而且存在协议方法返回了 perpertyTypeDic
        if ([value isKindOfClass:[NSArray class]] && propertyTypeDict) {
            Class itemModelClass = propertyTypeDict[propertyNameString];
            //封装数组：将每一个子数据转化为 Model
            NSMutableArray *itemArray = @[].mutableCopy;
            for (NSDictionary *itemDic  in value) {
                id model = [itemModelClass modelWithDictionary:itemDic];
                [itemArray addObject:model];
            }
            value = itemArray;
        }
        
        // 使用 KVC 方法将 value 更新到 object 中
        if (value != nil) {
            [object setValue:value forKey:propertyNameString];
        }
    }
    
    free(propertyList);
    
    return object;
}

@end
