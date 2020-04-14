//
//  SectorProgress.m
//  Chat
//
//  Created by lxj on 2018/11/16.
//  Copyright © 2018 ronglian. All rights reserved.
//

#import "SectorProgress.h"

@interface SectorProgress()

@property(strong,nonatomic) UILabel *progressLabel;

@end

@implementation SectorProgress

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];

        self.progressLabel = [[UILabel alloc] init];
        self.progressLabel.font = [UIFont systemFontOfSize:9];
        [self addSubview:self.progressLabel];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.progressLabel.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect{
    CGFloat width = self.width;
    //定义扇形中心
    CGPoint origin = CGPointMake(width/2, width/2);
    //定义扇形半径
    CGFloat radius = width/2;
    //设定扇形起点位置
    CGFloat startAngle = - M_PI_2;
    //根据进度计算扇形结束位置
    CGFloat endAngle = startAngle + self.progress * M_PI * 2;

    //根据起始点、原点、半径绘制弧线
    UIBezierPath *sectorPath = [UIBezierPath bezierPathWithArcCenter:origin radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    //从弧线结束为止绘制一条线段到圆心。这样系统会自动闭合图形，绘制一条从圆心到弧线起点的线段。
    [sectorPath addLineToPoint:origin];
    //    设置扇形的填充颜色
    [[UIColor darkGrayColor] set];
    //设置扇形的填充模式
    [sectorPath fill];
}


//重写progress的set方法，可以在赋值的同时给label赋值
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    //对label进行赋值
    self.progressLabel.text = [NSString stringWithFormat:@"%0.2f%%",progress * 100];
    //赋值结束之后要刷新UI，不然看不到扇形的变化
    [self setNeedsDisplay];
}

@end
