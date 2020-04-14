//
//  NSObject+ImageScaleSize.m
//  Common
//
//  Created by yuxuanpeng on 2017/8/7.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "NSObject+ImageScaleSize.h"
#define  IMImagescale 800
#define  otherImageSize 1280
@implementation NSObject (ImageScaleSize)

- (CGSize)getCompressCurrentImage:(CGSize)imgSize isIm:(BOOL)isIm
{
    CGFloat scaleScope = 0;
    if(isIm)
    {
        scaleScope = IMImagescale;
    }else
    {
        scaleScope = otherImageSize;
    }
    
    if(imgSize.height<=1280 && imgSize.width <=1280)
    {
    }
    //else if ((imgSize.height>scaleScope || imgSize.width>scaleScope) )
    return CGSizeMake(0, 0);
}

@end
