//
//  Person.h
//  Interview-KVO
//
//  Created by Red-Fish on 2021/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject {
    @public
    NSInteger _height;
}

@property (nonatomic, assign) NSInteger age;

@end

NS_ASSUME_NONNULL_END
