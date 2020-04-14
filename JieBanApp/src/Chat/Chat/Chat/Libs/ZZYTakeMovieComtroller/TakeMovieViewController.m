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
//#import "x264Manager.h"

@interface TakeMovieViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate>
{
    Camera *_camera;
    UIView *cameraView;
    BOOL isStart;
    BOOL isCancel;
    CALayer *progressLayer;
    StartButton *startButton;
    UILabel *tipsLabel;
    NSTimer *timer;
    NSInteger time;
    BOOL _isRecording; //是否在录制状态
    UIButton *_playBtn;
}
//@property (nonatomic, retain)x264Manager *manager264;

@end

@implementation TakeMovieViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    isStart = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f];
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
    
    //TabBarButtonItem
    UIImage *normalImg = [UIImage imageNamed:@"title_bar_back"];
    CGRect btnFrame = CGRectMake(-10, 0, 40, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:normalImg forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIView *frameView = [[UIView alloc] initWithFrame:btnFrame];
    [frameView addSubview:button];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameView];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    [self setRightNavBarItemsDone:NO];
    //默认不是在录制状态
    _isRecording = NO;
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kLittleVideoLocalPathKey];
}

- (void)setRightNavBarItemsDone:(BOOL)done{
    UIBarButtonItem *redoButton = [[UIBarButtonItem alloc]initWithTitle:@"重拍" style:UIBarButtonItemStylePlain target:self action:@selector(resetCamera:)];
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    UIBarButtonItem *changeButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera_switch"] style:UIBarButtonItemStylePlain target:self action:@selector(swapFrontAndBackCameras)];
    
    if ((!done)&&[self isFrontCameraAvailable]&&[self isRearCameraAvailable]&&[self hasMultipleCameras]) {
        self.navigationItem.rightBarButtonItems = @[changeButton];
    }else if (done){
        self.navigationItem.rightBarButtonItems = @[finishButton,redoButton];
    }
}

-(void)initCamera{
    
    //    x264Manager *m264 = [[x264Manager alloc]init];
    //    [m264 initForX264];
    //    self.manager264 = m264;
    //    [self.manager264 initForFilePath:kLittleVideoOutPutLocalPath];
    
    cameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_width, Screen_height/2)];
    [self.view insertSubview:cameraView atIndex:0];
    _camera = [[Camera alloc]init];
    _camera.frameNum = _frameNum;
    [_camera embedLayerWithView:cameraView];
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [_camera.imageOutput setSampleBufferDelegate:self queue:queue];
    [_camera startCamera];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setImage:[UIImage imageNamed:@"video_button_play_normal"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"video_button_play_pressed"] forState:UIControlStateHighlighted];
    _playBtn.frame = cameraView.bounds;
    [cameraView addSubview:_playBtn];
    _playBtn.hidden = YES;
    
}

-(void)initStartButton{
    startButton = [[StartButton alloc]initWithFrame:CGRectMake(Screen_width/4, Screen_height/2+Screen_height/16, Screen_width/2, Screen_width/2)];
    [self.view addSubview:startButton];
    
}
-(void)initProgress{
    progressLayer = [CALayer layer];
    progressLayer.backgroundColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1].CGColor;
    progressLayer.frame = CGRectMake(0, Screen_height/2, Screen_width, 5);
    [self.view.layer addSublayer:progressLayer];
    CABasicAnimation *countTime = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    countTime.toValue = @0;
    countTime.duration = _cameraTime;
    countTime.removedOnCompletion = NO;
    countTime.fillMode = kCAFillModeForwards;
    [progressLayer addAnimation:countTime forKey:@"progressAni"];
}
-(void)panAction:(UIPanGestureRecognizer*)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.y < Screen_height/2) {
        isCancel = YES;
        progressLayer.backgroundColor = [UIColor redColor].CGColor;
        tipsLabel.text = @"松手取消";
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.backgroundColor = [UIColor redColor];
//        tipsLabel.backgroundColor = ThemeColor
    }
    else{
        isCancel = NO;
        progressLayer.backgroundColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1].CGColor;
        tipsLabel.text = @"上移取消";
        tipsLabel.textColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1];
        tipsLabel.backgroundColor = [UIColor clearColor];
    }
}

-(void)startAction:(UILongPressGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        isStart = YES;
        isCancel = NO;
        [startButton disappearAnimation];
        [self initProgress];
        tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(Screen_width/2-42, Screen_height/2-30, 100, 20)];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.text = @"上移取消";
        tipsLabel.textColor = [UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1];
        [self.view addSubview:tipsLabel];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        time = 0;
        NSLog(@"start");
        
        _isRecording = YES;
        
        [_camera startRecordingWithUrl:kLittleVideoOutPutLocalPath];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if (isCancel) {
            NSLog(@"cancel");
            isStart = NO;
            [timer invalidate];
            [progressLayer removeFromSuperlayer];
            [tipsLabel removeFromSuperview];
            [startButton appearAnimation];
            return;
        }
        else{
            if (time < 1) {
                isStart = NO;
                [timer invalidate];
                [progressLayer removeFromSuperlayer];
                [startButton appearAnimation];
                tipsLabel.text = @"手指不要放开";
                tipsLabel.textColor = [UIColor whiteColor];
                tipsLabel.backgroundColor = [UIColor redColor];
                [UIView animateWithDuration:2.0 animations:^{
                    tipsLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [tipsLabel removeFromSuperview];
                }];
                return;
            }
            else if(time >=1 && time < _cameraTime){
                [self finishCamera];
            }
        }
    }
}
-(void)countDown:(NSTimer*)timerer{
    time++;
    if (time >= _cameraTime) {
        [self finishCamera];
    }
    NSLog(@"%ld",(long)time);
}
-(void)resetCamera:(UIBarButtonItem*)sender{
    //    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //    BOOL bRet = [fileMgr fileExistsAtPath:kLittleVideoOutPutLocalPath];
    //    if (bRet) {
    //        //
    //        NSError *err;
    //        [fileMgr removeItemAtPath:kLittleVideoOutPutLocalPath error:&err];
    //    }
    cameraView.hidden = NO;
    [_camera startCamera];
    startButton.hidden = NO;
    [startButton appearAnimation];
    _playBtn.hidden = YES;
    _isRecording = NO;
    [self setRightNavBarItemsDone:NO];
}
- (void)finishCamera{
    [timer invalidate];
    [_camera stopRecord];
    [_camera stopCamera];
    isStart = NO;
    [progressLayer removeFromSuperlayer];
    [tipsLabel removeFromSuperview];
    startButton.hidden = YES;
    cameraView.hidden = NO;
    _playBtn.hidden = NO;
    [self setRightNavBarItemsDone:YES];
}
-(void)done:(UIBarButtonItem*)sender{
    //push viewcontroller
    
    NSURL *assetUrl = [[NSUserDefaults standardUserDefaults] URLForKey:kLittleVideoLocalPathKey];
    if (assetUrl && ![assetUrl.path isEqualToString:@""]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSendUserVideoUrl:)]) {
            [self.delegate onSendUserVideoUrl:assetUrl];
        }
    }
    [self backAction];
    
}

- (void)backAction{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
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
- (void)playVideo{
    NSURL *assetUrl = [[NSUserDefaults standardUserDefaults] URLForKey:kLittleVideoLocalPathKey];
    //    NSURL *assetUrl = [NSURL URLWithString:kLittleVideoOutPutLocalPath];
    [self createMPPlayerController:assetUrl];
}

- (void)createMPPlayerController:(NSURL *)assetUrl {
    
    MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:assetUrl];
    
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
    if (_isRecording) {
        [SVProgressHUD showErrorWithStatus:@"暂不支持录制时切换摄像头功能"];
        return;
    }
    [_camera swapFrontAndBackCameras];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
