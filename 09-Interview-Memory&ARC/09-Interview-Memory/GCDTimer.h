//
//  GCDTimer.h
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDTimer : NSObject

- (NSString *)excuteTask:(void(^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeat:(BOOL)repeat asnyc:(BOOL)async;

- (void)cancelTask:(NSString *)task;

@end

NS_ASSUME_NONNULL_END
