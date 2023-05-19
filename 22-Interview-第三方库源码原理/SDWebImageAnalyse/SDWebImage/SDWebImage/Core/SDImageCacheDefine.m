/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageCacheDefine.h"
#import "SDImageCodersManager.h"
#import "SDImageCoderHelper.h"
#import "SDAnimatedImage.h"
#import "UIImage+Metadata.h"
#import "SDInternalMacros.h"

#import <CoreServices/CoreServices.h>

SDImageCoderOptions * _Nonnull SDGetDecodeOptionsFromContext(SDWebImageContext * _Nullable context, SDWebImageOptions options, NSString * _Nonnull cacheKey) {
    BOOL decodeFirstFrame = SD_OPTIONS_CONTAINS(options, SDWebImageDecodeFirstFrameOnly);
    NSNumber *scaleValue = context[SDWebImageContextImageScaleFactor];
    CGFloat scale = scaleValue.doubleValue >= 1 ? scaleValue.doubleValue : SDImageScaleFactorForKey(cacheKey);
    NSNumber *preserveAspectRatioValue = context[SDWebImageContextImagePreserveAspectRatio];
    NSValue *thumbnailSizeValue;
    BOOL shouldScaleDown = SD_OPTIONS_CONTAINS(options, SDWebImageScaleDownLargeImages);
    if (shouldScaleDown) {
        CGFloat thumbnailPixels = SDImageCoderHelper.defaultScaleDownLimitBytes / 4;
        CGFloat dimension = ceil(sqrt(thumbnailPixels));
        thumbnailSizeValue = @(CGSizeMake(dimension, dimension));
    }
    if (context[SDWebImageContextImageThumbnailPixelSize]) {
        thumbnailSizeValue = context[SDWebImageContextImageThumbnailPixelSize];
    }
    NSString *typeIdentifierHint = context[SDWebImageContextImageTypeIdentifierHint];
    NSString *fileExtensionHint;
    if (!typeIdentifierHint) {
        // UTI has high priority
        fileExtensionHint = cacheKey.pathExtension; // without dot
        if (fileExtensionHint.length == 0) {
            // Ignore file extension which is empty
            fileExtensionHint = nil;
        }
    }
    
    // First check if user provided decode options
    SDImageCoderMutableOptions *mutableCoderOptions;
    if (context[SDWebImageContextImageDecodeOptions] != nil) {
        mutableCoderOptions = [NSMutableDictionary dictionaryWithDictionary:context[SDWebImageContextImageDecodeOptions]];
    } else {
        mutableCoderOptions = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    
    // Override individual options
    mutableCoderOptions[SDImageCoderDecodeFirstFrameOnly] = @(decodeFirstFrame);
    mutableCoderOptions[SDImageCoderDecodeScaleFactor] = @(scale);
    mutableCoderOptions[SDImageCoderDecodePreserveAspectRatio] = preserveAspectRatioValue;
    mutableCoderOptions[SDImageCoderDecodeThumbnailPixelSize] = thumbnailSizeValue;
    mutableCoderOptions[SDImageCoderDecodeTypeIdentifierHint] = typeIdentifierHint;
    mutableCoderOptions[SDImageCoderDecodeFileExtensionHint] = fileExtensionHint;
    
    return [mutableCoderOptions copy];
}

void SDSetDecodeOptionsToContext(SDWebImageMutableContext * _Nonnull mutableContext, SDWebImageOptions * _Nonnull mutableOptions, SDImageCoderOptions * _Nonnull decodeOptions) {
    if ([decodeOptions[SDImageCoderDecodeFirstFrameOnly] boolValue]) {
        *mutableOptions |= SDWebImageDecodeFirstFrameOnly;
    } else {
        *mutableOptions &= ~SDWebImageDecodeFirstFrameOnly;
    }
    
    mutableContext[SDWebImageContextImageScaleFactor] = decodeOptions[SDImageCoderDecodeScaleFactor];
    mutableContext[SDWebImageContextImagePreserveAspectRatio] = decodeOptions[SDImageCoderDecodePreserveAspectRatio];
    mutableContext[SDWebImageContextImageThumbnailPixelSize] = decodeOptions[SDImageCoderDecodeThumbnailPixelSize];
    
    NSString *typeIdentifierHint = decodeOptions[SDImageCoderDecodeTypeIdentifierHint];
    if (!typeIdentifierHint) {
        NSString *fileExtensionHint = decodeOptions[SDImageCoderDecodeFileExtensionHint];
        if (fileExtensionHint) {
            typeIdentifierHint = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtensionHint, kUTTypeImage);
            // Ignore dynamic UTI
            if (UTTypeIsDynamic((__bridge CFStringRef)typeIdentifierHint)) {
                typeIdentifierHint = nil;
            }
        }
    }
    mutableContext[SDWebImageContextImageTypeIdentifierHint] = typeIdentifierHint;
}

UIImage * _Nullable SDImageCacheDecodeImageData(NSData * _Nonnull imageData, NSString * _Nonnull cacheKey, SDWebImageOptions options, SDWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(cacheKey);
    UIImage *image;
    // 解析解码选项，优先用context里面的，否则就用以下流程
    // 1.是否值解析第一帧
    // 2.根据2x、3x，或者context[SDWebImageContextImageScaleFactor]缩放因子做缩放
    // 3.保留宽高比
    // 4.根据最大60M做缩放
    // 5.类型标识符提示（是什么格式的图片）
    // 6.获取context里面的解码选项
    SDImageCoderOptions *coderOptions = SDGetDecodeOptionsFromContext(context, options, cacheKey);
    BOOL decodeFirstFrame = SD_OPTIONS_CONTAINS(options, SDWebImageDecodeFirstFrameOnly);
    CGFloat scale = [coderOptions[SDImageCoderDecodeScaleFactor] doubleValue];
    
    // Grab the image coder
    id<SDImageCoder> imageCoder = context[SDWebImageContextImageCoder];
    if (!imageCoder) {
        imageCoder = [SDImageCodersManager sharedManager];
    }
    
    if (!decodeFirstFrame) {
        // 开始解码
        Class animatedImageClass = context[SDWebImageContextAnimatedImageClass];
        // check whether we should use `SDAnimatedImage`
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(SDAnimatedImage)]) {
            image = [[animatedImageClass alloc] initWithData:imageData scale:scale options:coderOptions];
            if (image) {
                // Preload frames if supported
                if (options & SDWebImagePreloadAllFrames && [image respondsToSelector:@selector(preloadAllFrames)]) {
                    [((id<SDAnimatedImage>)image) preloadAllFrames];
                }
            } else {
                // Check image class matching
                if (options & SDWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) { // 还没图片，继续解码
        image = [imageCoder decodedImageWithData:imageData options:coderOptions];
    }
    if (image) {
        BOOL shouldDecode = !SD_OPTIONS_CONTAINS(options, SDWebImageAvoidDecodeImage);
        BOOL lazyDecode = [coderOptions[SDImageCoderDecodeUseLazyDecoding] boolValue];
        if (lazyDecode) {
            // lazyDecode = NO means we should not forceDecode, highest priority
            shouldDecode = NO;
        }
        if (shouldDecode) {
            image = [SDImageCoderHelper decodedImageWithImage:image];
        }
        // assign the decode options, to let manager check whether to re-decode if needed
        image.sd_decodeOptions = coderOptions;
    }
    
    return image;
}
