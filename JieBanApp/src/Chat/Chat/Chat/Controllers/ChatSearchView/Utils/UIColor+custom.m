//
//  UIColor+Custom.m
//  
//
//  Created by mac on 17/4/19.
//  Copyright (c) 2017年 mac. All rights reserved.
//

#import "UIColor+Custom.h"

@implementation UIColor (custom)
+ (UIColor *)colorWithHex:(int)color {
    
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

+ (UIColor *)mask {
    return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
}

+ (UIColor *)cardBackground {
    return  [UIColor colorWithHex:0xffffffff];
}

+ (UIColor *)cardHighlightBackground {
    return [UIColor colorWithHex:0xeeeeeeff];
}

+ (UIColor *)viewBackground {
    return [UIColor colorWithHex:0xe5e5e5ff];
}

+ (UIColor *)separator {
    return [UIColor colorWithHex:0xbbbbbbff];
}

+ (UIColor *)titleBarBackground {
    return [UIColor colorWithHex:0x424242ff];
}

+ (UIColor *)textColor {
    return [UIColor colorWithHex:0x444444ff];
}

+ (UIColor *)textColor2 {
    return [UIColor colorWithHex:0x666666ff];
}

+ (UIColor *)textColor3 {
    return [UIColor colorWithHex:0x999999ff];
}

+ (UIColor *)blueColor1 {
    return [UIColor colorWithHex:0x71c9f2ff];
}

+ (UIColor *)blueColor2 {
    return [UIColor colorWithHex:0x71c9f2ff];
}

+ (UIColor *)blueColor3 {
    return [UIColor colorWithHex:0x00acedff];
}

+ (UIColor *)blueColor4 {
    return [UIColor colorWithHex:0x12a5eaff];
}

+ (UIColor *)qqBlue {
    return [UIColor colorWithHex:0x25b7eeff];
}

+ (UIColor *)wechatGreen {
    return [UIColor colorWithHex:0x09bb07ff];
}

+ (UIColor *)greenColor1 {
    return [UIColor colorWithHex:0x22c064ff];
}

+ (UIColor *)redColor1 {
    return [UIColor colorWithHex:0xff5c26ff];
}

+ (UIColor *)disableColor {
    return [UIColor colorWithHex:0xeeeeeeff];
}

+ (UIColor *)disableTextColor {
    return [UIColor colorWithHex:0x8bbef2ff];
}

+ (UIColor *)disableTextColor2 {
    return [UIColor colorWithHex:0x999999ff];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
