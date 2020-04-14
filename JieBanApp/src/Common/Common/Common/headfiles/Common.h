//
//  Common.h
//  Common
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SynthesizeSingleton.h"
#import "BaseComponent.h"
// eagle代码混淆 debug不生效
#if DEBUG
#else
#import "YZcodeObfuscation.h"
#endif
#import "RXThirdPart.h"

//用于区分搜索类型 create by hw
typedef NS_ENUM(NSUInteger, RXSearchType) {
    RXSearchTypeChat,       //消息界面
    RXSearchTypeChatDetail, //消息界面详情
    RXSearchTypeAddressbook,//选择通讯录
    RXSearchTypeLocalSearch,//搜索本地聊天记录
    RXSearchTypeLocalSearchTime,//时间搜索本地聊天记录
    RXSearchTypeLocalSearchPerson,//成员搜索本地聊天记录
};

//之前的枚举
typedef NS_ENUM(NSInteger, SearchPart) {
    SEARCH_CHAT_PERSON,///联系人
    SEARCH_CHAT_GROUP,//群聊
    SEARCH_CHAT_RECORD,//聊天记录
    SEARCH_CHAT_FRIENDCIRCLE,//同事圈checkPointToPiontIsMyFriendWithAccount
    SEARCH_CHAT_GONGZHONGHAO,//公众号
    SEARCH_CHAT_GROUPS,//群组
};

typedef void(^SearchCompletionBlock)(id response, NSError *error);

@interface Common : BaseComponent

+ (Common *)sharedInstance;

//正在请求群组成员信息的群
@property(nonatomic, strong) NSMutableArray *cacheGroupMemberRequestArray;
//临时请求数据缓存 防止无限进入 频繁请求
@property(nonatomic, strong) NSMutableArray *cacheLoadRequestArray;

@property(nonatomic, assign) BOOL isreloadView;
@property(nonatomic, assign) BOOL ishaveSpecialUpdate;//有特别关注更新
@property(nonatomic, assign) BOOL isSendSportMeet;

@property(nonatomic, copy) NSString *historyMessageUrl;//历史消息
@property(nonatomic, copy) NSString *collectSynctime;//上次获取收藏的时间
@property(strong, nonatomic) NSMutableDictionary *FCDynamicDic;//同事圈动态记录 weijy
@property(nonatomic, assign) BOOL isIMMsgMoreSelect;//im消息多选状态
@property(nonatomic, strong) NSMutableArray *moreSelectMsgData;//更多选择的消息
@property(strong, nonatomic) NSMutableDictionary *FCDeleteDic;//通讯录离职删除朋友圈

@property(nonatomic, assign) BOOL isFirstEnterAdd;

@property(nonatomic, strong) NSArray *confRooms;

//pbs地址配置项 拆分插件的时候可以去掉
/** http or https */
@property(nonatomic,strong)NSString *httpType;

/** host */
@property(nonatomic,strong)NSString *host;

/** port */
@property(nonatomic,assign)int port;


//检查权限
- (BOOL)checkUserAuth:(NSString *)auth;

/**
 获取网络信号强度，需要开启AFNetworking网络监听
 */
- (NSString *)networkingStatesFromStatebar;

+ (BOOL)isAccordWithSearchConditionName:(NSString *)name withkeyWords:(NSString *)keyWords withFirstLetter:(NSString *)firstLet;


/**
 通过  获取用户昵称 或者群组名称

 @param phone 用户 account或者群组 id
 @return 昵称
 */
- (NSString *)getOtherNameWithPhone:(NSString *)phone;

///根据account获取个人信息
- (void)getUserInfoByAccount:(NSString *)account completion:(void (^)(NSDictionary *userInfo,NSString *userName))completion;

- (NSDictionary *)getOtherInfoWithSessionId:(NSString *)sessionId;

/**
 通过  获取用户昵称 或者群组名称 群组的时候会显示数量

 @param phone 用户 account或者群组 id
 @return 昵称
 */
- (NSString *)getOtherNameAndCountWithPhone:(NSString *)phone;

- (void)deleteOneGroupInfoGroupId:(NSString *)groupId;

/// eagle 隐藏chatvc右上角按钮
- (void)hideChatVCRightItemBarWithsessionId:(NSString *)sessionId;

//删除会话的数据
- (void)deleteAllMessageOfSession:(NSString *)sessionId;

- (CGSize)widthForContent:(NSString *)text withSize:(CGSize)size withLableFont:(CGFloat)fontSize;

/**
 音视频呼入铃声播放(铃声播放由应用层处理)
 */
- (void)playAVAudioIncomingCall;

/**
 音视频呼入铃声停止
 */
- (void)stopAVAudio;

/**
 音视频呼入震动(铃声播放由应用层处理)
 */
- (void)startVibrate:(BOOL)isPush;

/**
 停止振动
 */
- (void)stopShakeSoundVibrate;

/**
 检查账号是否被冻结或离职
 */
- (BOOL)checkPointToPiontChatWithAccount:(NSString *)account;

/**
 检查是否离职
 */
- (BOOL)isDimissionWithAccount:(NSString *)account;

//检查是否是符合权限控制
- (BOOL)checkPointToPiontIsMyFriendWithAccount:(NSString *)account needPrompt:(BOOL)isPromp;


/**
 用作公用的搜索方法

 @param searchType 搜索类型
 @param keyword 关键字
 @param data 通过字典的方法传入你想传入的参数
 @param completion 回调结果
 */
- (void)searchWithType:(RXSearchType)searchType keyword:(NSString *)keyword otherData:(NSDictionary *)data completed:(SearchCompletionBlock)completion;

////是否能查看联系方式（邮箱电话）
/// @param level 对方的级别
/// @param account 对方account
- (BOOL)canLookContacts:(NSString *)level account:(NSString *)account;

/// 能否聊天
/// @param level 对方的级别
/// @param account 对方account
- (BOOL)canChat:(NSString *)level account:(NSString *)account;

/// 下级是否可拉上级入群只根据PBS返回的规则来判断（不受好友关系和最近联系人影响）
/// @param level 对方的级别
/// @param account 对方account
- (BOOL)canCreatGroup:(NSString *)level account:(NSString *)account;

@end
