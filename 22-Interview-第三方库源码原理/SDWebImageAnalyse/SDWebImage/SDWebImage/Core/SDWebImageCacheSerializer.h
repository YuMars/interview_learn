/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

typedef NSData * _Nullable(^SDWebImageCacheSerializerBlock)(UIImage * _Nonnull image, NSData * _Nullable data, NSURL * _Nullable imageURL);

/**
 This is the protocol for cache serializer.
 We can use a block to specify the cache serializer. But Using protocol can make this extensible, and allow Swift user to use it easily instead of using `@convention(block)` to store a block into context options.
 */
@protocol SDWebImageCacheSerializer <NSObject>

/// 提供与图像关联的图像数据并存储到磁盘缓存
/// @param image 加载的图像
/// @param data 最初加载的图像数据。图像转换时可能为nil(UIImage.sd_isTransformed = YES)
/// @param imageURL 图像URL
- (nullable NSData *)cacheDataWithImage:(nonnull UIImage *)image originalData:(nullable NSData *)data imageURL:(nullable NSURL *)imageURL;

@end

/**
 A cache serializer class with block.
 */
@interface SDWebImageCacheSerializer : NSObject <SDWebImageCacheSerializer>

- (nonnull instancetype)initWithBlock:(nonnull SDWebImageCacheSerializerBlock)block;
+ (nonnull instancetype)cacheSerializerWithBlock:(nonnull SDWebImageCacheSerializerBlock)block;

@end
