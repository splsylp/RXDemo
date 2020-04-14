//
//  WaterMarkView.m
//  AddressBook
//
//  Created by ywj on 2017/2/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "WaterMarkView.h"

@interface WaterMarkView ()

@end

@implementation WaterMarkView

- (instancetype)initWithFrame:(CGRect)frame mobile:(NSString *)mobile userName:(NSString *)name  backColor:(UIColor *)color{
    if (self = [super initWithFrame:frame]) {
        [self setupWaterUIWithStaffNo:mobile andUserName:name backColor:color];
    }
    return self;
}

- (void)setupWaterUIWithStaffNo:(NSString *)staffNo andUserName:(NSString *)name  backColor:(UIColor *)color{
    if (name.length>2) {
        name = [name substringFromIndex:name.length -2];
    }

    CGFloat width = self.bounds.size.width;

    CGFloat fitScreenWidth = (self.bounds.size.width/320);
    
    self.backgroundColor = color ? : [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];

    //透明视图 放label 之后整个视图倾斜
    UIView *clearView = [[UIView alloc] initWithFrame:self.bounds];
    clearView.backgroundColor = [UIColor clearColor];

    for (NSInteger index = 0 ; index < 64; index++) {
        int left =  ((width - 50*fitScreenWidth*3)/4 + 50*fitScreenWidth)*index;
        NSInteger t = index/4; //行数 0 1 2 3 4 ....
        NSInteger d = fmod(index, 4); //第几个 0.1.2.3
        
        int top = (40.0f*fitScreenWidth+50)*t + 30;

        left = (width - 450*fitScreenWidth)/4*(d) + 150 *fitScreenWidth*d;
    
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 200*fitScreenWidth, 20)];
        label.text = [NSString stringWithFormat:@"%@  %@",name, staffNo];
        label.textColor = [UIColor lightGrayColor];
        label.alpha = 0.2;
        label.userInteractionEnabled = NO;
        [clearView addSubview:label];
        
        label.transform = CGAffineTransformMakeRotation(-M_PI/12);// 逆时针旋转30度
    }
    
    clearView.layer.masksToBounds = YES;
    self.clipsToBounds = YES; //超出self.bounds部分裁剪
    
    [self addSubview:clearView];
    
}
@end
