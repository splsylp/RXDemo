//
//  YXProgressView.m
//  Common
//
//  Created by yuxuanpeng on 2017/6/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXProgressView.h"

@interface YXProgressView ()

/**
 *  进度值0-1.0之间
 */
@property (nonatomic,assign)CGFloat progressValue;

@property (nonatomic, assign) CGFloat currentTime;

@end


@implementation YXProgressView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    DDLogInfo(@"width = %f",self.frame.size.width);
    CGPoint center = CGPointMake(self.frame.size.width/2.0, self.frame.size.width/2.0);  //设置圆心位置
    CGFloat radius = self.frame.size.width/2.0-5;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progressValue;  //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 10); //设置线条宽度
    [[UIColor colorWithRed:0.25f green:0.59f blue:0.31f alpha:1.00f] setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
}

- (void)setTimeMax:(NSInteger)timeMax {
    _timeMax = timeMax;
    self.currentTime = 0;
    self.progressValue = 0;
    [self setNeedsDisplay];

    self.hidden = NO;
    [self transformScale];
}

- (void)transformScale
{
   [UIView animateWithDuration:0.1 animations:^{
      // self.transform = CGAffineTransformMakeScale(1, 1);//宽高伸缩比例
       self.transform = CGAffineTransformIdentity;
   } completion:^(BOOL finished) {
       [self performSelector:@selector(startProgress) withObject:nil afterDelay:0.1];

   }];
}

- (void)clearProgress {
    _currentTime = _timeMax;
    self.hidden = YES;
    self.userInteractionEnabled = YES;
}

- (void)startProgress {
    _currentTime += 0.1;
    if (_timeMax > _currentTime) {
        _progressValue = _currentTime/_timeMax;
        DDLogInfo(@"progress = %f",_progressValue);
        [self setNeedsDisplay];
        [self performSelector:@selector(startProgress) withObject:nil afterDelay:0.1];
    }
    
    if (_timeMax <= _currentTime) {
        [self clearProgress];
        
    }
}

@end
