//
//  HXContinueVoicePlayManager.h
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/28.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>


//标记语音是否可以连续播放下去，（KVoicePlayIsSure 是先前写的，不能用，一旦播放就立即改变状态，不能作为播放完成后，连续播放的判断标志。VOICE_MESSAGE_CanContinuePlayKey 判断先前是否播放过，如果没有播放过可以连续播放，如果播放过，则不可以）
extern const char VOICE_MESSAGE_CanContinuePlayKey;   //----常量

/**
 @brief 语音连续播放---管理类
 @discussion
 */
@interface HXContinueVoicePlayManager : NSObject


/**
 @brief 语音连续播放
 @discussion
 */
+(instancetype)shardDefaultManager;

/**
 @brief 消息数组
 @discussion
 */
-(void)setMessageArray:(NSArray *)messageArray;

/**
 @brief 找到下一条消息，用于继续播放,
 @discussion 返回nil 表示没有找到下一条连续播放的消息
 */
-(ECMessage*)findNextMessageToContinuePlayWithCurrentVoiceMessage:(ECMessage*)completionMessage;

@end
