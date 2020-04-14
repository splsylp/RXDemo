//
//  BaseComponent.h
//  BaseComponent
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SynthesizeSingleton.h"


@protocol ComponentDelegate <NSObject>

@optional
-(NSDictionary *)onGetUserInfo;
-(NSString *)getDeptNameWithDeptID:(NSString *)deptID;
-(NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type;//0,根据account获取，1根据手机号获取

//创建白板
-(void)createBoardWithParams:(NSDictionary *)params andPresentedVC:(id)vc;

//加入白板
-(void)joinBoardWithParams:(NSDictionary *)params andPresentedVC:(id)vc;

/**
 @brief             白板发送IM消息
 @param info 信息
 roomID      房间ID
 psd         房间密码
 toUser      发送的对方
 keyValue    用来区分IM的类型
 */
-(void)sendBoardMessageWithInfo:(NSDictionary *)info;

//清空白板信息
-(void)cleanBoardInfo;

//根据手机号获取本地通讯录名字
-(NSString *)getLocalAddressNameWithPhoneNumber:(NSString *)phone;

/**
 获取选择联系人页面
 */
-(UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData WithType:(SelectObjectType)type;

/**
 @brief 通话结束回调
 @param error 失败错误码传回
 @param type 通话类型
 @param information 通话信息
 @param userData 用户透传信息字段 点对点时为空
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
 聊天界面分享图文到微信
 */
- (void)shareDataWithTarget:(id)target Text:(NSString *)str Image:(UIImage *)img Url:(NSString *)url;

/**
 功能面板点击红包
 */
- (void)redPacketTapWithArray:(NSArray *)groupMembers withPersonDic:(NSDictionary *)data withCountType:(NSInteger)type withController:(UIViewController *)controller isGroup:(BOOL)isGroup completeBlock:(void (^)(NSString *text,NSString *userData))completeBlock;
/**
 抢红包
 */
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
 参数说明:dic的key可选
 @"URL"：分享的链接
 @"imageStr"：分享链接的缩略图
 @"imgThumbPath":分享链接缩略图在本地的路径
 @"articleTitle"：分享链接的标题
 @"content"：分享链接的内容
 */
- (UIViewController *)sendFriendCircleWityDic:(NSDictionary *)dic;

/**
 打开公众号分享链接的界面
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
 @userData 红包的透传userData字段
 */
- (BOOL)isRedpacketWithData:(NSString *)userData;
- (BOOL)isTransferWithData:(NSString *)userData;
- (BOOL)isRedpacketOpenMessageWithData:(NSString *)userData;


/**
 @brief 个人中心侧滑
 @param isInit 侧滑出来的界面初始化
 @param isData 是否更新个人信息
 @param show 侧滑界面是否出来
 */
- (void)getSidePage:(BOOL)isInit withData:(BOOL)isData withShow:(BOOL)show;

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


@interface BaseComponent : NSObject

@property(nonatomic,strong) NSDictionary* componentInfo;
@property(nonatomic,weak) id owner;//所有者
@property(nonatomic,weak) id<ComponentDelegate> componentDelegate;//代理

-(UIViewController*)mainView;

-(NSString*)getAccount;

-(NSString*)getMobile;

-(NSString*)getAppid;

-(NSString*)getUserName;

- (NSString *)getStaffNo;

-(NSString*)getApptoken;

-(NSString*)getAvatar;

-(NSString*)getAppClientpwd;

-(NSString*)getCompanyId;

-(NSString*)getAPPCompanyName;

-(NSString*)getSex;//获取用户性别

-(NSString *)getRestHost;

-(NSArray *)getLvsArray;

-(NSString *)getVidyoRoomUrl;

-(NSString *)getConfNum_regex;

-(NSString *)getVidyoRoomID;

-(NSString *)getVidyoFQDN;

-(NSString *)getVidyoConfExten;

-(NSString *)getVidyoEntityID;

-(NSString *)getAuthtag;

-(NSString *)getBoardUrl;

-(NSString *)getBoardAppId;

-(NSString *)getApproval;

-(NSString*)getOutlookPwd;

-(NSString*)getUserLevel;

-(NSString*)getPersonLevel;

-(NSString *)getPassMd5;

-(NSString *)getDepartmentId;

-(NSString *)getOaAccount;

-(NSString *)getLoginTokenMd5;

-(NSString *)getFriendgroupUrl;

-(NSString *)getOneAccount;

-(NSString *)getOneClientPassWord;

-(NSString *)getOneUserName;

-(NSString *)getOneUserPhotoUrl;

-(NSString *)getOneUserMobile;

-(NSString *)getOneCompanyId;

-(NSString *)getOneUserPhotoMd5;

@end
