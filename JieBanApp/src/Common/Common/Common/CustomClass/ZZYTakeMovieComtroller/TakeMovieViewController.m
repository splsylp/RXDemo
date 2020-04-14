//
//  TakeMovieViewController.m
//  ZZYWeiXinShortMovie
//
//  Created by zhangziyi on 16/3/23.
//  Copyright © 2016年 GLaDOS. All rights reserved.
//
#define Screen_width [UIScreen mainScreen].bounds.size.width
#define Screen_height [UIScreen mainScreen].bounds.size.height
#import "TakeMovieViewController.h"
#import "StartButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "HXMPMovieController.h"
#import "KCConstants_API.h"
//#import "x264Manager.h"

@interface TakeMovieViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate>
{
    Camera *_camera;
    AVPlayer *_avplayer;
    AVPlayerLayer *_playerLayer;
    UIView *cameraView;
    BOOL isStart;
    BOOL isCancel;
    CAShapeLayer *progressLayer;
    CAShapeLayer *bgLayer;
    CAShapeLayer *shapeProgressLayer;
    
    StartButton *startButton; // 中间按着拍摄按钮
    
    UILabel *tipsLabel;
    NSTimer *timer;
    CGFloat time;
    
    UIButton *_playBtn; // 播放按钮
    //    UIBarButtonItem *_changeButton; //切换摄像头按钮 没用了
    UIButton *_rightBtn ;// 切换摄像头按钮
    UIButton *_redoButton;   //重拍按钮
    UIButton *_finishButton;  //发送按钮
    UIButton *leftBackButton ; // 左边返回按钮
    UIButton *btnCloseButton;//左边向下的箭头
    UIImage *myImage;//拍摄的照片
    CGFloat progressLayerPresent;// 进度条百分比
    CGFloat animateTime;// 进度条每次跳转的时间
}
//@property (nonatomic, retain)x264Manager *manager264;
@end

@implementation TakeMovieViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    animateTime = 0.05;
    progressLayerPresent = animateTime / _cameraTime;
    
    [self.navigationController.navigationBar setHidden:YES];
    self.navigationController.navigationBar.translucent = NO;
    //    [self.navigationController.view setBackgroundColor:[UIColor redColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    isStart = NO;
    self.view.backgroundColor = [UIColor blackColor];;
    
    [self setBackAndCameraBtn];
    
    [self initCamera];//初始化摄像头
    [self initStartButton];//初始化开始拍摄按钮
    
    //拍摄手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    panGesture.delegate = self;
    [startButton addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGeture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(startAction:)];
    longPressGeture.delegate = self;
    longPressGeture.minimumPressDuration = 0.1;
    [startButton addGestureRecognizer:longPressGeture];
    
    
    UITapGestureRecognizer *UITapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    UITapGesture.numberOfTapsRequired =1;
    UITapGesture.numberOfTouchesRequired  =1;
    [startButton addGestureRecognizer:UITapGesture];
    
    
    
    CGRect btnFrame = CGRectMake(0, 0, 40, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"1DA1F2"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightNavBarItemsDone:NO];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kLittleVideoLocalPathKey];
    
}
-(void)setBackAndCameraBtn{
    //重新拍摄按钮
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftButton.frame = CGRectMake(26*iPhone6FitScreenWidth, kScreenHeight-70*iPhone6FitScreenWidth - 60*iPhone6FitScreenWidth, 60 * iPhone6FitScreenWidth, 60 *iPhone6FitScreenWidth);
//    UIImage *leftBtnImage = ThemeImage(@"btn_return_normal");
//    [leftButton setImage:leftBtnImage forState:UIControlStateNormal];
//    leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    leftBackButton = leftButton;
//    leftBackButton.hidden = YES;
//    [self.view addSubview:leftBackButton];
//
    //  关闭页面按钮
    UIButton *btnCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseBtn.frame = CGRectMake(46*iPhone6FitScreenWidth, kScreenHeight-70*iPhone6FitScreenWidth - 50*iPhone6FitScreenWidth, 60 * iPhone6FitScreenWidth, 60 *iPhone6FitScreenWidth);
    UIImage *btnCloseBtnImage = ThemeImage(@"btn_close_normal");
    [btnCloseBtn setImage:btnCloseBtnImage forState:UIControlStateNormal];
    
    btnCloseBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnCloseBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    btnCloseButton = btnCloseBtn;
    btnCloseButton.hidden = NO;
    [self.view addSubview:btnCloseButton];
    
    // 切换摄像头按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(kScreenWidth - 26 *iPhone6FitScreenWidth - 60*iPhone6FitScreenWidth, kScreenHeight-70*iPhone6FitScreenWidth - 60*iPhone6FitScreenWidth, 60*iPhone6FitScreenWidth, 60*iPhone6FitScreenWidth);
    UIImage *rightBtnImage = ThemeImage(@"btn_cameralens");
    [rightButton setImage:rightBtnImage forState:UIControlStateNormal];
    rightButton.right = kScreenWidth-20;
    rightButton.top = 25.f;
    
    [rightButton addTarget:self action:@selector(swapFrontAndBackCameras) forControlEvents:UIControlEventTouchUpInside];
    _rightBtn = rightButton;
//    _rightBtn.hidden = YES;
    [self.view addSubview:_rightBtn];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!startButton.hidden)
    {
        [_camera startCamera];
    }
}

- (void)dealloc
{
    
}

- (void)setRightNavBarItemsDone:(BOOL)done{
    
    if ((!done)&&[self isFrontCameraAvailable]&&[self isRearCameraAvailable]&&[self hasMultipleCameras]) {
        //        self.navigationItem.rightBarButtonItem = _changeButton;
        _redoButton.hidden = YES;
        _finishButton.hidden = YES;
        _rightBtn.hidden = NO;
    }else if (done){
        //        self.navigationItem.rightBarButtonItem = nil;
        _redoButton.hidden = NO;
        _finishButton.hidden = NO;
        
        leftBackButton.hidden = YES;
        _rightBtn.hidden = YES;
        btnCloseButton.hidden = YES;
    }
}

-(void)initCamera{
    
    cameraView = [[UIView alloc]initWithFrame:CGRectMake(0,0, Screen_width, Screen_height)];
    [self.view insertSubview:cameraView atIndex:0];
    _camera = [[Camera alloc]init];
    _camera.frameNum = _frameNum;
    [_camera embedLayerWithView:cameraView];
    
    WS(weakSelf)
    _camera.finishCameraBlock = ^(NSURL *url) {
        if (time > 1.0) {
            [weakSelf playVideo:url];
        }
    };
}

-(void)initStartButton{
    // 重拍按钮
    _redoButton = [[UIButton alloc]initWithFrame:CGRectMake(60*iPhone6FitScreenWidth, Screen_height - 50*iPhone6FitScreenWidth - 72*iPhone6FitScreenWidth, 72*iPhone6FitScreenWidth, 72*iPhone6FitScreenWidth)];
    UIImage *redoImage = ThemeImage(@"btn_return_normal");
    UIImage *redoPressImage = ThemeImage(@"btn_return_pressed");
    [_redoButton setImage:redoImage forState:UIControlStateNormal];
    [_redoButton setImage:redoPressImage forState:UIControlStateHighlighted];
    [_redoButton setAlpha:1];
    _redoButton.layer.masksToBounds = YES;
    _redoButton.hidden = YES;
    [_redoButton addTarget:self action:@selector(resetCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    //发送按钮
    _finishButton = [[UIButton alloc]initWithFrame:CGRectMake(Screen_width-60*iPhone6FitScreenWidth-54*iPhone6FitScreenWidth, Screen_height-50*iPhone6FitScreenWidth-72*iPhone6FitScreenWidth, 72*iPhone6FitScreenWidth, 72*iPhone6FitScreenWidth)];
    UIImage *photoOkImage = ThemeImage(@"btn_confirm_normal");
    UIImage *photoOkPressImage = ThemeImage(@"btn_confirm_pressed");
    [_finishButton setImage:photoOkImage forState:UIControlStateNormal];
    [_finishButton setImage:photoOkPressImage forState:UIControlStateHighlighted];
    [_finishButton setAlpha:1];
    _finishButton.layer.masksToBounds = YES;
    _finishButton.hidden = YES;
    [_finishButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 中间录制按钮
    startButton = [[StartButton alloc]initWithFrame:CGRectMake(Screen_width / 2 - 34*iPhone6FitScreenWidth, Screen_height - 134 *iPhone6FitScreenWidth, 68 * iPhone6FitScreenWidth , 68 * iPhone6FitScreenWidth)];
    
    [self.view addSubview:_redoButton];
    [self.view addSubview:_finishButton];
    [self.view addSubview:startButton];
    
}

-(void)initProgress{
    
    //
    //第一步，通过UIBezierPath设置圆形的矢量路径
    //    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, -100, 200, 200)];
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0,0) radius:56*iPhone6FitScreenWidth startAngle:-M_PI / 2 endAngle:M_PI * 1.5 clockwise:YES];
    
    UIBezierPath *circle2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0,0) radius:48*iPhone6FitScreenWidth startAngle:-M_PI / 2 endAngle:M_PI * 1.5 clockwise:YES];
    //第二步，用CAShapeLayer沿着第一步的路径画一个完整的环（颜色灰色，起始点0，终结点1）
    bgLayer = [CAShapeLayer layer];
    bgLayer.frame = CGRectMake(0, 0, 0, 0);//设置Frame
    //    bgLayer.position = self.view.center;//居中显示
    bgLayer.position = startButton.center;
    bgLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色=透明色
    //     bgLayer.fillColor = [UIColor redColor].CGColor;//填充颜色=透明色
    bgLayer.lineWidth = 2.f;//线条大小
    //        bgLayer.strokeColor = [UIColor yellowColor].CGColor;//线条颜色
    bgLayer.strokeColor = [UIColor clearColor].CGColor;
    bgLayer.strokeStart = 0.f;//路径开始位置
    bgLayer.strokeEnd = 1.f;//路径结束位置
    bgLayer.path = circle2.CGPath;//设置bgLayer的绘制路径为circle的路径
    [self.view.layer addSublayer:bgLayer];//添加到屏幕上
    
    //第三步，用CAShapeLayer沿着第一步的路径画一个红色的环形进度条，但是起始点=终结点=0，所以开始不可见
    progressLayer = [CAShapeLayer layer];
    progressLayer.frame = CGRectMake(0, 0,0, 0);
    //    progressLayer.position = self.view.center;
    progressLayer.position = startButton.center;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    //        progressLayer.fillColor = [UIColor blueColor].CGColor;
    progressLayer.lineWidth = 5.f;
    progressLayer.strokeColor = [UIColor colorWithHexString:@"#48CB83"].CGColor;
    //   progressLayer.strokeColor =  [UIColor orangeColor].CGColor;
    progressLayer.strokeStart = 0;
    progressLayer.strokeEnd = 0;
    progressLayer.path = circle.CGPath;
    [self.view.layer addSublayer:progressLayer];
    
    //第四步，用一个定时器进行测试 之前有定时器了，这里不需要了
    //    timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(animate) userInfo:nil repeats:YES];
    
    
    // 原来横线的时候这样的
    //    progressLayer = [CALayer layer];
    //    progressLayer.backgroundColor = ThemeColor.CGColor;
    //    progressLayer.frame = CGRectMake(0, Screen_height/2, Screen_width, 5);
    //    //[self.view.layer addSublayer:progressLayer];
    //    CABasicAnimation *countTime = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //    countTime.toValue = @0;
    //    countTime.duration = _cameraTime;
    //    countTime.removedOnCompletion = NO;
    //    countTime.fillMode = kCAFillModeForwards;
    //    [shapeProgressLayer addAnimation:countTime forKey:@"progressAni"];
    //timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
}
-(void)animate{
    progressLayer.strokeEnd += progressLayerPresent;
    NSLog(@" time ====== %ld    progressLayer.strokeEnd------> %f",(long)time,progressLayer.strokeEnd);
}
-(void)countDown:(NSTimer*)timerer{
    time += animateTime;
    progressLayer.strokeEnd += progressLayerPresent;
    NSLog(@" time ====== %f    progressLayer.strokeEnd------> %f",time,progressLayer.strokeEnd);
    if (time >= _cameraTime) {
        [self finishCamera];
    }
    NSLog(@"%f",time);
}
#pragma mark - 禁止横屏
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return   UIInterfaceOrientationPortrait ;
}

-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=1;
    //    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}
-(void)panAction:(UIPanGestureRecognizer*)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.y < Screen_height/2) {
        isCancel = YES;
        progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        tipsLabel.text = @"松手取消";
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.backgroundColor = [UIColor clearColor];
    }
    else{
        isCancel = NO;
        //        progressLayer.backgroundColor = ThemeColor.CGColor;
        progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        tipsLabel.text = @"上移取消";
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.backgroundColor = [UIColor clearColor];
    }
}

-(void)takePhoto:(UITapGestureRecognizer*)gestureRecognizer{
    if (self.type == RXTakeMovieTypeVideo) {
        return;
    }
    if (time>0.1) {
        return;
    }
    [_camera photoBtnDidClickWithcompletion:^(UIImage *image) {
        DDLogInfo(@"image = %@",image);
        if (image) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:kLittleVideoLocalPathKey];
            myImage = image;
            [self finishCamera];
        }
    }];
    DDLogInfo(@"takePhoto");
}
-(void)startAction:(UILongPressGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (self.type == RXTakeMovieTypePhoto) {
            return;
        }
        isStart = YES;
        isCancel = NO;
        [startButton disappearAnimation];
        [self initProgress];
        tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(startButton.center.x-45, startButton.center.y-30-68*iPhone6FitScreenWidth, 90, 20)];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        //tipsLabel.text = @"上移取消";
        tipsLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:tipsLabel];
        timer = [NSTimer scheduledTimerWithTimeInterval:animateTime target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        time = 0;
        progressLayer.strokeEnd = 0;
        NSLog(@"start");
        self.navigationItem.rightBarButtonItem = nil;
        [_camera startRecordingWithUrl:kLittleVideoOutPutLocalPath];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if (isCancel) {
            NSLog(@"cancel");
            isStart = NO;
            [timer invalidate];
            [progressLayer removeFromSuperlayer];
            [bgLayer removeFromSuperlayer];
            [tipsLabel removeFromSuperview];
            [startButton appearAnimation];
            //            self.navigationItem.rightBarButtonItems = @[_changeButton];
            return;
        }
        else{
            if (time <= 1.0) {
                DDLogInfo(@"eagle.time = %lf",time);
                isStart = NO;
                [timer invalidate];
                [progressLayer removeFromSuperlayer];
                [bgLayer removeFromSuperlayer];
                [startButton appearAnimation];
                //                self.navigationItem.rightBarButtonItems = @[_changeButton];
                tipsLabel.text = @"录制时间过短";
                tipsLabel.textColor = [UIColor whiteColor];
                tipsLabel.backgroundColor = [UIColor clearColor];
                [UIView animateWithDuration:2.0 animations:^{
                    tipsLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [tipsLabel removeFromSuperview];
                }];
                return;
            }
            else if(time >1.0 && time < _cameraTime){
                [self finishCamera];
            }
        }
    }
}

-(void)resetCamera:(UIBarButtonItem*)sender{
    cameraView.hidden = NO;
    
    [self stopPlay];
    
    [_camera startCamera];
    startButton.hidden = NO;
    btnCloseButton.hidden = NO;
    
//    _rightBtn.hidden = YES;
    leftBackButton.hidden = YES;
    _finishButton.hidden = YES;
    _playBtn.hidden = YES;
    
    myImage = nil;
    [startButton appearAnimation];
    [self setRightNavBarItemsDone:NO];
}
- (void)finishCamera{
    [timer invalidate];
    [_camera stopRecord];
    [_camera stopCamera];
    isStart = NO;
    [progressLayer removeFromSuperlayer];
    [bgLayer removeFromSuperlayer];
    [tipsLabel removeFromSuperview];
    startButton.hidden = YES;
    _redoButton.hidden = NO;
    _finishButton.hidden = NO;
    cameraView.hidden = NO;
    _playBtn.hidden = NO;
    _rightBtn.hidden = YES;
    leftBackButton.hidden = YES;
    [self setRightNavBarItemsDone:YES];
    
}

-(void)done:(UIBarButtonItem*)sender{
    //push viewcontroller
    
    NSURL *assetUrl = [[NSUserDefaults standardUserDefaults] URLForKey:kLittleVideoLocalPathKey];
    if (myImage){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSendImage:)]) {
            [self.delegate onSendImage:myImage];
        }
    } else if (assetUrl && ![assetUrl.path isEqualToString:@""]) {
        [self stopPlay];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSendUserVideoUrl:)]) {
            [self.delegate onSendUserVideoUrl:assetUrl];
        }
    }

    [self backAction];
}

- (void)backAction{
    [timer invalidate];
    [_camera stopRecord];
    [_camera stopCamera];
    [_camera stopRecord];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelTake)]) {
        [self.delegate cancelTake];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    //    if (isStart) {
    //        [self.manager264 encoderToH264:sampleBuffer];
    //    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//预览播放
- (void)playVideo:(NSURL *)assetUrl{
//    NSURL *assetUrl = [[NSUserDefaults standardUserDefaults] URLForKey:kLittleVideoLocalPathKey];
    //    NSURL *assetUrl = [NSURL URLWithString:kLittleVideoOutPutLocalPath];
//    [self createMPPlayerController:[NSString stringWithFormat:@"%@",assetUrl]];
    [self removeNotification];
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:assetUrl];
    AVPlayer * player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = cameraView.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [cameraView.layer addSublayer:playerLayer];
    [player play];
    _avplayer = player;
    _playerLayer = playerLayer;
    [self addNotification];
}

- (void)createMPPlayerController:(NSString *)fileNamePath {
    
    HXMPMovieController *playerView =[[HXMPMovieController alloc]initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", fileNamePath]]];
    
    
    // MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", fileNamePath]]];
    
    playerView.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    
    [playerView.view setBackgroundColor:[UIColor clearColor]];
    [playerView.view setFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerView.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStateChangeCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:playerView.moviePlayer];
    
    [self presentViewController:playerView animated:NO completion:nil];
}

-(void)movieStateChangeCallback:(NSNotification*)notify  {
    
    //点击播放器中的播放/ 暂停按钮响应的通知
    MPMoviePlayerController *playerView = notify.object;
    MPMoviePlaybackState state = playerView.playbackState;
    switch (state) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");
            break;
        case MPMoviePlaybackStateSeekingForward:
            NSLog(@"快进");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"快退");
            break;
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"打断");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",(long)state);
            break;
    }
}

-(void)movieFinishedCallback:(NSNotification*)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    MPMoviePlayerController* theMovie = [notify object];
    [theMovie stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

// 前面的摄像头是否可用
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}
// 后面的摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
- (BOOL) hasMultipleCameras {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices != nil && [devices count] >1) return YES;
    return NO;
}
- (void)swapFrontAndBackCameras{
    [_camera swapFrontAndBackCameras];
}

 /**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_avplayer.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [_avplayer seekToTime:CMTimeMake(0, 1)];
    [_avplayer play];
}

- (void)stopPlay {
    [_avplayer pause];
    [_avplayer.currentItem cancelPendingSeeks];
    [_avplayer.currentItem.asset cancelLoading];
    [self removeNotification];
    //当代码中调用了addPeriodicTimeObserverForInterval方法的时候，还需要释放addPeriodicTimeObserverForInterval返回的playbackObserver对象
    [_playerLayer removeFromSuperlayer];
}

@end

