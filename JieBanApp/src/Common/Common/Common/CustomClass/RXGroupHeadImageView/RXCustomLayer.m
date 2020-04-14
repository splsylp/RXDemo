//
//  HXCustomLayer.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/6/8.
//  Copyright © 2016年 yuxuanpeng. All rights reserved.
//

#import "RXCustomLayer.h"
static inline float radians(double degrees) { return degrees * M_PI / 180; }
@interface RXCustomLayer ()

@property (nonatomic, assign) NSInteger degrees;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) BOOL isClip;

@end
@implementation RXCustomLayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _degrees = 0;
        _scale = 1.0;
        _isClip = YES;
    }
    return self;
}

+ (RXCustomLayer *)createWithImage:(UIImage *)image scale:(CGFloat)scale degrees:(NSInteger)degrees isClip:(BOOL)isClip
{
    RXCustomLayer *res = [RXCustomLayer layer];
    [res updateWithImage:image scale:scale degrees:degrees isClip:isClip];
    return res;
}

- (void)updateWithImage:(UIImage *)image scale:(CGFloat)scale degrees:(NSInteger)degrees isClip:(BOOL)isClip;
{
    _degrees = degrees;
    _scale = scale;
    _image = image;
    _isClip = isClip;
    self.contentsScale = 1/scale;
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    CGContextSetRGBFillColor(context, 0, 0, 1, 1);
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect bounds = self.bounds;
        CGSize size = bounds.size;
        CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, center.x, center.y);
        transform = CGAffineTransformRotate(transform, radians(_degrees));
        transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
        if (_isClip) {
            CGPathAddArc(path, &transform, size.width / 2.0, size.height / 2.0, size.width / 2.0, radians((90 - 30)), radians(90 + 30), 1);
            CGPathAddArcToPoint(path,&transform,
                                size.width / 2.0,
                                size.height / 2.0 + (size.width / 2.0 * sin(radians(90 - 30)) - size.width / 2.0 * sin(radians(30)) * tan(radians(30))),
                                size.width / 2.0 + size.width / 2.0 * sin(radians(30)),
                                size.height / 2.0 + size.width / 2.0 * sin(radians(90 - 30)),
                                size.width / 2.0);
        } else {
            CGPathAddArc(path, &transform, size.width / 2.0, size.height / 2.0, size.width / 2.0, radians((90)), radians(90 + 0.01), 1);
        }
        CGContextAddPath(context, path);
        CGContextClosePath(context);
        CGContextClip(context);
        UIGraphicsPushContext(context);
        [_image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIGraphicsPopContext();
        CGPathRelease(path);
    // 下面是圆形头像
//    CGContextSetRGBFillColor(context, 0, 0, 1, 1);
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGRect bounds = self.bounds;
//    CGSize size = bounds.size;
//    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    transform = CGAffineTransformTranslate(transform, center.x, center.y);
//    transform = CGAffineTransformRotate(transform, radians(_degrees));
//    transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
//    if (_isClip) {
//        CGPathAddArc(path, &transform, size.width / 2.0, size.height / 2.0, size.width / 2.0, radians((90 - 30)), radians(90 + 30), 1);
//        CGPathAddArcToPoint(path,&transform,
//                            size.width / 2.0,
//                            size.height / 2.0 + (size.width / 2.0 * sin(radians(90 - 30)) - size.width / 2.0 * sin(radians(30)) * tan(radians(30))),
//                            size.width / 2.0 + size.width / 2.0 * sin(radians(30)),
//                            size.height / 2.0 + size.width / 2.0 * sin(radians(90 - 30)),
//                            size.width / 2.0);
//    } else {
//        CGPathAddArc(path, &transform, size.width / 2.0, size.height / 2.0, size.width / 2.0, radians((90)), radians(90 + 0.01), 1);
//    }
//    CGContextAddPath(context, path);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    UIGraphicsPushContext(context);
//    [_image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    UIGraphicsPopContext();
//    CGPathRelease(path);
    
}
@end
