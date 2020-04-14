//
//  Camera.m
//  ZZYWeiXinShortMovie
//
//  Created by zhangziyi on 16/3/23.
//  Copyright © 2016年 GLaDOS. All rights reserved.
//

#import "Camera.h"
#import "UIImage+deal.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
@interface Camera()
//@property (nonatomic,strong) <#id#> <#owner#>
@property(nonatomic,strong)CMMotionManager  *cmmotionManager;
@property (nonatomic, assign) UIInterfaceOrientation orientationLast;// 上次的方向
@end

@implementation Camera

-(id)init
{
    if(self =[super init])
    {
        if(!_session)
        {
            _session = [[AVCaptureSession alloc]init];
            [_session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        
        //获得输入设备 后置摄像头和麦克风 一般情况下使用默认的就可以了
        AVCaptureDevice *videoDevice  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        
        //根据输入设备初始化设备输入对象，用于获得输入数据
        NSError *error = nil;
        AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:videoDevice error:&error];
        AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioDevice error:&error];
        
        //将设备输入添加到会话中
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
        }
        
        if ([_session canAddInput:audioInput]) {
            [_session addInput:audioInput];
        }
        
        //配置默认帧数1秒10帧
        [_session beginConfiguration];
        if ([_device lockForConfiguration:&error]) {
            [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, 15)];
            [_device setActiveVideoMinFrameDuration:CMTimeMake(1, 10)];
            [_device unlockForConfiguration];
        }
        [_session commitConfiguration];
        
        //初始化设备输出对象，用于获得输出数据
        _deviceVideoOutput = [[AVCaptureMovieFileOutput alloc]init];
        //将设备输出添加到会话中
        if ([_session canAddOutput:_deviceVideoOutput]) {
            [_session addOutput:_deviceVideoOutput];
        }
        
        
        //添加图片输出
        _imageOutput = [[AVCaptureStillImageOutput alloc]init];
        [_imageOutput setHighResolutionStillImageOutputEnabled:false];
        if ([_session canAddOutput:_imageOutput]) {
            [_session addOutput:_imageOutput];
        }
        
        //    连接输出设备
        AVCaptureConnection *videoConnection = [_deviceVideoOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([videoConnection isVideoStabilizationSupported]) {//录制的稳定
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    [self initializeMotionManager];
    return self;
}
-(void)inputDevice{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = kCATransitionFade;
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromRight;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [_session beginConfiguration];
            [_session removeInput:_input];
            if ([_session canAddInput:newInput]) {
                [_session addInput:newInput];
                self.input = newInput;
                
            } else {
                [_session addInput:self.input];
            }
            
            [_session commitConfiguration];
            
        } else if (error) {
            DDLogInfo(@"toggle carema failed, error = %@", error);
        }
        
    }
}


- (void)cameraDistrict
{
    //设备取景开始
    [_session startRunning];
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

- (void)initializeMotionManager{
    self.cmmotionManager = [[CMMotionManager alloc] init];
    self.cmmotionManager.accelerometerUpdateInterval = .2;
    self.cmmotionManager.gyroUpdateInterval = .2;
    
    [self.cmmotionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                               withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                   if (!error) {
                                                       [self outputAccelertionData:accelerometerData.acceleration];
                                                   }
                                                   else{
                                                       NSLog(@"%@", error);
                                                   }
                                               }];
}
- (void)outputAccelertionData:(CMAcceleration)acceleration{
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
        //        KitDLog(@"方向是 左");
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
        //        KitDLog(@"方向是 右边u'b");
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
        //        KitDLog(@"方向是 上");
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
        //        KitDLog(@"方向是 下");
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == self.orientationLast)
        return;
    
    self.orientationLast = orientationNew;
}
#pragma mark - 截取照片

/**
 *  横着拍照时候，进行压缩
 *
 *  @param image 传过来的图片
 *
 *  @return 返回的图片
 */
- (UIImage*)imageCompressWithSimple:(UIImage*)image{
    CGSize size = image.size;
    CGFloat scale = 1.0;
    //TODO:KScreenWidth屏幕宽
    if (size.width > kScreenWidth || size.height > kScreenHeight) {
        if (size.width > size.height) {
            scale = kScreenWidth / size.width;
        }else {
            scale = kScreenHeight / size.height;
        }
    }
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGSize secSize =CGSizeMake(scaledWidth, scaledHeight);
    //TODO:设置新图片的宽高
    UIGraphicsBeginImageContext(secSize); // this will crop
    [image drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) photoBtnDidClickWithcompletion:(void (^)(UIImage *image))completion;
{//completion:(void(^)(ECError* error, NSArray* conferenceList))completion
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kLittleVideoLocalPathKey];
    AVCaptureConnection * videoConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevicePosition position = [[_input device] position];
    if (position == AVCaptureDevicePositionFront){
        videoConnection.videoMirrored = YES;
    }else {
        videoConnection.videoMirrored = NO;
    }
    if (!videoConnection) {
        DDLogInfo(@"take photo failed!");
        
        completion(nil);
        
        return;
    }
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            completion(nil);
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        UIImage *myImage = image;
        switch (self.orientationLast) {
            case UIInterfaceOrientationPortrait:
                DDLogInfo(@"正方向");
                break;
            case UIInterfaceOrientationLandscapeLeft:
                DDLogInfo(@"左边");
                if (position == AVCaptureDevicePositionFront){
                    myImage= [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUpMirrored];
                }else {
                    myImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationDown];
                }
                myImage = [self imageCompressWithSimple:myImage];
                break;
            case UIInterfaceOrientationLandscapeRight:
                DDLogInfo(@"右边");
                if (position == AVCaptureDevicePositionFront){
                    myImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationDownMirrored];
                }else {
                    myImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
                }
                myImage = [self imageCompressWithSimple:myImage];
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                DDLogInfo(@"头朝下边");
                myImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationRightMirrored];
                break;
            default:
                DDLogInfo(@"不知道方向");
                break;
        }
        [_session stopRunning];
        [self stopRecordVideo];
        
        DDLogInfo(@"11");
        if (myImage.size.height < kScreenHeight) {
            // 左右拍摄并且压缩过的
        }else{
            if (isIPhoneX) {
                UIImage *image2 = [self compressImageWithImage:myImage Size:CGSizeMake(kScreenWidth, kScreenHeight)];
                myImage = image2;
            }
        }
        DDLogInfo(@"image size = %@",NSStringFromCGSize(myImage.size));
        completion(myImage);
        
    }];
}

- (UIImage *)compressImageWithImage:(UIImage *)image Size:(CGSize)viewsize {
    CGFloat imgHWScale = image.size.height/image.size.width;
    CGFloat viewHWScale = viewsize.height/viewsize.width;
    CGRect rect = CGRectZero;
    if (imgHWScale>viewHWScale) {
        rect.size.height = viewsize.width*imgHWScale;
        rect.size.width = viewsize.width;
        rect.origin.x = 0.0f;
        rect.origin.y =  (viewsize.height - rect.size.height)*0.5f;
    }
    else {
        CGFloat imgWHScale = image.size.width/image.size.height;
        rect.size.width = viewsize.height*imgWHScale;
        rect.size.height = viewsize.height;
        rect.origin.y = 0.0f;
        rect.origin.x = (viewsize.width - rect.size.width)*0.5f;
    }
    
    UIGraphicsBeginImageContext(viewsize);
    [image drawInRect:rect];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (NSString *)saveToDocument:(UIImage *)image {
    return [image saveToDocumentAndThum];
}
- (void)photoBtnDidClick2
{
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        NSLog(@"拍照失败!");
        return;
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        //        [self.session stopRunning];
        //        [self.view addSubview:self.cameraImageView];
        NSLog(@"212");
    }];
}
//开始录像
-(void)startRecordVideo
{
    
    AVCaptureConnection *connection = [_deviceVideoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (![_session isRunning]) {
        //如果捕获会话没有运行
        [_session startRunning];
    }
    //根据连接取得设备输出的数据
    if (![_deviceVideoOutput isRecording]) {
        //如果输出 没有录制
        //如果支持多任务则则开始多任务
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        //预览图层和视频方向保持一致
        connection.videoOrientation = [_videoPreviewLayer connection].videoOrientation;
        //开始录制视频使用到了代理 AVCaptureFileOutputRecordingDelegate 同时还有录制视频保存的文件地址的
    }
}

//停止录制
-(void)stopRecordVideo
{
    if ([_deviceVideoOutput isRecording]) {
        [_deviceVideoOutput stopRecording];
    }//把捕获会话也停止的话，预览视图就停了
    if ([_session isRunning]) {
        [_session stopRunning];
    }
}


//预览层嵌入
-(void)embedLayerWithView:(UIView *)view{
    _cameraView = view;
    if (_session == nil) {
        DDLogInfo(@".......是不是你的问题");
        return;
    }
    
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    //设置layer大小
    _videoPreviewLayer.frame = view.layer.bounds;
    DDLogInfo(@"..ai..........%@.",NSStringFromCGRect(_videoPreviewLayer.frame));
    //layer填充状态
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //设置摄像头朝向
    _videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [view.layer addSublayer:_videoPreviewLayer];
    //初始化对焦提示框
    focusView = [[UIView alloc]init];
    focusView.layer.borderWidth = 2;
    focusView.layer.borderColor = [UIColor greenColor].CGColor;
    [_videoPreviewLayer addSublayer:focusView.layer];
    [self focusViewAnimation:view.center];
    //创建对焦手势
    //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToFocus:)];
    //    [view addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *singleTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.delaysTouchesBegan = YES;
    
    UITapGestureRecognizer *doubleTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delaysTouchesBegan = YES;
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [view addGestureRecognizer:singleTapGesture];
    [view addGestureRecognizer:doubleTapGesture];
    
}
-(void)singleTap:(UITapGestureRecognizer *)tapGesture{
    
    CGPoint point= [tapGesture locationInView:_cameraView];
    [self focusAtPoint:point];
}
-(void)doubleTap:(UITapGestureRecognizer *)tapGesture{
    
    DDLogInfo(@"双击");
    
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        if (captureDevice.videoZoomFactor == 1.0) {
            CGFloat current = 2.0;
            if (current < captureDevice.activeFormat.videoMaxZoomFactor) {
                [captureDevice rampToVideoZoomFactor:current withRate:10];
            }
        }else{
            [captureDevice rampToVideoZoomFactor:1.0 withRate:10];
        }
    }];
}

-(void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange{
    
    //也可以直接用_videoDevice,但是下面这种更好
    AVCaptureDevice *captureDevice= [_deviceInput device];
    NSError *error;
    
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        DDLogInfo(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    }else{
        [_session beginConfiguration];
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        [_session commitConfiguration];
    }
}

//设置自动对焦
-(void)focusAtPoint:(CGPoint)point{
    CGPoint cameraPoint= [_videoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self focusViewAnimation:point];
    
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        
        //聚焦
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }else{
            DDLogInfo(@"聚焦模式修改失败");
        }
        
        //聚焦点的位置
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:cameraPoint];
        }
        
        //曝光模式
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            //            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
            [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }else{
            DDLogInfo(@"曝光模式修改失败");
        }
        
        //曝光点的位置
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:cameraPoint];
        }
        
    }];
}

//对焦提示框动画
-(void)focusViewAnimation:(CGPoint)point{
    focusView.frame = CGRectMake(0, 0, 80, 80);
    focusView.center = point;
    focusView.alpha = 1;
    [UIView animateWithDuration:0.2 animations:^{
        focusView.frame = CGRectMake(0, 0, 60, 60);
        focusView.center = point;
    } completion:^(BOOL finished) {
        focusView.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            focusView.alpha = 1;
        } completion:^(BOOL finished) {
            focusView.alpha = 0;
        }];
    }];
}
//配置自定义拍摄帧数
- (void)setFrameNum:(NSInteger)frameNum{
    _frameNum = frameNum;
    [_session beginConfiguration];
    NSError *error;
    if ([_device lockForConfiguration:&error]) {
        [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, (int)_frameNum)];
        [_device setActiveVideoMinFrameDuration:CMTimeMake(1, (int)_frameNum)];
        [_device unlockForConfiguration];
    }
    [_session commitConfiguration];
}
//开始拍摄
-(void)startCamera{
    
    //[_session startRunning];
    [self startRecordVideo];
    
}
//停止拍摄
-(void)stopCamera{
    [self stopRecordVideo];
    //[_session stopRunning];
}


-(void)startRecordingWithUrl:(NSString*)filePath{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.deviceVideoOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    if (![self.deviceVideoOutput isRecording]) {
        //        self.enableRotation=NO;
        //        //如果支持多任务则则开始多任务
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            self.backgroundTaskIdentifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        //        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[_videoPreviewLayer connection].videoOrientation;
        DDLogInfo(@"save path is :%@",filePath);
        NSURL *fileUrl=[NSURL fileURLWithPath:filePath];
        DDLogInfo(@"fileUrl:%@",fileUrl);
        [self.deviceVideoOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
    else{
        [self.deviceVideoOutput stopRecording];//停止录制
    }
}


-(void)stopRecord{
    if (self.deviceVideoOutput) {
        [self.deviceVideoOutput stopRecording];//停止录制
    }
}
#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    DDLogInfo(@"开始录制...");
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kLittleVideoLocalPathKey];
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    DDLogInfo(@"视频录制完成.");
    //视频录入完成之后在后台将视频存储到相簿
    // self.enableRotation=YES;
    UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier=self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier=UIBackgroundTaskInvalid;
    
    [[NSUserDefaults standardUserDefaults]setURL:outputFileURL forKey:kLittleVideoLocalPathKey];
    !self.finishCameraBlock?:self.finishCameraBlock(outputFileURL);
}


-(void)cancelRecord{
    [self.deviceVideoOutput stopRecording];
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)swapFrontAndBackCameras {
    // Assume the session is already running
    
    NSArray *inputs = _session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [_session beginConfiguration];
            
            [_session removeInput:input];
            [_session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [_session commitConfiguration];
            break;
        }
    }
}



@end;
