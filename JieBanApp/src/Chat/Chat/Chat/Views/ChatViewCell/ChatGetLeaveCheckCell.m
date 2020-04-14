//
//  ChatGetLeaveCheckCell.m
//  Chat
//
//  Created by yuxuanpeng on 2017/5/10.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ChatGetLeaveCheckCell.h"

#define originX  15*fitScreenWidth
#define FrameW  180*fitScreenWidth
#define FrameLineY 5*fitScreenWidth  //间隔

@implementation ChatGetLeaveCheckCell{
    UIView * _shView;//总显示View
    UIImageView * _spimage;//审批图片1
    UIImageView * _checkImage;//审批图片2
    UILabel *_titleLabel;//标题  补卡审批
    UILabel *_explainLabel;//审批说明
    UILabel *_contentLabel;//补卡内容
    UILabel *_getLeaveLabel;//补卡班次
    UILabel *_timeLabel;//补卡时间
    UILabel *_weekTimeLabel;//星期时间
    UILabel *_stateLabel;//补卡状态
    UIView  *_lineView;//分割线
    UILabel *_checkLabel;//查看详情
    UIImageView *_imgIcon;//箭头
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self initUI];
    }
    return self;
}

- (void)initUI{
    _shView = [[UIView alloc]init];
    _shView.frame = CGRectMake(0.0f, 0.0f, 230*fitScreenWidth, 170 * fitScreenHeight);
    [self.bubbleView addSubview:_shView];
    //头
    _spimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 230*fitScreenWidth, 40*fitScreenHeight)];
    _spimage.image = [ThemeImage(@"chating_left_a") resizableImageWithCapInsets:UIEdgeInsetsMake(17.5, 17.5, 2,17.5) resizingMode:UIImageResizingModeStretch];
    _spimage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_shView addSubview:_spimage];
    //尾
    _checkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40*fitScreenHeight, 230*fitScreenWidth, 125*fitScreenHeight)];
    _checkImage.image = [ThemeImage(@"chating_left_b") resizableImageWithCapInsets:UIEdgeInsetsMake(7.5, 15, 7.5,15) resizingMode:UIImageResizingModeStretch];
    [_shView addSubview:_checkImage];
    //审批标签头
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 10*fitScreenHeight, FrameW, 20*fitScreenHeight)];
    _titleLabel.font = ThemeFontLarge;
    _titleLabel.textColor = [UIColor whiteColor];
    [_spimage addSubview:_titleLabel];
    //审批内容
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, 10*fitScreenHeight, FrameW, 16*fitScreenWidth)];
    _contentLabel.font =ThemeFontSmall;
    _contentLabel.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
    [_checkImage addSubview:_contentLabel];
    //审批显示
    _explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_contentLabel.frame)+FrameLineY, FrameW, 16*fitScreenWidth)];
    _explainLabel.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
    _explainLabel.font = ThemeFontSmall;
    _explainLabel.text = languageStringWithKey(@"审批");
    [_checkImage addSubview:_explainLabel];
    //班次
    _getLeaveLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_explainLabel.frame)+FrameLineY, FrameW, 16*fitScreenWidth)];
    _getLeaveLabel.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
    _getLeaveLabel.font =ThemeFontSmall;
    _getLeaveLabel.text = languageStringWithKey(@"补卡班次");
    [_checkImage addSubview:_getLeaveLabel];
    //时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_getLeaveLabel.frame)+FrameLineY*2, FrameW, 16*fitScreenWidth)];
    _timeLabel.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
    _timeLabel.font =ThemeFontSmall;
    [_checkImage addSubview:_timeLabel];
    //日期
    _weekTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_timeLabel.frame)+FrameLineY, FrameW, 16*fitScreenWidth)];
    _weekTimeLabel.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
    _weekTimeLabel.font =ThemeFontSmall;
    [_checkImage addSubview:_weekTimeLabel];
    //状态
    _stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(originX, CGRectGetMaxY(_weekTimeLabel.frame)+FrameLineY*2, FrameW, 16*fitScreenWidth)];
    _stateLabel.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
    _stateLabel.font =ThemeFontSmall;
    [_checkImage addSubview:_stateLabel];
    //分割线
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_stateLabel.frame)+FrameLineY*2, 0, 1)];
    _lineView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.97f alpha:1.00f];
    [_checkImage addSubview:_lineView];
    //查看详情
    _checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, CGRectGetMaxY(_lineView.frame)+5*fitScreenHeight, FrameW, 18*fitScreenHeight)];
    _checkLabel.text = languageStringWithKey(@"查看详情");
    _checkLabel.font = ThemeFontMiddle;
    [_checkImage addSubview:_checkLabel];
    //箭头
    _imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(originX+FrameW, CGRectGetMaxY(_lineView.frame)+4*fitScreenHeight, 14*fitScreenWidth, 14*fitScreenHeight)];
    _imgIcon.image = ThemeImage(@"enter_icon_02");
    _imgIcon.backgroundColor = [UIColor clearColor];
    [_checkImage addSubview:_imgIcon];
}

@end
