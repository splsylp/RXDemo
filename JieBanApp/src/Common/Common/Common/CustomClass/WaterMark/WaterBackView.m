//
//  WaterBackView.m
//  Common
//
//  Created by zhangmingfei on 2017/3/8.
//  Copyright © 2017年 ronglian. All rights reserved.
//
#define cellHeight 60.0f
#import "WaterBackView.h"
#import "KCConstants_API.h"
@implementation WaterBackView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        [self setupUIWithFrame:frame];
    }
    return self;
}

//页面布局
- (void)setupUIWithFrame:(CGRect)frame {
//    self.backgroundColor = [UIColor whiteColor];
    
    //水印要求在cell上 显示名字后两位和手机号后四位
    if (isHaveWaterView == 1) {
        NSInteger index = 0;
        CGFloat maxX = 0;
        while (maxX < kScreenWidth) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10*fitScreenWidth + index * 120*fitScreenWidth, frame.size.height- 37*(frame.size.height/cellHeight)*fitScreenHeight, 70*fitScreenWidth, 20)];
            NSString *name = [Common sharedInstance].getUserName;
            if (name.length > 2) {
                name = [name substringFromIndex:(name.length - 2)];
            }
            NSString *mobile = [Common sharedInstance].getMobile;
            if (mobile.length > 4) {
                mobile = [mobile substringFromIndex:(mobile.length -4)];
            }
            label.text = [NSString stringWithFormat:@"%@%@",name,mobile];
            label.textColor = [UIColor lightGrayColor];
            label.font = ThemeFontLarge;
            label.alpha = 0.3;
            [self addSubview:label];
            index++;
            maxX = CGRectGetMaxX(label.frame);
            label.transform = CGAffineTransformMakeRotation(-M_PI/6);// 逆时针旋转30度
        }
        self.clipsToBounds = YES; //超出self.bounds部分裁剪
    }
    else if (isHaveWaterView == 0) {
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
