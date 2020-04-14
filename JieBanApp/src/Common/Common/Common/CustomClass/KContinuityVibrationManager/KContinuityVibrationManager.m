//
//  KContinuityVibrationManager.m
//  zhendong
//
//  Created by 陈长军 on 2017/2/17.
//  Copyright © 2017年 陈长军. All rights reserved.
//

#import "KContinuityVibrationManager.h"
#import "UIKitConfiManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface KContinuityVibrationManager ()
/**
 @brief 容错机制处理
 */
@property (nonatomic,strong) NSTimer    *mTimer;
@property (nonatomic,assign) BOOL       mIsWorking; //振动状态
@property (nonatomic,assign) NSInteger  mSecond;    //统计当前振动的总时间

@end


@implementation KContinuityVibrationManager

#pragma mark----------------------------关于init-------------------------------------
static KContinuityVibrationManager *sharedKContinuityVibrationManager = nil;

+(instancetype)shardDefaultManager
{
    static dispatch_once_t threadOnceToken;
    dispatch_once(&threadOnceToken, ^{
        if(!sharedKContinuityVibrationManager){
            sharedKContinuityVibrationManager = [[KContinuityVibrationManager alloc] init];
            sharedKContinuityVibrationManager.mIsWorking = NO;
        }
    });
    return sharedKContinuityVibrationManager;
}


/**
 @brief 开始振动
 */
-(void)startVibration
{
    #if TARGET_IPHONE_SIMULATOR
        return ;//模拟器不能振动
    #endif
    
    if([UIKitConfiManager msgVibrateVailableStatus]==NO){   //App是否开启振动
        return;
    }
    if(sharedKContinuityVibrationManager.mIsWorking == YES){ //App是否正在振动
        if(self.mSecond>=Max_VibrationErrorTime){
            [self stopVibration];
        }
        return;
    }
    
    [self startCheckError];                                     //容错处理
    sharedKContinuityVibrationManager.mIsWorking = YES;
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, KCsoundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


void KCsoundCompleteCallback(SystemSoundID sound,void * clientData) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Time_Interval_Vibration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  //震动
    });
}

/**
 @brief 停止振动
 */
-(void)stopVibration
{
    [self.mTimer invalidate];
    self.mTimer = nil;
    self.mSecond = 0;
    sharedKContinuityVibrationManager.mIsWorking = NO;
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
}

#pragma mark--------------------------容错处理----------------------------------
/**
 @brief  开启计时
 */
-(void)startCheckError
{
    self.mSecond = 0;
    self.mTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeSub) userInfo:nil repeats:YES];
    [self.mTimer fire];
}

/**
 @brief  时间累计
 */
-(void)timeSub{
    if(self.mSecond>=Max_VibrationErrorTime){//超过最大时间会停止振动
        [self stopVibration];
    }else{
        self.mSecond++;
    }
}


/**
 @brief 静音模式不让播放音乐
 @discussion
 */
-(void)setSoundPayerMode;
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}


-(BOOL)silenced
{
#if TARGET_IPHONE_SIMULATOR
    // return NO in simulator. Code causes crashes for some reason.
    return NO;
#endif
    
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    if(CFStringGetLength(state) > 0)
        return NO;
    else
        return YES;
}



-(BOOL)isHaveCameraRights
{
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        return  NO;
    }else{
        return  YES;
    }
}

@end
