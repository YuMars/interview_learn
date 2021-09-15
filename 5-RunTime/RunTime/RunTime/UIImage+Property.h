//
//  UIImage+Property.h
//  RunTime
//
//  Created by Red-Fish on 2021/9/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Property)

@property (nonatomic, copy) NSString *urlString;

- (void)clearAssociatedObject;

@end

NS_ASSUME_NONNULL_END
