//
//  YXPPlayer.h
//  Common
//
//  Created by yuxuanpeng on 2017/9/29.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "YXPMediaItem.h"
@class YXPPlayer;


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
- (BOOL)mediaPlayerWillStartPlaying:(YXPPlayer *)player media:(YXPMediaItem *)item;

@optional

/**
 播放进度

 @param player 播放器
 */
- (void)mediaPlayerDidChangedPlaybackTime:(YXPPlayer *)player;

/**
 缓存进度

 @param progress 进度
 @param player 播放器
 @param item 缓存的对象
 */
- (void)mediaPlayerDidUpdateBufferProgress:(float)progress player:(YXPPlayer *)player media:(YXPMediaItem *)item;


/**
 将要开始下载

 @param player 播放器
 @param item 下载的对象
 */
- (void)mediaPlayerWillStartLoading:(YXPPlayer *)player media:(YXPMediaItem *)item;


/**
 结束下载

 @param player 播放器
 @param item 下载的对象
 */
- (void)mediaPlayerDidEndLoading:(YXPPlayer *)player media:(YXPMediaItem *)item;


/**
 播放中

 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidStartPlaying:(YXPPlayer *)player media:(YXPMediaItem *)item;


/**
 播放完成

 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidFinishPlaying:(YXPPlayer *)player media:(YXPMediaItem *)item;



/**
 停止播放

 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidStop:(YXPPlayer *)player media:(YXPMediaItem *)item;

/**
 播放失败

 @param error 错误
 @param player 播放器
 @param item 播放的对象
 */
- (void)mediaPlayerDidFailedWithError:(NSError *)error player:(YXPPlayer *)player media:(YXPMediaItem *)item;


/**
 被中断

 @param player 播放器
 @param type 中断类型
 */
- (void)mediaPlayerDidInterrupt:(YXPPlayer *)player interruptState:(AVAudioSessionInterruptionType)type;


/**
 播放的状态

 @param player 播放的对象
 @param state 当前播放的状态
 */
- (void)mediaPlayerWillChangeState:(YXPPlayer *)player state: (YXPMediaPlaybackState)state;

/**
 播放
 * 切换到扬声器时，暂停播放
 * 切换到耳机、蓝牙等，继续播放
 
 @param player 播放器
 */
- (void)mediaPlayerDidChangeAudioRoute:(YXPPlayer *)player;

@end

@interface YXPPlayer : NSObject
//+ (instancetype)sharePlayer;

/* 播放 暂停 停止*/
- (void)play;
- (void)pause;
- (void)stop;

/* 设置播放的队列 */
- (void)setQueue:(NSArray <YXPMediaItem *>*)playList;


/* 当前播放进度   当前播放总时长*/
- (NSTimeInterval)currentPlayTime;
- (NSTimeInterval)currentPlayDuration;

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

//代理声明
@property (nonatomic, weak) id<YXPMediaPlayerDelegate>delegate;

//状态
@property (nonatomic, assign, readonly) YXPMediaPlaybackState playbackState;


@end