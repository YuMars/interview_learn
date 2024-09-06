//
//  Proxy.h
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Proxy : NSObject

+ (instancetype)proxyWithTarget:(id)target;

@property (nonatomic, weak) id target;

@end

NS_ASSUME_NONNULL_END
