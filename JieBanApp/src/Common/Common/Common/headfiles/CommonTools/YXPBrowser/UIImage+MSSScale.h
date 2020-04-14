//
//  UIImage+MSSScale.h
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/6.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MSSScale)

// 得到图像显示完整后的frame
- (CGRect)mss_getBigImageRectSizeWithScreenWidth:(CGFloat)sWidth ScreenHeight:(CGFloat)sHeight;
@end
