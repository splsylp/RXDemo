//
//  HXMergerLinkBubbleView.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/4/1.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergerLinkBubbleView.h"


@interface HXMergerLinkBubbleView ()

///默认图
@property (nonatomic, strong) UIImageView *mImageView;
///链接两个字
@property (nonatomic,strong) UILabel *mLabel;
///描述
@property (nonatomic,strong) UILabel      *mDesLabel;

@end

@implementation HXMergerLinkBubbleView

- (instancetype)init{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+ MERGE_HEAD_WITH + 10, BUBLEVIEW_TITLE_Disatance + EDGE_Distance_TOP + 15*FitThemeFont,BubbleViewWidth, VideoHeight)];
    if (self) {
        [self addSubview:self.mImageView];
//        [self addSubview:self.mLabel];
        [self addSubview:self.mDesLabel];

        self.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];
    }
    return self;
}


- (UILabel *)mDesLabel{
    if(!_mDesLabel){
        _mDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right + 5, self.mImageView.top, _model.bubbleW? _model.bubbleW:BubbleViewWidth - (self.mImageView.right + 5),self.mImageView.height)];
        _mDesLabel.textColor = [UIColor darkGrayColor];
        _mDesLabel.font =ThemeFontSmall;
        _mDesLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _mDesLabel;
}

- (UILabel *)mLabel{
    if(!_mLabel){
        _mLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right +5, 7, 100, 16)];
        _mLabel.textColor = [UIColor blackColor];
        _mLabel.font = ThemeFontLarge;
        _mLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _mLabel;
}

- (UIImageView *)mImageView{
    if(!_mImageView){
        _mImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, VideoHeight - 10, VideoHeight - 10)];
//        _mImageView.backgroundColor = [UIColor colorWithHexString:XHMergeBackColor];
        _mImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _mImageView;
}


+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model{
    return VideoHeight;
}

- (void)setModel:(HXMergeMessageModel *)model{
    _model = model;
    self.mDesLabel.text = model.merge_content;
    __weak HXMergerLinkBubbleView *blockSelf = self;
    [self.mImageView sd_setImageWithURL:[NSURL URLWithString:self.model.merge_linkThumUrl] placeholderImage:ThemeImage(@"ios_rx_logo") options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(!error){
            blockSelf.mImageView.image = image;
        }
    }];
    
    [self.mDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mImageView.mas_right).mas_offset(5);
        make.right.mas_offset(-5);
        make.centerY.mas_offset(0);
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.bubbleViewClickBlock){
        self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Preview);
    }
}



@end
