//
//  SynthesizeSingleton.h
//
// Modified by Karl Stenerud starting 16/04/2010.
// - Moved the swizzle code to allocWithZone so that non-default init methods may be
//   used to initialize the singleton.
// - Added "lesser" singleton which allows other instances besides sharedInstance to be created.
// - Added guard ifndef so that this file can be used in multiple library distributions.
// - Made singleton variable name class-specific so that it can be used on multiple classes
//   within the same compilation module.
//
//  Modified by CJ Hanson on 26/02/2010.
//  This version of Matt's code uses method_setImplementaiton() to dynamically
//  replace the +sharedInstance method with one that does not use @synchronized
//
//  Based on code by Matt Gallagher from CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
/*
 *创建单列的
 */
#ifndef SYNTHESIZE_SINGLETON_FOR_CLASS

#import <objc/runtime.h>


/**
 *  选人的场景
 */
typedef NS_ENUM(NSInteger, SelectObjectType){
    
    SelectObjectType_None = 0,//无
    
    SelectObjectType_CreateGroupChatSelectMember = 1001,//创建群聊选人
    
    SelectObjectType_CreateBoardCoopSelectMember = 1111,//创建白板选人
    
    SelectObjectType_GroupChatSelectMember = 1002,//群组中选人
    
    /**
     * 此值被用于voiceMeeting
     * phoneMeeting中废弃使用SelectObjectType_VoiceMeetingSelectMember
     * phoneMeeting中废弃使用SelectObjectType_CreateVoiceMeetingSelectMember
     */
    //SelectObjectType_VoiceMeetingSelectMember = 1011,//语音会议选人
    
    //SelectObjectType_CreateVoiceMeetingSelectMember = 1012,//创建语音会议选人
    
    SelectObjectType_VideoMeetingSelectMember = 1021,//视频会议选人
    
    SelectObjectType_CreateVideoMeetingSelectMember = 1022,//创建视频会议选人
    
    SelectObjectType_TransmitSelectMember = 1031,//转发选人
    
    SelectObjectType_OnlyMergeMultiSelectContactMode = 1032,//合并消息转发
    
    SelectObjectType_CreateVidyoSelectMember = 1041,//创建vidyo会议选人
    
    SelectObjectType_VidyoConferenceSelectMember = 1042,//vidyo会议中选人
    
    SelectObjectType_SpecialAttSelectMember = 1051,//特别关注选人
    
    SelectObjectType_SendCardSelectMember = 3000,//发送名片选人
    
    SelectObjectType_FromeJSSelectMember = 4000,//从js调用选人
    
    SelectObjectType_FromeOthorAppSelectMember = 4001,//从第三方app分享文件进行转发
    
    
    SelectObjectType_InPhoneMeetingSelectMember = 9000,//电话会议中选人
    /*(调用ChatSelectMemberViewController【电话会议选人】)*/
    
    SelectObjectType_CreateReservePhoneMeetingSelectMember = 9001,//创建预约电话会议选人
    /*(调用ChatSelectMemberViewController【预约电话会议选人】)*/
    
    SelectObjectType_CreatePhoneMeetingSelectMember = 9002,//创建电话会议选人
    /*(调用ChatSelectMemberViewController【电话会议选人】)*/
    /// eagle 有会
    //    YHCSelectObjectType_None = 0,//无
    
    YHCSelectObjectType_ConfInfoSelectMember = 101,//会议详情选人
    
    YHCSelectObjectType_ConfOnlineSelectMember = 102,//会议中选人
    
    YHCSelectObjectType_ConfOnlineSelectPhoneMember = 103,//会议中选手机联系人
    
    YHCSelectObjectType_GroupCreateSelectMember = 104,//创建群聊选人
    
    YHCSelectObjectType_GroupChatSelectMember = 105,//群组中选人
    
    YHCSelectObjectType_TransmitSelectMember = 106,//转发选人
};

/**
 *  通话结束时用于判断通话类型
 */
typedef NS_ENUM(NSInteger, VoipCallType){
    
    VoipCallType_Voice = 0,//语音单聊
    
    VoipCallType_Video = 1,//视频单聊
    
    VoipCallType_LandingCall = 2,//网络直播
    
    VoipCallType_LandingReCall = 3,//网络回拨
    
    VoipCallType_VoiceMeeting = 20,//语音会议
    
    VoipCallType_VideoMeeting = 21,//视频会议
};

/**
 *  当前处于的聊天状态
 */
typedef NS_ENUM(NSInteger,NowChatingObjectType) {
    
    NowChatingObjectType_None=0,//没有聊天
    
    NowChatingObjectType_Member=1,//正在跟某人聊天界面
    
    NowChatingObjectType_Group=2,//正在跟某个群组聊天界面
    
    NowChatingObjectType_App=3,//正在某个应用聊天界面
    
    NowChatingObjectType_Department = 999,//正在某个部门聊天界面
};

typedef NS_ENUM(NSInteger, RelayMessageType){
    
    RelayMessage_multi = -1,
    RelayMessage_text = 0,   //文本
    RelayMessage_image = 1,//图片
    RelayMessage_link=2,//连接
    RelayMessage_file=3, //文件
    RelayMessage_video=4,//视频
    RelayMessage_voice=5,//语音
    RelayMessage_card=6,//名片
    RelayMessage_mergeMessage = 7, //合并转发
    RelayMessage_eachMessage = 8,//逐条转发
    RelayMessage_personCard = 9,//个人名片
    RelayMessage_location = 10,//个人名片
    RelayMessage_other //其他
};

#pragma mark -
#pragma mark Singleton


#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(className) \
\
+ (className *)sharedInstance;

#define SYNTHESIZE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)sharedInstance { \
static className *sharedInstance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
sharedInstance = [[self alloc] init]; \
}); \
return sharedInstance; \
}




#endif
