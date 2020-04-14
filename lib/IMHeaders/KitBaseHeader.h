
/*
 *创建单例的
 */
#ifndef SYNTHESIZE_SINGLETON_FOR_CLASS

#import <objc/runtime.h>
#import "ECError.h"

/**
 *  选人的场景
 */
typedef NS_ENUM(NSInteger, SelectObjectType){
      SelectObjectType_None = 0,//无
       
       SelectObjectType_CreateGroupChatSelectMember = 1001,//创建群聊选人
       
       SelectObjectType_CreateBoardCoopSelectMember = 1111,//创建白板选人
       
       SelectObjectType_GroupChatSelectMember = 1002,//群组中选人
       
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

@protocol ComponentDelegate <NSObject>

@required

/**
 @brief 获取登录用户信息回调
 @return 登陆的用户信息字典
 */
-(NSDictionary*)onGetUserInfo;

/**
 @brief 获取用户信息回调
 @param Id 用户的account或者手机号
 @param type 查询类型  0,根据account获取，1根据手机号获取
 @return 用户信息字典
 */
-(NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type;


/**
 获取选择联系人页面
 */
-(UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData WithType:(SelectObjectType)type;

@optional

/**
 @brief 通话结束回调
 @param error 失败错误码穿回
 @param type 通话类型
 @param information 通话信息
 */
- (void)finishedCallWithError:(NSError *)error WithType:(VoipCallType)type WithCallInformation:(NSDictionary*)information   UserData:(NSString *)userData;

@end


@protocol AppModelDelegate <NSObject>

@end

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
