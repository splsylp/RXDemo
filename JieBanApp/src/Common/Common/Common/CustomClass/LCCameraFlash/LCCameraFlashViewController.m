//
//  CameraFlashViewController1.m
//  Photo
//
//  Created by 刘畅 on 2017/10/11.
//  Copyright © 2017年 刘畅. All rights reserved.
//

#import "LCCameraFlashViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface LCCameraFlashViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;
//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;
@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, assign) AVCaptureVideoOrientation currentVideoOrientation;

// 连拍图片
@property(nonatomic, strong) NSMutableArray *tempImages;
@property(nonatomic, strong) NSMutableArray *tempDatas;
@property(nonatomic, assign) int changeSheet;
@end

@implementation LCCameraFlashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.changeSheet = self.sheet;
    if (![self canUserCamear]) {
        [self sendError:1];
        return;
    }

    [self customCamera];
    [self startMotionManager];
    
    CGFloat SW = self.view.frame.size.width;
    CGFloat SH = self.view.frame.size.height;
    // 拍照按钮
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( SW / 2 - 30 ,SH-100, 60, 60);
    [cameraButton setImage:ThemeImage(@"cameraflash_start_normal") forState: UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(shutterCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    // 关闭按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(SW - 60, 20, 40, 40);
    [cancelButton setImage:ThemeImage(@"cameraflash_close_normal") forState: UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    if (self.session) {
        [self.session stopRunning];
    }
}

- (void)dealloc
{
    [_motionManager stopDeviceMotionUpdates];
}

- (void)startMotionManager{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    if (_motionManager.deviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    } else {
        [self setMotionManager:nil];
    }
}

// 获取屏幕旋转反向
// 此方法在关闭旋转也可以调用
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            self.currentVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            // UIDeviceOrientationPortraitUpsideDown;
        } else{
            self.currentVideoOrientation = AVCaptureVideoOrientationPortrait;
            // UIDeviceOrientationPortrait;
        }
    } else {
        if (x >= 0){
            self.currentVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            // UIDeviceOrientationLandscapeRight;
        } else{
            self.currentVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            // UIDeviceOrientationLandscapeLeft;
        }
    }
}

-(NSMutableArray *)tempImages {
    if (!_tempImages) {
        _tempImages = [[NSMutableArray alloc] init];
    }
    return _tempImages;
}

-(NSMutableArray *)tempDatas {
    if (!_tempDatas) {
        _tempDatas = [[NSMutableArray alloc] init];
    }
    return _tempDatas;
}

- (NSError *)getError: (NSInteger)code {
    NSError * error = [[NSError alloc] initWithDomain:@"CameraFlashErrorDomain" code:code userInfo:nil];
    return error;
}

- (void)sendError: (NSInteger)code {
    if (self.errorBlock) {
        self.errorBlock([self getError:code]);
    }
}

- (void)customCamera {
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //使用设备初始化输入
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    // 设置图片大小，默认原图
//    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
//        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
//    }
    
    if ([self.session canAddInput: input]) {
        [self.session addInput: input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    previewLayer.frame = self.view.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:previewLayer];
    
    //开始启动
    [self.session startRunning];
    if ([device lockForConfiguration:nil]) {
        // 关闭闪光灯
        if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        //自动白平衡
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [device unlockForConfiguration];
    }
}

// 禁止旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)shutterCamera: (UIButton *)button {
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
//    if (self.currentVideoOrientation) {
//        videoConnection.videoOrientation = self.currentVideoOrientation;
//    }
    if (!videoConnection) {
        [self sendError:2];
        return;
    }
    
    button.enabled = NO;
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            [self sendError:3];
            button.enabled = YES;
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        if (self.imageDatasBlock) {
            [self.tempDatas addObject:imageData];
        }
        if (self.imagesBlock) {
            UIImage *image = [UIImage imageWithData:imageData];
            [self.tempImages addObject:image];
        }
        self.changeSheet--;
        if (self.changeSheet <= 0) {
            button.enabled = YES;
            self.changeSheet = self.sheet;
            if (self.imagesBlock) {
                self.imagesBlock(self.tempImages);
                [self.tempImages removeAllObjects];
            }

            if (self.imageDatasBlock) {
                self.imageDatasBlock(self.tempDatas);
                [self.tempDatas removeAllObjects];
            }
            [self cancelClick];
        } else {
            [self shutterCamera:button];
        }
    }];
}

-(void)cancelClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)canUserCamear {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}

@end
