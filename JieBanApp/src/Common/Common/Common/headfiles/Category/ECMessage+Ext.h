//
//  ECMessage+Ext.h
//  ECSDKDemo_OC
//
//  Created by wangming on 16/5/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXThirdPart.h"

typedef NS_ENUM(NSInteger,ChatMessageType) {
    ///网址
    ChatMessageTypeWebsite = 0,
    ///定位
    ChatMessageTypeLocation,
    ///语音,图片,小视频
    ChatMessageTypeMedia,
    ///文本
    ChatMessageTypeText,
    ///图文
    ChatMessageTypeImageText,
    ///文件
    ChatMessageTypeFile,
    ///合并转发文件
    ChatMessageTypeMergeFile,
    ///音视频拨打后消息
    ChatMessageTypeCall,
    ///大表情
    ChatMessageTypeBigEmoji,
    ///白板消息
    ChatMessageTypeBoard,
    ///个人或服务号 名片
    ChatMessageTypeCard,
    ///转发文件
    ChatMessageTypeForwardFile,
    ///个人信息改变 CMD消息
    ChatMessageTypeProfileChanged,
    ///多终端置顶 CMD消息 {"account":"g8000161825","com.yuntongxun.rongxin.message_type":"StickyOnTopChanged","isTop":"true"}
    ChatMessageTypeTopterminal,
    
    ///多终端消息已读 CMD消息
    ChatMessageTypeReadterminal,
    ///PC退出的 CMD消息
    ChatMessageTypePCLoginout,
    /// 多终端消息免打扰 CMD消息 {"account":"g8000161825","com.yuntongxun.rongxin.message_type":"NewMsgNotiSetMute","isMute":"true"}
    ChatMessageTypeMessageNoticeterminal,
    
    ChatMessageTypeUnsendUrl = 26,
    
    ChatMessageTypeSendUrl = 27,
};

@interface ECMessage (Ext)
- (void)setHeight:(int) height;
- (int)getHeight;

- (void)setVersion:(NSUInteger)version;
- (NSUInteger)getVersion;

- (void)setMsgPrimaryKey:(NSInteger)msgPrimaryKey;
- (NSInteger)getMsgPrimaryKey;
- (void)setSpeed:(unsigned long long)speed;
- (unsigned long long)getSpeed;

///是否是图文消息
- (BOOL)isRichTextMessage;
///是否是阅后即焚消息
- (BOOL)isBurnWithMessage;
///是否是名片消息
- (BOOL)isCardWithMessage;
///是否是合并消息
- (BOOL)isMergeMessage;

//给合并收藏用的
+ (BOOL)isMergeMessage:(NSString *)userdata;

///是否是白板消息
- (BOOL)isBoardMessage;
///是否是多终端上下线消息
- (BOOL)isMoreLoginMessage;
///是否是置顶消息
- (BOOL)isTopMessage;
///是否多终端设置免打扰
- (BOOL)isSetMuteMessage;
///是否是多终端消息通知
- (BOOL)isNotiMuteMessage;

/// 是否是修改密码消息
- (BOOL)isModifyPasswordMessage;

///是否是人员删除消息
- (BOOL)isDeleteAccountMessage;

///是否是多终端个人信息（头像）同步
- (BOOL)isProfileChangedMessage;
///是否是文件转发消息
- (BOOL)isForwardMessage;
///是否是消息已读消息
- (BOOL)isHaveReadMessage;
///是否是添加好友相关消息
- (BOOL)isAddFriendMessage;
///是否是群组 包含g判断
- (BOOL)isGroupFlag;
///是否是 VoIP 通话记录消息
- (BOOL)isVoipRecordsMessage;
///是否是群组通知消息
- (BOOL)isGroupNoticeMessage;
//是否是网页消息
- (BOOL)isWebUrlMessage;

- (BOOL)isAnalysisedMessage;

- (BOOL)isWebUrlMessageSendSuccess;

- (BOOL)isWebUrlMessageSendFail;

///add by李晓杰 保存图片cell的高度
- (void)setImageHeight:(CGFloat)height;
- (CGFloat)getImageHeight;
- (void)setImageWight:(CGFloat)wight;
- (CGFloat)getImageWight;
- (NSInteger)getUnreadCount;
///将消息的userdata转成字典
- (NSDictionary *)userDataToDictionary;

@end
