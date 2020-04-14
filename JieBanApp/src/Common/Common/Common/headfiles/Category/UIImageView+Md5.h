//
//  UIImageView+Md5.h
//  Common
//
//  Created by yuxuanpeng on 2017/6/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXThirdPart.h"
@interface UIImageView (Md5)

/**
 * urlStr 下载的图片Url
 * urlmd5  图片md5值
 * placeholder 默认图片
 * isRefreshCached 是否刷新缓存
 **/
- (void)setImageWithURLString:(NSString *)urlStr urlmd5:(NSString*)urlmd5 options:(SDWebImageOptions)options placeholderImage:(UIImage *)placeholder withRefreshCached:(BOOL)isRefreshCached;
/**
 * headUrl 头像下载地址
 * md5Str 头像的md5
 */
- (BOOL)hasCurrentRequestCache:(NSString *)headUrl withMd5:(NSString *)md5Str;

/**
 * md5  头像的md5
 * headUrl  头像下载地址
 */
- (void)setMd5:(NSString *)md5 withKey:(NSString *)headUrl;

@end
