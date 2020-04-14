//
//  GroupDeleCollectionViewCell.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "GroupDeleCollectionViewCell.h"

@implementation GroupDeleCollectionViewCell

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
    _deleteMemberBtn=[UIButton buttonWithType:UIButtonTypeCustom];
     _deleteMemberBtn.frame=CGRectMake(14*fitScreenWidth, 7*fitScreenWidth, self.width-28*fitScreenWidth, self.width-28*fitScreenWidth);
    [_deleteMemberBtn setBackgroundImage:ThemeImage(@"groups_delete_icon.png") forState:UIControlStateNormal];
    [_deleteMemberBtn setBackgroundImage:ThemeImage(@"groups_delete_icon_on.png") forState:UIControlStateHighlighted];
    [_deleteMemberBtn addTarget:self action:@selector(deleteMemberAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteMemberBtn];
    
    _deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_deleteMemberBtn.frame)+2, self.width, 17*fitScreenWidth)];
    _deleteLabel.font = SystemFontSmall;
    _deleteLabel.text = languageStringWithKey(@"移除");
    _deleteLabel.textColor =[UIColor colorWithRed:0.63f green:0.63f blue:0.63f alpha:1.00f];
    _deleteLabel.backgroundColor =[UIColor clearColor];
    _deleteLabel.textAlignment=NSTextAlignmentCenter;
    [self.contentView addSubview:_deleteLabel];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideTheCell:) name:@"hideTheCell" object:nil];

}
-(void)hideTheCell:(NSNotification *)notification{
    self.hidden = YES;
}
-(void)deleteMemberAction
{
   if(self.delegate && [self.delegate respondsToSelector:@selector(onChickDeleteMember)])
   {
       [self.delegate onChickDeleteMember];
   }

}
@end
