//
//  HXMessageMergeManager.h
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/29.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_Message_Count 30


//消息转发方式
typedef NS_OPTIONS(NSUInteger, ForwardMode) {
    ForwardMode_EachMessage                                            =1,        //逐条转发
    ForwardMode_MergeMessage                                          =2,        //合并转发
};


typedef void (^Completion) (void);

static NSString * const HXMergeMessageTitleKey       = @"merge_title";         // 合并消息的标题--- 最外层的key
static NSString * const HXMergeMessageDesKey         = @"merge_messageDes";    // 合并消息的描述--- 最外层的key




static NSString * const HXMergeMessageType          = @"merge_type";        //消息类型
static NSString * const HXMergeMessageTitle         = @"merge_title";       //消息title
static NSString * const HXMergeMessageTime          = @"merge_time";        //消息时间
static NSString * const HXMergeMessageUrl           = @"merge_url";         //消息url--图片地址，视频地址
static NSString * const HXMergeMessageContent       = @"merge_content";     //文字消息，
static NSString * const HXMergeMessageAccount       = @"merge_account";     //消息是谁发的
static NSString * const HXMergeMessageUserData      = @"merge_userData";    //消息数据

//增加一个字段，用来放链接的缩略图
static NSString * const HXMergeMessageLinkThumUrl   = @"merge_linkThumUrl";    //用于链接消息的缩略图
//增加一个字段，messageId
static NSString * const HXMergeMessageId            = @"merge_messageId";       //消息Id
//增加一个字段，fileSize
static NSString * const HXMergeMessageFileSize      = @"merge_fileSize";      //文件大小

//增加一个字段，sessonId
static NSString * const HXMergeMessageSessonId     = @"merge_sessonId";        //

//增加一个字段，语音消息时长
static NSString * const HXMergeMessageDuration     = @"merge_duration";        //



@class BaseViewController;
@class HXMergeMessageModel;


@interface HXMessageMergeManager : NSObject


@property (nonatomic,strong) void (^completion) (void);



/**
 @brief 消息合并的管理类
 @discussion
 */
+(instancetype)sharedInstance;


/**
 @brief 获取当前转发消息的模式
 @discussion
 */
-(ForwardMode)getForwardMode;


/**
 @brief 获取合并消息的标题
 @discussion
 */
-(void)setMergeMessageTitleWithSessonId:(NSString *)sessionId;

/**
 @brief 合并消息跳转到选择人
 @discussion
 */
- (void)forwardChatMultipleMessageMerge:(NSArray<ECMessage *>*)messageArr withVC:(UIViewController *)vc;


/**
 @brief
 @discussion 提取消息信息,提取规则
 */
- (NSDictionary *)mergeMessageWithMessage:(ECMessage *)message;


/**
 @brief 合并消息发送
 @discussion
 selectResultArray:选择要发送的人
 completion:发送完成后的回调
 */
//- (void)sendMergeMessageAndSelectResultArray:(NSArray *)selectResultArray andCompletion:(Completion)completion;

- (void)sendMergeMessageAndSelectResultArray:(NSArray *)selectResultArray andCompletion:(Completion)completion andView:(UIView *)currentView;


/**
 @brief 逐条消息转发
 @discussion
 */
- (void)eachForwardChatMessage:(NSArray<ECMessage *>*)messageArr withVC:(BaseViewController *)vc;




/**
 @brief时间 ，标准时间 ---> MM月dd日 hh:mm
 @discussion
 */
+(NSString *)timeWithTimeIntervalString:(NSString *)timeString;

//单例方法
-(NSDictionary *)jsonDicWithBase64UserData:(NSString *)userData;

//类方法
+(NSDictionary *)jsonDicWithBase64UserData:(NSString *)userData;

+(NSDictionary *)jsonDicWithNOBase64UserData:(NSString *)userData;
//获取userData中json信息，返回jsonString
+(NSString *)getUserBase64DataString:(NSString *)userData;


//外部调用 runtime
- (NSNumber *)checkIsMergeMessage:(ECMessage *)message;

//下载文件--用于图片
- (void)startDownload:(HXMergeMessageModel*)model andCompletion:(Completion)completion;

- (void)gy_sendMergeMessageAndSelectResultArray:(NSString *)sessionId andCompletion:(void (^)(ECMessage *message))completion;
@end
