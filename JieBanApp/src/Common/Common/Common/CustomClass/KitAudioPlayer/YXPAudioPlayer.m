//
//  YXPAudioPlayer.m
//  Common
//
//  Created by yuxuanpeng on 2017/10/16.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPAudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "YXPPlayerError.h"
#import "AVPlayerItem+YXPPlayerCache.h"
#import "YXPSharePlayer.h"


@interface YXPAudioPlayer()
{
    __weak id<NSObject>_timeObserver;
    NSInteger _playingIndex; //当前播放的index
    BOOL      _interrupt; // 是否是被外部应用打断
}
@property (nonatomic, strong)YXPSharePlayer * voicePlayer;//播放器
@property (nonatomic, strong)AVAsset * loadingAsset;//下载的容器
// 缓存最大上限
@property (nonatomic, assign)NSUInteger cacheMaxCount;
// 缓存过期时间
@property (nonatomic, assign)NSUInteger expireTime;

//当前播放的item
@property (nonatomic, strong)YXPMediaItem  * currentPlayItem;

//播放的队列
@property (nonatomic, strong)NSMutableArray *playItemQueue;

@property (nonatomic, assign)BOOL isAddObserver;//是否初始化过


@end

@implementation YXPAudioPlayer
static void *kYXPAudioControllerBufferingObservationContext = &kYXPAudioControllerBufferingObservationContext;
static void *kYXPAudioControllerPlayStateObservationContext = &kYXPAudioControllerPlayStateObservationContext;

static NSString *const kYXPLoadedTimeRangesKeyPath = @"loadedTimeRanges";
static NSString *const kYXPPlayRateKeyPath = @"rate";

+(instancetype)sharePlayer {
    
    static YXPAudioPlayer * instancePlayer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instancePlayer = [[self class] new];
    });
    
    return instancePlayer;
}

-(void)dealloc {
    if (_timeObserver) {
        [self.voicePlayer removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
    [self removePlayItemReachEndNotifcation];
    [self removeAudioSessionNotification];
    [self removeAudioSessionRouteChangeNotification];
    [self removePlayerItemObservers];
    [self.voicePlayer pause];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _playingIndex = 0;
        _interrupt    = NO;
        _playItemQueue = [NSMutableArray array];
        _isAddObserver = NO;
        _currentIsPauseWay = NO;
        _voicePlayer = [[YXPSharePlayer alloc]init];
        if ([_voicePlayer respondsToSelector:@selector(setAutomaticallyWaitsToMinimizeStalling:)]) {
            _voicePlayer.automaticallyWaitsToMinimizeStalling = NO;
        }
    }
    return self;
}

- (void)prepareToPlay:(YXPMediaItem *)item complete:(void(^)(AVPlayerItem *avitem, NSError *error))completeHandle {
    // [self removePlayerItemObservers];
    [self stop];
    [self.voicePlayer.currentItem.asset cancelLoading];
    if (self.delegate || !item) {
        if (![self.delegate respondsToSelector:@selector(mediaPlayerWillStartPlaying:media:)] ||
            [self.delegate mediaPlayerWillStartPlaying:self media:item] == NO ||
            !item) {
            return;
        }
    }
    
    [self setCurrentState:YXPMediaPlaybackStateLoading];
    
    if ([self.delegate respondsToSelector:@selector(mediaPlayerWillStartLoading:media:)]) {
        [self.delegate mediaPlayerWillStartLoading:self media:item];
    }
    
    __weak typeof(self)weakSelf = self;
    [self loadAssetValues:item complete:^(AVPlayerItem *avitem, NSError *error) {
        if (error) {
            [weakSelf setCurrentState:YXPMediaPlaybackStateStopped];
            [weakSelf.loadingAsset cancelLoading];
            weakSelf.loadingAsset = nil;
            
            if ([weakSelf.delegate respondsToSelector:@selector(mediaPlayerDidFailedWithError:player:media:)]) {
                [weakSelf.delegate mediaPlayerDidFailedWithError:error player:weakSelf media:item];
            }
            [weakSelf stop];

        }else {
            
            // 清理缓存
            
            //[[avitem class] removeExpireFiles:weakSelf.cacheMaxCount beforeTime:self.expireTime];
            
            if ([weakSelf.delegate respondsToSelector:@selector(mediaPlayerDidEndLoading:media:)]) {
                [weakSelf.delegate mediaPlayerDidEndLoading:weakSelf media:item];
            }
            
            // 加载新的asset
            weakSelf.voicePlayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
            [weakSelf.voicePlayer replaceCurrentItemWithPlayerItem:avitem];
            weakSelf.isAddObserver = YES;
            [weakSelf addPlayerItemObservers];
            [weakSelf addPlayItemReachEndNotifcation];
            [weakSelf addTimeObserver];
            
            if([weakSelf.delegate respondsToSelector:@selector(mediaPlayerDidStartPlaying:media:)]) {
                [weakSelf.delegate mediaPlayerDidStartPlaying:weakSelf media:item];
            }
            
            weakSelf.currentPlayItem = item;
        }
        if (completeHandle) {
            completeHandle(avitem,error);
        }
    }];
}

#pragma mark - load asset
- (void)loadAssetValues:(YXPMediaItem *)item complete:(void(^)(AVPlayerItem *item, NSError * error))completeHandle {
    
    if (_loadingAsset) {
        [_loadingAsset cancelLoading];
    }
    AVPlayerItem * newPlayItem = nil;
    NSURL * url = item.currentUrl;
    if ([url isFileURL]) {
        newPlayItem = [AVPlayerItem playerItemWithURL:url];
    }else {
        newPlayItem = [AVPlayerItem mc_playerItemWithRemoteURL:url error:nil];
    }
    [self.voicePlayer replaceCurrentItemWithPlayerItem:newPlayItem];

    _loadingAsset = newPlayItem.asset;
    __weak AVAsset * weakAsset = _loadingAsset;
    __weak typeof(self)weakSelf = self;
    [_loadingAsset loadValuesAsynchronouslyForKeys:[self.class assetKeysRequiredToPlay] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __strong typeof(weakSelf)strongself = weakSelf;
            
            if ([weakSelf.delegate respondsToSelector:@selector(mediaPlayerDidEndLoading:media:)]) {
                [weakSelf.delegate mediaPlayerDidEndLoading:self media:item];
            }
            NSArray * allKeys = [self.class assetKeysRequiredToPlay];
            NSError * customeError = nil;
            for (NSString * key in allKeys) {
                NSError * error = nil;
                if ([weakAsset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    customeError = error;
                    break;
                }
            }
            
            if (!weakAsset.playable || weakAsset.hasProtectedContent) {
                
                if (!customeError) {
                    customeError = [strongself errorWithMesssage:@"url can not to play" code:kMediaPlayerErrorCodeCannotPlay];
                    [AVPlayerItem mc_removeCacheWithCacheFilePath:newPlayItem.mc_cacheFilePath];
                }else if([customeError.userInfo[@"NSURL"] isFileURL])
                {
                    NSURL *fileUrl = customeError.userInfo[@"NSURL"];
                    NSString *filePath = fileUrl.path;
                    
                    [AVPlayerItem mc_removeCacheWithCacheFilePath:filePath];

                    [AVPlayerItem mc_removeCacheWithCacheFilePath:newPlayItem.mc_cacheFilePath];

                }
            }
            // 回调
            if (completeHandle) {
                completeHandle(newPlayItem, customeError);
            }
        });
    }];
}


#pragma mark setting

- (void)setCurrentState:(YXPMediaPlaybackState)state
{
    if (state == _playbackState) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(mediaPlayerWillChangeState:state:)]) {
        [self.delegate mediaPlayerWillChangeState:self state:state];
    }
    
    
    if (state == YXPMediaPlaybackStatePlaying) {
        //  更新锁屏信息
        [self updatLockScreenInfo];
        
        NSError * error = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        [audioSession setActive:YES error:NULL];
        
        [self addAudioSessionNotification];
    }else
    {
        [self removeAudioSessionNotification];

    }
    
    _playbackState = state;
}

// 尝试加载对应key的内容
+ (NSArray *)assetKeysRequiredToPlay {
    return @[@"playable", @"hasProtectedContent"];
}


- (void)removeTimeObserver {
    if (_timeObserver) {
        [self.voicePlayer removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
}

- (void)setQueue:(NSArray <YXPMediaItem *>*)playList {
    //[self stop];
    
    [self.playItemQueue removeAllObjects];
    self.playItemQueue = [NSMutableArray arrayWithArray:playList];
}


- (void)speedTime:(NSTimeInterval)time
{
    __weak typeof(self)weakSelf = self;
    if (self.voicePlayer.status != AVPlayerStatusReadyToPlay) {
        return;
    }
    [self.voicePlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf updatLockScreenInfo];
    }];
}

#pragma mark Custom

//如果正在播放，刷新进度
- (void)syncPlayProcess:(CMTime)time {
    
    if ([self.delegate respondsToSelector:@selector(mediaPlayerDidChangedPlaybackTime:)]) {
        [self.delegate mediaPlayerDidChangedPlaybackTime:self];
    }
}
//错误提示
- (NSError *)errorWithMesssage:(NSString *)msg code:(NSInteger)errorCode {
    return sqr_errorWithCode((int)errorCode, msg);
}

- (void)updatLockScreenInfo {
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}

#pragma mark remove  Observers

- (void)removePlayerItemObservers {
    @try {
        
//        if (objc_getAssociatedObject(self, &kYXPLoadedTimeRangesKeyPath) ) {
//            [self.voicePlayer.currentItem removeObserver:self forKeyPath:kYXPLoadedTimeRangesKeyPath];
//        }
//        if(objc_getAssociatedObject(self, &kYXPPlayRateKeyPath))
//        {
//            [self.voicePlayer removeObserver:self forKeyPath:kYXPPlayRateKeyPath];
//        }
        if(self.isAddObserver)
        {
            [self.voicePlayer.currentItem removeObserver:self forKeyPath:kYXPLoadedTimeRangesKeyPath];
            [self.voicePlayer removeObserver:self forKeyPath:kYXPPlayRateKeyPath];
            self.isAddObserver = NO;
        }
        

    } @catch(NSException *exception) {
    }
}

- (void)removePlayItemReachEndNotifcation {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

//中断通知

- (void)removeAudioSessionNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

//线路更换通知
- (void)removeAudioSessionRouteChangeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}



#pragma mark add Observers
-(void)addTimeObserver {
    __weak typeof(self)weakSelf = self;
    if (!_timeObserver) {
        _timeObserver = [self.voicePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakSelf syncPlayProcess:time];
        }];
    }
}

- (void)addPlayerItemObservers {
    [self.voicePlayer.currentItem addObserver:self forKeyPath:kYXPLoadedTimeRangesKeyPath options:NSKeyValueObservingOptionNew context:&kYXPAudioControllerBufferingObservationContext];
    [self.voicePlayer addObserver:self forKeyPath:kYXPPlayRateKeyPath options:NSKeyValueObservingOptionNew context:kYXPAudioControllerPlayStateObservationContext];
    
}

#pragma mark - play notification

- (void)addPlayItemReachEndNotifcation {
    
    [self removePlayItemReachEndNotifcation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem * item = notification.object;

    if (self.voicePlayer.currentItem == item) {
        //播放完成
        if(self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerDidFinishPlaying:media:)])
        {
            [self.delegate mediaPlayerDidFinishPlaying:self media:_currentPlayItem];
        }
    }
    else {
        [self removePlayerItemObservers];
    }
    
    [self stop];

}

- (void)addAudioSessionNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionChangeRoute:) name:AVAudioSessionRouteChangeNotification object:nil];    
}


- (void)volumeChanged:(NSNotification *)notification
{
    float volume =[[[notification userInfo]objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]floatValue];
}

- (void)audioSessionInterrupted:(NSNotification *)notification {
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    AVAudioSessionInterruptionType type = interruptionType.unsignedIntegerValue;
    
    if ([_delegate respondsToSelector:@selector(mediaPlayerDidInterrupt:interruptState:)]) {
        [_delegate mediaPlayerDidInterrupt:self interruptState:type];
    }
}

- (void)audioSessionChangeRoute:(NSNotification *)notification {
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        if (![AVAudioSession sharedInstance].currentRoute.outputs) {
            [self pause];
        }
        if([_delegate respondsToSelector:@selector(mediaPlayerDidChangeAudioRoute:)]) {
            [_delegate mediaPlayerDidChangeAudioRoute:self];
        }
    }
}
#pragma mark -  Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kYXPAudioControllerBufferingObservationContext) {
        AVPlayerItem* playerItem = (AVPlayerItem*)object;
        NSArray* times = playerItem.loadedTimeRanges;
        
        NSValue* value = [times firstObject];
        
        if(value) {
            CMTimeRange range;
            [value getValue:&range];
            float start = CMTimeGetSeconds(range.start);
            float duration = CMTimeGetSeconds(range.duration);
            
            CGFloat videoAvailable = start + duration;
            CGFloat totalDuration = CMTimeGetSeconds(self.voicePlayer.currentItem.asset.duration);
            CGFloat progress = videoAvailable / totalDuration;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(mediaPlayerDidUpdateBufferProgress:player:media:)]) {
                    [self.delegate mediaPlayerDidUpdateBufferProgress:progress player:self media:_currentPlayItem];
                }
            });
            
            //        LOG_I(@"steaming have cache %0.2f",progress);
        }
        return;
    }
    else if (context == kYXPAudioControllerPlayStateObservationContext) {
        if (keyPath == kYXPPlayRateKeyPath) {
            NSNumber * rateNumber = change[NSKeyValueChangeNewKey];
            if ([rateNumber isKindOfClass:[NSNumber class]]) {
                float rate = [rateNumber floatValue];
                if (rate == 0.0) {
                    [self setCurrentState:YXPMediaPlaybackStatePaused];
                }else if (rate == 1.0) {
                    [self setCurrentState:YXPMediaPlaybackStatePlaying];
                }
            }
        }
        return;
    }
    
    
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
}

#pragma mark - play info

- (NSTimeInterval)currentPlaybackTime {
    return self.voicePlayer.currentTime.value == 0 ? 0: self.voicePlayer.currentTime.value / self.voicePlayer.currentTime.timescale;
}

- (NSTimeInterval)currentPlaybackDuration {
    return CMTimeGetSeconds([[self.voicePlayer.currentItem asset] duration]);
}

- (YXPMediaItem *)currentPlayItem
{
    return _currentPlayItem;
}


-(void)playMedia:(YXPMediaItem *)item {
    __weak typeof(self)weakSelf = self;
    
    [self prepareToPlay:item complete:^(AVPlayerItem *avitem, NSError *error) {
        __strong typeof (weakSelf)strong_self = weakSelf;
        if (error) {
        }else {
            [strong_self play];
        }
    }];
}

- (void)play
{
    if (self.playbackState == YXPMediaPlaybackStateStopped) {
        [self.voicePlayer seekToTime:CMTimeMake(0, 1)];
    }
    if (self.currentPlayItem == nil) {
        [self playMedia:self.playItemQueue.firstObject];
    }
    else {
        [self.voicePlayer play];
    }
    _currentIsPauseWay = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];//开启感应

}

- (void)pause {
    [self.voicePlayer pause];
}

- (void)stop {
    [self.voicePlayer pause];
    if ([self.delegate respondsToSelector:@selector(mediaPlayerDidStop:media:)]) {
        [self.delegate mediaPlayerDidStop:self media:_currentPlayItem];
    }
    
    _currentPlayItem = nil;
    
    [self removePlayItemReachEndNotifcation];
    [self removePlayerItemObservers];
    [self removeTimeObserver];
    
    [self setCurrentState:YXPMediaPlaybackStateStopped];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];//关闭感应
}
- (void)clear
{
    _currentPlayItem = nil;
}

- (void)setplayerAudioMix
{
    NSArray *audioTracks = [_loadingAsset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
}

#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else//没黑屏幕
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
    }
}

@end
