//
//  Created by wangming on 16/7/18.
//  Copyright © 2016年 ronglian. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^didFinishLoaded)(NSDictionary *dict, NSString *path);
typedef void (^didFailLoaded)(NSError *error, NSString *path);


@interface RestApi : NSObject

+ (RestApi *)sharedInstance;

-(void)setAccountDict:(NSDictionary*)dict;

/**
 GET请求

 @param path URL地址
 @param params 参数
 @param finish 完成
 @param fail 失败
 */
- (void)requestGet:(NSString *)path params:(NSDictionary *)params didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

- (void)requestGet:(NSString *)path params:(NSDictionary *)params progress:(void (^)(NSProgress *))progress didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 POST请求

 @param path URL地址
 @param params POST数据
 @param finish 完成
 @param fail 失败
 */
- (void)requestPost:(NSString *)path params:(NSDictionary *)params didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

- (void)requestPost:(NSString *)path params:(NSDictionary *)params progress:(void (^)(NSProgress *))progress didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 错误信息

 @param errorDomain 错误
 */
+(void)showErrorDomain:(NSError *)errorDomain;

/**
 处理错误信息

 @param errDomain 错误码
 @param prompt 错误描述
 @return 返回错误信息
 */
+(NSString *)errorDomain:(NSString *)errDomain withErrorPrompt:(NSString *)prompt;

/**
 *  处理错误信息
 *
 *  @param errorcode 错误码
 */
+ (void)handlerErrorCode:(int)errorcode;

/**
 *  错误信息
 *
 *  @param errorcode 错误码
 *
 *  @return 错误信息
 */
+ (NSString *)errorMessage:(int)errorcode;

/**
 *  登录
 *
 *  @param mobile     手机号码
 *  @param verifyCode 验证码
 *  @param pwd        密码
 */
- (void)userLoginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  登录
 *
 *  @param mobile     手机号码
 *  @param verifyCode 验证码
 *  @param pwd        密码
 *  @param type       业务类型
 *  @param codeKey    图片验证码的key
 *  @param imgCode    图片验证码的值
 */
- (void)userLoginWithMobile:(NSString *)mobile
                 verifyCode:(NSString *)verifyCode
                     passwd:(NSString *)pwd
                   userType:(int)type
                withCodeKey:(NSString *)codeKey
                    imgCode:(NSString *)imgCode
                     compId:(NSString *)compId
            didFinishLoaded:(didFinishLoaded)finish
              didFailLoaded:(didFailLoaded)fail;
/**
 *
 * 获取图片验证码
 * account 账号
 * 900363 开始获取验证码
 *
 **/
- (void)getLoginImageCodeWithUuid:(NSString *)uuid didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  注册
 *
 *  @param mobile     手机号码
 *  @param verifyCode 验证码
 
 *  @param pwd        密码
 */
- (void)userRegisterWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

- (void)sendSMSVerifyCodeWithMobile:(NSString *)mobile
                           withFlag:(NSString *)flag
                            codeKey:(NSString *)codeKey
                            imgCode:(NSString *)imgCode
                             compId:(NSString *)compId
                    didFinishLoaded:(didFinishLoaded)finish
                      didFailLoaded:(didFailLoaded)fail;

- (void)sendTelVerifyCodeWithMobile:(NSString *)mobile withFlag:(NSString *)flag didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 找回密码

 @param mobile 用户手机号
 @param newpwd 新密码
 @param verifyCode 短信验证码
 @param compId 企业ID
 @param finish 成功
 @param fail 失败
 */
- (void)findPasswordWithMobile:(NSString *)mobile
                        newpwd:(NSString *)newpwd
                    verifyCode:(NSString *)verifyCode
                        compId:(NSString *)compId
               didFinishLoaded:(didFinishLoaded)finish
                 didFailLoaded:(didFailLoaded)fail;

/**
 *  修改密码
 *
 *  @param auth   短信验证码
 *  @param newpwd 新密码
 */
- (void)updatePasswordWithMobile:(NSString *)mobile auth:(NSString *)auth newpwd:(NSString *)newpwd type:(NSString*)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
- (void)updateNewPasswordWithAccount:(NSString *)account auth:(NSString *)auth newPass:(NSString *)newPwd type:(int )type oldPwd:(NSString *)oldPwd didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

- (void)feedBackWithDict:(NSDictionary *)feedbackDict didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

- (void)checkVersionWithMobile:(NSString *)mobile didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  设置用户信息
 *
 *  @param nickName  昵称
 *  @param photo     头像
 *  @param signature 联系人个性签名
 */
- (void)updateUserInfo:(NSString *)mobile nickName:(NSString *)nickName photo:(UIImage *)photo signature:(NSString *)signature didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  获取VOIP用户信息
 *
 *  @param mobile  电话号码 或者为voip号码
 *  @param type     0   mobilenum 为电话号码  1   mobilenum为voip号码 2 account
 */
- (void)getVOIPUserInfoWithMobile:(NSString *)mobile type:(NSString*)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
//- (void)getVOIPUserInfoWithMobile:(NSString *)mobile number:(NSArray*)number type:(NSString*)type  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/// 获取权限控制匹配规则
/// @param compId 企业id
/// @param finish 成功回调
/// @param fail 失败回调
- (void)getPrivilegeRuleWithCompId:(NSString *)compId  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/// 获取企业下所有部门
/// @param compId 企业id
/// @param finish 成功回调
/// @param fail 失败回调
- (void)getAllDepartInfo:(NSString *)compId  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 下载企业通讯录

 @param account 手机号码
 @param finish 完成
 @param fail 失败
 */
- (void)downloadCOMAddressBookWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *
 * 下载企业通讯录文件text
 *
 */
-(void)downloadComTextWithUrl:(NSString *)textUrl didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 申请加入企业

 @param mobile 手机号码
 @param companyid 企业id
 @param finish 完成
 @param fail 失败
 */
+ (void)confirmInvitWithMobile:(NSString *)mobile companyid:(NSString *)companyid didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 获取企业审核状态

 @param mobile 手机号码
 @param finish 完成
 @param fail 失败
 */
+ (void)confirmInvitStatusWithMobile:(NSString *)mobile  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

#pragma mark - 运动会
/**
 *  运动会 恒信 消息发布
 *  @sig MD5(account+passWord)
 *  @mobile 账号
 *  @content 内容
 *  @imgUrl 图片地址
 *  @domain 运动会期间{“msgType”:””, “item”:””,“status”:”” }，1你我看点，2场外之声，3精彩回放，4战绩快报
 *  @subject 主题
 */
+ (void)sendSportMeetMessageSig:(NSString *)sig
                    withAccount:(NSString *)mobile
                    withContent:(NSString *)content
                    withFileUrl:(NSArray *)imgUrl
                      withDomin:(NSDictionary *)domain
                    withSubject:(NSString *)subject
                didFinishLoaded:(didFinishLoaded)finish
                  didFailLoaded:(didFailLoaded)fail;

/**
 *  运动会 恒信 获取消息
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @content 内容
 *  @limit 获取个数 默认是5条
 *  @domain 运动会期间{“msgType”:””, “item”:””,“status”:”” }，1你我看点，2场外之声，3精彩回放，4战绩快报
 *  @version 开始的版本号，默认为空，从第一条开始
 */

+ (void)getSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version withLimit:(int )limit withDomain:(NSDictionary *)domain didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  运动会 恒信 获取单条消息
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 开始的版本号，默认为空，从第一条开始
 */
+ (void)getSingleSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  获取某个人的所有同事圈
 *  @sig MD5(account+passWord)
 *  @account 自己账号
 *  @friendAccount 朋友的账号
 *  @limit 获取个数 默认是10条
 *  @domain 自定义json字段
 *  @msgId 开始的版本号，默认为空，从第一条开始
 */

+ (void)getFCMyListMessageSig:(NSString *)sig withAccout:(NSString*)account withMsgId:(NSString *)msgId withLimit:(int)limit withDomain:(NSDictionary *)domain didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  删除同事圈
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 */
+ (void)deleteFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *  获取所有评论和点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 *  @flag    0 全部， 1 赞，2评论   默认值0
 */
+ (void)getRepliesAndFavorsWithFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version withFlag:(int)flag didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *  同事圈评论
 *  @sig MD5(account+passWord)
 *  @account 自己账号
 *  @rAccount 回复对方的帐号
 *  @version 同事圈消息版本号
 *  @content 评论内容
 */
+ (void)replyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyAccount:(NSString *)rAccount withVersion:(NSString *)version withContent:(NSString *)content didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *  同事圈点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 */
+ (void)favourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *  取消同事圈评论
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @replyId 评论消息ID
 */
+ (void)cancelReplyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyId:(NSString *)replyId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *  取消同事圈点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 */
+ (void)cancelFavourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  增加收藏
 *  account 账号
 *  content 收藏内容
 *  type  1,文本 ；2，图片；3，网页；4，语音；5，视频；6，图文
 */
+ (void)addCollectDataWithAccount:(NSString *)account fromAccount:(NSString *)fromAccount TxtContent:(NSString *)txtContent Url:(NSString *)url   DataType:(NSString *)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *  增加收藏
 *  account 账号
 *  collectContents 收藏的数据
 */
+ (void)addMultiCollectDataWithAccount:(NSString *)account
                       collectContents:(NSArray *)collectContents
                       didFinishLoaded:(didFinishLoaded)finish
                         didFailLoaded:(didFailLoaded)fail;

/**
 收藏
 
 @param account 自己的 account
 @param sessionId 会话 id（合并收藏的时候必选）
 @param collectContents 收藏内容
 @param finish 成功回调
 @param fail 失败回调
 */
+ (void)addMultiCollectDataWithAccount:(NSString *)account
                             sessionId:(NSString *)sessionId
                       collectContents:(NSArray *)collectContents
                       didFinishLoaded:(didFinishLoaded)finish
                         didFailLoaded:(didFailLoaded)fail;

/**
 *  删除收藏
 *  account 账号
 *  collectIds 收藏id数组
 */
+ (void)deleteCollectDataWithAccount:(NSString *)account CollectIds:(NSArray *)collectIds didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *  获取收藏
 *  account 账号
 *  synctime 上次同步时间，为空则为全量
 *  collectId 收藏id
 */
+ (void)getCollectDataWithAccount:(NSString *)account Synctime:(NSString *)synctime CollectId:(NSString *)collectId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

//上传附件 将文件名字和图片传进来
+ (void)uploadPhoWithFileName:(NSString *)fileName photo:(UIImage *)photo fileData:(NSData *)fileData fileType:(NSString *)fileType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

#pragma mark 朋友圈上传文件
//上传附件 将文件名字和图片传进来
+ (void)uploadPhoWithFileName1:(NSString *)fileName photo:(UIImage *)photo fileData:(NSData *)fileData fileType:(NSString *)fileType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
+ (void)uploadPhoWithFileName1:(NSString *)fileName photo:(UIImage *)photo fileData:(NSData *)fileData fileType:(NSString *)fileType withImageType:(NSInteger)imageType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  获取已关注的公众号
 *  account 账号
 **/
+(void)getMyAttentionPublicSig:(NSString *)sig account:(NSString*)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 * 获取公众号信息
 * sig Md5(account + userpwd)
 * account 账号
 * pnid 公众号
 */
+(void)getPublicInfoDataSig:(NSString *)sig account:(NSString*)account publicId:(NSString *)pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *
 *  公众号搜索
 *  account 账号
 *  lPnId 本轮查询中的上次返回数据中最大pn_id
 *  limit 一次获取多少条公众号信息，默认20
 **/
+(void)getPublicSearchDataSig:(NSString *)sig account:(NSString*)account searchStr:(NSString *)searchString publicId:(NSInteger )ipnId limit:(NSInteger)limit didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

//-------公众号


/**
 * 公众号置顶功能
 * sig鉴权字段 account+client
 * account 获取账号
 * pnId 获取的公众号信息
 *
 *
 ***/

+ (void)settingPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 * 公众号取消置顶功能
 * sig鉴权字段 account+client
 * account 获取账号
 * pnId 获取的公众号信息
 *
 *
 ***/
+ (void)cancelPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *
 *  关注公众号
 *  account 账号
 *  pnid 公众号Id
 **/
+(void)attentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *
 *  取消公众号
 *  account 账号
 *  pnid 公众号Id
 **/
+(void)cancelAttentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 * 获取公众号历史记录
 * sig鉴权字段 account+userpassword
 * account 获取账号
 * pnId 获取的公众号信息
 * msgSendId 可选 发送消息记录Id 默认为0 此值从缓存中取，取最小值，无缓存置0；
 值为0时，取最新消息
 * limit 可选 默认10 获取消息条数
 **/
+(void)getPublicHistroyDataSig:(NSString *)sig account:(NSString *)account publicId:(int )pnId msgSendId:(int)msgSendId limit:(int)limit didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 * 获取消息记录        群组操作
 * appid             应用ID
 * groupId           群组ID
 * startTime         开始时间
 * endTime           结束时间
 * pageNo            页码 缺省第一页
 * pageSize          每页条数，最多100条 缺省100条
 * msgDecompression  返回的消息内容是否解压。0、不解压 1、解压 缺省0
 **/

+ (void)getHistoryGroupListMessageGroupId:(NSString *)groupId startTime:(NSString *)startTime endTime:(NSString *)endTime pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize msgDecompression:(NSString *)msgDecompression didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 * 获取历史消息记录
 * appId           应用Id  必选
 * userName        登录帐号 必选
 * version         消息版本号 可选
 * msgId           消息Id version和msgId两个参数二选一，都传则以version为准 可选
 * pageSize        获取消息条数，最多100条。默认10条 可选
 * talker          交互者账号 必选
 * order           1.升序 2.降序 默认1  可选
 **/

+ (void)getHistoryMyChatMessageWithAccount:(NSString *)userName withAppid:(NSString *)appid version:(long long)version time:(NSString *)time pageSize:(NSInteger)pageSize talker:(NSString *)talker order:(NSInteger)order  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 * 获取历史消息记录   个人聊天
 * appId           应用Id  必选
 * userName        登录帐号 必选
 * version         消息版本号 可选
 * msgId           消息Id version和msgId两个参数二选一，都传则以version为准 可选
 * pageSize        获取消息条数，最多100条。默认10条 可选
 * talker          交互者账号 必选
 * order           1.升序 2.降序 默认1  可选
 拉取消息类型msgType
 **/

+(void)getHistoryMyChatMessageWithAccount:(NSString *)userName withAppid:(NSString *)appid version:(long long)version msgId:(NSString *)msgId pageSize:(NSInteger)pageSize talker:(NSString *)talker order:(NSInteger)order andMsgType:(NSInteger)msgType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  特别关注
 *  取消或者添加特别关注
 *   type 0.增加 1.删除
 *  attectionAccounts 关注的账号
 */
+ (void)selectSpecialAccount:(NSArray *)attectionAccounts type:(int)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  特别关注
 *  获取自己关注的账号
 *  addRequest 是否是增量更新
 *  account 自己账号
 */
+ (void)getAllSpecialAtt:(NSString *)account withAddRequest:(BOOL)addRequest didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

//-----好友
/**
 *
 *  添加好友
 *  type 0/1/2 邀请/接受/拒绝
 *  account 好友account 唯一标示
 *  0/1/2 邀请/接受/拒绝 邀请描述内容
 *
 **/
+(void)addNewFriendAccount:(NSString *)userAccount inviteType:(NSInteger)inviteType descrContent:(NSString *)descrContent didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 *
 *  获取邀请历史记录记录接口
 *  account my账号
 *
 **/
+(void)getMyFriendHistorytWithAccount:(NSString *)account  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *
 *  获取自己的好友列表
 *  synctime 同步时间  有值为增量 nil时为全量
 **/
+(void)getMyFriendWithAccount:(NSString *)account synctime:(NSString *)synctime  addRequest:(BOOL)addRequest didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *
 *  删除好友
 *  account 删除账号
 *  friendAccounts
 **/
+(void)deleteMyFriendWithAccount:(NSString *)account friendAccounts:(NSArray *)friendAccounts didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *
 *  搜索用户
 *  account 账号
 *  keyword 关键词
 *  pageSize 每页显示多少条，默认10条
 *  currentPage 当前页数
 **/
+(void)searchUserInfoWithAccount:(NSString *)account KeyWord:(NSString *)keyword PageSize:(NSInteger)pageSize CurrentPage:(NSInteger)currentPage didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 查询消息已读状态
 
 @param type       0 未读 1已读
 @param msgId      消息id
 @param pageSize   每页数量
 @param pageNo     页数
 @param completion block返回值
 */
- (void)queryMessageReadStatus:(NSInteger)type
                         msgId:(NSString*)msgId
                      pageSize:(NSInteger)pageSize
                        pageNo:(NSInteger)pageNo
                    completion:(void (^)(NSString *err,NSArray *array,NSInteger totalSize))completion;
/**
 发送请求
 **/
+ (void)requestWithPath:(NSString *)path body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

+ (void)requestWithPathAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 *
 * 获取线下终端会议室
 * account 唯一标识
 *
 **/
+ (void)getOfflineRoomsWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/*
 * 获取加密文件的key请求*
 * account 唯一标识
 * fileNodeId 文件的uuid
 * 应答:"fileKey": "5192ea4082a624f4a1ec78bbcc"
 **/

+(void)getKeyByFileNodeIdWithAccount:(NSString *)account withNodeId:(NSString *)fileNodeId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  获取红包签名
 *  account 账号
 */
+ (void)getRedpacketSignWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


-(NSString *)md5PassWord:(NSString *)passWord;

//急速打卡的接口
/**
 *  account 用户账号
 *  addrename 打卡地点名称
 *  longitude  经度
 *  fdimension 维度
 *  altitude   海拔高度
 *  device_type 打卡设备,1: Android Phone 2: iPhone  10: iPad  11: Android Pad  20: PC  (Just Allowed phone 2 PC(Pad) login) 21: HTML5 WEBSOCKET 22:MAC 30:安卓座机;10以下是手机类型；10以上，20以下，是pad类型；20以上，30以下，是主机类型
 *  deviceuuid  设备唯一标志
 *  orgId  所属组织id
 *  wifimac  wifimac
 *  wifissid
 */

+ (void) speedPunchWithAccount:(NSString *)account withAddressName:(NSString *)addrename withLongitude:(double)longitude withFdimension:(double)fdimension altitude:(double)altitude orgId:(NSInteger)orgId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 *  获取应用列表
 compId 必选  String 企业id
 account 必选 String 统一账号
 type 必选 String 请求类型 1.表示已安装2.表示所有应用
 currentPage 必须 String 当前页 
 pageSize 必须 String 条数
 */
+ (void)getApps:(NSString *)account type:(NSString*)type compId:(NSString*)compId currentPage:(int) currentPage pagesize:(int) pagesize didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 *  安装删除app
 compId 必选 String 企业id
 account 必选 String 统一账号
 appId 必须 int 应用id
 type 必选 String 请求类型 1.表示安装2.表示卸载
 */
+ (void)installApps:(NSString *)account compId:(NSString *)compId type:(NSString*)type appId:(NSString*)appId  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 *  自定义url
 *  path url
 *  isNeed 是否需要鉴权
 *  finish  成功
 *  fail   失败
 */
+ (void)requestWithCustomPathAtAuthorization:(NSString *)path body:(NSDictionary *)body isNeedAuthor:(BOOL)isNeed didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  获取自己已经安装的应用列表
 compId 必选  String 企业id
 account 必选 String 统一账号
 */
+ (void)getMyApps:(NSString *)account compId:(NSString*)compId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 *  华勤获取IDToken
 path 必选  请求路径
 body必选 请求参数
 */
-(void)requestGetIdToken:(NSString *)path authStr:(NSString *)authStr body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 批量获取用户头像

 @param useraccList account数组
 @param isSimpUseracc 缺省0 返回完整useracc，1 同应用返回userName
 */
- (void)getUserAvatarListByUseraccList:(NSArray *)useraccList type:(NSString *)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 @brief 扫一扫加入群 add by keven.
 @param confirm 1:不需要同意直接入群
 @param declared  传fromQRCode:这个字段会在 sdk的回调里返回  用作区分是通过二维码还是普通的邀请加群
 @param groupId  群id
 @param members  传被邀请人account数组
 @param userName  群主账号
 */
- (void)joinGroupChatWithConfirm :(NSInteger)confirm  Declared:(NSString *)declared GroupId:(NSString *)groupId Members:(NSArray*)members UserName :(NSString *)userName  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 获取已读未读数量

 @param msgId 消息id
 @param version 消息版本号msgId和version传一个即可 都传以version为准
 @param type 类型 1.已读 2.未读
 @param userName 用户账号
 @param isReturnList 是否获取人员列表 1-是；2-否
 */
- (void)getMessageReceiptByMsgId:(NSString *)msgId version:(NSString *)version type:(NSString *)type userName:(NSString *)userName isReturnList:(NSString *)isReturnList didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
    
    
/**
 获取已读未读数量
 
 @param msgId 消息id
 @param version 消息版本号msgId和version传一个即可 都传以version为准
 @param type 类型 1.已读 2.未读
 @param userName 用户账号
 @param isReturnList 是否获取人员列表 1-是；2-否
 @param
*/
- (void)getMessageReceiptByMsgId:(NSString *)msgId version:(NSString *)version type:(NSString *)type userName:(NSString *)userName isReturnList:(NSString *)isReturnList pageNo:(int)pageNo didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 变更---讨论组转群组  添加允许设置某人为群组创建者
 
 @param groupID 必选 群组ID
 @param groupName 必选 群组名字最长为50个字符
 @param declared 可选 群组公告最长为200个字符
 @param permission 可选 申请加入模式 0：默认直接加入1：需要身份验证 2：私人群组缺省0
 @param groupDomain 可选 用户扩展字段
 @param userName 可选 自定义账号（自定义登录方式需传此参数并且应用ID不能为空），当 subAccountSid参数为空时生效
 @param uesracc 可选 群员唯一标识，如果传入则设置该群员为群组创建者
 @param finish 回调
 @param fail 失败
 */
-(void)ModifyGroupAndMemberRoleWithGroupId:(NSString *)groupID withGroupName:(NSString *)groupName withDeclared:(NSString *)declared withPermission:(NSString *)permission withGroupDomain:(NSString *)groupDomain withUserName:(NSString *)userName withUseracc:(NSString *)useracc didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 设置消息免打扰
 
 @param userAccount 用户账号
 @param state 状态 1开清静音，2，关闭静音
 @param type 状态   1开启静音  2关闭静音
 */
-(void)setMsgRuleUserAccount:(NSString *)userAccount withState:(NSString *)state withType:(NSString *)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 获取设置静音的装填
 
 @param account 用户账号
 @param finish 成功回调
 @param fail 失败回调
 */
-(void)getMsgMuteWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 获取通讯录

 @param deptId 部门ID,获取人员时部门ID为必选
 @param level 获取通讯录级别 ：0—企业、1—部门、2—人员
 @param isBig 是否是大通讯录 0—不是  1—是
 */
- (void)getLargeCompanyAddressByDeptId:(NSString *)deptId level:(NSString *)level isBig:(NSString *)isBig didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 搜索联系人

 @param searchValue 搜索值
 @param page 页码 从0开始
 @param pageSize 页大小 默认20
 */
- (void)getLargeSearchFriendBySearchValue:(NSString *)searchValue page:(NSInteger)page pageSize:(NSInteger)pageSize didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

#pragma mark - 设备安全
/**
 @brief 安全登录接口 add by keven
 @param loginName 客户端登录账号
 @param cipherCode  用户密钥（MD5小写密码）
 @param macAddr  当前设备唯一标识
 */
- (void)safeLoginInEquipmentLockWithLoginName:(NSString*)loginName cipherCode:(NSString *)cipherCode macAddr:(NSString *)macAddr didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
/**
 @brief 开启/取消设备锁账号 add by keven
 @param account 开启/取消设备锁账号
 @param status  设备锁状态 0：取消 1：开启
 */
- (void)setEquipmentLockWithAccount:(NSString*)account Status:(int)status didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 @brief 获取短信验证码 add by keven
 @param phoneNum 手机号
 */
- (void)getSMSInEquipmentLockWithPhoneNum:(NSString*)phoneNum didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 @brief 查询受信任设备列表 add by keven
 @param account account
 */
- (void)getTrustedEquipmentListWithAccount:(NSString*)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 @brief 移动端确认PC安全登陆接口
 @param uuid
 */
- (void)confirmLoginWithAccount:(NSString*)account uuid:(NSString *)uuid didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 @brief 删除受信任设备
 */
- (void)delTrustedEquipmentWithAccount:(NSString*)account macAddr:(NSString *)macAddr didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 @brief 通过短信验证码绑定手机号
 */
- (void)bindPhoneBySMSWithAccount:(NSString*)account phoneNum:(NSString *)phoneNum smsCode:(NSString *)smsCode didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 @brief 短信绑定设备接口完成设备绑定后SafeServer直接返回登录信息，客户端完成登陆功能
 @param phoneNum 手机号
 @param smsCode 短信验证码
 @param macAddr 当前设备唯一标识
 @param name 设备名称（例如：Chan's iPhone）
 @param type 1:Android、2：iOS、3：H5、4：pc 5：mac
 */
- (void)bindEquipmentAndLoginInEquipmentWithphoneNum:(NSString *)phoneNum smsCode:(NSString *)smsCode macAddr:(NSString *)macAddr name:(NSString *)name type:(int)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;



/**
 一键创群

 @param depart_id 部门id
 @param is_full 是否遍历子部门
 @param finish 成功回调
 @param fail 失败回调
 */
- (void)createGroupMethodByDepart_id:(NSString *)depart_id is_full:(NSString *)is_full didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

/**
 取消或订阅在线状态
 
 @param account 订阅人账号
 @param type 0：订阅（默认），1：取消订阅
 @param eventType 事件类型，固定设置为1，即 eventType=1
 @param publisherUserAccs 被订阅人的账号列表，最多100个账号,示例：["pub_user1","pub_user2"]
 
 */
- (void)subscribeModifyByAccount:(NSString *)account type:(NSString *)type eventType:(NSString *)eventType publisherUserAccs:(NSArray *)publisherUserAccs didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
@end
