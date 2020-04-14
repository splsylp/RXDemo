//
//  KCConstants_string.h
//  KX3
//
//  Created by zhi peng on 12-11-14.
//  Copyright (c) 2012年 kaixin001. All rights reserved.
//

#ifndef KX3_KCConstants_string_h
#define KX3_KCConstants_string_h
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
// eagle代码混淆 debug不生效
#if DEBUG
#else

#import "YZcodeObfuscation.h"
#endif
#define  ISSTRING_ISSTRING(ISstr)  [NSString stringWithFormat:@"%@",ISstr]

//#define KitDEBUG

//#ifdef KitDEBUG              
//#   define DDLogInfo(fmt, ...) {DDLogInfo((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
//#else
//#   define DDLogInfo(...)
//#endif

//
//#ifdef __OPTIMIZE__
//# define DDLogInfo(...) {}
//#else
//# define DDLogInfo(...) DDLogInfo(__VA_ARGS__)
//#endif

/**
 *
 * 系统参数，UI布局参数等宏定义
 *
 **/


//判断当前语言
#define  isEnLocalization ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RL_languageKey"] isEqualToString:@"en"] || [[[NSUserDefaults standardUserDefaults]objectForKey:@"RL_languageKey"]hasPrefix:@"en"])?YES : NO

//定义屏幕的宽度和高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//按设备比例来拉伸当前视图的高度和宽
#define fitScreenWidth (kScreenWidth/320)
#define fitScreenHeight (kScreenHeight/568)

#define iPhone6FitScreenWidth (kScreenWidth/375)
#define iPhone6FitScreenHeight (kScreenHeight/667)

#define iPhone6plus (iOS7 && kScreenHeight == 736.0)
#define kOffsetHeight 64

#define iPhoneStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

// 判断是否是iPhone5
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)]\
? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)\
|| CGSizeEqualToSize(CGSizeMake(1136, 640), [[UIScreen mainScreen] currentMode].size) : NO)

//判断当前系统
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define iOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define iOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define iOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)
#define iOS13 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
#define isIPhoneX ([[UIScreen mainScreen] bounds].size.height == 812 || [[UIScreen mainScreen] bounds].size.height == 896)
#define IPhoneXBottomSpaceHeight  (isIPhoneX ? 34.0f : 0)  //iphoneX底部留出空白的高度

//状态栏+导航栏高度
#define kTotalBarHeight  (isIPhoneX ? 88 : 64)
// 底部高度
#define IphoneXBottom    (isIPhoneX ? 10 : 0)
#define IphoneXBottomHeight (isIPhoneX ? 34.0f : 0)
// tabBar高度
#define TAB_BAR_HEIGHT ((isIPhoneX ? (49.f+34.f) : 49.f) * FitThemeFont)
//状态栏高度
#define kMainStatusBarHeight  (isIPhoneX ? 44 : 20)

//设备屏幕frame
#define kMainScreenFrameRect                            [[UIScreen mainScreen] bounds]
//状态栏高度
#define kMainScreenStatusBarFrameRect                   [[UIApplication sharedApplication] statusBarFrame]
#define kMainScreenHeight                               kMainScreenFrameRect.size.height
#define kMainScreenWidth                                kMainScreenFrameRect.size.width
//减去状态栏和导航栏的高度
#define kScreenHeightNoStatusAndNoNaviBarHeight         (kMainScreenFrameRect.size.height - kMainScreenStatusBarFrameRect.size.height-44.0f)

//减去状态栏和底部菜单栏高度
#define kScreenHeightNoStatusAndNoTabBarHeight          (kMainScreenFrameRect.size.height - kMainScreenStatusBarFrameRect.size.height-49.0f)

//减去状态栏和底部菜单栏以及导航栏高度
#define kScreenHeightNoStatusAndNoTabBarNoNavBarHeight  (kMainScreenFrameRect.size.height - kMainScreenStatusBarFrameRect.size.height-49.0f - 44.0f)

//底部工具栏高度
#define kTabBarHeight               49

//导航栏高度
#define kNavBarHeight               44

//状态栏高度
#define kStatusBarHeight            20
#define kViewDown [AppModel sharedInstance].theViewDown // 通话中时候，聊天界面下压20

//颜色和透明度设置 都用的这个249, 178, 192, 1
#define RGBA(r,g,b,a)               [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]
// RGB颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ColorEFEFEF [UIColor colorWithRGB:0xEFEFEF]
#define Color66B243 [UIColor colorWithRGB:0x66B243]

#define APPMainUIColorHexString  @"#000000" //@"#48cb83" 之前的
#define APPMainUIColor [RXColorExChange colorWithHexString:APPMainUIColorHexString]
//#define KKThemeImage(pathName)  [UIImage imageNamed:pathName]
#define KKThemeImage(pathName)  [[AppModel sharedInstance] imageWithName:pathName]
#define KILocalization(key) [KILocalizationManager localizationWithKey:key]

//==================================================
// 主题颜色字体
//==================================================*/
#define MainTheme_ViewBackgroundColor [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f]
#define MainTheme_CellColor           [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f]
#define MainTheme_CellSelectedColor   [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f]
#define MainTheme_CellLineColor       [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.00f]
#define MainTheme_RedColor            [UIColor colorWithRed:0.82f green:0.09f blue:0.05f alpha:1.00f]//d1180d
#define MainTheme_YellowColor         [UIColor colorWithRed:0.97f green:0.74f blue:0.18f alpha:1.00f]//#f7bd2d
//#define MainTheme_GreenColor          [UIColor colorWithRed:0.48f green:0.66f blue:0.26f alpha:1.00f]//7aa843
#define MainTheme_GreenColor          [UIColor colorWithRed:54/255.0f green:155/255.0f blue:236/255.0f alpha:1.00f]//#369BEC
#define MainTheme_BrownColor          [UIColor colorWithRed:0.98f green:0.75f blue:0.23f alpha:1.00f]//#F9C03A
#define MainTheme_TextBlackColor      [UIColor colorWithRed:0.20f green:0.18f blue:0.18f alpha:1.00f]//332e2e
#define MainTheme_TextGrayColor       [UIColor colorWithRed:0.49f green:0.50f blue:0.49f alpha:1.00f]//7d7f7e
#define MainTheme_TextLightGrayColor  [UIColor colorWithRed:0.66f green:0.67f blue:0.69f alpha:1.00f]//a9acb1

//==================================================
//文件缓存信息
//==================================================*/
#define  cachefileUrl         @"fileUrl"   //远程URL 自己发的则是其他类型
#define  cacheFileLocatPath   @"cacheFileLocatPath" //本地缓存路径
#define  cacheimSissionId     @"imSissionId"  //IM标识
#define  cachefileDirectory   @"fileDirectory"  //目录
#define  cachefileIdentifer   @"fileIdentifer"  //文件标示
#define  cachefileDisparhName @"fileDisparhName" //文件名称
#define  cachefileExtension   @"fileExtension"  //扩展名
#define  cachefileSize         @"fileSize"
#define cachefileUuid         @"fileUuid"
#define cachefileKey          @"fileKey"

#define  cacheSelectIdentifer @"cacheSelectIdentifer" //选择标识

#define  cacheFileInfoKey   @"cacheFileInfoKey"

//整个应用文件缓存的目录
#define  YXP_FileCacheManager_CacheDirectoryOfDocument  @"YXPFileCache_DirectoryOfFile"


//主题颜色的设定
#define  kThemeSetting      @"kThemeSetting"
#define UrlSchema @"com.ronglian.rongxin4://"
#define ShareExtensionName @"group.ronglian.rongxin4.ShareExtension"
#define APP_ID @"1205101700"  //上架appStore的id
//公众号名字
#define isCreateCompanyName isHCQ? @"HCQ":@"容信"
#define APP_slogan           languageStringWithKey(@"暂未填写")
#define  APP_NAME           isHCQ? @"HCQ":@"容信"

#define kRXUserAuthtag @"RX_user_authtag"

/**
 *
 * 项目运行相关宏定义判断
 *
 **/
//第一次运行APP判断
#define kNotFirstRunAppKey @"first_run_app_version_key"
#define khaschangeIP @"haschangeIP"//是否切换过ip
//是否第一次登陆 需要验证码验证
#define isFirstLoginIntoMainViewController  @"isFirstLoginIntoMainViewController"

//登录设置个人信息 方便推送显示对应的名字
#define  isLoginSetPersonInfo @"isLoginSetPersonInfo"

/*恒丰项目1.3.0 更换项目代码是，3个字段定义发生变化，需要手动交换3个字段的值
 如果登录以后，就不需要交换
mobile 手机号
oaAccount  登录账号
account   rx开头的唯一标识
 */
#define isHaveExchangeLoginUserInfoSavePath @"isHaveExchangeLoginUserInfo"  //标识在本地的路径
#define isHaveExchangeLoginUserInfoIndex        @"hxchangeLoginUserInfo"                           //当前版本的，登录信息交换标识


//XML文件路径
#define kAPI_APPXMLPATH_CCPSDKBundle  @"CCPSDKBundle.bundle"
#define kAPI_APPXMLPATH_XML  @"ServerAddr.xml"
 
//图片缓存头像路径字段 和 数据库存储路径 区分不同项目的路径
#define kPathStringHeaderImage @"RongXinCurrUserImagePath.png"
#define KPathStringSqliteOther  @"RX3_App_Other.db"
#define KPathStringSqliteChat  @"RX3_App_chat.db"
#define KPathStringSqliteVoip  @"RX3_App_Voip.db"
#define KPathStringSqliteGroup @"RX3_App_group.db"

//群组头像缓存路径
#define NSCacheDirectory() [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define  ClearGroupHeadImagePath  @"HXClearGroupHeadImagePath"  //清空头像
//提示是否升级  取消后将不再提示
#define KNotification_NEWVERSION           @"KNotification_NEWVERSION"//新的版本下载
#define KNotification_NEWVERSIONUPDATE     @"KNotification_NEWVERSIONUPDATE" //新的版本号
#define KNotifcation_FORCEUPDATE            @"KNotifcation_FORCEUPDATE" //更新类型0/1/2 不更新/非强制/强制
#define KNotifcation_UPDATEDESCRITION       @"KNotifcation_UPDATEDESCRITION" //更新描述
#define KNotification_UPDATEAPPURL           @"KNotification_UPDATEAPPURL"//强制更新地址

#define VERSION_ALERTVIEW_TAG 8000





/**
 *
 * 数据库等字段定义
 *
 **/
#define App_AppKey         @"App_AppKey"         //应用Id
#define App_Token          @"App_Token"          //应用令牌
#define App_Clientpwd      @"RX_clientpwd_key"
#define App_Resthost        @"App_Resthost"
#define App_LvsArray        @"App_lvsArray"
#define App_boardUrl        @"App_boardUrl"
#define APP_CooAppId        @"APP_CooAppId"

#define APP_VidyoRoomUrl    @"APP_VidyoRoomUrl"
#define Vidyo_VidyoEntityID @"Vidyo_VidyoEntityID"
#define Vidyo_VidyoRoomID   @"Vidyo_VidyoRoomID"
#define Vidyo_VidyoFQDN     @"Vidyo_VidyoFQDN"
#define Vidyo_VidyoConfExten  @"Vidyo_VidyoConfExten"
#define Vidyo_ConfNum_regex @"Vidyo_ConfNum_regex"

//白板相关 USERID PASSWORD BOARDTYPE SENDIM ROOMID
#define USERID      @"userid"       //用户ID
#define PASSWORD    @"CO_ROOM_PASSWORD"     //房间密码
#define ROOMTYPE    @"roomtype"     //房间类型(临时或永久)
#define BOARDTYPE   @"boardtype"    //进入的类型
#define USERS       @"users"        //房间的所有人员
#define ROOMID      @"CO_ROOM_ID"       //房间ID
#define SENDIM      @"sengIM"       //是否发送IM
#define SUBMITDOC   @"submitDoc"    //上传的文档
#define BOARDURL @"CO_ROOM_SERVER"
#define SendIMWhenExit    @"sendIMWhenExit"     //判断是否是通知过来的加入
#define NOTIFLAG    @"notiFlag"     //判断是否是通知过来的加入
#define ISPRESENT   @"isPresent"
#define DEVICETYPE  @"deviceType"   //设备类型
#define ISCREATER    @"isCreater"     //是创建者
#define PREVIEWMODE @"previewMode"  //是否默认预览模式




//==================================================
//文件缓存信息
//==================================================*/
#define  cachefileUrl         @"fileUrl"   //远程URL 自己发的则是其他类型
#define  cacheFileLocatPath   @"cacheFileLocatPath" //本地缓存路径
#define  cacheFileAppStoreFilePath         @"AppStoreSaveFilePath" //应用缓存路径
#define  cacheimSissionId     @"imSissionId"  //IM标识
#define  cachefileDirectory   @"fileDirectory"  //目录
#define  cachefileIdentifer   @"fileIdentifer"  //文件标示
#define  cachefileDisparhName @"fileDisparhName" //文件名称
#define  cachefileExtension   @"fileExtension"  //扩展名
#define  cachefileSize         @"fileSize"      //文件大小
#define  cachefileUuid        @"fileUuid"      //文件uuid
#define  cachefileKey         @"fileKey"       //文件加密key

#define  cacheSelectIdentifer @"cacheSelectIdentifer" //选择标识

#define  cacheFileInfoKey   @"cacheFileInfoKey"

#pragma mark ==================================================
#pragma mark == 用户表 User
#pragma mark ==================================================
#define Table_User_company_id        @"company_id"        //'公司id',
#define Table_User_company_name      @"company_name"      //'公司名称',（额外增加）
#define Table_User_nickname          @"nickname"          //'昵称',
#define Table_User_staffNo         @"staffNo" // 员工编号
#define Table_User_account           @"account"           //'帐号',
#define Table_User_oaAccount         @"oaAccount"         //'oa帐号',
#define Table_User_loginTokenMd5     @"loginTokenMd5"         //'loginTokenMd5',
#define Table_User_avatar            @"avatar"            //'头像',
#define Table_User_urlmd5            @"urlmd5"            //'urlmd5',
#define Table_User_member_name       @"member_name"       //'姓名',
#define Table_User_name_quanpin      @"name_quanpin"      //'姓名全拼',
#define Table_User_name_initial      @"name_initial"      //'姓名首字母',
#define Table_User_role              @"role"              //'角色：0普通用户 1 管理员',
#define Table_User_details           @"details"           //'个人介绍',
#define Table_User_sex               @"sex"               //'性别 1:女 2男',
#define Table_User_email             @"email"             //'邮箱（帐号）',
#define Table_User_mobile            @"mobile"            //'手机号码',
#define Table_User_position_id       @"position_id"       //'职位id',
#define Table_User_position_name     @"position_name"     //'职位名称',（额外增加）
#define Table_User_posts_id          @"posts_id"          //'岗位id',
#define Table_User_posts_name        @"posts_name"        //'岗位名称',（额外增加）
#define Table_User_phone             @"phone"             //'座机',
#define Table_User_work_number       @"work_number"       //'员工号',
#define Table_User_department_id     @"department_id"     //'部门id',
#define Table_User_department_name   @"department_name"   //'部门名称'（额外增加）
#define Table_User_superior_id       @"superior_id"       //'上级领导id',
#define Table_User_exp               @"exp"               //'经验值',
#define Table_User_score             @"score"             //'积分',
#define Table_User_last_update_time  @"last_update_time"  //'最后修改时间',
#define Table_User_last_login_time   @"last_login_time"   //'最后登录时间',
#define Table_User_status            @"status"            //'状态:0 ？？？,1显示,2禁用 3 离职',
#define Table_User_is_director       @"is_director"       //'设为经理 0 不是经理 1 是经理',
#define Table_User_background_images @"background_images" //'背景图片',
#define Table_User_calendar_tip      @"calendar_tip"      //'日程提醒',
#define Table_User_hobby             @"hobby"             //'爱好',
#define Table_User_constellation     @"constellation"     //'星座',
#define Table_User_birthday          @"birthday"          //'生日',
#define Table_User_is_birthday       @"is_birthday"       //'生日提醒 0 不提醒 1 提醒' ,
#define Table_User_marriage          @"marriage"          //'婚否：0 未婚 1已婚',
#define Table_User_member_name_en    @"member_name_en"    //'英文名',
#define Table_User_qq                @"qq"                //'QQ',
#define Table_User_weixin            @"weixin"            //'微信',
#define Table_User_weibo             @"weibo"             //'微博',
#define Table_User_access_control    @"access_control"    //'权限',
#define Table_User_signature         @"signature"         //'签名',
#define Table_User_OrgId             @"userOrgId"         //企业id
#define Table_User_Level             @"level"         //用户级别
#define Table_User_Approval          @"approval"    //用户请假  wjy
#define Table_User_OutlookPwd        @"OutlookPwd"
#define Table_User_Level             @"level"

#define Table_User_PassMd5           @"passmd5"

#define Table_User_FriendGroupUrl    @"friendgroup_Url"

#define Table_User_confRooms      @"Table_User_confRooms"
// 保存支持的编码格式数组
#define CodecSetArr @"CodecSetArr"
//设备类型
#define BMSystem @"BMSystem"
#define kClientType_PC @"Rongxin_Client_PC"
#define kClientType_iPhone @"iPhone"

// PC登陆
#define PC_online @"PC_online"
#define PC_offline @"PC_offline"
// 多终端
#define StickyOnTopChanged @"StickyOnTopChanged" // 置顶，取消置顶发送的CMD 消息字段
#define NewMsgNotiSetMute @"NewMsgNotiSetMute" //消息通知
/// eagle 是否包含有会的开关
#pragma mark -- 功能开关
#define IsHaveYHCConference 0
#define isopenReceipte 1// IM消息已读未读功能开关
#define isOpenScanInSession 1// 会话界面是否打开扫一扫 add by keven.
#define isOpenDeviceSafe 0// 设备安全功能开关 add by keven.
//是否隐藏二维码
static BOOL const isHiddeCode = YES;

//会议类型
#define KTYPE_VOICEMEETTING @"ktype_voicemeetting"
#define KTYPE_VIDEOMEETTING @"ktype_videomeetting"
#define KCallReceivedOnInCallId       @"KCallReceivedOnInCallId"//voip模式 电话ID
#define KCallReceivedOnInCalltype     @"KCallReceivedOnIncalltype"//类型

#define SETUPTOP @"NSUSERDEFAULTSETUPTOP" //置顶
#define SETUPTOPNEWTIME @"SETUPTOPNEWTIME" //置顶的时间
#define connetServerTime @"connetServerTime" //连接服务器成功时的时间

#define notificationKickedOff @"notificationKickedOff" // 被踢下线的通知
#define notificationKickedOffInDeleSafeDevice @"notificationKickedOffInDeleSafeDevice" //删除安全设备后

//恒信im消息字段
#define kRonxinMessageType    @"com.yuntongxun.rongxin.message_type"// 1 语音会议 2视频会议 3实时对讲 由于安卓发送过来的枚举值跟ios不相同,是字符串,因此换成字符串 用下面二个区分 ProfileChanged为用户信息变更
#define kRonxinANON_MODE @"com.yuntongxun.rongxin.anon_mode"// 匿名模式
#define kRonxinBURN_MODE @"com.yuntongxun.rongxin.burn_mode"// 阅后即焚模式

#define kRONGXINVOICEMEETTING @"VOICE_MEETING"//语音会议
#define kRONGXINVIDEOMEETTING @"VIDEO_MEETING"//视频会议
#define kRONGXINVIDEOSWITCHVIOCE @"VIDEOTOVOICE"//视频切换语音

#define kRONGXIDATAMEETTING @"DATA_MEETING"//数据协同
#define kRONGXIDATAMEETTING_IP @"DATA_MEETINGIP"//数据协同IP

#define kRONGXINANON_ON @"ANON_ON"//开启匿名模式
#define kRONGXINANON_OFF @"ANON_OFF"//关闭匿名模式

#define kRONGXINBURN_ON @"BURN_ON"//开启阅后即焚模式
#define kRONGXINBURN_OFF @"BURN_OFF"//关阅后即焚模式
#define kCCPInterphoneConfNo   @"com.yuntongxun.rongxin.meeting_id"  //判断实时对讲和电话会议以及视频会议的字段  在userData中才有的字段

# pragma 新消息类型

#define TYPE_SHNAP_BURN        @"10"    // 阅后即焚
#define TYPE_RICH_TXT          @"11"    // 图文混排消息
#define TYPE_CARD              @"13"    // 服务号/个人名片
#define TYPE_COMBINE_MSG       @"14"    // 合并消息
#define TYPE_WBSS              @"15"    // 白板消息
#define TYPE_CALL              @"18"    // 音视频通话记录
#define TYPE_ONLINE            @"20"    // 多终端上下线
#define TYPE_STICKY_ON_TOP     @"21"    // 多终端置顶同步
#define TYPE_PROFILE_SYNC      @"22"    // 多终端个人信息同步
#define TYPE_FORWARD           @"23"    // 转发文件
#define TYPE_READ_SYNC         @"24"    // 会话消息已读同步
#define TYPE_FRIEND            @"25"    // 好友验证消息
#define TYPE_SMILEY            @"26"    // 自定义表情
#define TYPE_WEBURL            @"27"    // 本地连接消息格式
#define TYPE_STICKER           @"28"    // 自定义动态图表情
#define TYPE_NO_DISTURB        @"29"    // 免打扰同步

//群组修改详情对应的参数宏
#define KGroupInfoModify @"KGroupInfoModify"//修改的群组信息
#define KGroupInfoModifyType @"KGroupInfoModifyType"//修改类型
#define KGroupInfoGroupName @"KGroupInfoGroupName"//群组名称
#define KGroupInfoGroupId @"KGroupInfoGroupId"//群组id
#define KGroupInfoGroupDeclared @"KGroupInfoGroupDeclared"//群组公告
#define kGroupInfoGroupNickName @"kGroupInfoGroupNickName" //个人昵称
#define KGroupInfoModifyJurisdiction @"KGroupInfoModifyJurisdiction" //修改群信息权限
#define kGroupInfoGroupMembersNickNameSwitch  @"kGroupInfoGroupMembersNickNameSwitch"

//音视频 点对点和会议 字段
#define KVOICETYPE_TELEPHONEMEETTING @"kvoicetype_telephonemeetting"//电话会议
#define KVOICETYPE_RONXINMEETTING @"kvoicetype_ronxinmeetting" //恒信会议
#define KINVITE_JOINMEEtting @"kinvite_joinmeetting"//会议后邀请

#define KCallReceivedOnInCallId       @"KCallReceivedOnInCallId"//voip模式 电话ID
#define KCallReceivedOnInCalltype     @"KCallReceivedOnIncalltype"//类型
#define KCallReceivedOnInCaller       @"KCallReceivedOnInCaller"//呼叫者号码
#define KCallReceivedOnInCallername   @"KCallReceivedOnInCallername"//呼叫者的名字
#define KCallReceivedOnInMeetingData  @"KCallReceivedOnInMeetingData"//电话会议数据
#define KCallReceivedOnInisMeetInvite @"KCallReceivedOnInisMeetInvite"//会议要求
//callView 和answerView 模态视图
#define kIsPresentModalView  @"presentModalView"

//选人页面 发起群聊  发起语音会议  视频会议 类型
#define KTYPE_GROUPCHATTING @"ktype_groupchatting"
#define KTYPE_VOICEMEETTING @"ktype_voicemeetting"
#define KTYPE_VIDEOMEETTING @"ktype_videomeetting"
//vidyo会议
#define KTYPE_VIDYOCONFERENCE @"ktype_vidyoconference"
//消息转发
#define KTYPE_MESSAGETRANSMITED @"ktype_msgtransmited"

// ------- 文件传输助手相关
//#define FileTransferAssistant [[Common sharedInstance] getOneAccount]
#define FileTransferAssistant @"~ytxfa"

// IM系统登录发送给自己的消息相关
#define IMSystemLoginSessionId @"IMSystemLoginSessionId"
#define IMSystemLoginMsgFrom @"IMSystemLoginMsgFrom"
//-------------公众号相关
//鉴权字段
#define App_ClientAccount  [[AppModel sharedInstance].appData.userInfo objectForKey:Table_User_mobile]

#define KPublicMessList_publicId @"publicMessageId001"//删除时使用
#define KPublicMessCount @"KPublicMessCount"//未读消息数

//设置滚动条tag
#define noDisableVerticalScrollTag 836913
#define noDisableHorizontalScrollTag 836914
//添加companybook tag
#define kCompanyBookTag 100
//网络连接中断
#define kNetConnectFail @"isNotConnetNet"
#define kDeleteMessage @"deleteMessage"
#define EXPRESSION_SCROLL_VIEW_TAG 100

//扩展功能tabbar(+) 内容事件
#define KTYPE_ADDTELEPHONEMEETTING @"kTYPE_ADDTELEPHONEMEETTING"//+电话会议
#define KTYPE_BURNCHATTING @"kTYPE_BURNCHATTING"//+阅后即焚
#define KTYPE_ANONCHATTING @"kTYPE_ANONCHATTING"//匿名讨论

//------分享个人名片进入通讯录选择联系人
#define HX_BusinessCardShare_Push @"businessCardShare"
#define ShareCardMode @"ShareCard"
//#define ShareCard @"ShareCard"

//是否是拨号界面进入 以及电话号码
#define isRecodeMobileInto @"isRecodeMobileInto"
#define kRecodeGetMobile @"kRecodeGetMobile"

#define KSportMeetMessage_type @"sportMeet_type"//运动会消息类型
#define KCreateSportMeetMessageList @"haveSportMessageList"

#define KCreateSportnoticionSessionId @"SportMeetNoticaion"//消息推送字段的sessionid

#define KCreateSportMeetMessageFriendClass @"haveSportMessageFriendClass"
#define KReceiveSportMeetMessageFriendTime @"KReceiveSportMeetMessageFriendTime"
#define KSendSportMeetMessageFriendTime @"KSendSportMeetMessageFriendTime"
#define KCreateSportMeetMessageSportPrize @"haveSportMeetPrize"
#define KGetPCMessageNotice @"havePCMessage"

#define KCreateSportnoticionSessionId @"SportMeetNoticaion"//消息推送字段的sessionid
//语音播放后的状态判断
#define KVoicePlayIsSure @"RongXin_IsPlayVoice"
//------接受好友成功后 表示字段
#define  receiverFriendInvite @"addFriend"

//恒信恒信消息的合并转发
#define kMergeMessage_CustomType @"customtype=501" //标识

//恒信OA监控
#define kOAMessage_CustomType    @"customtype=350" //标识
#define KOAMessage_sessionIdentifer @"rx_as_"  //oa的sessionId标识
#define KOAMessage_verify @"dianpiaoxitong" //oa消息指纹需要验证
/** 合并消息 */
#define MessageBodyType_MessageMerge 200
//恒信跨端文件传输消息 userData内参数字段名称
#define kFileTransferMsgNotice_CustomType @"customtype=300" //文件传输标识
#define kVidyoSyncDeviceName @"syncDeviceName"

//账号冻结
#define KAccountFrozen_CustomType @"customtype=101" //账号冻结标识
#define KAccountFrozen                          1  //账号冻结
#define KAccountDel_CustomType @"customtype=102"    //账号删除标识

#define KMyAppStore_CustomType @"customtype=351" //第三方应用消息

#define KAccountleavejob_CustomType @"customtype=103"    //账号离职标识

#define kUpdatePwdNotice_CustomType @"customtype=100" //修改密码标识

#define RXleaveJobImageHeadShowContent @"离职"//人员离职头像显示内容
//OA消息
typedef enum
{
    HXOAMessageTypePublicNum =201,  //工作报告
    HXOAMessageTypeOtherAPPstore = 250,//应用商店消息
    HXAttenceMessageTypePublicNum = 350 //考勤
}HXOAMessageType;

/**
 *  选取本地缓存文件类型
 */
typedef NS_ENUM(NSInteger, SelectCacheDocumentType){
    
    SelectCacheDocumentType_Document = 1,
    
    SelectCacheDocumentType_Image = 2,
    
    SelectCacheDocumentType_Media = 3,
    
    SelectCacheDocumentType_Other = 4,
};

#define OATitle @"集中监控平台"
#define AttenceTitle @"考勤通知"
#define KNOTIFICATION_OAMessage_RECEIVE  @"KNOTIFICATION_OAMessage_RECEIVE"






/**
 *
 * 通知相关
 *
 **/
#define KNOTIFICATION_onMesssageFCChanged    @"KNOTIFICATION_onMesssageFCChanged"//朋友圈
#define kFirendCircleNotification @"kFirendCircleNotification" //新增朋友圈通知，进行数据库操作

#define KNOTIFICATION_onConnected       @"KNOTIFICATION_onConnected"

#define kPhoneMeetingViewAddNewMember   @"PhoneMeetingViewAddNewMember"//增加会议成员
#define KVideoMeetingViewAddNewMember   @"KVideoMeetingViewAddNewMember"//增加视频会议成员

#define kJSSelectMember     @"kJSSelectMember" //js选择联系人

#define KNOTIFICATION_onConnectedNOTLINE       @"KNOTIFICATION_onConnectedNOTLINE"

#define KNOTIFICATION_onNetworkChanged    @"KNOTIFICATION_onNetworkChanged"
#define KNOTIFICATION_PCLogin @"KNOTIFICATION_PCLogin"

#define KNOTIFICATION_onMesssageChanged    @"KNOTIFICATION_onMesssageChanged"
#define KNOTIFICATION_onMesssageChangedTheSessionId    @"KNOTIFICATION_onMesssageChangedTheSessionId"

#define KNOTIFICATION_haveHistoryMessage @"KNOTIFICATION_haveHistoryMessage"
#define KNOTIFICATION_HistoryMessageCompletion @"KNOTIFICATION_HistoryMessageCompletion"

#define KNOTIFICATION_needInputName @"KNOTIFICATION_needInputName"

#define kNotificationTransform  @"notificationTransform" //首页跳转

#define kNotification_update_im_message_unread_num  @"Notification_update_im_message_unread_num" //未读消息更新
#define kNotification_update_session_im_message_num @"notification_update_session_im_message_num" //沟通界面消息沟通
#define kNotification_update_session_deleteGroup @"kNotification_update_session_deleteGroup"//自己被群主移除该群
#define kNotification_ClearAllIMMsg @"notification_clear_all_immsg" // 清空聊天记录
#define kNotification_Join_Group @"notification_join_group" // 加入群
#define kNotification_memberChange_Group @"notification_invite_group" // 群组成员变化
#define kNotification_Logout_Group @"notification_logout_group" // 退出群
#define kNotification_Dismiss_Group @"notification_dismiss_group" // 解散群

#define kNotification_Modify_Group @"notification_modify_group" // 修改群
#define kNotification_update_invite_type @"notification_update_invite_type"//企业
#define kNotification_query_groupInfo_result @"notification_query_groupInfo_result"//查询结果返回时通知
#define kNotification_update_address_book @"notification_update_address_book"//更新通讯录
#define KNotice_ReloadSessionGroup  @"KNotice_ReloadSessionGroup"//刷新沟通界面显示群组信息
#define KNotice_reloadSessionGroupName @"KNotice_reloadSessionGroupName"//刷新群组名称
#define KNotice_InsertGroupMemberArray @"KNotice_InsertGroupMemberArray"//更新完群组的通讯录
#define Knotice_reloadSessionPerson @"Knotice_reloadSessionPerson"//刷新沟通界面个人聊天信息
//多终端已读通知
#define KNotice_Multi_TerminalRead @"KNotice_Multi_TerminalRead"

#define UIPushCompanyAddress @"UIPushCompanyAddress" //企业通讯录跳转

#define KMyFriendInviteMessList_InviteId @"InviteMessageId001"//好友邀请数量通知字段

//增量下载通讯录
#define KNotification_ADDCOUNTQUEST     @"KNotification_ADDCOUNTQUEST"//增
#define KNotification_ADDCOUNTQUESTTime     @"KNotification_ADDCOUNTQUESTTime"//是否和增量的时间返回的时间相同
//插入数据库通知
#define insertCompanyAddressBook @"insertCompanyAddressBook"

//------------公众号相关通知
#define kPublicReciveNotification  @"kPublicReciveNotification"
#define KReceivePublicNotification @"KReceivePublicNotification" // iM消息列表接收到公众号消息推送
#define KReceivePublic @"KReceivePublic" // 公众号页面接收到公众号消息推送

//IM notification (选择对应的通知和关闭的通知一共两个)
#define KNOTIFICATION_onWhiteBoardNotice     @"WhiteBoardNotice"        //普通白板(tab +)
#define KNOTIFICATION_onPTPBoardNotice       @"PTPBoardNotice"          //群聊模式
#define KNOTIFICATION_onVideoBoardNotice     @"VideoBoardNotice"        //音视频会议

#define KNOTIFICATION_onCloseBoardNotice     @"CloseBoardNotice"        //关闭白板

//白板视图 notification (可选通知)
#define KNOTIFICATION_onCloseBoardMine       @"closeBoardMine"          //关闭自己白板的通知
#define KNOTIFICATION_onAffineBoardNotice    @"AffineBoardNotice"       //白板最小化

#define KNOTIFICATION_onOpenBoardMine       @"openBoardMine"          //打开白板的通知

#define KNotification_LOCALADDRESSCOUNT     @"KNotification_LOCALADDRESSCOUNT"//手机联系人数量
#define KNOTIFICATION_SpecialSynNotice      @"KNOTIFICATION_SpecialSynNotice" //特别关注同步通知
// 关闭会议和通话的通知
#define kNotification_CloseConf @"kNotification_CloseConf" // 关闭会议的通知
#define kNotification_CloseVoip @"kNotification_CloseVoip" // 关闭点对点通话的通知


//收到电话和语音呼叫,停止语音播放
#define kNotification_Video_Voice_Call_StopVoiceMessagePlay  @"kNotification_Video_Voice_Call_StopVoiceMessagePlay"

//网络变化的通知
#define KNotification_onConnected       @"KNotification_onConnected_onConnected"

//恒丰新增wjy
#define KNOTIFICATION_fileTranProgressChanged @"KNOTIFICATION_fileTranProgressChanged" //文件传输进度变化
#define KMessageKey @"kmessagekey"

//SVC会议通知
#define kNOTIFICATION_ReloadConfCurrentList       @"NOTIFICATION_ReloadConfCurrentList"
#define kNOTIFICATION_ReloadConfHistoryList       @"NOTIFICATION_ReloadConfHistoryList"
#define kNOTIFICATION_onCallVideoRatioChanged       @"onCallVideoRatioChanged"
#define kNOTIFICATION_OnReceiveConferenceMsg        @"NOTIFICATION_OnReceiveConferenceMsg"
#define kNOTIFICATION_onReceiveVoiceMembersInConf   @"onReceiveVoiceMembersInConf"

#define KNotification_DeleteLocalSessionMessage @"KNotification_DeleteLocalSessionMessage" //删除聊天记录
#define KNotification_HiddenChatVCRightButtonSessionMessage @"KNotification_HiddenChatVCRightButtonSessionMessage" //隐藏聊天界面右上角按钮
#define KNotification_UpdatecompanOtherSuccess @"KNotification_UpdatecompanOtherSuccess"//通讯录更新完成的宏



/**
 *
 * 其他暂未整理
 *
 **/
//T9切换
#define IsSwitchT9Search @"22233344455566677778889999"

//字母数字
#define isPassWordLimitDigitalLetter @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"


//检测字符串为空
//#define KCNSSTRING_ISEMPTY(str) (str == nil || [str isEqual:[NSNull null]] || str.length <= 0)
#define KCNSSTRING_ISEMPTY(str) (str == nil || [str isEqual:[NSNull null]] || str.length <= 0 || [str isEqualToString:@"(null)"] || [str isEqualToString:@"<null>"] )

//恒丰新增wjy
//字符串为空时 赋值@""
#define KSCNSTRING_ISNIL(str)  !KCNSSTRING_ISEMPTY(str)?str:@""

//网址正则匹配字符串  @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?" 旧正则
#define REGULAR_WEBSITE_STRING  @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"


//-------------公众号相关错误

#define  publicDataNotExistErrorCode  610009  //数据不存在

#define  publicNotExistErrorCode  610100 //公众号不存在

#define  publicAttErrorCode  610120 //已关注了该公众号

#define  publicNoAttErrorCode 610121  //该账号尚未关注该公众号

#define  publicNotCancelErrorCode  610122 //内部订阅无法取消

#define  publicToTopErrorCode  610123 //该账号已置顶了此公众号

#define  publicNoToTopErrorCode 610124 //未置顶公众号

#define  publicHasBeenAccepted  610125  // 该账号已设置接收此公众号消息

#define  publicHasNotAccepted   610126// 该账号尚未设置接收此公众号消息

#define  publicHasBeenPulledBlack 610127 // 该账号已已被此公众号拉黑

#define  publicNoUpdate       610105   //公众号没有更新


#define  HXLevelisFristAndSecond(curLevel,curMobile) ( (curLevel == 1 || curLevel == 2) && ![curMobile isEqualToString:[Common sharedInstance].getAccount] )
#define  hiddenMobileAndShowDefault  @""


/*****搜索UI****/

#define  selectSearchViewUI  1

//[[RXUser sharedInstance].level integerValue]  && [[RXUser sharedInstance].level integerValue] == 3
#define  HXSecondLevelClient(curLevel)   ( ([[Common sharedInstance].getUserLevel integerValue]-curLevel) = 1 )  //二级用户权限 跨一级权限
#define  HXThreeLevelClient(curLevel)   (([[Common sharedInstance].getUserLevel integerValue]-curLevel)>1  && curLevel <3)  //三级用户权限  跨二级权限

#define  HXThreeToOneLevelClient(curLevel)   (([[Common sharedInstance].getUserLevel integerValue]-curLevel)>=1  && curLevel <3)  //三级用户权限  跨一级权限


//#define  HXLevelisFristAndSecond(curLevel,curMobile) ( (curLevel == 1 || curLevel == 2) && ![curMobile isEqualToString:[Common sharedInstance].getAccount] )
//&& ([[RXUser sharedInstance].level integerValue] > 2)
#define  ScreenSpecialDpid(curDeptId)   ( [curDeptId isEqualToString:@"100122"] )  //屏蔽特殊的部门 3级部门不能查看行领导室

#define  hiddenMobileAndShowDefault  @""

//add2017yxp9.5 邮箱消息
#define  fromWorkFileShare @"fromWorkFileShare"




//--------runtime-----键值------
/**
 *键名 设置屏幕旋转
 */
static const NSString *settingOrientationStatuss = @"settingOrientationStatus";//设置key
static const NSString *KPublicVoiceIsPlayKey = @"KPublicVoiceIsPlayKey";//设置服务号语音播放
//电话会议账号类型
#define Phone_ECAccountType @"ECAccountType"


//会议通知消息发送者
#define YHC_CONFMSG @"yhc_confMsg"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define kNOTIFICATION_UpdateAddressData       @"kNOTIFICATION_UpdateAddressData"
#define kNOTIFICATION_UpdateFriendlist       @"kNOTIFICATION_UpdateFriendlist"
#define kKitConfRoomId       @"YH_confRoomId_key"

// 接收到实时对讲消息的通知
#define KNOTIFICATION_ReceiveInterphoneMeetingMsg @"KNOTIFICATION_ReceiveInterphoneMeetingMsg"

///add by 李晓杰 userdata改为json传输2018.10.16
///是否是新消息类型
#define ISSwithToNewMESSAGE 1
///10.阅后即焚11.图文混排消息13.服务号/个人名片14.合并消息15.白板消息18.音视频通话记录20.多终端上下线21.多终端置顶同步22.多终端个人信息同步23.转发文件24.会话消息已读同步25.好友验证消息
#define SMSGTYPE @"sMsgType"
///end by 李晓杰

///是否是开启级别判断 开启后 无法查看高于自己2次的用户信息
#define ISLEVELMODE 0
#define ISFTSMODE 0
#define ISOPENCipher 0 // 是否开启数据库加密
#define isHCQ 0 // 1为华勤 0 为容信lite
#define OpenSSO 0
#define isOpenPhoneContact 0 // 是否打开手机通讯录

//是否开通一键创群
#define isOpenCreateGroup 0
#define isRealGroup 1// 创建的是否是真的群组1是群组，0是讨论组
// 未下载的文件能否转发
#define isUndownloadFileCanShare 1
// 能否分享到微信
#define isCanShareToWeChat 1
// 是否包含韩语
#define isContainKorean 0

#define isShowCompanyNum 1// 通讯录中是否显示人数

// log宏
#ifdef DEBUG
#define debugMethod() NSLog(@"%s", __func__)
#define GYString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define NSLog2(...) printf("%s 第%d行: %s\n\n", [GYString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

#define NSLog(format, ...) do {                                                                          \
fprintf(stderr, "<%s : 第%d行> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)

#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)


// 异步主线程执行，不强持有Self
#define RLDispatchAsyncOnMainQueue(x) \
__weak typeof(self) weakSelf = self; \
dispatch_async(dispatch_get_main_queue(), ^{ \
typeof(weakSelf) self = weakSelf; \
{x} \
});


#else /** Release*/
//eagle end

#define NSLog(...)

#endif

//好友开关
#define isShowMyFriend 1
//大通讯录模式相关
#define isLargeAddressBookModel 1  //开关  默认为0不开启

#define KNotification_bindPhoneBySMSInDeviceSafe @"KNotification_bindPhoneBySMSInDeviceSafe"//设备安全通过短信验证码绑定手机号
#endif
