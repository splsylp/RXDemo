//
//  YXPCameraViewController.m
//  Common
//
//  Created by yuxuanpeng on 2017/6/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YXPPlayer.h"
#import "YXProgressView.h"
#import <CoreMotion/CoreMotion.h>

#define HX_SaveMovePath  [NSTemporaryDirectory() stringByAppendingString:@"RlmyMovie.mp4"]

//#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

typedef enum : NSUInteger {
    CurrentOrientationPortrait,
    CurrentOrientationPortraitUpsideDown,
    CurrentOrientationLandscapeRight,
    CurrentOrientationLandscapeLeft
} CurrentDeviceOrientation;

@interface YXPCameraViewController ()<AVCaptureFileOutputRecordingDelegate>

/***************控件******************/
//提示语控件  轻触拍照，按住摄像
@property(nonatomic,strong)UILabel *promptLable;

//返回按钮
@property(nonatomic,strong)UIButton *backBtn;

//重新录制
@property(nonatomic,strong)UIButton *afreshBtn;

//确定
@property(nonatomic,strong)UIButton *sureBtn;

//摄像头切换
@property(nonatomic,strong)UIButton *switchBtn;


//视频播放view
@property(nonatomic,strong)YXPPlayer *player;

//进度条
@property(nonatomic,strong)YXProgressView *progressView;

//录制imageview
@property (strong, nonatomic)UIImageView *imgRecordView;

////聚焦光标
@property (strong, nonatomic) UIImageView *focusCursor;

@property (strong, nonatomic) UIImageView *bgView;

/************录制视频和拍照*****************/
//视频输出流
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;

//获取输入数据
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;

//捕捉录制数据对象
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;


/***************其他参数***********************/
//记录需要保存视频的路径
@property (strong, nonatomic) NSURL *saveVideoUrl;

//记录录制的时间
@property(nonatomic,assign)NSInteger seconds;

//是否在对焦
@property(nonatomic,assign)BOOL isFocus;

//后台任务标识
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (assign,nonatomic) UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier;

//是否是摄像 YES 代表是录制  NO 表示拍照
@property (assign, nonatomic) BOOL isVideo;
@property (assign, nonatomic) BOOL isEnd;//拍照完成

//获取第一帧图片
@property (strong, nonatomic) UIImageView *takeImageView;
@property (strong, nonatomic) UIImage *takeImage;
@property (strong, nonatomic) AVCaptureDevice *device; //创建 配置输入设备

@property (strong, nonatomic) CMMotionManager *motionManager;//加速器
@property (assign, nonatomic) CurrentDeviceOrientation deviceOrientation;   // 判断横竖屏




@end

//时间大于这个就是视频，否则为拍照
#define TimeMax 1

//距离底部的距离
#define  bottomSpacing  50
//录制按钮的高和宽
#define  recordWH  60*fitScreenWidth
#define  progressWH 90*fitScreenWidth

#define  focusWH   120*fitScreenWidth
@implementation YXPCameraViewController

#pragma mark life cycle

- (void)dealloc
{
    [self removeNotification];
   
}

- (BOOL)shouldRecognizeTapGesture
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置view的背景是黑色
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bgView];
    [self customCamera];
    [self initMotionManager];
    [self.view addSubview:self.promptLable];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.imgRecordView];
    [self.view addSubview:self.sureBtn];
    [self.view addSubview:self.afreshBtn];
    [self.view addSubview:self.switchBtn];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.focusCursor];
    [self hiddenPrompt];
    [self performSelector:@selector(durationShowFocusCursor) withObject:nil afterDelay:1];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    DDLogInfo(@"开始录制...");
    self.seconds = self.recordTime;
    [self performSelector:@selector(setProgressShowView:) withObject:fileURL afterDelay:0.4];
}


-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    DDLogInfo(@"视频录制完成.");
    [self changeLayout:outputFileURL];
    
    
}

- (void)videoHandlePhoto:(NSURL *)url {
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
    NSError *error = nil;
    CMTime time = CMTimeMake(0,5);//缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获取某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        DDLogInfo(@"截取视频图片失败:%@",error.localizedDescription);
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    if (image) {
        DDLogInfo(@"视频截取成功");
    } else {
        DDLogInfo(@"视频截取失败");
    }
    
    
    self.takeImage = image;//[UIImage imageWithCGImage:cgImage];
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    
    if (!self.takeImageView) {
        self.takeImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        self.takeImageView.backgroundColor=[UIColor blackColor];
        self.takeImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.takeImageView.clipsToBounds = YES;
        [self.bgView addSubview:self.takeImageView];
    }
    self.takeImageView.hidden = NO;
    self.takeImageView.image = self.takeImage;
}

#pragma mark  customCamera 自定义相机

- (void)customCamera
{
    //初始化会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc] init];

    //设置分辨率 (设备支持的最高分辨率)
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    //取得后置摄像头
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    
    
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];

    //初始化输入设备
    NSError *error = nil;
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        DDLogInfo(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //添加音频
    error = nil;
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        DDLogInfo(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //输出对象
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];//视频输出
    
    //将输入设备添加到会话
    if ([self.session canAddInput:self.captureDeviceInput]) {
        [self.session addInput:self.captureDeviceInput];
        [self.session addInput:audioCaptureDeviceInput];
        //设置视频防抖
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }
    
    //将输出设备添加到会话 (刚开始 是照片为输出对象)
    if ([self.session canAddOutput:self.captureMovieFileOutput]) {
        [self.session addOutput:self.captureMovieFileOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;//填充模式
    self.previewLayer.frame = self.view.bounds;//CGRectMake(0, 0, self.view.width, self.view.height);
    self.previewLayer.hidden =YES;
    [self.bgView.layer addSublayer:self.previewLayer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    
    if (![_session isRunning]) {
        //如果捕获会话没有运行
        [_session startRunning];
    }

}

#pragma mark systemMothod    系统方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    self.saveVideoUrl = nil;//清空保存路径
    if ([[touches anyObject] view] == self.imgRecordView) {
        self.isEnd = NO;
        DDLogInfo(@"开始录制");
        //根据设备输出获得连接
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        //根据连接取得设备输出的数据
        if (![self.captureMovieFileOutput isRecording]) {
            //如果支持多任务则开始多任务
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            if (self.saveVideoUrl) {
                [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
            }
            //预览图层和视频方向保持一致 首先判断当前设备的方向

            connection.videoOrientation =[self getCurRecordVideoOrientation];
            //[self.previewLayer connection].videoOrientation;
            if([[NSFileManager defaultManager]fileExistsAtPath:HX_SaveMovePath])
            {
                [[NSFileManager defaultManager]removeItemAtPath:HX_SaveMovePath error:nil];
            }
            NSURL *fileUrl=[NSURL fileURLWithPath:HX_SaveMovePath];
            DDLogInfo(@"fileUrl:%@",fileUrl);
            [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        } else {
            [self.captureMovieFileOutput stopRecording];
        }
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] view] == self.imgRecordView) {
        if (!self.isVideo) {
            self.isEnd = YES;
            [self performSelector:@selector(endRecord) withObject:nil afterDelay:0.6];
        } else {
            [self endRecord];
        }
    }

    DDLogInfo(@"结束触摸");
 
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
    DDLogInfo(@"...结取消..移除手势.....");

}


#pragma mark customMothod    自定义方法

//开始设置录制按钮

- (void)setProgressShowView:(NSURL *)fileURL
{
    if(self.isEnd)
    {
        return;
    }
    if ([self.captureMovieFileOutput isRecording]) {
         self.seconds =self.seconds-0.5;
        if (self.seconds > 0) {
            if ((self.recordTime - self.seconds + 0.4) >= TimeMax && !self.isVideo) {
                self.isVideo = YES;//长按时间超过TimeMax 表示是视频录制
                [self setImageReordCameraScale:0.6];
                self.progressView.timeMax = self.seconds;
            }
            [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:0.6];
        } else {
            if ([self.captureMovieFileOutput isRecording]) {
                [self.captureMovieFileOutput stopRecording];
            }
        }
    }

}

//开始录制计算时间
- (void)onStartTranscribe:(NSURL *)fileURL {
    if ([self.captureMovieFileOutput isRecording]) {
        -- self.seconds;
        if (self.seconds > 0) {
            if (self.recordTime - self.seconds >= TimeMax && !self.isVideo) {
                self.isVideo = YES;//长按时间超过TimeMax 表示是视频录制
                self.progressView.timeMax = self.seconds;
            }
            [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:1.0];
        } else {
            if ([self.captureMovieFileOutput isRecording]) {
                [self.captureMovieFileOutput stopRecording];
            }
        }
    }
}

//停止录制
- (void)endRecord {
    
    if ([self.captureMovieFileOutput isRecording]) {
        [self.captureMovieFileOutput stopRecording];
    }
}

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

- (void)dismissBack
{
    if(_motionManager)
    {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
    }
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void)switchCamera
{
    DDLogInfo(@"切换摄像头");
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;//前
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;//后
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.session beginConfiguration];
    //移除原有输入对象
    [self.session removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.session commitConfiguration];
}

- (void)sureAction
{
    DDLogInfo(@"确定 这里进行保存或者发送出去");
    if (self.saveVideoUrl) {
        
        if (self.takeBlock) {
            self.takeBlock(self.saveVideoUrl);
        }
//        WS(weakSelf)
//        [self showProgressWithMsg:@"视频处理中..."];
//        ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
//        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:self.saveVideoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
//            Plog(@"outputUrl:%@",weakSelf.saveVideoUrl);
//            [[NSFileManager defaultManager] removeItemAtURL:weakSelf.saveVideoUrl error:nil];
//            if (weakSelf.lastBackgroundTaskIdentifier!= UIBackgroundTaskInvalid) {
//                [[UIApplication sharedApplication] endBackgroundTask:weakSelf.lastBackgroundTaskIdentifier];
//            }
//            if (error) {
//                DDLogInfo(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
//                
//            } else {
//                if (weakSelf.takeBlock) {
//                    weakSelf.takeBlock(assetURL);
//                }
//                DDLogInfo(@"成功保存视频到相簿.");
//                [weakSelf closeProgress];
//            }
//        }];
    } else {
        //照片
        UIImageWriteToSavedPhotosAlbum(self.takeImage, self, nil, nil);
        if (self.takeBlock) {
            self.takeBlock(self.takeImage);
        }
    }
    [self dismissBack];
}

- (void)freshAction
{
    //重新录制
    [self recoverLayout];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    DDLogInfo(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    DDLogInfo(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    DDLogInfo(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    DDLogInfo(@"会话发生错误.");
}


//重新拍摄时调用
- (void)recoverLayout {
   
    [self.session commitConfiguration];
    [self.session startRunning];


    if (self.isVideo) {
        self.isVideo = NO;
        [self.player stopPlayer];
        self.player.hidden = YES;
    }
    
    if (!self.takeImageView.hidden) {
        self.takeImageView.hidden = YES;
    }
    [self setImageReordCameraScale:1.0];
    [self setProgressScale:recordWH/progressWH];
    self.imgRecordView.hidden = NO;
    self.switchBtn.hidden = NO;
    self.afreshBtn.hidden = YES;
    self.sureBtn.hidden = YES;
    self.backBtn.hidden = NO;
    [self durationShowFocusCursor];

    [UIView animateWithDuration:0.25 animations:^{
        self.afreshBtn.originX = (kScreenWidth-recordWH)/2;
        self.sureBtn.originX = (kScreenWidth-recordWH)/2;
    }];
    

}

//拍摄完成时调用
- (void)changeLayout:(NSURL*)outputFileURL {
    
    self.switchBtn.hidden = YES;
    if (self.isVideo) {
        [self.progressView clearProgress];
    }
    [self setProgressScale:recordWH/progressWH];
    if (self.isVideo) {
        self.saveVideoUrl = outputFileURL;
        self.player = nil;
        if(self.player)
        {
            [self.player stopPlayer];
            self.player  = nil;
        }
        self.player = [[YXPPlayer alloc] initWithFrame:self.bgView.bounds withShowInView:self.bgView url:outputFileURL];

    } else {
        //照片
        self.saveVideoUrl = nil;
        [self videoHandlePhoto:outputFileURL];
    }
    [UIView animateWithDuration:0.15 animations:^{
        [self setImageReordCameraScale:1.0];
    } completion:^(BOOL finished) {
        self.imgRecordView.hidden = YES;
        self.afreshBtn.hidden = NO;
        self.sureBtn.hidden = NO;
        self.backBtn.hidden = YES;
        [UIView animateWithDuration:0.15 animations:^{
            
            self.afreshBtn.originX = (kScreenWidth/2 -self.afreshBtn.width)/2;
            self.sureBtn.originX = kScreenWidth/2  +  (kScreenWidth/2 -self.afreshBtn.width)/2;
        }];
        self.lastBackgroundTaskIdentifier = self.backgroundTaskIdentifier;
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        [self.session stopRunning];
    }];
    

    
}
//隐藏提示语
- (void)hiddenPrompt
{
    self.promptLable.alpha = 1.0;
    [self performSelector:@selector(hiddenTipsLabel) withObject:nil afterDelay:3.5];
    
}

- (void)hiddenTipsLabel
{
    self.promptLable.alpha = 1.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.promptLable.alpha = 0.0;
    }];
    
}

- (void)dismissView
{
    if(_motionManager)
    {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
    }
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

//延迟调用显示聚焦光标
- (void)durationShowFocusCursor
{
    self.previewLayer.hidden =NO;
    [self performSelector:@selector(showFocusView) withObject:nil afterDelay:0.3];
}
//显示聚焦光标
- (void)showFocusView
{
    [self setFocusCursorWithPoint:self.view.center];

}

#pragma mark setting 设置

//-(BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
//}

/**
 * 设置录制按钮的比例
 * scale 缩放的比例 float 类型
 **/

- (void)setImageReordCameraScale:(CGFloat)scale
{
    self.imgRecordView.transform = CGAffineTransformMakeScale(scale, scale);//宽高伸缩比例
}

/**
 * 设置进度条的缩放比例
 * scale 比例
 */

- (void)setProgressScale:(CGFloat)scale
{
   self.progressView.transform = CGAffineTransformMakeScale(scale, scale);//宽高伸缩比例
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        //自动白平衡
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动根据环境条件开启闪光灯
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        DDLogInfo(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}


/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    if (!self.isFocus) {
        self.isFocus = YES;
        self.focusCursor.center=point;
        self.focusCursor.alpha = 1.0;
        [UIView animateWithDuration:0.2 animations:^{
            self.focusCursor.transform = CGAffineTransformMakeScale(0.65, 0.65);

        } completion:^(BOOL finished) {
            [self performSelector:@selector(onHiddenFocusCurSorAction) withObject:nil afterDelay:0.3];
        }];
        

    }
}

- (void)onHiddenFocusCurSorAction {
    self.focusCursor.alpha=0;
    self.focusCursor.transform = CGAffineTransformIdentity;
    self.isFocus = NO;
}

//获取当前旋转的方向
- (AVCaptureVideoOrientation)getCurRecordVideoOrientation
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    switch (_deviceOrientation) {
        case CurrentOrientationPortrait:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case CurrentOrientationLandscapeLeft:
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case CurrentOrientationLandscapeRight:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case CurrentOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
    
    return videoOrientation;
}


- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    
//    if (fabs(y) >= fabs(x))
//    {  // DDLogInfo(@"竖屏");
//       
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];//这句话是防止手动先把设备置为竖屏,导致下面的语句失效.
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
//    }
//    else
//    {       // DDLogInfo(@"横屏");
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];//这句话是防止手动先把设备置为横屏,导致下面的语句失效.
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
//    }
    
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            _deviceOrientation = CurrentOrientationPortraitUpsideDown;
            // UIDeviceOrientationPortraitUpsideDown;
        }
        else{
            // UIDeviceOrientationPortrait;
            _deviceOrientation = CurrentOrientationPortrait;

        }
    }
    else
    {
        if (x >= 0){
            // UIDeviceOrientationLandscapeLeft;

            _deviceOrientation = CurrentOrientationLandscapeLeft;


        }
        else{
            // UIDeviceOrientationLandscapeRight;

            _deviceOrientation = CurrentOrientationLandscapeRight;

        }
    }
    
}

#pragma mark - 通知

//注册通知
- (void)setupObservers
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}


//进入后台就退出视频录制
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self dismissBack];
}

/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

#pragma mark setter and getter

//加速器
- (void)initMotionManager
{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    // 提供设备运动数据到指定的时间间隔
    _motionManager.deviceMotionUpdateInterval = .3;
    
    if (_motionManager.deviceMotionAvailable) {  // 确定是否使用任何可用的态度参考帧来决定设备的运动是否可用
        // 启动设备的运动更新，通过给定的队列向给定的处理程序提供数据。
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }else
    {
        [self setMotionManager:nil];
    }
}

- (UIImageView *)bgView
{

    if(!_bgView)
    {
        _bgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _bgView.userInteractionEnabled = YES;
    }
    
    return _bgView;
}


- (UILabel *)promptLable
{
   if(!_promptLable)
   {
       _promptLable = [[UILabel alloc]initWithFrame:CGRectMake(11.0, kScreenHeight-bottomSpacing-progressWH-20-20, kScreenWidth-22.0, 20)];
       _promptLable.text = _promptTitle;
       _promptLable.backgroundColor = [UIColor clearColor];
       _promptLable.textAlignment = NSTextAlignmentCenter;
       _promptLable.textColor = [UIColor whiteColor];
       _promptLable.alpha = 1.0;
   }
    return _promptLable;
}

- (YXProgressView *)progressView
{
   if(!_progressView)
   {
       _progressView = [[YXProgressView alloc]initWithFrame:CGRectMake((kScreenWidth-progressWH)/2, kScreenHeight-bottomSpacing-progressWH, progressWH, progressWH)];
       _progressView.backgroundColor = [UIColor colorWithRed:0.85f green:0.83f blue:0.82f alpha:1.00f];
       _progressView.layer.cornerRadius = _progressView.width/2;
       _progressView.layer.masksToBounds = YES;
       _progressView.hidden = YES;
       _progressView.userInteractionEnabled = YES;
   }
    return _progressView;
}

- (UIImageView *)imgRecordView
{
   if(!_imgRecordView)
   {
       _imgRecordView = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-recordWH)/2, kScreenHeight-recordWH- bottomSpacing - (progressWH-recordWH)/2, recordWH, recordWH)];
       _imgRecordView.userInteractionEnabled = YES;
       _imgRecordView.image = ThemeImage(@"camera_record");
   }
    return _imgRecordView;
}

- (UIButton *)backBtn
{
   if(!_backBtn)
   {
       _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
       _backBtn.frame = CGRectMake((kScreenWidth-recordWH)/4-(23*fitScreenWidth)/2, kScreenHeight- bottomSpacing - (progressWH-recordWH)/2 - (recordWH + 13*fitScreenWidth)/2, 23*fitScreenWidth, 13*fitScreenWidth);
       [_backBtn setBackgroundImage:ThemeImage(@"camera_back") forState:UIControlStateNormal];
       [_backBtn addTarget:self action:@selector(dismissBack) forControlEvents:UIControlEventTouchUpInside];
   }
    return _backBtn;
}

- (UIButton *)switchBtn
{
   if(!_switchBtn)
   {
       _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
       _switchBtn.frame = CGRectMake(kScreenWidth-37-15, 30, 30, 23);
       [_switchBtn setBackgroundImage:ThemeImage(@"camera_switch.png") forState:UIControlStateNormal];
       [_switchBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
   }
    
    return _switchBtn;
}

- (UIButton *)sureBtn
{
   if(!_sureBtn)
   {
       _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
       _sureBtn.frame = CGRectMake((kScreenWidth-recordWH)/2, kScreenHeight-recordWH- bottomSpacing - 10, recordWH, recordWH);
       [_sureBtn setBackgroundImage:ThemeImage(@"camera_confirm.png") forState:UIControlStateNormal];
       [_sureBtn setBackgroundImage:ThemeImage(@"camera_confirm_on.png") forState:UIControlStateHighlighted];
       [_sureBtn setBackgroundImage:ThemeImage(@"camera_confirm_on.png") forState:UIControlStateSelected];

       [_sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
       _sureBtn.hidden = YES;
   }
    return _sureBtn;
}

- (UIButton *)afreshBtn
{
    if(!_afreshBtn)
    {
        _afreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _afreshBtn.frame = CGRectMake((kScreenWidth-recordWH)/2,kScreenHeight-recordWH- bottomSpacing - 10, recordWH, recordWH);
        [_afreshBtn setBackgroundImage:ThemeImage(@"camera_cancel") forState:UIControlStateNormal];
        [_afreshBtn addTarget:self action:@selector(freshAction) forControlEvents:UIControlEventTouchUpInside];
        _afreshBtn.hidden = YES;
    }
    return _afreshBtn;
}

- (UIImageView *)focusCursor
{
   if(!_focusCursor)
   {
       _focusCursor = [[UIImageView alloc]init];
       _focusCursor.size = CGSizeMake(focusWH,focusWH);
       _focusCursor.center = self.view.center;
       _focusCursor.backgroundColor = [UIColor clearColor];
       _focusCursor.image = ThemeImage(@"camera_focusing");
       _focusCursor.alpha = 0.0;
   }
    
    return _focusCursor;
}

@end
