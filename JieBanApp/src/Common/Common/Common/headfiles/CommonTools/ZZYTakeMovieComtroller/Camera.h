//
//  Camera.h
//  ZZYWeiXinShortMovie
//
//  Created by zhangziyi on 16/3/23.
//  Copyright © 2016年 GLaDOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kLittleVideoLocalPathKey @"kLittleVideoLocalPath"
#define kLittleVideoOutPutLocalPath [NSTemporaryDirectory() stringByAppendingString:@"myMovie.mp4"]
@interface Camera : NSObject<AVCaptureFileOutputRecordingDelegate>
{
    //会话
    AVCaptureSession *_session;
    //创建 配置输入设备
    AVCaptureDevice *_device;
    //显示层
    AVCaptureVideoPreviewLayer *_videoPreviewLayer;
    UIView *focusView;
}
@property (nonatomic,strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic,strong) AVCaptureMovieFileOutput *deviceVideoOutput;//视频输出流
//@property (nonatomic,strong) AVCaptureVideoDataOutput *imageOutput;
//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutput;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;


@property (nonatomic,strong) UIView *cameraView;
@property (nonatomic,assign) NSInteger frameNum;
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识
- (void)photoBtnDidClick;
#pragma mark - 截取照片
- (void)photoBtnDidClickWithcompletion:(void (^)(UIImage *image))completion;
//开始拍摄
-(void)startCamera;
//停止拍摄
-(void)stopCamera;
//预览层嵌入
-(void)embedLayerWithView:(UIView *)view;
-(void)startRecordingWithUrl:(NSString*)filePath;
-(void)stopRecord;
//切换摄像头
- (void)swapFrontAndBackCameras;

//gy add
@property (copy,nonatomic)void (^finishCameraBlock)(NSURL *url);

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
