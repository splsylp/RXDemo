//
//  ChatViewVideoCell.m
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/30.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewVideoCell.h"

//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "RLAVPlayerViewController.h"
#import "LoopProgressView.h"

@interface ChatViewVideoCell()

@property (nonatomic,strong) LoopProgressView *progressView;//进度条
@property (nonatomic,strong) UIImageView *blurView;//蒙版

@end

NSString *const KResponderCustomChatViewVideoCellBubbleViewEvent = @"KResponderCustomChatViewVideoCellBubbleViewEvent";
#define progressWidth 50
@implementation ChatViewVideoCell {
    UIImageView* _displayImage;
    UIButton * _playBtn;
    UILabel *fileSizeLabel;
    BOOL isLoading;//是否正在下载
}

-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        
        _displayImage.layer.cornerRadius =_displayImage.frame.size.width/2;
        _displayImage.layer.masksToBounds=YES;
        
        _displayImage.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        
        _playBtn = [[UIButton alloc]init];
        [_playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:ThemeImage(@"video_button_play_normal") forState:UIControlStateNormal];
        [_playBtn setImage:ThemeImage(@"video_button_play_pressed") forState:UIControlStateHighlighted];
        
        fileSizeLabel = [[UILabel alloc] init];
        fileSizeLabel.textColor = [UIColor whiteColor];
        fileSizeLabel.font =ThemeFontSmall;
        
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.strokeColor = [UIColor clearColor].CGColor;
        maskLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
        maskLayer.contentsScale = [UIScreen mainScreen].scale;
        
        if (self.isSender) {
            _displayImage.frame = CGRectMake(0, 0, 180*fitScreenWidth, 135*fitScreenWidth);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-_displayImage.width-10, self.portraitImg.frame.origin.y, 180*fitScreenWidth, 135*fitScreenWidth);
            maskLayer.contents = (id)ThemeImage(@"chating_right_02").CGImage;
//            // hanwei
//            fileSizeLabel.frame = CGRectMake(self.bubbleView.frame.size.width-65.0f, self.bubbleView.frame.size.height-20.0f, 50.0f, 15.0f);
//            fileSizeLabel.textAlignment = NSTextAlignmentRight;
            
        } else {
            
            _displayImage.frame = CGRectMake(0, 0, 180*fitScreenWidth, 135*fitScreenWidth);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 180*fitScreenWidth, 135*fitScreenWidth);
            fileSizeLabel.frame = CGRectMake(15.0f, self.bubbleView.frame.size.height-20.0f, 50.0f, 15.0f);
             maskLayer.contents = (id)ThemeImage(@"chating_left_01").CGImage;
        }
        
        maskLayer.frame = self.bubbleView.bounds;
        self.bubbleView.layer.mask = maskLayer;
        
        _playBtn.frame = CGRectMake(_displayImage.center.x-35*fitScreenWidth/2, _displayImage.center.y-35*fitScreenWidth/2, 35.0f*fitScreenWidth, 35.0f*fitScreenWidth);
        
        [self.bubbleView addSubview:_displayImage];
        [self.bubbleView addSubview:_playBtn];
        [self.bubbleView addSubview:fileSizeLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revokeMessageNoti:) name:@"notificationrevokeMessage" object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileTransProgressChanged:) name:KNOTIFICATION_fileTranProgressChanged object:nil];

    }
    return self;
}
//2017yxp8.23 小视频撤销还在加载问题
- (void)revokeMessageNoti:(NSNotification *)noti
{
    NSDictionary *messDic = noti.userInfo;
    if(isLoading && messDic.count>0)
    {
        NSString *messId = messDic[@"msgid"];
        if([messId isEqualToString:self.displayMessage.messageId])
        {
           
            [SVProgressHUD dismiss];
        }
    }
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 135*fitScreenWidth+30;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    ECVideoMessageBody *mediaBody = (ECVideoMessageBody *)message.messageBody;
    fileSizeLabel.text = nil;
    _displayImage.image = nil;
    
    if (mediaBody.remotePath.length > 8 && mediaBody.thumbnailRemotePath.length <= 0) {
        mediaBody.thumbnailRemotePath = [NSString stringWithFormat:@"%@_thum",mediaBody.remotePath];
    }
   
    if (mediaBody.localPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] && (mediaBody.mediaDownloadStatus == ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
        UIImage *image = [self getVideoImage:[mediaBody.localPath copy]];
        if (image) {
            _displayImage.image = image;
        }
    } else if (mediaBody.thumbnailRemotePath.length > 0){
        __weak UIImageView *weakImgView = _displayImage;
        [_displayImage sd_setImageWithURL:[NSURL URLWithString:mediaBody.thumbnailRemotePath] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                weakImgView.image = image;
            }
        }];
        if (mediaBody.fileLength) {
            fileSizeLabel.text = [NSString stringWithFormat:@"%.1fM",(float)(mediaBody.fileLength/1024)/1024];
        }
    }
    _progressView.hidden = YES;
    [super bubbleViewWithData:message];
}

- (void)bubbleViewTapGesture:(id)sender {
    
}
#pragma mark - tableview界面点击小视频cell后调用
-(void)playVideo {
    [self dispatchCustomEventWithName:KResponderCustomChatViewVideoCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:nil];
    if (![Common sharedInstance].isIMMsgMoreSelect) {
        //视频会议时，不可播放视频
        NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"VidyoHelper" :@"IsVidyoingWhenOtherOperate" :nil];
        if(number.integerValue ==1){
            return;
        }

        [self videoCellPlayVideoTap:self.displayMessage];
    }
    
}

-(UIImage *)getVideoImage:(NSString *)videoURL
{
    NSString* fileNoExtStr = [videoURL stringByDeletingPathExtension];
    NSString* imagePath = [NSString stringWithFormat:@"%@.jpg", fileNoExtStr];
    UIImage * returnImage = [[UIImage alloc] initWithContentsOfFile:imagePath] ;
    if (returnImage){
        return returnImage;
    }
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:opts] ;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(360.0f, 480.0f);
    NSError *error = nil;
    CGImageRef image = [gen copyCGImageAtTime: CMTimeMake(1, 1) actualTime:NULL error:&error];
    returnImage = [[UIImage alloc] initWithCGImage:image] ;
    CGImageRelease(image);
    [UIImageJPEGRepresentation(returnImage, 0.6) writeToFile:imagePath atomically:YES];
    return returnImage;
}

#pragma mark - 播放小视频
-(void)videoCellPlayVideoTap:(ECMessage*)message {
    
    __weak typeof(ECMessage *)weakMessage = message;
    [[AppModel sharedInstance] readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode == ECErrorType_NoError) {
            weakMessage.isRead = YES;
            [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:amessage.messageId isRead:amessage.isRead];
        }
    }];
    
    ECVideoMessageBody *mediaBody = (ECVideoMessageBody*)message.messageBody;
    if (message.messageState != ECMessageState_Receive && mediaBody.localPath.length>0&&[[NSFileManager defaultManager]fileExistsAtPath:mediaBody.localPath] ) {
        [self createMPPlayerController:mediaBody.localPath];
        return;
    }
    if (mediaBody.mediaDownloadStatus != ECMediaDownloadSuccessed || mediaBody.localPath.length == 0) {
        [SVProgressHUD showWithStatus:languageStringWithKey(@"正在加载视频，请稍后")];
        __weak typeof(self) weakSelf = self;isLoading =YES;
        [[ChatMessageManager sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [SVProgressHUD dismiss];
            if (error.errorCode == ECErrorType_NoError) {
                [strongSelf createMPPlayerController:mediaBody.localPath];
                UIImage *image = [self getVideoImage:[mediaBody.localPath copy]];
                if (image) {
                    self->_displayImage.image = image;
                }
            }
            self->isLoading = NO;
        }];
    } else {
        [self createMPPlayerController:mediaBody.localPath];
    }
}

- (void)createMPPlayerController:(NSString *)fileNamePath {
    NSString *videoName = fileNamePath.lastPathComponent;
    NSString *cachePath = [NSCacheDirectory() stringByAppendingPathComponent:videoName];
    //视频播放的url
    NSURL *playerURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", cachePath]];
    if (![[NSFileManager defaultManager]fileExistsAtPath:cachePath]) {//可能是相册里的路径
        cachePath = fileNamePath;
        playerURL = [NSURL fileURLWithPath:fileNamePath];
    }
    
   
        //初始化
        AVPlayerViewController *playerView2 = [[AVPlayerViewController alloc]init];
        //        AVPlayerViewController *playerView2 = [[AVPlayerViewController alloc]init];
        playerView2.player = [AVPlayer playerWithURL:playerURL];
        playerView2.videoGravity = AVLayerVideoGravityResizeAspect;
        playerView2.showsPlaybackControls = YES;
        // 设置拉伸模式
        playerView2.videoGravity = AVLayerVideoGravityResizeAspectFill;
        // 设置是否显示媒体播放组件
        playerView2.showsPlaybackControls = YES;
        // 设置大力
        //    playerView2.delegate = self;
        // 播放视频
        [playerView2.player play];
        // 设置媒体播放器视图大小
        playerView2.view.bounds = [UIScreen mainScreen].bounds;
        //    playerView2.view.center = CGPointMake(CGRectGetMidX(self.
        
        [playerView2.view setBackgroundColor:[UIColor clearColor]];
        [playerView2.view setFrame:[UIScreen mainScreen].bounds];
        
        ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
        
        //扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
        [chatVC presentViewController:playerView2 animated:NO completion:nil];
    
}
- (void)createMPPlayerController2:(NSString *)fileNamePath {

        
       MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", fileNamePath]]];
        playerView.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [playerView.view setBackgroundColor:[UIColor clearColor]];
        [playerView.view setFrame:[UIScreen mainScreen].bounds];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerView.moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStateChangeCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:playerView.moviePlayer];
        
        ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];
        if([chatVC.messageArray containsObject:self.displayMessage])
        {
            [chatVC presentViewController:playerView animated:NO completion:nil];
        }
}

-(void)failedToPlay:(NSNotification *)notification{
//    [chatVC.tempVC dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)videoFinishCallback:(NSNotification *)notification{
//    [chatVC.tempVC dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)movieStateChangeCallback:(NSNotification*)notify  {
    
    //点击播放器中的播放/ 暂停按钮响应的通知
    MPMoviePlayerController *playerView = notify.object;
    MPMoviePlaybackState state = playerView.playbackState;
    switch (state) {
        case MPMoviePlaybackStatePlaying:
            DDLogInfo(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            DDLogInfo(@"暂停播放.");
            break;
        case MPMoviePlaybackStateSeekingForward:
            DDLogInfo(@"快进");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            DDLogInfo(@"快退");
            break;
        case MPMoviePlaybackStateInterrupted:
            DDLogInfo(@"打断");
            break;
        case MPMoviePlaybackStateStopped:
            DDLogInfo(@"停止播放.");
            break;
        default:
            DDLogInfo(@"播放状态:%li",(long)state);
            break;
    }
}

-(void)movieFinishedCallback:(NSNotification*)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    MPMoviePlayerController* theMovie = [notify object];
    [theMovie stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

-(UIImageView *)blurView{
    if (!_blurView) {
        _blurView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bubbleView.size.width, self.bubbleView.size.height)];
        
        _blurView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        _blurView.alpha = 0.3;
        [self.bubbleView insertSubview:_blurView belowSubview:_progressView];
    }
    return _blurView;
}
-(LoopProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[LoopProgressView alloc]initWithFrame:CGRectMake((self.bubbleView.size.width -progressWidth)/2.0, (self.bubbleView.size.height -progressWidth)/2.0, progressWidth, progressWidth)];
        _progressView.progress = 0;
        _progressView.hidden = YES;
        [self.bubbleView addSubview:_progressView];
    }
    return _progressView;
}

///发送进度改变
- (void)fileTransProgressChanged:(NSNotification *)noti{
    NSDictionary *dataDic = noti.userInfo;
    ECMessage *message = (ECMessage *)[dataDic objectForKey:KMessageKey];
    ///当前进度
    float progress = [(NSNumber *)[dataDic objectForKey:@"progress"] floatValue];
    if ([message.messageId isEqualToString:self.displayMessage.messageId]) {
        self.progressView.hidden = NO;
        self.blurView.hidden = NO;
        _playBtn.hidden = YES;
        //进度条
        self.progressView.progress = progress;
        if (progress == 1) {
            self.blurView.hidden = YES;
            self.progressView.hidden = YES;
            _playBtn.hidden = NO;
        }
    }
}

@end
