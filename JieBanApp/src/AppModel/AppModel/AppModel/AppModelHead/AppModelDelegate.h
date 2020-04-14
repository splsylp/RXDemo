//
//  AppModelDelegate.h
//  AppModel
//
//  Created by wangming on 2016/12/5.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#ifndef AppModelDelegate_h
#define AppModelDelegate_h
@protocol AppModelDelegate <NSObject>

@optional
-(NSDictionary *)onGetUserInfo;
-(NSString *)getDeptNameWithDeptID:(NSString *)deptID;
-(NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type;//0,根据account获取，1根据手机号获取
-(void)getChatVCWithAccount:(NSString *)account;
-(void)startCallForPlugiInViewWithDict:(NSDictionary *)dict ;//插件用的接口，调用音视频呼叫

-(void)responseAccountFreezedKickedOff;
//wwl 账号被删除
-(void)responseAccountDelete;
//add yuxp 人员离职
-(void)responseAccountleaveJob;
/**
 获取选择联系人页面
 */
-(UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData WithType:(SelectObjectType)type;
/// eagle 有会选择联系人
-(UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData withType:(SelectObjectType)type completion:(void(^)(NSArray *membersArr))completion;
/**
 @brief 通话结束回调
 @param error 失败错误码穿回
 @param type 通话类型
 @param information 通话信息
 */
-(void)finishedCallWithError:(NSError *)error WithType:(VoipCallType)type WithCallInformation:(NSDictionary*)information  UserData:(NSString *)userData;


/**
 获取成员列表
 */
-(UIViewController *)getMemberListVCWithData:(NSDictionary *)data;

/**
 获取联系人详情页面
 */
-(UIViewController *)getContactorInfosVCWithData:(id)data;

/**
 聊天界面"+"号功能列表定制
 */
- (void)getChatMoreArrayWithIsGroup:(BOOL)isGroup andMembers:(NSArray *)members completion:(void(^)(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr))completion;

/**
 定制聊天界面长按消息item
 */
- (NSArray <NSString *> *)getMenuItems;

/**
 会话列表界面右上角"+"号功能列表定制
 */
- (void)getSessionMoreArrayWithCurrentVc:(UIViewController *)currentVC completion:(void(^)(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr))completion;

/**
 自定义会话列表导航栏按钮
 */
- (void)configSessionListNavigationItemsWithBlock:(void(^)(NSArray <UIBarButtonItem *>*leftItems,NSArray <UIBarButtonItem *>*rightItems))block;


/**
 聊天界面分享图文
 */
- (void)shareDataWithTarget:(id)target Text:(NSString *)str Image:(UIImage *)img Url:(NSString *)url;

/**
 红包点击
 */
- (void)redPacketTapWithArray:(NSArray *)groupMembers withPersonDic:(NSDictionary *)data withCountType:(NSInteger)type withController:(UIViewController *)controller isGroup:(BOOL)isGroup completeBlock:(void (^)(NSString *text,NSString *userData))completeBlock;
- (void)reloadRedpacketCellWithData:(NSDictionary *)data withVC:(id)Vc withSessionId:(NSString *)sessionID;
/**
 单聊转账
 */
- (void)transformMoneyWithPerson:(NSDictionary *)persondic withSessionId:(NSString *)sessionId withVC:(UIViewController *)controller;

//获取联系人
//array的item为dict类型，至少需要包括name名字，phone电话
-(NSArray*)getContacts;

/**
 分享到朋友圈功能
 */
- (UIViewController *)sendFriendCircleWityDic:(NSDictionary *)dic;

/**
 打开公众号分享链接的界面
 字段：@"URL":打开的链接
 字段：@"sender":message.from 消息来源
*/
- (UIViewController *)getWebViewControllerWithDic:(NSDictionary *)dic;

/**
 可实现回调，获取公众号历史消息列表，用于IM展示，点击恒信服务号入口可见
 */
- (UIViewController *)getHXPublicViewController;
/**
 IM搜索公众号
 */
- (NSMutableArray *)getHXPublicData:(NSString *)searchText;

/**
 删除数据库缓存，用于更新IM列表
 */
- (void)deletePublicIMListWihtId:(NSString *)sessionID;

/**
 收到公众号消息推送
 */
- (id)getNotificationWithPublicDic:(NSDictionary *)dic;

/**
 可实现回调，文件助手的功能模板中点击链接事件
 */
- (UIViewController *)sendWebLinkViewControllerWithDic:(NSDictionary *)dic;
/**
 可实现回调，获取收藏界面
 */
- (UIViewController *)getCollectionViewControllerWithData:(NSDictionary *)dic;
/**
 可实现回调，获取添加好友界面
 */
-(UIViewController *)getAddRXfriend:(NSDictionary *)data;

/**
 @brief 个人详情界面点击钱包界面
 */
- (UIViewController *)clickedMoneyController;

/**
 @brief 连接状态接口
 @discussion 监听与服务器的连接状态 V5.0版本接口
 @param state 连接的状态
 @param error 错误原因值
 */
-(void)onConnectState:(ECConnectState)state  failed:(NSError *)error;

-(void)onReceiveMultiDeviceState:(NSArray*)multiDevices;
/**
 @userData 红包的透传userData字段
 */
- (BOOL)isRedpacketWithData:(NSString *)userData;
- (BOOL)isTransferWithData:(NSString *)userData;
- (BOOL)isRedpacketOpenMessageWithData:(NSString *)userData;

/**
 ·@brief 会议插件点击成员代理方法
 @discussion 点击成员代理方法
 */
- (UIViewController *)onAvatarClickListener:(NSDictionary *)data;


/**
 ·@brief 会议插件分享代理方法
 @discussion 分享代理
 */
- (void)WXShareConferenceContent:(NSString *)strContent;
@end


#endif
