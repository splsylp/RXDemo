//
//  YHCNotificationHeader.h
//  YouHui
//
//  Created by 王文龙 on 2017/8/17.
//  Copyright © 2017年 wwl. All rights reserved.
//

#ifndef YHCNotificationHeader_h
#define YHCNotificationHeader_h


#define KNOTIFICATION_onNetworkChanged                  @"KNOTIFICATION_onNetworkChanged"
#define KNOTIFICATION_onSDKConnected                    @"KNOTIFICATION_onSDKConnected"
#define KNOTIFICATION_onReceivedConfNewMsg              @"KNOTIFICATION_onReceivedConfNewMsg"
#define KNOTIFICATION_onReloadConfMsgCount              @"KNOTIFICATION_onReloadConfMsgCount"
#define KNOTIFICATION_onReloadAddressMsgCount           @"KNOTIFICATION_onReloadAddressMsgCount"


#define KNOTIFICATION_onRecordingAmplitude              @"KNOTIFICATION_onRecordingAmplitude"

#define KNOTIFICATION_onMesssageChanged                 @"KNOTIFICATION_onMesssageChanged"
#define KNOTIFICATION_onMesssageSend                    @"KNOTIFICATION_onMesssageSend"
#define KNotification_DeleteLocalSessionMessage         @"KNotification_DeleteLocalSessionMessage"
#define KNOTIFICATION_ShoulDownloadMediaMessage         @"KNOTIFICATION_ShoulDownloadMediaMessage"
#define KNOTIFICATION_DownloadMessageCompletion         @"KNOTIFICATION_DownloadMessageCompletion"
#define KNOTIFICATION_ReceiveMessageDelete              @"KNOTIFICATION_ReceiveMessageDelete"
#define KNOTIFICATION_SendMessageCompletion             @"KNOTIFICATION_SendMessageCompletion"
#define KNOTIFICATION_IsReadMessage                     @"KNOTIFICATION_IsReadMessage"

#define KNOTIFICATION_haveHistoryMessage @"KNOTIFICATION_haveHistoryMessage"
#define KNOTIFICATION_HistoryMessageCompletion @"KNOTIFICATION_HistoryMessageCompletion"

#define KNOTIFICATION_onReceivedGroupNoticeDeleteMine @"KNOTIFICATION_onReceivedGroupNoticeDeleteMine"
#define KNOTIFICATION_onReceivedGroupNoticeChageGroupInfo @"KNOTIFICATION_onReceivedGroupNoticeChageGroupInfo"

#define kNotification_Invite_Group @"notification_invite_group" // 邀请加入群

#define KNOTIFICATION_groupIsDisbanded @"KNOTIFICATION_groupIsDisbanded"
#define KNotice_reloadSessionGroupName @"KNotice_reloadSessionGroupName"//刷新群组名称
#define KNotice_ReloadSessionGroup  @"KNotice_ReloadSessionGroup"//刷新沟通界面显示群组信息
#define KNotice_reloadSession @"KNotice_reloadSession"//刷新群组名称
#define KNotice_deleteGroupSession @"KNotice_deleteGroupSession"// 删除群组通知
#define KNotice_downloadFileMessageState   @"downloadFinshFileMessage"//更新下载文件状态

//收到电话和语音呼叫,停止语音播放
#define kNotification_Video_Voice_Call_StopVoiceMessagePlay  @"kNotification_Video_Voice_Call_StopVoiceMessagePlay"

#define kGroupInfoGroupMembersNickNameSwitch  @"kGroupInfoGroupMembersNickNameSwitch"
#define KNOTIFICATION_onReceivedGroupNickNameModifyNotice @"KNOTIFICATION_onReceivedGroupNickNameModifyNotice" //群昵称修改通知


#define KNOTIFICATION_revokeMessage @"KNOTIFICATION_revokeMessage"



#define kDeleteMessage @"deleteMessage"

#define KNOTIFICATION_fileTranProgressChanged @"KNOTIFICATION_fileTranProgressChanged" //文件传输进度变化
#define KMessageKey @"kmessagekey"


//白板KEY
//IM notification (选择对应的通知和关闭的通知一共两个)
#define KNOTIFICATION_onWhiteBoardNotice     @"WhiteBoardNotice"        //普通白板(tab +)
#define KNOTIFICATION_onPTPBoardNotice       @"PTPBoardNotice"          //点对点音视频
#define KNOTIFICATION_onVideoBoardNotice     @"VideoBoardNotice"        //音视频会议
#define KNOTIFICATION_onCloseBoardNotice     @"CloseBoardNotice"        //关闭白板

//白板视图 notification (必须监听)
#define KNOTIFICATION_onShowBoardMine        @"showBoardMine"          //打开自己白板的通知
#define KNOTIFICATION_onCloseBoardMine       @"closeBoardMine"          //关闭自己白板的通知
#define KNOTIFICATION_onExtMarkBoardNotice   @"extMarkBoardNotice"          //打开自己白板的通知
#define KNOTIFICATION_onAffineBoardNotice    @"AffineBoardNotice"       //白板最小化

#define USERID      @"userid"       //用户ID
#define USERNAME    @"username"     //用户姓名
#define PASSWORD    @"password"     //房间密码
#define ROOMTYPE    @"roomtype"     //房间类型(临时或永久)
#define BOARDTYPE   @"boardtype"    //进入的类型
#define ROOMID      @"roomID"       //房间ID
#define SUBMITDOC   @"submitDoc"    //上传的文档
#define ROOMID      @"roomID"       //房间ID
#define SendIMWhenExit    @"sendIMWhenExit"     //是否发送IM
#define NOTIFLAG    @"notiFlag"     //判断是否是通知过来的加入
#define PREVIEWMODE @"previewMode"  //是否默认预览模式


#define KNOTIFICATION_CloudStorageItemSelect  @"CloudStorageItemSelect"
#define KNOTIFICATION_AddressBookSearchBarResignFirstResponder  @"addressBookSearchBarResignFirstResponder"

#endif /* YHCNotificationHeader_h */
