//
//  YXPAudioPlayer.h
//  Common
//
//  Created by yuxuanpeng on 2017/10/16.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "YXPMediaItem.h"

@class YXPAudioPlayer;

typedef NS_ENUM(NSUInteger, YXPMediaPlaybackState) {
    YXPMediaPlaybackStateStopped = 0,
    YXPMediaPlaybackStatePlaying,
    YXPMediaPlaybackStatePaused,
    YXPMediaPlaybackStateLoading
};

@protocol YXPMediaPlayerDelegate <NSObject>
@required

/**
 媒体将要播放
 
 @param player player播放器
 @param item 播放的对象
 @return YES/NO
 */
- (BOOL)mediaPlayerWillStartPlaying:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;

@optional

/**
 播放进度
 
 @param player 播放器
 */
- (void)mediaPlayerDidChangedPlaybackTime:(YXPAudioPlayer *)player;

/**
 缓存进度
 
 @param progress 进度
 @param player 播放器
 @param item 缓存的对象
 */
- (void)mediaPlayerDidUpdateBufferProgress:(float)progress player:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;


/**
 将要开始下载
 
 @param player 播放器
 @param item 下载的对象
 */
- (void)mediaPlayerWillStartLoading:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;


/**
 结束下载
 
 @param player 播放器
 @param item 下载的对象
 */
- (void)mediaPlayerDidEndLoading:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;


/**
 开始播放
 
 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidStartPlaying:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;


/**
 播放完成
 
 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidFinishPlaying:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;



/**
 停止播放
 
 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidStop:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;

/**
 播放失败
 
 @param error 错误
 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidFailedWithError:(NSError *)error player:(YXPAudioPlayer *)player media:(YXPMediaItem *)item;


/**
 被中断
 
 @param player 播放器
 @param type 中断类型
 */
- (void)mediaPlayerDidInterrupt:(YXPAudioPlayer *)player interruptState:(AVAudioSessionInterruptionType)type;


/**
 播放的状态
 
 @param player 播放的对象
 @param state 当前播放的状态
 */
- (void)mediaPlayerWillChangeState:(YXPAudioPlayer *)player state: (YXPMediaPlaybackState)state;

/**
 播放
 * 切换到扬声器时，暂停播放
 * 切换到耳机、蓝牙等，继续播放
 
 @param player 播放器
 */
- (void)mediaPlayerDidChangeAudioRoute:(YXPAudioPlayer *)player;

@end

@interface YXPAudioPlayer : NSObject

+ (instancetype)sharePlayer;

/* 播放 暂停 停止*/
- (void)play;
- (void)pause;
- (void)stop;
//置nil
- (void)clear;

/* 设置播放的队列 */
- (void)setQueue:(NSArray <YXPMediaItem *>*)playList;


/* 当前播放进度   当前播放总时长*/
//- (NSTimeInterval)currentPlayTime;
//- (NSTimeInterval)currentPlayDuration;

/* 快进 */
- (void)speedTime:(NSTimeInterval)time;

/* 播放某个媒体 */
- (void)playMedia:(YXPMediaItem *)item;

/** 获取当前播放item*/
- (YXPMediaItem *)currentPlayItem;

//准备播放
- (void)prepareToPlay:(YXPMediaItem *)item complete:(void(^)(AVPlayerItem *avitem, NSError *error))completeHandle;

//获取当前播放时间
- (NSTimeInterval)currentPlaybackTime;

//获取播放的当前时长
- (NSTimeInterval)currentPlaybackDuration;

//设置播放的音量
- (void)setplayerAudioMix;

//代理声明
@property (nonatomic, weak) id<YXPMediaPlayerDelegate>delegate;

//状态
@property (nonatomic, assign, readonly) YXPMediaPlaybackState playbackState;

//获取暂停的方式 YES/NO 自己暂停/被动暂停

@property (nonatomic, assign)BOOL currentIsPauseWay;//暂停的方式/YES/NO 手动/被动



@end
