//
//  HXWaterStainLayer.m
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 2017/4/7.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXWaterStainLayer.h"
#define  isOpenChangeWater  0
@implementation HXWaterStainLayer

+ (HXWaterStainLayer *) initLayer
{

    HXWaterStainLayer *overlayLayer = [HXWaterStainLayer layer];
    UIImage *waterImage;
    if (IsHengFengTarget && isOpenChangeWater) {
        //没有用到
//        waterImage =ThemeImage(@"恒丰银行水印.png");
        overlayLayer.frame = CGRectMake((kScreenWidth-249.5*fitScreenWidth)/2, (kScreenHeight-kTotalBarHeight-473.5*fitScreenWidth)/2,249.5*fitScreenWidth,473.5*fitScreenWidth);
    }else{
        
        NSString *name = [Common sharedInstance].getUserName;
        NSString *staffNo = [Common sharedInstance].getStaffNo;
//        if (name.length > 2) {
//            name = [name substringFromIndex:(name.length - 2)];
//        }
        NSString *mobile = [Common sharedInstance].getMobile;
        if (mobile.length > 4) {
            mobile = [mobile substringFromIndex:(mobile.length -4)];
        }
        
        //1.获取上下文
        CGRect bounds = [UIScreen mainScreen].bounds;
        UIGraphicsBeginImageContext(bounds.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        CGContextFillRect(context, bounds);
        
        CGFloat width = 120*fitScreenWidth;
        CGFloat height = 100;
        UIFont *font = ThemeFontLarge;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        
        style.alignment = NSTextAlignmentCenter;
        
        //文字的属性
        
        NSDictionary *dic = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:[UIColor colorWithWhite:0.667 alpha:.2]};
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(c, -M_PI/6);
        
        for (int x = 0; x*width<kScreenWidth; x++) {
            for (int y = 0; y*height<kScreenHeight; y++) {
                //3.绘制水印文字
                
                CGRect rect = CGRectMake(x*width+(y+1)%2*(width/2), y*height, width, height);
                rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(M_PI/6));
                //将文字绘制上去
                // hanwei start
                if (KCNSSTRING_ISEMPTY(staffNo)) {
                    [[NSString stringWithFormat:@"%@\n%@",name, mobile] drawInRect:rect withAttributes:dic];
                }
                else {
                    [[NSString stringWithFormat:@"%@\n%@",name, staffNo] drawInRect:rect withAttributes:dic];
                }

                // hanwei end
            }
        }
        
        
        //4.获取绘制到得图片
        
        waterImage = UIGraphicsGetImageFromCurrentImageContext();
        
        
        
        //5.结束图片的绘制
        
        UIGraphicsEndImageContext();

        overlayLayer.frame = bounds;
    }

    [overlayLayer setBackgroundColor:[UIColor clearColor].CGColor];
    overlayLayer.contents =(id)waterImage.CGImage;
    
    [overlayLayer setMasksToBounds:YES];
    
    return overlayLayer;
    
}



@end
