//
//  HXMergeLoactionBubbleView.m
//  Chat
//
//  Created by y g on 2019/9/9.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "HXMergeLoactionBubbleView.h"

@interface HXMergeLoactionBubbleView()

/**
 *@brief 视频的默认图
 */
@property (nonatomic, strong) UIButton *bgButtonView;

/**
 *@brief 地址
 */
@property (nonatomic,strong) UILabel *mLabel;

/**
 *@brief 图标
 */
@property (nonatomic,strong) UIImageView  *iconImgView;

@end

@implementation HXMergeLoactionBubbleView

-(UIImageView *)iconImgView
{
    if(!_iconImgView){
        _iconImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,30, 30)];
        [_iconImgView setImage:ThemeImage(@"collection_icon_positionbig")];
        _iconImgView.userInteractionEnabled = NO;
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImgView;
}


- (UILabel *)mLabel{
    if(!_mLabel){
        _mLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImgView.right +5, 7, 100, 16)];
        _mLabel.textColor = [UIColor blackColor];
        _mLabel.centerY = LocationHeight/2;
        _mLabel.font = ThemeFontLarge;
        _mLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _mLabel.textAlignment = NSTextAlignmentLeft;
        _mLabel.text = languageStringWithKey(@"语音");
    }
    return _mLabel;
}


- (UIButton *)bgButtonView{
    if(!_bgButtonView){
        _bgButtonView = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, LocationHeight-10, LocationHeight-10)];
        _bgButtonView.userInteractionEnabled = NO;
        //        _mImageView.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];
        //        [_mImageView addTarget:self action:@selector(playVoiceClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgButtonView;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, BUBLEVIEW_TITLE_Disatance+EDGE_Distance_TOP+15*FitThemeFont,BubbleViewWidth, LocationHeight)];
    if (self) {
        [self addSubview:self.bgButtonView];
        [self addSubview:self.mLabel];
        [self addSubview:self.iconImgView];
        self.iconImgView.center = self.bgButtonView.center;
        self.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];
    }
    return self;
}

+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model{
    return LocationHeight;
}

-(void)setModel:(HXMergeMessageModel *)model{
    _model = model;
//    NSDictionary *dic = model.faterMessage.userDataToDictionary;
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_offset(0);
        make.left.mas_offset(15);
    }];
    
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-10);
        make.centerY.mas_offset(0);
        make.left.mas_equalTo(self.iconImgView.mas_right).mas_offset(5);
    }];

    self.mLabel.textColor = [UIColor colorWithHexString:@"333333"];
    self.mLabel.text = [NSString stringWithFormat:@"%@",model.merge_content];
    if(self.bubbleViewClickBlock){
        [_iconImgView setImage:ThemeImage(@"collection_icon_positionbig_able")];
    }else {
        [_iconImgView setImage:ThemeImage(@"collection_icon_positionbig")];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.bubbleViewClickBlock){
        self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Location);
    }
}

@end
