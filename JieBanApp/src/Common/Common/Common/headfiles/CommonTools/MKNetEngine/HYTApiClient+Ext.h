//
//  HYTApiClient+Ext.h
//  HIYUNTON
//
//  Created by yuxuanpeng MINA on 14-10-11.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "HYTApiClient.h"
//所以网络请求的接口
typedef void (^didFinishLoadedMK)(NSDictionary *json, NSString *path);
typedef void (^didFailLoadedMK)(NSError *error, NSString *path);

@interface HYTApiClient (Ext)

/**
 *  错误信息
 *
 *  @param errorcode 错误
 *
 *  @return 错误信息
 */
+(void)showErrorDomain:(NSError *)errorDomain;

/**
 *  处理错误信息
 *
 *  @param errorcode 错误码
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
 HTTP请求

 @param path   url
 @param body   包体
 @param finish 返回值
 @param fail   失败回执
 */
+ (void)requestWithPathAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *  登录
 *
 *  @param mobile     手机号码
 *  @param verifyCode 验证码
 *  @param pwd        密码
 *  @param type       类型 1:手机号作为账号 3:账号登陆 account
 */
+ (void)userLoginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd userType:(int)type withCodeKey:(NSString *)codeKey imgCode:(NSString *)imgCode didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

+ (void)userLoginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd userType:(int)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  注册
 *
 *  @param mobile     手机号码
 *  @param verifyCode 验证码
 *  @param pwd        密码
 */
+ (void)userRegisterWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  找回密码
 *
 *  获取短信验证码
 *  @param mobile     手机账号
 */
+ (void)sendSMSVerifyCodeWithMobile:(NSString *)mobile withFlag:(NSString *)flag didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  找回密码
 *
 *  获取语音验证码
 *  @param mobile     手机账号
 */
+ (void)sendTelVerifyCodeWithMobile:(NSString *)mobile withFlag:(NSString *)flag didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  找回密码
 *
 *  获取邮箱验证码
 *  @param mobile     账号
 */
+(void)sendEmailVerifyCodeWithAccount:(NSString *)account withFlag:(int)flag codeKey:(NSString *)codeKey imgCode:(NSString *)imgCode didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  找回密码
 *
 *  @param mobile     手机号码 或者账号
 *  @param newpwd     新密码
 *  @param verifyCode 短信验证码
 *  @param finish
 *  @param fail
 */
+ (void)findPasswordWithMobile:(NSString *)mobile newpwd:(NSString *)newpwd verifyCode:(NSString *)verifyCode didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 * 验证验证码
 *
 * @param account 账号
 * @parma code  验证码
 **/
+ (void)checkSMSVerifyCodeWithAccount:(NSString *)account verifyCode:(NSString *)code didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  修改密码
 *
 *  @param auth   短信验证码
 *  @param newpwd 新密码
 */
+ (void)updatePasswordWithMobile:(NSString *)mobile auth:(NSString *)auth newpwd:(NSString *)newpwd type:(NSString*)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

+ (void)feedBackWithMobile:(NSString *)mobile feedback:(NSString *)feedback didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

+ (void)checkVersionWithMobile:(NSString *)mobile didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  设置用户信息
 *
 *  @param nickName  昵称
 *  @param photo     头像
 *  @param signature 联系人个性签名
 */
+ (void)updateUserInfo:(NSString *)mobile nickName:(NSString *)nickName photo:(UIImage *)photo signature:(NSString *)signature didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  获取VOIP用户信息
 *
 *  @param mobile  电话号码 或者为voip号码
 *  @param type     0   mobilenum 为电话号码 1   mobilenum为voip号码  2  mobilenum 为account(唯一标识值)
 */
+ (void)getVOIPUserInfoWithMobile:(NSString *)mobile type:(NSString*)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
+ (void)getVOIPUserInfoWithMobile:(NSString *)mobile number:(NSArray*)number type:(NSString*)type  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  下载企业通讯录
 *
 *  @param mobile 手机号码
 */
+ (void)downloadCOMAddressBookWithMobile:(NSString *)mobile didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *
 * 下载企业通讯录文件text
 *
 */
+(void)downloadComTextWithUrl:(NSString *)textUrl didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  申请加入企业
 *
 *  @param mobile
 */
+ (void)confirmInvitWithMobile:(NSString *)mobile companyid:(NSString *)companyid didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  获取企业审核状态
 *
 *  @param mobile
 */
+ (void)confirmInvitStatusWithMobile:(NSString *)mobile  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  备份联系人
 *
 *  @param mobile
 */
+ (void)backupContactsWithMobile:(NSString *)mobile path:(NSString *)path didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  恢复联系人
 *
 *  @param mobile
 */
+ (void)downloadContactssWithMobile:(NSString *)mobile didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  查询网盘文件
 *
 *      type	必选	String	业务类型	1 个人文档 2 群组文档 3 组织部门文档 4共享文档
 *      queryid	必选	String	查询关键字	用户帐号、群组ID、部门ID等
 *      mobile	必须	String	查询者	13066665555
 */
+ (void)getNetDistWithMobile:(NSString *)mobile queryid:(NSString*)queryid type:(NSString*)type  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

//上传附件 将文件名字和图片传进来 或者传递图片数据
+ (void)uploadPhoWithFileName:(NSString *)fileName photo:(UIImage *)photo withImageData:(NSData *)imageData fileData:(NSData *)fileData fileType:(NSString *)fileType didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

//上传附件 将文件名字和图片传进来 或者传递图片数据
+ (void)uploadPhoWithFileName:(NSString *)fileName photo:(UIImage *)photo withImageData:(NSData *)imageData fileData:(NSData *)fileData fileType:(NSString *)fileType withImageType:(NSInteger)imageType didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

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
                 didFinishLoadedMK:(didFinishLoadedMK)finish
                   didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  运动会 恒信 获取消息
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @content 内容
 *  @limit 获取个数 默认是5条
 *  @domain 运动会期间{“msgType”:””, “item”:””,“status”:”” }，1你我看点，2场外之声，3精彩回放，4战绩快报
 *  @version 开始的版本号，默认为空，从第一条开始
 */

+ (void)getSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version withLimit:(int )limit withDomain:(NSDictionary *)domain didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  运动会 恒信 获取单条消息
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 开始的版本号，默认为空，从第一条开始
 */
+ (void)getSingleSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  获取某个人的所有同事圈
 *  @sig MD5(account+passWord)
 *  @account 自己账号
 *  @friendAccount 朋友的账号
 *  @limit 获取个数 默认是10条
 *  @domain 自定义json字段
 *  @msgId 开始的版本号，默认为空，从第一条开始
 */

+ (void)getFCMyListMessageSig:(NSString *)sig withAccout:(NSString*)account withMsgId:(NSString *)msgId withLimit:(int)limit withDomain:(NSDictionary *)domain didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  删除同事圈
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 */
+ (void)deleteFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  获取所有评论和点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 *  @flag    0 全部， 1 赞，2评论   默认值0
 */
+ (void)getRepliesAndFavorsWithFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version withFlag:(int)flag didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  同事圈评论
 *  @sig MD5(account+passWord)
 *  @account 自己账号
 *  @rAccount 回复对方的帐号
 *  @version 同事圈消息版本号
 *  @content 评论内容
 */
+ (void)replyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyAccount:(NSString *)rAccount withVersion:(NSString *)version withContent:(NSString *)content didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  同事圈点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 */
+ (void)favourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  取消同事圈评论
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @replyId 评论消息ID
 */
+ (void)cancelReplyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyId:(NSString *)replyId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
/**
 *  取消同事圈点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 */
+ (void)cancelFavourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  特别关注
 *  取消或者添加特别关注
 *   type 0.增加 1.删除
 *  attectionAccounts 关注的账号
 */
+ (void)selectSpecialAccount:(NSArray *)attectionAccounts type:(int)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  特别关注
 *  获取自己关注的账号
 *  自己的账号
 */

+ (void)getAllSpecialAtt:(NSString *)account withAddRequest:(BOOL)addRequest didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

//-------公众号


/**
 * 公众号置顶功能
 * sig鉴权字段 account+client
 * account 获取账号
 * pnId 获取的公众号信息
 *
 *
 ***/

+ (void)settingPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 * 公众号取消置顶功能
 * sig鉴权字段 account+client
 * account 获取账号
 * pnId 获取的公众号信息
 *
 *
 ***/
+ (void)cancelPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 * 获取公众号历史记录
 * sig鉴权字段 account+userpassword
 * account 获取账号
 * pnId 获取的公众号信息
 * msgSendId 可选 发送消息记录Id 默认为0 此值从缓存中取，取最小值，无缓存置0；
 值为0时，取最新消息
 * limit 可选 默认10 获取消息条数
 **/
+(void)getPublicHistroyDataSig:(NSString *)sig account:(NSString *)account publicId:(int )pnId msgSendId:(int)msgSendId limit:(int)limit didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 * 获取公众号信息
 * sig Md5(account + userpwd)
 * account 账号
 * pnid 公众号
 * utime 
 */
+(void)getPublicInfoDataSig:(NSString *)sig account:(NSString*)account publicId:(NSString *)pnId utime:(long long )utime didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *
 *  公众号搜索
 *  account 账号
 *  lPnId 本轮查询中的上次返回数据中最大pn_id
 *  limit 一次获取多少条公众号信息，默认20
 **/
+(void)getPublicSearchDataSig:(NSString *)sig account:(NSString*)account searchStr:(NSString *)searchString publicId:(NSInteger )ipnId limit:(NSInteger)limit didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *
 *  关注公众号
 *  account 账号
 *  pnid 公众号Id
 **/
+(void)attentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *
 *  取消公众号
 *  account 账号
 *  pnid 公众号Id
 **/
+(void)cancelAttentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *
 *  获取已关注的公众号
 *  account 账号
 **/
+(void)getMyAttentionPublicSig:(NSString *)sig account:(NSString*)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *
 *  获取菜单中的消息
 *  account 账号
 *  pnId  公众号ID
 *  msg_id 消息id
 *  sig 鉴权
 **/

+(void)getPublicMenuMessage:(NSString *)sig account:(NSString*)account msg_id:(NSString *)msgId publicId:(NSInteger )pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;



//-----好友
/**
 *
 *  添加好友
 *  type 0/1/2 邀请/接受/拒绝
 *  account 好友account 唯一标示
 *  0/1/2 邀请/接受/拒绝 邀请描述内容
 *
 **/
+(void)addNewFriendAccount:(NSString *)userAccount inviteType:(NSInteger)inviteType descrContent:(NSString *)descrContent didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *
 *  获取邀请历史记录记录接口
 *  account my账号
 *
 **/
+(void)getMyFriendHistorytWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *
 *  获取自己的好友列表
 *  synctime 同步时间  有值为增量 nil时为全量
 **/
+(void)getMyFriendWithAccount:(NSString *)account synctime:(NSString *)synctime  addRequest:(BOOL)addRequest didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *
 *  删除好友
 *  account 删除账号
 *  friendAccounts
 **/
+(void)deleteMyFriendWithAccount:(NSString *)account friendAccounts:(NSArray *)friendAccounts didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *
 *  搜索用户
 *  account 账号
 *  keyword 关键词
 *  pageSize 每页显示多少条，默认10条
 *  currentPage 当前页数
 **/
+(void)searchUserInfoWithAccount:(NSString *)account KeyWord:(NSString *)keyword PageSize:(NSInteger)pageSize CurrentPage:(NSInteger)currentPage didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;







/**
 *  增加收藏
 *  account 账号
 *  content 收藏内容
 *  url 附件url
 *  type  1,文本 ；2，图片；3，网页；4，语音；5，视频；6，图文
 */

+ (void)addCollectDataWithAccount:(NSString *)account fromAccount:(NSString *)fromAccount TxtContent:(NSString *)txtContent Url:(NSString *)url DataType:(NSString *)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  删除收藏
 *  account 账号
 *  collectIds 收藏id数组
 */

+ (void)deleteCollectDataWithAccount:(NSString *)account CollectIds:(NSArray *)collectIds didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *  获取收藏
 *  account 账号
 *  synctime 上次同步时间，为空则为全量
 *  collectId 收藏id
 */

+ (void)getCollectDataWithAccount:(NSString *)account Synctime:(NSString *)synctime CollectId:(NSString *)collectId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;






/**
 *  获取红包签名
 *  account 账号
 */

+ (void)getRedpacketSignWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;








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

+ (void)getHistoryMyChatMessageWithAccount:(NSString *)userName withAppid:(NSString *)appid version:(long long)version msgId:(NSString *)msgId pageSize:(NSInteger)pageSize talker:(NSString *)talker order:(NSInteger)order  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

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

+ (void)getHistoryGroupListMessageGroupId:(NSString *)groupId startTime:(NSString *)startTime endTime:(NSString *)endTime pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize msgDecompression:(NSString *)msgDecompression didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *
 * 获取图片验证码
 * uuid 自己生存32位 
 *
 *
 **/
+ (void)getLoginImageCodeWithUuid:(NSString *)uuid didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;


/**
 *
 * 获取线下终端会议室
 * account 唯一标识
 *
 **/
+ (void)getOfflineRoomsWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 *
 * 检查鉴权
 * account 唯一标识
 *
 **/
+ (void)checkAuthWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

/**
 获取邀请码
 **/
+ (void)getIpInfoWithDict:(NSDictionary*)dict  didFinishLoaded:(didFailLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;



/*获取加密文件uuid和key请求
 *account 唯一标识
 *应答
 * "fileNodeId": "43cf185192ea4082a624f4a1ec78bbcc",*
 " fileKey": "5192ea4082a624f4a1ec78bbcc"*
 */

+ (void)getFileNodelIdAndKeyWithAccount:(NSString *)account didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;

/*
 * 获取加密文件的key请求*
 * account 唯一标识
 * fileNodeId 文件的uuid
 * 应答:"fileKey": "5192ea4082a624f4a1ec78bbcc"
 **/

+(void)getKeyByFileNodeIdWithAccount:(NSString *)account withNodeId:(NSString *)fileNodeId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;

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
 **/

+ (void)speedPunchWithAccount:(NSString *)account withAddressName:(NSString *)addrename withLongitude:(double)longitude withFdimension:(double)fdimension altitude:(double)altitude orgId:(NSInteger)orgId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;

/**
 * account 用户标识
 * time 更新时间
 */
+(void)getBannersWithAccount:(NSString *)account withUpdateTime:(NSString *)time didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;



/**
 创建直播频道
 
 @param uid 用户ID
 @param name 频道名称
 */
+ (void)createChannelWithUid:(NSString *)uid Name:(NSString *)name didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;

/**
 创建直播频道
 
 @param uid 用户ID
 @param name  用户名
 @param  description 描述
 @param channelCover 频道名称
 */
+ (void)createChannelWithUid:(NSString *)uid Name:(NSString *)name  description:(NSString *)description channelCover:(NSString *)channelCover  didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;

/**
 获取推流地址
 
 @param uid 用户ID
 @param channelId 直播频道ID
 */
+ (void)getPushUrlsWithUid:(NSString *)uid ChannelId:(NSString *)channelId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;


/**
 获取直播频道列表
 
 @param status 频道状态(可选) 默认为ALL, 状态可以:”ALL”, "READY", "LIVEING", "NOSTREAM"，"STOPED", "BANNED", "UNBAN", "DELETE"
 @param uid 用户ID(可选)
 */
+ (void)getChannelListWithStatus:(NSString *)status Uid:(NSString *)uid PageNo:(NSInteger)pageNo PageSize:(NSInteger)pageSize didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;

/**
 获取播放地址
 
 @param uid 用户ID
 @param channelId 直播频道ID
 */
+ (void)getPlayUrlsWithUid:(NSString *)uid ChannelId:(NSString *)channelId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail;


#pragma mark - gy

//上传应用商店的文件 新增yuxp
/**
 post请求
 
 @param fileData 数据
 @param uploadUrl 上传文件地址
 @param fileName 文件名
 @param headDic 请求头
 @param bodyDic 现在并没有处理
 @param finish 完成
 @param fail 失败
 */
+ (void)upLoadStoreAppFile:(NSArray <NSData *>*)datas withUploadUrl:(NSString *)uploadUrl withHead:(NSDictionary *)headDic didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;

@end
