//
//  StartButton.m
//  ZZYWeiXinShortMovie
//
//  Created by zhangziyi on 16/3/23.
//  Copyright © 2016年 GLaDOS. All rights reserved.
//

#import "StartButton.h"


@implementation StartButton
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.frame = self.bounds;  //(76-5)/2*iPhone6FitScreenWidth+10 = 45.5
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:_circleLayer.position radius: 45.5*iPhone6FitScreenWidth startAngle:-M_PI endAngle:M_PI clockwise:YES];
        _circleLayer.path = path.CGPath;
        _circleLayer.lineWidth = 5/2*iPhone6FitScreenWidth;
        _circleLayer.fillColor = [UIColor colorWithHexString:@"#C9C9C9"].CGColor;
        _circleLayer.strokeColor = [UIColor colorWithHexString:@"#C9C9C9"].CGColor;

        _circleLayer.opacity = 1;
        [self.layer addSublayer:_circleLayer];
        
        
        
        CAShapeLayer *blackLayer = [CAShapeLayer layer];
        blackLayer.frame = self.bounds;
        UIBezierPath *blackPath = [UIBezierPath bezierPathWithArcCenter:_circleLayer.position radius:66/2*iPhone6FitScreenWidth startAngle:-M_PI endAngle:M_PI clockwise:YES];
        blackLayer.path = blackPath.CGPath;
        blackLayer.lineWidth = 5/2*iPhone6FitScreenWidth;
        blackLayer.fillColor = [UIColor colorWithHexString:@"#ECECEC"].CGColor;
        blackLayer.strokeColor = [UIColor colorWithHexString:@"#ECECEC"].CGColor;

        [self.layer addSublayer:blackLayer];
        self.blackLayer = blackLayer;
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        _label.center = CGPointMake(self.frame.size.width/2, -self.frame.size.height/2);
        _label.textColor = [UIColor whiteColor];
        _label.text = @"按住拍摄";
        _label.textAlignment = NSTextAlignmentCenter;
        [_label setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_label];
    }
    return self;
}

-(void)disappearAnimation{
    _label.hidden = YES;
    _circleLayer.hidden = YES;
    CABasicAnimation *animation_scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation_scale.toValue = @1.3;//@1.5; //缩放比例
    CABasicAnimation *animation_opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation_opacity.toValue = @1;//@0.5; 透明度变化
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    aniGroup.duration = 0.2;
    aniGroup.animations = @[animation_scale,animation_opacity];
    aniGroup.fillMode = kCAFillModeForwards;
    aniGroup.removedOnCompletion = NO;
    [_blackLayer addAnimation:aniGroup forKey:@"start"];
    [_label.layer addAnimation:aniGroup forKey:@"start1"];
}

-(void)appearAnimation{
    _label.hidden = NO;
     _circleLayer.hidden = NO;
    CABasicAnimation *animation_scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation_scale.toValue = @1;
    CABasicAnimation *animation_opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation_opacity.toValue = @1;
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    aniGroup.duration = 0.2;
    aniGroup.animations = @[animation_scale,animation_opacity];
    aniGroup.fillMode = kCAFillModeForwards;
    aniGroup.removedOnCompletion = NO;
    [_blackLayer addAnimation:aniGroup forKey:@"reset"];
    [_label.layer addAnimation:aniGroup forKey:@"reset1"];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
