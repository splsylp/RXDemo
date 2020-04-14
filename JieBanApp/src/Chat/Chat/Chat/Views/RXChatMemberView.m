//
//  RXChatMemberView.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/10/27.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "RXChatMemberView.h"
@implementation RXChatMemberView


-(id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    
    if(self)
    {
        [self createMemberView];
    }
    return self;
}
-(void)createMemberView
{
    //头像
    _headerIconView =[[UIImageView alloc]initWithFrame:CGRectMake((self.width-40*fitScreenWidth)/2, 10, 40*fitScreenWidth, 40*fitScreenWidth)];
    _headerIconView.backgroundColor =[UIColor clearColor];
    self.headerIconView.layer.masksToBounds=YES;
    self.headerIconView.layer.cornerRadius= 4.f;//self.headerIconView.frame.size.width/2;
    self.headerIconView.clipsToBounds=YES;
    [self addSubview:_headerIconView];
    //名字
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headerIconView.left, _headerIconView.bottom, _headerIconView.width, 21*fitScreenWidth)];
    _nameLabel.font = SystemFontMiddle;
    _nameLabel.textColor =[UIColor colorWithRed:0.63f green:0.63f blue:0.63f alpha:1.00f];
    _nameLabel.backgroundColor =[UIColor clearColor];
    _nameLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:_nameLabel];
    //删除
    _deleteBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame =CGRectMake(_headerIconView.originX-10*fitScreenWidth, 0, 25*fitScreenWidth, 25*fitScreenWidth);
    [_deleteBtn setBackgroundImage:ThemeImage(@"delete_icon") forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleMember:) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn.hidden=YES;
    [self addSubview:_deleteBtn];
}
-(void)deleMember:(UIButton *)deleBtn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RXChatMemberView:index:)]) {
        [self.delegate RXChatMemberView:self index:self.tag];
    }
}

@end
