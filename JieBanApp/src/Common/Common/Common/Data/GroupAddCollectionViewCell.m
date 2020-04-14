//
//  GroupAddCollectionViewCell.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "GroupAddCollectionViewCell.h"

@implementation GroupAddCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    
    if(self)
    {
        [self layoutSubview];
        
    }
    
    return self;
    
}
-(void)layoutSubview
{
    //[super layoutSubviews];
    
    _addMemberBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _addMemberBtn.frame=CGRectMake(14*fitScreenWidth, 7*fitScreenWidth, self.width-28*fitScreenWidth, self.width-28*fitScreenWidth);
    [_addMemberBtn setBackgroundImage:ThemeImage(@"groups_add_icon.png") forState:UIControlStateNormal];
    [_addMemberBtn setBackgroundImage:ThemeImage(@"groups_add_icon_on.png") forState:UIControlStateHighlighted];
    [_addMemberBtn addTarget:self action:@selector(selectMemberAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_addMemberBtn];

    _memberInfoLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_addMemberBtn.frame)+2, self.width, 17*fitScreenWidth)];
    _memberInfoLabel.font = SystemFontSmall;
    _memberInfoLabel.textColor =[UIColor colorWithRed:0.63f green:0.63f blue:0.63f alpha:1.00f];
    _memberInfoLabel.backgroundColor =[UIColor clearColor];
    _memberInfoLabel.textAlignment=NSTextAlignmentCenter;
    _memberInfoLabel.text = languageStringWithKey(@"添加");
    [self.contentView addSubview:_memberInfoLabel];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideTheCell:) name:@"hideTheCell" object:nil];
}

-(void)hideTheCell:(NSNotification *)notification{
    self.hidden = YES;
}
-(void)selectMemberAction
{
   if(self.delegate && [self.delegate respondsToSelector:@selector(onChickAddMember)])
   {
       [self.delegate onChickAddMember];
   }

}

@end
