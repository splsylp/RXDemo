//
//  HXCustomLayer.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/6/8.
//  Copyright © 2016年 yuxuanpeng. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface RXCustomLayer : CALayer
+(RXCustomLayer *)createWithImage:(UIImage *)image scale:(CGFloat)scale degrees:(NSInteger)degrees isClip:(BOOL)isClip;
- (void)updateWithImage:(UIImage *)image scale:(CGFloat)scale degrees:(NSInteger)degrees isClip:(BOOL)isClip;
@end
