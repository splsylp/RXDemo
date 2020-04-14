//
//  RXVideoShowView.m
//  FriendsCircle
//
//  Created by 魏继源 on 17/4/13.
//  Copyright © 2017年 maibou. All rights reserved.
//

#import "RXVideoShowView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface RXVideoShowView()

#define TopViewHeight 50
#define BottomViewHeight 72
#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height
#define timeSpan 0.1
#define timeLabelWidth  40

//上层建筑
@property (nonatomic,strong)UIView *topView;
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIButton *settingsBtn;

//经济基础
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UILabel *textLabel;
@property (nonatomic,strong)UILabel *timeLabel;//显示播放时间
@property (nonatomic,assign)BOOL isPlay;
@property (nonatomic,strong)UISlider *movieProgressSlider;//进度条
@property (nonatomic,assign)CGFloat ProgressBeginToMove;
@property (nonatomic,assign)CGFloat totalMovieDuration;//视频总时间

//核心躯干
@property (nonatomic,strong)AVPlayer *player;
@property (nonatomic,strong)AVPlayerItem *playerItem;

//神之右手
@property (nonatomic,strong)UIView *settingsView;
@property (nonatomic,strong)UIView *rightView;
@property (nonatomic,strong)UIButton *setTestBtn;

//touch evens
@property (nonatomic,assign)BOOL isShowView;
@property (nonatomic,assign)BOOL isSettingsViewShow;
@property (nonatomic,assign)BOOL isSlideOrClick;

@property (nonatomic,strong)UISlider *volumeViewSlider;
@property (nonatomic,assign)float systemVolume;//系统音量值
@property (nonatomic,assign)float systemBrightness;//系统亮度
@property (nonatomic,assign)CGPoint startPoint;//起始位置坐标

@property (nonatomic,assign)BOOL isTouchBeganLeft;//起始位置方向
@property (nonatomic,copy)NSString *isSlideDirection;//滑动方向
@property (nonatomic,assign)float startProgress;//起始进度条
@property (nonatomic,assign)float NowProgress;//进度条当前位置

//监控进度
@property (nonatomic,strong)NSTimer *avTimer;
//监控时间
@property (nonatomic,strong)NSTimer *timeTimer;

@property (nonatomic,strong)UIView *snapshotView;

@end


@implementation RXVideoShowView
-(instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url{
    self = [super initWithFrame:frame];
    if (self) {
        _url = url;
        [self initData];
        self.backgroundColor = [UIColor blackColor];
        //我来组成躯干
        [self createAvPlayer];
        //我来组成头部
        [self createTopView];
        //我来组成底部
        [self createBottomView];
        //我来组成右手
        //    [self createRightSettingsView];
        //获取系统音量
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        _volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider *)view;
                break;
            }
        }
        //获取系统亮度
        _systemBrightness = [UIScreen mainScreen].brightness;
        [self playClick:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    }
    return self;
}

- (void)initData {
    //    _isExitVideo = YES;
}

#pragma mark - 播放器躯干
- (void)createAvPlayer{
    //设置静音状态也可播放声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    CGRect playerFrame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
    
    AVURLAsset *asset = [AVURLAsset assetWithURL: _url];
    Float64 duration = CMTimeGetSeconds(asset.duration);
    //获取视频总时长
    _totalMovieDuration = duration;
    
    _playerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    _player = [[AVPlayer alloc]initWithPlayerItem:_playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = playerFrame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:playerLayer];
    
}

#pragma mark - 头部View
- (void)createTopView{
    CGFloat titleLableWidth = 400;
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, TopViewHeight)];
    _topView.backgroundColor = [UIColor clearColor];
    
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, TopViewHeight)];
    [_backBtn setTitle:languageStringWithKey(@"返回") forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.height/2-titleLableWidth/2, 0, titleLableWidth, TopViewHeight)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = languageStringWithKey(@"我是标题");
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.userInteractionEnabled = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    //    [_topView addSubview:_titleLabel];
    
    _settingsBtn = [[UIButton alloc]initWithFrame:CGRectMake(mainHeight - 50, 0, 50, TopViewHeight)];
    [_settingsBtn setTitle:languageStringWithKey(@"设置") forState:UIControlStateNormal];
    [_settingsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_settingsBtn addTarget:self action:@selector(settingsClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [_topView addSubview:_settingsBtn];
    
    [self addSubview:_topView];
    _topView.alpha = 0;
    
}

#pragma mark - 底部View
- (void)createBottomView{
    CGFloat titleLableWidth = 400;
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, mainHeight - TopViewHeight, mainWidth, TopViewHeight)];
    _bottomView.backgroundColor = [UIColor clearColor];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 24)];
    [_playBtn setTitle:languageStringWithKey(@"播放") forState:UIControlStateNormal];
    [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playBtn];
    
    //显示当前播放时间
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_playBtn.right, 0, timeLabelWidth, 24)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.text = @"00:00";
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.font = ThemeFontMiddle;
    [_bottomView addSubview:_timeLabel];
    
    //进度条
    _movieProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(_timeLabel.right + 10, 0, _bottomView.frame.size.width -(_timeLabel.right + 5)-timeLabelWidth-10-5, 24)];
    [_movieProgressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [_movieProgressSlider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
    //    [_movieProgressSlider setThumbImage:ThemeImage(@"progressThumb.png") forState:UIControlStateNormal];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
    [_bottomView addSubview:_movieProgressSlider];
    
    
    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(_bottomView.frame.size.width -timeLabelWidth-10, 0, timeLabelWidth, 24)];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = ThemeFontMiddle;
    [_bottomView addSubview:_textLabel];
    
    //在totalTimeLabel上显示总时间
    //    _textLabel.text = [self convertMovieTimeToText:_totalMovieDuration];
    _textLabel.text = [self timeFormatted:_totalMovieDuration];
    
    [self addSubview:_bottomView];
    _bottomView.alpha = 0;
    
}

//时间文字转换
-(NSString*)convertMovieTimeToText:(CGFloat)time{
    if (time<60.f) {
        return [NSString stringWithFormat:@"%.0f秒",time];
    }else{
        return [NSString stringWithFormat:@"%.2f",time/60];
    }
}
//时间显示
- (NSString *)timeFormatted:(int)totalSeconds

{
    int seconds = totalSeconds % 60;
    
    int minutes = (totalSeconds / 60) % 60;
    
    //    int hours = totalSeconds / 3600;
    //
    //    DDLogInfo(@"%02d:%02d:%02d",hours,minutes,seconds);
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

//播放/暂停 Click
- (void)playClick:(UIButton *)btn{
    if (!_isPlay) {
        [self PlayOrStop:YES];
    }else{
        [self PlayOrStop:NO];
    }
}

#pragma mark - play
- (void)PlayOrStop:(BOOL)isPlay{
    if (isPlay) {
        //1.通过实际百分比获取秒数。
        float dragedSeconds = floorf(_totalMovieDuration * _NowProgress);
        CMTime newCMTime = CMTimeMake(dragedSeconds,1);
        //2.更新电影到实际秒数。
        [_player seekToTime:newCMTime];
        //3.play 并且重启timer
        [_player play];
        _isPlay = YES;
        [_playBtn setTitle:languageStringWithKey(@"暂停") forState:UIControlStateNormal];
        self.avTimer = [NSTimer scheduledTimerWithTimeInterval:timeSpan target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
        //更新时间
        self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }else{
        [_player pause];
        _isPlay = NO;
        [_playBtn setTitle:languageStringWithKey(@"播放") forState:UIControlStateNormal];
        [self.avTimer invalidate];
        //更新时间
        [self.timeTimer invalidate];
    }
}
//#pragma mark - 播放完成后
- (void)playbackFinished:(NSNotification *)notification {
    DDLogInfo(@"视频播放完成通知");
    _playerItem = [notification object];
    [_playerItem seekToTime:kCMTimeZero]; // item 跳转到初始
    if (_isExitVideo) {
        [self backClick];
    }else{
        _isPlay = NO;
        [_playBtn setTitle:languageStringWithKey(@"播放") forState:UIControlStateNormal];
    }
    //[_player play]; // 循环播放
}

//返回Click
- (void)backClick{
    _finisBlock();
}

//设置Click
- (void)settingsClick:(UIButton *)btn{
    
    _isShowView = NO;
    _isSettingsViewShow = YES;
    _settingsView.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        _topView.alpha = 0;
        _bottomView.alpha = 0;
    }];
}

-(void)updateUI{
    //1.根据播放进度与总进度计算出当前百分比。
    float new = CMTimeGetSeconds(_player.currentItem.currentTime) / CMTimeGetSeconds(_player.currentItem.duration);
    //2.计算当前百分比与实际百分比的差值，
    float DValue = new - _NowProgress;
    //3.实际百分比更新到当前百分比
    _NowProgress = new;
    //4.当前百分比加上差值更新到实际进度条
    self.movieProgressSlider.value = self.movieProgressSlider.value + DValue;
    
    int nowtime = _NowProgress * _totalMovieDuration;
    _timeLabel.text = [self timeFormatted:nowtime];
    
}

- (void)updateTime{
    
}
//按住滑块
-(void)scrubbingDidBegin{
    _ProgressBeginToMove = _movieProgressSlider.value;
}

//释放滑块
-(void)scrubbingDidEnd{
    [self UpdatePlayer];
}

//拖动停止后更新avplayer
-(void)UpdatePlayer{
    //1.暂停播放
    [self PlayOrStop:NO];
    //2.存储实际百分比值
    _NowProgress = _movieProgressSlider.value;
    //3.重新开始播放
    [self PlayOrStop:YES];
}

#pragma mark - 右侧设置View


- (void)setTestBtnClick:(UIButton *)btn{
    DDLogInfo(@"点击了设置区测试按钮");
}

#pragma mark - touch
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    _isSlideOrClick = YES;
    //右半区调整音量
    CGPoint location = [[touches anyObject] locationInView:self];
    CGFloat changeY = location.y - _startPoint.y;
    CGFloat changeX = location.x - _startPoint.x;
    
    if (_isShowView) {
        //上下View为显示状态，此时点击上下View直接return
        CGPoint point = [[touches anyObject] locationInView:self];
        if ((point.y>CGRectGetMinY(self.topView.frame)&&point.y< CGRectGetMaxY(self.topView.frame))||(point.y<CGRectGetMaxY(self.bottomView.frame)&&point.y>CGRectGetMinY(self.bottomView.frame))) {
            _isSlideOrClick = NO;
            return;
        }
    }
    
    //初次滑动没有滑动方向，进行判断。已有滑动方向，直接进行操作
    if ([_isSlideDirection isEqualToString:languageStringWithKey(@"横向")]) {
        int index = location.x - _startPoint.x;
        if(index>0){
            _movieProgressSlider.value = _startProgress + abs(index)/10 * 0.008;
        }else{
            _movieProgressSlider.value = _startProgress - abs(index)/10 * 0.008;
        }
    }else if ([_isSlideDirection isEqualToString:languageStringWithKey(@"纵向")]){
        if (_isTouchBeganLeft) {
            int index = location.y - _startPoint.y;
            if(index>0){
                [UIScreen mainScreen].brightness = _systemBrightness - abs(index)/10 * 0.01;
            }else{
                [UIScreen mainScreen].brightness = _systemBrightness + abs(index)/10 * 0.01;
            }
            
        }else{
            int index = location.y - _startPoint.y;
            if(index>0){
                [_volumeViewSlider setValue:_systemVolume - (abs(index)/10 * 0.05) animated:YES];
                [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            }else{
                [_volumeViewSlider setValue:_systemVolume + (abs(index)/10 * 0.05) animated:YES];
                [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        
    }else{
        //"第一次"滑动
        if(fabs(changeX) > fabs(changeY)){
            _isSlideDirection = languageStringWithKey(@"横向");//设置为横向
        }else if(fabs(changeY)>fabs(changeX)){
            _isSlideDirection = languageStringWithKey(@"纵向");//设置为纵向
        }else{
            _isSlideOrClick = NO;
            DDLogInfo(@"不在五行中。");
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(event.allTouches.count == 1){
        //保存当前触摸的位置
        CGPoint point = [[touches anyObject] locationInView:self];
        _startPoint = point;
        _startProgress = _movieProgressSlider.value;
        _systemVolume = _volumeViewSlider.value;
        DDLogInfo(@"volume:%f",_volumeViewSlider.value);
        if(point.x < self.frame.size.width/2){
            _isTouchBeganLeft = YES;
        }else{
            _isTouchBeganLeft = NO;
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [[touches anyObject] locationInView:self];
    if (!_isSettingsViewShow) {
        
        if (_isSlideOrClick) {
            _isSlideDirection = @"";
            _isSlideOrClick = NO;
            
            CGFloat changeY = point.y - _startPoint.y;
            CGFloat changeX = point.x - _startPoint.x;
            //如果位置改变 刷新进度条
            if(fabs(changeX) > fabs(changeY)){
                [self UpdatePlayer];
            }
            return;
        }
        
        if (_isShowView) {
            //上下View为显示状态，此时点击上下View直接return
            if ((point.y>CGRectGetMinY(self.topView.frame)&&point.y< CGRectGetMaxY(self.topView.frame))||(point.y<CGRectGetMaxY(self.bottomView.frame)&&point.y>CGRectGetMinY(self.bottomView.frame))) {
                return;
            }
            _isShowView = NO;
            [UIView animateWithDuration:0.5 animations:^{
                _topView.alpha = 0;
                _bottomView.alpha = 0;
            }];
        }else{
            _isShowView = YES;
            [UIView animateWithDuration:0.5 animations:^{
                _topView.alpha = 1;
                _bottomView.alpha = 1;
            }];
        }
        
    }else{
        if (point.x>CGRectGetMinX(_rightView.frame)&&point.x< CGRectGetMaxX(_rightView.frame)) {
            return;
        }
        _settingsView.alpha = 0;
        _isSettingsViewShow = NO;
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
