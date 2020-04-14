//
//  UIImage+RX_MLTint.h
//  MLSelectPhoto
//
//  Created by 张磊 on 15/4/23.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RX_MLTint)
//这方法和iOS13 tableviewcell的箭头有冲突，代码中没有用到这个图片选择器，先注释掉它的实现方法
- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;
@end
