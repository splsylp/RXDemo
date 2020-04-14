//
//  Camera.m
//  ZZYWeiXinShortMovie
//
//  Created by zhangziyi on 16/3/23.
//  Copyright © 2016年 GLaDOS. All rights reserved.
//

#import "Camera.h"
@implementation Camera
-(instancetype)init{
    if (self = [super init]) {
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        //添加输入
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (error) {
            NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        }
        //添加一个音频输入设备
        AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
        if (error) {
            NSLog(@"取得音频设备输入对象时出错，错误原因：%@",error.localizedDescription);
        }
        if ([_session canAddInput:_deviceInput]) {
            [_session addInput:_deviceInput];
            [_session addInput:audioCaptureDeviceInput];
            
            AVCaptureConnection *captureConnection=[_deviceVideoOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([captureConnection isVideoStabilizationSupported ]) {
                captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
            }
        }
        
        
//        //添加图片输出
//        _imageOutput = [[AVCaptureVideoDataOutput alloc]init];
//        [_imageOutput setVideoSettings:
//         [NSDictionary dictionaryWithObject:
////          [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
//          [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
//                                     forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
//        _imageOutput.alwaysDiscardsLateVideoFrames = YES;
//        if ([_session canAddOutput:_imageOutput]) {
//            [_session addOutput:_imageOutput];
//        }
        
        //添加输出视频 和上面的图片输出只能用一个，否则图片的会被覆盖，如果明天可以找到底层库开发人员要到x264的编码函数，可以只保留_imageOutput那个，
        //然后我们可以用TakeMovieViewController里面的captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
        //函数来进行x264编码
        
        _deviceVideoOutput = [[AVCaptureMovieFileOutput alloc]init];
        
        if ([_session canAddOutput:_deviceVideoOutput]) {
            [_session addOutput:_deviceVideoOutput];
        }
        
        //配置默认帧数1秒10帧
        [_session beginConfiguration];
        if ([_device lockForConfiguration:&error]) {
            [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, 15)];
            [_device setActiveVideoMinFrameDuration:CMTimeMake(1, 10)];
            [_device unlockForConfiguration];
        }
        [_session commitConfiguration];
        
        //设置自动聚焦和曝光
        [self focusAtPoint:_cameraView.center];

    }
    return self;
}
//预览层嵌入
-(void)embedLayerWithView:(UIView *)view{
    _cameraView = view;
    if (_session == nil) {
        return;
    }
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    //设置layer大小
    _videoPreviewLayer.frame = view.layer.bounds;
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
    
    NSLog(@"双击");
    
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
        NSLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
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
            NSLog(@"聚焦模式修改失败");
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
            NSLog(@"曝光模式修改失败");
        }
        
        //曝光点的位置
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:cameraPoint];
        }
        
    }];
}
////点击手势响应方法
//-(void)tapToFocus:(UITapGestureRecognizer*)gestureRecognizer{
//    CGPoint point = [gestureRecognizer locationInView:_cameraView];
//    CGPoint focusPoint = CGPointMake(point.x/_cameraView.frame.size.width, point.y/_cameraView.frame.size.height);
//    [self focusAtPoint:focusPoint];
//    //    [self continuousFocusAtPoint:focusPoint];
//    [self focusViewAnimation:point];
//    NSLog(@"x%f,y%f",focusView.frame.origin.x,focusView.frame.origin.y);
//}
////设置自动对焦
//-(void)focusAtPoint:(CGPoint)point{
//    if ([_device isFocusPointOfInterestSupported] && [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//        NSError *error = nil;
//        if ([_device lockForConfiguration:&error]) {
//            [_device setFocusPointOfInterest:point];
//            [_device setFocusMode:AVCaptureFocusModeAutoFocus];
//            [_device unlockForConfiguration];
//        }
//    }
//}
////设置连续对焦
//-(void)continuousFocusAtPoint:(CGPoint)point{
//    if ([_device isFocusPointOfInterestSupported] && [_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
//        NSError *error = nil;
//        if ([_device lockForConfiguration:&error]) {
//            [_device setFocusPointOfInterest:point];
//            [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
//            [_device unlockForConfiguration];
//        }
//    }
//}
//对焦提示框动画
-(void)focusViewAnimation:(CGPoint)point{
    focusView.frame = CGRectMake(0, 0, 80, 80);
    focusView.center = point;
    focusView.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
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
    [_session startRunning];
}
//停止拍摄
-(void)stopCamera{
    [_session stopRunning];
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
        NSLog(@"save path is :%@",filePath);
        NSURL *fileUrl=[NSURL fileURLWithPath:filePath];
        NSLog(@"fileUrl:%@",fileUrl);
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
    NSLog(@"开始录制...");
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kLittleVideoLocalPathKey];
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
//    //视频录入完成之后在后台将视频存储到相簿
//    self.enableRotation=YES;
    UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier=self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier=UIBackgroundTaskInvalid;
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    
    [[NSUserDefaults standardUserDefaults]setURL:outputFileURL forKey:kLittleVideoLocalPathKey];
    
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
        }
        NSLog(@"outputUrl:%@",outputFileURL);
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        [[NSUserDefaults standardUserDefaults]setURL:assetURL forKey:kLittleVideoLocalPathKey];
        
        if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
        }
        NSLog(@"成功保存视频到相簿.");
    }];
    
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