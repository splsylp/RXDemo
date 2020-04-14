//
//  UIImage+MSSScale.m
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/6.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import "UIImage+MSSScale.h"

@implementation UIImage (MSSScale)

// 得到图像显示完整后的宽度和高度
- (CGRect)mss_getBigImageRectSizeWithScreenWidth:(CGFloat)sWidth ScreenHeight:(CGFloat)sHeight
{
    CGFloat widthRatio = sWidth / self.size.width;
    CGFloat heightRatio = sHeight / self.size.height;
    CGFloat scale = MIN(widthRatio, heightRatio);
    CGFloat width = scale * self.size.width;
    CGFloat height = scale * self.size.height;
    return CGRectMake((sWidth - width) / 2, (sHeight - height) / 2, width, height);
}

@end
