//
//  HXMergerVideoBubbleView.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/4/1.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergerVideoBubbleView.h"

@interface HXMergerVideoBubbleView ()

/**
 *@brief 视频的默认图
 */
@property (nonatomic, strong) UIImageView *mImageView;



/**
 *@brief 视频两个字
 */
@property (nonatomic,strong) UILabel      *mLabel;


/**
 *@brief 播放按钮
 */
@property (nonatomic,strong) UIButton     *mPlayerButton;

@end


@implementation HXMergerVideoBubbleView

-(UIButton *)mPlayerButton
{
    if(!_mPlayerButton){
        _mPlayerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,30, 30)];
        [_mPlayerButton setBackgroundImage:ThemeImage(@"video_button_play_normal.png") forState:UIControlStateNormal];
        _mPlayerButton.userInteractionEnabled = NO;
    }
    return _mPlayerButton;
}


- (UILabel *)mLabel{
    if(!_mLabel){
        _mLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right +5, 7, 100, 16)];
        _mLabel.textColor = [UIColor blackColor];
        _mLabel.font = ThemeFontLarge;
        _mLabel.textAlignment = NSTextAlignmentLeft;
        _mLabel.text = languageStringWithKey(@"视频");
    }
    return _mLabel;
}


- (UIImageView *)mImageView{
    if(!_mImageView){
        _mImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, VideoHeight-10, VideoHeight-10)];
        _mImageView.backgroundColor = [UIColor colorWithHexString:XHMergeBackColor];
    }
    return _mImageView;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, BUBLEVIEW_TITLE_Disatance+EDGE_Distance_TOP+15*FitThemeFont,BubbleViewWidth, VideoHeight)];
    if (self) {
        [self addSubview:self.mImageView];
        [self addSubview:self.mLabel];
        [self addSubview:self.mPlayerButton];
        self.mPlayerButton.center = self.mImageView.center;
        self.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];
    }
    return self;
}


+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model
{
    return VideoHeight;
}

-(void)setModel:(HXMergeMessageModel *)model
{
    _model = model;
    __weak HXMergerVideoBubbleView *blockSelf = self;
    NSString *thumb = [NSString stringWithFormat:@"%@_thum",_model.merge_url];
   // NSDictionary * companyInfo = [[Common sharedInstance].componentDelegate getDicWithId:model.faterMessage.from withType:0];
    
    [self.mImageView sd_setImageWithURL:[NSURL URLWithString:thumb] placeholderImage:nil options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(!error){
            blockSelf.mImageView.image = image;
        }
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.bubbleViewClickBlock){
        self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Video);
    }
}


@end
