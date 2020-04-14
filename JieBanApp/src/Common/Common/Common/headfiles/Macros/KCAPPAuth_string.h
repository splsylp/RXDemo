//
//  KCAPPAuth_string.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/9/20.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#ifndef KCAPPAuth_string_h
#define KCAPPAuth_string_h


/* 用户权限 */

/*
#define IMAuth  @"1"  //IM聊天
#define AddressBookAuth  @"4"  //通讯录
#define CreateGroupAuth  @"9"  //创建群组
#define ConferenceAuth  @"10"  //会议
#define PhoneMeetingAuth  @"11"  //电话会议
#define VoiceMeetingAuth  @"12"  //语音会议
#define VideoMeetingAuth  @"13"  //视频会议
#define RecordAuth  @"14"  //录制(音频，视频)
#define EmergencyConfAuth  @"15"  //应急会议
#define MSMAuth  @"17"  //短信
#define CallAuth  @"20"  //呼叫管理
#define VoiceAuth  @"21"  //网络电话
#define DirectAuth  @"22"  //直拨
#define BackDialAuth  @"23"  //回拨
#define VideoAuth  @"24"  //视频通话
#define MicroPortalAuth  @"26" //微门户
#define PublicDocumentAuth  @"27" //公共文档
#define NewsAuth  @"28"  //公告新闻
#define DutyGroupAuth  @"29"  //值班群组
#define FCAuth  @"31"  //朋友圈
#define RedpacketAuth  @"32"  //红包
#define CoopAuth  @"33"  //白板协同
#define PublicAuth  @"34"  //服务号
#define WorksAuth  @"35"  //工作入口权限
#define AskForLeaveAuth @"36" //请假
#define ApprovalAuth  @"37"  //审批
#define DownloadFileAuth  @"39"  //可下载文件权限
#define DeskAuth  @"40"  //坐席权限
#define AppStoreAuth @"41" //应用商店
#define PhotographyAuth  @"48"  //摄影作品投票
#define SportAuth  @"49"  //运动会评奖
 */

#define VOIPAuth  @"3"  //网络电话
#define DirectAuth  @"4"  //直拨
#define BackDialAuth  @"5"  //回拨
#define VidyoAuth  @"6"  //视频通话
#define RXVoiceMeetAuth @"7"//语音会议
#define VidyoMeetAuth  @"8"  //视频会议
#define PhotographyAuth  @"17"  //摄影作品投票
#define SportAuth  @"18"  //运动会评奖
#define FCAuth  @"40"  //朋友圈
#define RedpacketAuth  @"50"  //红包
#define CoopAuth  @"60"  //白板协同
#define PublicAuth  @"70"  //公众号
#define WorkModuleAuth @"80" //进入工作模块权限
#define AskForLeaveAuth @"81" //请假
#define ApprovalAuth  @"82"  //审批
#define VoiceMeetAuth @"90" //电话会议
#define HasAppStoreAuth @"119" //是否有应用商店
#define AppStoreAuth @"120" //应用商店在线安装权限


/* 功能模块开关 */

#define K_RestoreAvatar 0 //恢复默认头像
#define CallKitAuth 0   //是否有CallKit权限
#define isOpenPushKit (isHCQ?0:1)  //pushkit开关
#define K_MergeMessageForward  1   //消息的合并转发
#define clientShowInfomation   0  //1.2级领导不显示手机号部门
#define isHFSendFile   YES
#define HX_fileEncodedSwitch                    1  //是否需要文件加密处理
#define HX_ModifyPassword_Switch                1  //修改密码开关
#define HX_Password_3DES_Encrypt                0  //密码3des加密
#define isOAFunction                            0   //OA 功能
#define isUserNewAppFrame                       0   //是否使用源生框架
#define isShowMessageUnreadCount                1 //聊天页面中，右下角是否显示未读消息数目
#define isSearchIndex_Account                   0 //搜索的时候用mobile作为标识
#define isShowGroupUnReadCount_Select           0//选择群组时，是否需要显示未读数，（其他项目显示）
#define kShowFriensCircleVideo 1    //朋友圈发小视频独立开关
#define isHXSwitch 2 //判断红包，转账是恒丰的还是容信的 1-恒丰  2-容信
#define isHaveWaterView 1 // 0 没水印，1 有水印
#define isHaveIMBigText 1 //0： IM文本不放大 1：放大
#define isHaveChangeVoiceToText 0// 0：没有语音转文字，1：有语音转文字
#define isSendOriginImageData               0 //是否发送原图数据
#define isZipBaseFile 1  //添加关于通讯录压缩的宏
#define BoardAuth 1  //是否有白板权限
#define multiCompanyAuth 1 //多企业选择权限
#define publicReaAndALike  0  //是否增加account 阅读和点赞
#define publicMessageTop   1  //公众号是否置顶
#define KitOnReceiveOfflineMessage  1  //是否需要接受离线消息提示
#define isHeadRequestUserMd5  0
#define hasProxy   0 //自己应用是否走代理服务器
#define IsHengFengTarget  0
#define IsChecNewVersion 1// 检查版本更新
#endif /* KCAPPAuth_string_h */
