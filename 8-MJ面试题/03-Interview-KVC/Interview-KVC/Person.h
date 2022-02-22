//
//  Person.h
//  Interview-KVC
//
//  Created by Red-Fish on 2021/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QKCat : NSObject

@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) NSNumber *data;

@end

@interface Person : NSObject {
    @public
    NSInteger _age;
    NSInteger _isAge;
    NSInteger age;
    NSInteger isAge;
}

//@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) QKCat *cat;

@end

NS_ASSUME_NONNULL_END
