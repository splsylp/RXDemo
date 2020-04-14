//
//  Created by wangming on 16/7/18.
//  Copyright © 2016年 ronglian. All rights reserved.

#ifndef KX3_KCConstants_API_h
#define KX3_KCConstants_API_h

//https http
#define kHttpSAndHttp  1

#if kHttpSAndHttp

#define kRX_PORT 7773
#define kFriednclePORT 9093

#else

#define kRX_PORT 7772
#define kFriednclePORT 9093

#endif

#define kRequestHttp  [Common sharedInstance].httpType
#define kPORT [Common sharedInstance].port

//add by keven.
//设备安全相关接口模块所需配置 41环境用http 固定端口17772
#define kHttpSAndHttpInDeviceSafe  0

#if kHttpSAndHttpInDeviceSafe

#define kRequestHttpInDeviceSafe @"https"
#define kPORTInDeviceSafe 17772

#else

#define kRequestHttpInDeviceSafe  @"http"
#define kPORTInDeviceSafe 17772

#endif
//end

/**
 * PBS开关 0关 1开
 */
#define kPBSSwitch 1

/**
 * PBS地址切换开关 0关 1开
 */
#define kSwitchPBSURL 1

/**
 * 海尔COSMO 0关 1开
 */
#define isCOSMO 1


/**
 * 环境切换
 **/

#define KHostURL 4 //环境开关


#if    KHostURL == 1            //外网演示环境

#define kRX_HOST  @"124.206.192.46"//@"101.201.117.151"
//#define kHOST @"124.206.192.46"
//#define kHOST @"10.0.138.109" //万科POC

#elif  KHostURL == 2            //内网测试环境

//#define kHOST  @"192.168.179.193"
//#define kRX_HOST @"124.206.192.41"
//#define kHOST  @"118.194.243.239"
//#define kHOST  @"192.168.179.192"
#define kHOST  @"47.105.129.198"

#elif  KHostURL == 3            //项目POC环境

//#define kHOST  @"10.72.8.11"//天润项目

//#define kHOST  @"123.57.204.169"
#define kRX_HOST  @"hcquat.huaqin.com"//上海华勤域名
//#define kHOST  @"120.136.169.37" //上海华勤
//#define kHOST  @"47.104.160.251"   //南京炬塔
//#define kHOST  @"192.168.10.100"   //人资项目
#elif  KHostURL == 4
//#define kHOST @"124.206.192.46" // 192.168.179.194 的映射

#define kRX_HOST @"118.89.218.99"
//#define kRX_HOST @"192.168.27.101"
 // 192.168.179.194 的映射
//#define kHOST @"20.124.163.80"  // 南宁公安环境
//
//#define kHOST @"192.168.8.240"
//#define kRX_HOST @"192.168.27.239"

//#define kHOST @"172.16.8.176"

///大通讯录环境
//#define kHOST @"192.168.27.239"
//#define kHOST @"124.206.192.41"

#endif

#define kHOST [Common sharedInstance].host

#define NewRequestUrl   [NSString stringWithFormat:@"%@://%@:%d",kRequestHttp,kHOST,kPORT]
#define kProxyServer    [NSString stringWithFormat:@"https://%@:%d",kHOST,7778]

#define kShareConfUrl   [NSString stringWithFormat:@"http://%@:9073/conference-portal-site/webConf/join.html?confId=",kHOST]
#define kShareUrl       [NSString stringWithFormat:@"http://%@:9073/conference-portal-site/webConf/down.html",kHOST]
#define kUserProtocol   [NSString stringWithFormat:@"http://%@:9073/conference-portal-site/webConf/serviceTerms.html",kHOST]


/**
 *
 * 应用相关配置
 *
 **/

//后台传回的容联云的appid和apptoken
#define kAPI_APPKEY     [RXUser sharedInstance]appid]
#define kAPI_APPTOKEN   [RXUser sharedInstance]apptoken]
//分享相关
#define kUMAppKey       @"55c9a952e0f55a4753003105" // app的友盟appKey，此appKey从友盟网站获取
//容信基线专用微信分享的id  项目请单独申请
#define kWXAppID        @"wx095731ccfdca64a1" //微信分享key  wx609ffabe65a10c8f
#define kWXAppSecret    @"fee067d9d42995bbf5d84fbc8d864e75" //  ed38936dbf8c3f878a6986f94c4e7f10
#define kRXShareUrl     @"http://123.57.204.169:9999/filedown/web/rx/rongxin.html" //恒信分享的URL

/**
 *
 * api
 *
 **/
#define KPathStringCheckIP  [NSString stringWithFormat:@"http://%@:8081/Public/checkUser?u=",kHOST]//审批


#define kAPI_Auth @"/ClientAuth" // 注册、登录
//#define kAPI_Feedback @"/FeedBack/%@" // 意见反馈
#define kAPI_Feedback @"/FeedBack" // 意见反馈
#define kAPI_CheckVersion @"/GetVersion" // 版本更新
#define kAPI_ModifiPassword @"/UpdatePwd" //更新密码
#define KAPI_GETSMS @"/GetAuthSMS" // 获取短信验证码
//#define kAPI_SetUserInfo @"/SetUserInfo/%@" //设置用户信息请求
#define kAPI_SetUserInfo @"/SetUserInfo" //设置用户信息请求
//#define kAPI_GetVOIPUserInfo @"/GetVOIPUserInfo/%@" //获取VOIP用户信息请求
#define kAPI_GetVOIPUserInfo @"/GetVOIPUserInfo" //获取VOIP用户信息请求
#define kAPI_GetPrivilegeRule @"/personLevel/findPersonLevel" //获取权限规则
#define kAPI_GetAllDepartInfo @"/common/compcontact/getAllDepartInfo" //获取企业下所有部门

#define kAPI_DownloadCOMAddBook @"/DownloadCOMAddBook/%@" //下载企业通讯录
#define kAPI_GETCOMAddBook @"/GetAllUserInfo" //下载企业通讯录
#define kAPI_ConfirmInvit @"/ConfirmInvit/%@" //申请加入企业
#define kAPI_GetComStatus @"/GetComStatus/%@" //获取企业状态
#define kAPI_BackupContacts @"/BackupContacts/%@" //备份通讯录
#define kAPI_DownloadContacts @"/DownloadContacts/%@" //恢复通讯录
#define kAPI_SpecialServiceUrl @"/common/attention/addOrDelAttentions"//增加取消特别关注地址
#define kAPI_GetSpecialServiceUrl @"/common/attention/getToAttentions" //获取特别关注地址

#define KAPI_GetImageCode  @"/common/login/getImgCode"  //获取图片验证码
#define KAPI_VerfyJWTTokenAndGetLoginData @"/common/login/verifyJWTTokenAndGetLoginData"//校验jwttoken 并获取登陆状态

#define KAPI_SetDisturb @"IM/SetDisturb" //设置消息免打扰
#define KAPT_SetMsgMute @"/IM/SetMsgMute" //设置静音接口
#define KAPT_GetMsgMute @"/IM/GetMsgMute" //获取静音状态接口

//好友功能

#define KAPI_ADDNewFrien @"/friend/addFriend" //添加好友

#define KAPI_GetFriendInviteRecord  @"/getAddFriendHistoryt"//获取邀请记录

#define KAPI_GetMyFriend  @"/friend/getFriends" //获取自己的好友列表

#define KAPI_DeleteMyFriend @"/friend/delFriends"//删除好友

#define KAPI_SearchUser @"/common/userInfo/searchUserInfo" //搜索用户

#define KAPI_GetOfflineRooms  @"/common/coo/getOfflineRooms"  //获取线下终端会议室

#define kAPI_Join_group @"/IM/Group/InviteJoinGroup" //扫一扫加入群
#define KAPI_ModifyGroupAndMemberRole @"/IM/Group/ModifyGroupAndMemberRole"//变更---讨论组转群组  添加允许设置某人为群组创建者
//文件加密处理

#define  KAPI_File_getNodelIdAndKey  @"/netDisk/getFileNodeIdAndKey" //获取加密文件uuid和key
#define  KAPI_File_getKeyByNodeId    @"/netDisk/getKeyByFileNodeId"  //获取解密文件的秘钥

//人脸识别

#define  KAPI_LevenessFace      @"/common/login/regFace"

#define  KAPI_LevenessRegister @"/  e"

#define kAPI_GETNetDistQuery @"/NetDiskQuery" //查询网盘文件列表
#define kAPI_GetRedpacketSign @"/redPacket/getRedPacketSign"  //获取红包签名

//朋友圈
#define kAPI_sendSportMeet @"/fc1/send/" //发送运动会消息
#define kAPI_GETSportMeet @"/fc1/getFCList/" //获取运动会消息
#define kAPI_GETFC @"/fc1/getFC/"
#define kAPI_Reply @"/fc1/c/" //评论
#define kAPI_CancelReply @"/fc1/c/d/" //删除评论
#define kAPI_Favour @"/fc1/p/" //点赞
#define kAPI_CancelFavour @"/fc1/p/d/" //取消点赞
#define kAPI_getRepliesAndFavors @"/fc1/getpc/" //获取评论和点赞
#define kAPI_deleteFCMsg @"/fc1/d/" //删除同事圈
#define KAPI_getFCMyList @"/fc1/getFCFriendList/" //获取某个人所有的同事圈

#define FRIENDGROUPURL  @"friendGroupUrl"

#define KAPI_AddCollect @"/common/collect/addCollect" //增加收藏内容
#define KAPI_DelCollect @"/common/collect/delCollect" //删除收藏内容
#define KAPI_GetCollects @"/common/collect/getCollects" //获取收藏


//服务号 相关请求
#define KAPI_GetMyAttPublicNum @"/pn/getPNFList/"//获取已关注公众号列表
#define KAPI_GetPublicUrl @"/pn/getPN/" //根据公众号id,获取公众号相关数据
#define KAPI_GetSearchPublicUrl @"/pn/getPNList/"//获取搜索数据
#define KAPI_PUBLICTOTOPAPI @"/pn/t/" //公众号置顶
#define KAPI_PUBLICCANCELTOP @"/pn/t/d/" //取消公众号置顶
#define KAPI_ATttPublicNum @"/pn/f/" //关注公众号
#define KAPI_DeleteMyAttPublicNum @"/pn/f/d/" //取消关注的公众号
#define KAPI_GETHISTORYMESSAGELIST @"/pn/getPNMHistoryList/" //获取公众号历史消息
#define KAPI_PUBLICMENUMESSAGE @"/pn/getPNmsg/" //获取菜单中的消息

//急速打卡

#define KAPI_SpeedPunchUrl     [NSString stringWithFormat:@"http://%@:%d/webhtml/asi/jsdkadd",kHOST,9092]


//应用商店
#define kAPI_GetApps @"/common/appstore/getAllApps" // 应用商店获取所有应用列表
#define kAPI_GetMyApps @"/common/appstore/getMyApps" // 获取已经安装的应用列表
#define kAPI_InstallApps @"/common/appstore/installApps" //增加、删除应用

//banner图接口

#define KAPI_GetBanners  @"/common/appstore/getAppStoreBanners"

//大通讯录模式相关
#define kAPI_GetLargeAddressBook @"/common/compcontact/getUserInfo" //获取通讯录
#define kAPI_GetLargeSearchFriend @"/friend/searchFriend"//搜索好友


//设备锁安全
#define kSetEquipmentLock @"/common/safeSec/setEquipmentLock/" //开启/取消设备锁账号
#define kGetSMSInEquipmentLock @"/common/sms/getSMS/" //获取短信验证码
#define kBindPhoneBySMS @"/common/safeSec/bindPhoneBySMS/"//通过短信验证码绑定手机号
#define kGetTrustedEquipmentList @"/common/safeSec/getTrustedEquipmentList/"//查询受信任设备列表
#define kDelTrustedEquipment @"/common/safeSec/delTrustedEquipment/"//删除受信任设备
#define kSafeLoginInEquipment @"/common/login/safeLogin"//登录接口
#define kbindEquipmentAndLoginInEquipment @"/common/login/bindEquipment"//新设备受信任绑定接口并登录
#define kConfirmLoginForPCInEquipment @"/common/login/confirmLogin/"//移动端确认PC安全登陆接口
///一键创群
#define KAPI_CreateGroupMethod @"/common/group/createGroupMethod"
//取消或订阅在线状态
#define KAPI_SubscribeState @"/IM/Subscribe/Modify"

#endif
