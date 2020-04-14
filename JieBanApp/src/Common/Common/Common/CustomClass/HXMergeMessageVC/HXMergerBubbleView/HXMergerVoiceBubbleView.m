//
//  HXMergerVoiceBubbleView.m
//  Chat
//
//  Created by 高源 on 2019/7/22.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "HXMergerVoiceBubbleView.h"

@interface HXMergerVoiceBubbleView()

/**
 *@brief 视频的默认图
 */
@property (nonatomic, strong) UIButton *mImageView;



/**
 *@brief 视频两个字
 */
@property (nonatomic,strong) UILabel      *mLabel;


/**
 *@brief 播放按钮
 */
@property (nonatomic,strong) UIImageView     *mPlayerButton;

@end

@implementation HXMergerVoiceBubbleView

-(UIImageView *)mPlayerButton
{
    if(!_mPlayerButton){
        _mPlayerButton = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,30, 30)];
        [_mPlayerButton setImage:ThemeImage(@"collection_icon_playvoice3_left")];
        _mPlayerButton.userInteractionEnabled = NO;
        _mPlayerButton.animationDuration = 1;
        _mPlayerButton.animationImages = [NSArray arrayWithObjects:ThemeImage(@"collection_icon_playvoice2_left"), ThemeImage(@"collection_icon_playvoice1_left"), ThemeImage(@"collection_icon_playvoice2_left"),ThemeImage(@"collection_icon_playvoice3_left"), nil];
        _mPlayerButton.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _mPlayerButton;
}


- (UILabel *)mLabel{
    if(!_mLabel){
        _mLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mImageView.right +5, 7, 100, 16)];
        _mLabel.textColor = [UIColor blackColor];
        _mLabel.centerY = VoiceHeight/2;
        _mLabel.font = ThemeFontLarge;
        _mLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _mLabel.textAlignment = NSTextAlignmentLeft;
        _mLabel.text = languageStringWithKey(@"语音");
    }
    return _mLabel;
}


- (UIButton *)mImageView{
    if(!_mImageView){
        _mImageView = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, VoiceHeight-10, VoiceHeight-10)];
        _mImageView.userInteractionEnabled = NO;
//        _mImageView.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];
//        [_mImageView addTarget:self action:@selector(playVoiceClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mImageView;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, BUBLEVIEW_TITLE_Disatance+EDGE_Distance_TOP+15*FitThemeFont,BubbleViewWidth, VoiceHeight)];
    if (self) {
        [self addSubview:self.mImageView];
        [self addSubview:self.mLabel];
        [self addSubview:self.mPlayerButton];
        self.mPlayerButton.center = self.mImageView.center;
        self.backgroundColor = [UIColor colorWithHexString:@"F3F3F5"];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVoiceClick)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model{
    return VoiceHeight;
}

-(void)setModel:(HXMergeMessageModel *)model{
    _model = model;
    NSDictionary *dic = model.faterMessage.userDataToDictionary;
    if ([dic[@"merge_canPlayVoice"] isEqualToString:@"false"]) {
        self.mPlayerButton.hidden = YES;
        self.mImageView.hidden = YES;
        self.mLabel.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音消息")];
        self.mLabel.left = 10.f;
        self.mLabel.textColor = [UIColor blackColor];
    }else {
        self.mPlayerButton.hidden = NO;
        self.mImageView.hidden = NO;
        self.mLabel.left = self.mImageView.right +5;
        self.mLabel.text = [NSString stringWithFormat:@"%@%@",model.merge_duration,@"″"];
        self.mLabel.textColor = [UIColor colorWithHexString:@"999999"];
    }
}

#pragma mark 播放语音
- (void)playVoiceClick{
    UIButton *btn = self.mImageView;
    btn.selected = !btn.selected;
    
    NSURL *voiceURL = [NSURL URLWithString:_model.merge_url];
    NSString *localPath = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),voiceURL.lastPathComponent];
    
    if (btn.selected) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            ECVoiceMessageBody * voiceBody = [[ECVoiceMessageBody alloc] initWithFile:localPath displayName:voiceURL.lastPathComponent];
            voiceBody.duration = [_model.merge_duration integerValue];
            [_mPlayerButton startAnimating];
            WS(weakSelf)
            [[ECDevice sharedInstance].messageManager playVoiceMessage:voiceBody completion:^(ECError *error) {
                if (error.errorCode == ECErrorType_NoError) {
                    weakSelf.mImageView.selected = !weakSelf.mImageView.selected;
                    [weakSelf.mPlayerButton stopAnimating];
                }
            }];
        }else{
            NSString *fileDir = [NSString stringWithFormat:@"%@/Library/Caches", NSHomeDirectory()];
            [SVProgressHUD showWithStatus:languageStringWithKey(@"下载中...")];
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:voiceURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                NSString *voiceFilePath = [NSString stringWithFormat:@"%@/%@",fileDir,voiceURL.lastPathComponent];
                BOOL success = [data writeToFile:voiceFilePath  atomically:YES];
                if (success) {
                    [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"下载成功")];
                }else{
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"下载失败")];
                }
            }];
        }
    }else {
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        [_mPlayerButton stopAnimating];
    }
}

@end
