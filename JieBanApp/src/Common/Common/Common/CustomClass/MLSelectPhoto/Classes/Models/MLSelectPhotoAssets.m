//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLAssets.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "MLSelectPhotoAssets.h"

@implementation MLSelectPhotoAssets

- (UIImage *)thumbImage{
    return [UIImage imageWithCGImage:[self.asset thumbnail]];
}

- (UIImage *)originImage{
    //zmf add
//    return [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
    DDLogInfo(@"asset ==  %@",_asset);
    
    UIImage *image = [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
    
    if (image.size.height>4*image.size.width) {//eagle 长图时候不压缩，防止模糊
        UIImage *longImage = [UIImage imageWithCGImage:_asset.defaultRepresentation.fullResolutionImage
                                                 scale:_asset.defaultRepresentation.scale
                                           orientation:(UIImageOrientation)_asset.defaultRepresentation.orientation];
        return longImage;
        
    }
    return image;
}
- (UIImage *)realOriginImage{
    NSLog(@"asset ==  %@",_asset);
    
    //该方法导致内存暴涨
    UIImage *image = [UIImage imageWithCGImage:_asset.defaultRepresentation.fullResolutionImage
                                         scale:_asset.defaultRepresentation.scale
                                   orientation:(UIImageOrientation)_asset.defaultRepresentation.orientation];
    return image;
}
- (BOOL)isVideoType{
    NSString *type = [self.asset valueForProperty:ALAssetPropertyType];
    //媒体类型是视频
    return [type isEqualToString:ALAssetTypeVideo];
}

- (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size {
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInteger:size],
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}
static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        DDLogInfo(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

@end
