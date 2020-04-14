//
//  UIColor+Ext.h
//  Lafaso
//
//  Created by yuxuanpeng on 14-7-8.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Ext)

+ (UIColor *)colorWithIntRed:(uint)red green:(uint)green blue:(uint)blue alpha:(uint)alpha;
+ (UIColor *)colorWithRGB:(uint)rgb;
+ (UIColor*)colorWithARGB:(NSInteger)argbOrRGB;

@end

@interface UIColor (string)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHex:(int)hex;
+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;

@end

@interface UIColor (image)

+ (UIImage *)createImageWithColor:(UIColor *)color;
+ (UIImage *)createImageWithColor:(UIColor *)color withRadius:(float)Radius;
+ (UIImage *)createImageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (UIImage *)createImageWithColor:(UIColor *)color andSize:(CGSize)size withRadius:(float)Radius;
@end
