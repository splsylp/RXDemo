//
//  HXContinueVoicePlayManager.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/28.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXContinueVoicePlayManager.h"

const char VOICE_MESSAGE_CanContinuePlayKey;

@interface HXContinueVoicePlayManager ()


/**
 @brief 临时指向消息数组，weak 可不影响消息的释放
 */
@property (nonatomic,weak) NSArray  *mMessageArray;


@end


extern const char KVoiceIsPlayKey;

@implementation HXContinueVoicePlayManager

#pragma mark----------------------------关于init-------------------------------------
static HXContinueVoicePlayManager *shareContinueVoicePlayManager = nil;

+(instancetype)shardDefaultManager
{
    static dispatch_once_t threadOnceToken;
    dispatch_once(&threadOnceToken, ^{
        if(!shareContinueVoicePlayManager){
            shareContinueVoicePlayManager = [[HXContinueVoicePlayManager alloc] init];
        }
    });
    return shareContinueVoicePlayManager;
}


-(void)setMessageArray:(NSArray *)messageArray
{
    self.mMessageArray = messageArray;
}


-(ECMessage*)findNextMessageToContinuePlayWithCurrentVoiceMessage:(ECMessage*)completionMessage
{
    
    //当前播放的消息是否是第一次播放，非第一次播放不用查询
    NSNumber* canContinue = objc_getAssociatedObject(completionMessage, &VOICE_MESSAGE_CanContinuePlayKey);
    if(canContinue.boolValue==NO){
        return nil;
    }

    //如果播放的是阅后即焚的消息，不用寻找下一条语音
    if(completionMessage.isBurnWithMessage){
        return nil;
    }
    
    //确定当前消息的位置
    NSInteger row = [self.mMessageArray indexOfObject:completionMessage];
    if(row == NSNotFound){
        return  nil;
    }
    
    //从当前消息的位置开始往下找
    for (NSInteger i = row+1; i< self.mMessageArray.count;i++)
    {
        ECMessage *tempMessage = [self.mMessageArray objectAtIndex:i];
        //1.跳过阅后即焚
        if(tempMessage.isBurnWithMessage){
            continue;
        }
        //2.播放不能是自己发的
        
        if([tempMessage.from isEqualToString:[[Common sharedInstance]getAccount]]){
            continue;
        }
        //3.必须是语音消息
        if(![tempMessage.messageBody isKindOfClass:[ECVoiceMessageBody class]]){
            //不是语音消息,跳过
            continue;
        }else{
            //语音消息
            if(tempMessage.isRead == NO){//如果是未读,播放
                return tempMessage;
            }else{                        //碰到已读，停止查询
                return nil;
            }
        }
    }
    return nil;
}


@end
