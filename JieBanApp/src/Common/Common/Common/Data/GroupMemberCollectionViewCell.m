//
//  GroupMemberCollectionViewCell.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "GroupMemberCollectionViewCell.h"

@implementation GroupMemberCollectionViewCell


-(id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor=[UIColor clearColor];
        [self layoutSubview];
    }
    
    return self;
}
-(void)layoutSubview
{
   // [super layoutSubviews];
//headerView
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.width- 20)];
    _headerView.backgroundColor = [UIColor clearColor];
//    UITapGestureRecognizer *headTapG =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onChickHeader:)];
//    [self.headerView addGestureRecognizer:headTapG];
//    self.headerView.userInteractionEnabled=YES;
    [self.contentView addSubview:_headerView];
    //头像
    _headerIconView =[[UIImageView alloc]initWithFrame:CGRectMake(14*fitScreenWidth, 7*fitScreenWidth, self.width-28*fitScreenWidth, self.width-28*fitScreenWidth)];
    _headerIconView.backgroundColor =[UIColor clearColor];
    _headerIconView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerIconView.layer.masksToBounds=YES;
    self.headerIconView.layer.cornerRadius= 5;//self.headerIconView.frame.size.width/2;
    self.headerIconView.clipsToBounds=YES;
    [self.headerView addSubview:_headerIconView];
    
    //名字
    _nameLabel =[[UILabel alloc]initWithFrame:CGRectMake(_headerIconView.left, _headerIconView.bottom+2, _headerIconView.width, 17*fitScreenWidth)];
    _nameLabel.font = SystemFontSmall;
    _nameLabel.textColor =[UIColor colorWithHexString:@"666666"];
    _nameLabel.backgroundColor =[UIColor clearColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
    
    //删除
    _deleteBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame =CGRectMake(_headerIconView.originX-10*fitScreenWidth, 2, 22*fitScreenWidth, 22*fitScreenWidth);
    [_deleteBtn setBackgroundImage:ThemeImage(@"cell_delete_icon") forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleMember:) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn.hidden=YES;
    [self.headerView addSubview:_deleteBtn];
}


- (void)iconViewLayerAnimation
{
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
   
        CAKeyframeAnimation *animaiton = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        NSArray *rotationVelues = @[@(M_PI_4/8), @(-M_PI_4/8), @(M_PI_4/8)];
        animaiton.values = rotationVelues;
        animaiton.duration = 0.5f;
        animaiton.repeatCount = HUGE_VALF;      //    #define    HUGE_VALF    1e50f
        [self.headerView.layer addAnimation:animaiton forKey:nil];
//        [self.layer addAnimation:animaiton forKey:nil];
}
-(void)deleteAnimation{
    [self.headerView.layer removeAllAnimations];
}
-(void)deleMember:(UIButton *)deleBtn
{
   if(self.delegate && [self.delegate respondsToSelector:@selector(onChickDeleteMemberIndex:withMemberName:)])
   {
       [self.delegate onChickDeleteMemberIndex:self.tag withMemberName:_nameLabel.text];
   }
}
-(void)onChickHeader:(UITapGestureRecognizer *)recognizer
{
   if(self.delegate && [self.delegate respondsToSelector:@selector(onchickHeadImgMemberIndex:withMemberName:)])
   {
       [self.delegate onchickHeadImgMemberIndex:self.tag withMemberName:_nameLabel.text];
   }
}

@end
