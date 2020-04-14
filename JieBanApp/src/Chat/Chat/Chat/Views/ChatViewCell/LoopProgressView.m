#import "LoopProgressView.h"
#import <QuartzCore/QuartzCore.h>

#define ViewWidth self.frame.size.width   //环形进度条的视图宽度
#define ProgressWidth 2.5                 //环形进度条的圆环宽度
#define Radius ViewWidth/2-ProgressWidth  //环形进度条的半径
#define DEGREES_DefaultStart(degrees)  ((3.14 * (degrees+270))/ 180) //默认270度为开始的位置
#define DEGREES_TO_RADIANS(degrees)  ((pi * degrees)/ 180)         //转化为度
@interface LoopProgressView()
{
    CAShapeLayer *arcLayer;
    UILabel *label;
    NSTimer *progressTimer;
    CGRect myRect;
}
@property (nonatomic,assign)CGFloat i;
@property (nonatomic ,assign) CGFloat startPercent;
@property (nonatomic ,assign) CGFloat endPercent;
@property (nonatomic ,assign) BOOL isHaveLabel;
@end

@implementation LoopProgressView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
   
    myRect = rect;
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    _i=0;
   
    if (!_isHaveLabel) {
        _isHaveLabel = YES;
        // 背后的圆圈
        CGContextRef progressContext = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(progressContext, ProgressWidth);
        CGContextSetRGBStrokeColor(progressContext, 183.0/255.0, 183.0/255.0, 183.0/255.0, 1);
        CGFloat startA = 0;
        CGFloat endA = self.progress*2*M_PI;
        NSLog(@"startA = %lf,endA =%lf",startA,endA);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(xCenter, yCenter) radius:Radius startAngle:startA endAngle:2*M_PI clockwise:YES];
        CGContextAddPath(progressContext, path.CGPath);
        CGContextStrokePath(progressContext);
        
        // 进度数字字号,可自己根据自己需要，从视图大小去适配字体字号
        int fontNum = ViewWidth/6;
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,Radius+10, ViewWidth/6)];
        label.center = CGPointMake(xCenter, yCenter);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:fontNum];
        label.text = @"0%";
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        
    }
    //    //绘制环形进度环
    CGContextRef progressContext2 = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(progressContext2, ProgressWidth);
    CGContextSetRGBStrokeColor(progressContext2, 255.0/255.0, 255.0/255.0, 255.0/255.0, 1);
    CGFloat startA = 0;
    CGFloat endA = self.progress*2*M_PI;
    NSLog(@"startA = %lf,endA =%lf",startA,endA);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(xCenter, yCenter) radius:Radius startAngle:startA endAngle:endA clockwise:YES];
    CGContextAddPath(progressContext2, path.CGPath);
    CGContextStrokePath(progressContext2);
    

}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    label.text = [NSString stringWithFormat:@"%.0f%%",_progress*100];
    [self setNeedsDisplay];
}


@end
