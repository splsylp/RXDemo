//
//  NSObject+ImageScaleSize.h
//  Common
//
//  Created by yuxuanpeng on 2017/8/7.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ImageScaleSize)

/**
 * 图片压缩尺寸
 * imgSize 当前图片的尺寸
 * isIm  是否是IM消息图片
 */
- (CGSize)getCompressCurrentImage:(CGSize)imgSize isIm:(BOOL)isIm;

@end
