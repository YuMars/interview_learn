//
//  NSObject+Model.h
//  RunTime
//
//  Created by Red-Fish on 2021/9/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSObjectModel <NSObject>

@optional

+ (NSDictionary <NSString *, id> *)modelContainerPropertyGenericClass;

@end

@interface NSObject (Model)

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
