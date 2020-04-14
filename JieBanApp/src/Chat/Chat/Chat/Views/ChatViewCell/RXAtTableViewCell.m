//
//  RXAtTableViewCell.m
//  Chat
//
//  Created by 杨大为 on 2017/4/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "RXAtTableViewCell.h"

@implementation RXAtTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}
#pragma mark createUI
-(void)createUI{
    self.userHeadImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
    self.userHeadImg.layer.cornerRadius= 4.f;//self.userHeadImg.frame.size.width/2;
    self.userHeadImg.layer.masksToBounds=YES;
    [self.contentView addSubview:self.userHeadImg];
    
    self.groupHeadView=nil;
    self.groupHeadView = [[RXGroupHeadImageView alloc]initWithFrame:CGRectMake(10.0f, 5, 40, 40)];
    self.groupHeadView.hidden = YES;
    self.groupHeadView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.groupHeadView];
    
    self.userNameLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 80, 20)];
    self.userNameLable.font = ThemeFontLarge;
    [self.contentView addSubview:self.userNameLable];
    
    self.positionLab = [[UILabel alloc] initWithFrame:CGRectMake(self.userNameLable.right + 10, 5, 150, 20)];
    self.positionLab.textColor = [UIColor lightGrayColor];
    self.positionLab.font =ThemeFontSmall;
    self.positionLab.backgroundColor =[UIColor clearColor];
    [self.contentView addSubview: self.positionLab];
    
    self.userMobileLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 100, 15)];
    self.userMobileLable.font = ThemeFontMiddle;
    self.userMobileLable.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.userMobileLable];
    // 分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 49, kScreenWidth-10, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];;
    [self.contentView addSubview:lineView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
