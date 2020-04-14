//
//  HXShareBonceView.m
//  ECSDKDemo_OC
//
//  Created by 王明哲 on 16/9/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXShareBonceView.h"
#import "UIView+Ext.h"

#define KITCOLOR    [UIColor colorWithRed:0/255.0   green:153/255.0  blue:255/255.0  alpha:1]
#define LAYERCOLOR  [UIColor colorWithRed:100/255.0 green:100/255.0  blue:100/255.0  alpha:1]

@interface HXShareBonceView()
@property (nonatomic , retain) UIView *mainView;
@property (nonatomic , copy)  ClickButtonBlock buttonBlock;

@end

@implementation HXShareBonceView

- (void)createBonceViewWithFrame:(CGRect)frame buttonBlock:(ClickButtonBlock)block{
    self.frame=frame;
    self.backgroundColor=[UIColor clearColor];
    
    //layer
    self.layer.borderWidth =1;
    self.layer.masksToBounds = YES;
    self.layer.borderColor =LAYERCOLOR.CGColor;
    
    //block
    self.buttonBlock = [block copy];
    
    //mainView
    self.mainView =[[UIView alloc]init];
    self.mainView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.mainView.backgroundColor=[UIColor whiteColor];
    self.mainView.userInteractionEnabled=YES;
    [self insertSubview:self.mainView aboveSubview:self];
    
    //共享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [shareBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [shareBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [shareBtn setFrame:CGRectMake(20, 10, frame.size.width-40, 40)];
    [shareBtn setTitle:@"共享" forState:UIControlStateNormal];
    [shareBtn setTitleColor:KITCOLOR forState:UIControlStateNormal];
    [self.mainView addSubview:shareBtn];
    
    //分割线
    UIImageView *sepImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, shareBtn.bottom, frame.size.width-20, 2)];
    [sepImageView setBackgroundColor:KITCOLOR];
    [self.mainView addSubview:sepImageView];
    
    //白板 文档 取消
    NSArray *titleArray = @[@"白板",@"文档",@"取消"];
    for (NSInteger i = 0; i < 3; i ++) {
        UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempBtn setTag:i];
        [tempBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [tempBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [tempBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [tempBtn setFrame:CGRectMake(20, sepImageView.bottom + i*40 + 5, frame.size.width-40, 40)];
        [tempBtn addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [tempBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [tempBtn setTitleColor:KITCOLOR forState:UIControlStateNormal];
        [self.mainView addSubview:tempBtn];
    }
}

- (void)buttonClickAction:(UIButton *)button {
    if (self.buttonBlock) {
        self.buttonBlock(button.tag);
        [self dismissModalDialogWithAnimation:YES];
    }
}

@end
