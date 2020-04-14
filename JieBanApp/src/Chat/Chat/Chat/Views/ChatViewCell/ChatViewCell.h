//
//  ChatViewCell.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIResponder+Custom.h"

///语音视频点击事件
extern NSString *const KResponderCustomChatViewCellBubbleViewEvent;
///重发消息事件
extern NSString *const KResponderCustomChatViewCellResendEvent;
///已读按钮点击事件
extern NSString *const KResponderCustomChatViewCellMessageReadStateEvent;

///这是key value为message对象
extern NSString *const KResponderCustomECMessageKey;
///重发事件 这是key value为对应的cell
extern NSString *const KResponderCustomTableCellKey;

///系统群通知名字点击事件
extern NSString *const KResponderCustomChatViewCellNameTapEvent;

extern const char KTimeIsShowKey;

@class ChatViewCell;

@protocol ChatViewCellDelegate <NSObject>

- (void)ChatViewCellOfMoreSelectWithMessage:(ECMessage *)msg chatCell:(ChatViewCell *)cell isSelect:(BOOL)isSelect;

@end

@interface ChatViewCell : UITableViewCell
///是否是发送者
@property (nonatomic, assign) BOOL isSender;
///是否是匿名模式
@property (nonatomic, assign) BOOL isAnon_sender;
///是否是阅后即焚发送者
@property (nonatomic, assign) BOOL isBurn_sender;

///头像
@property (nonatomic, strong) UIImageView *portraitImg;
///发送者lab
@property (nonatomic, strong) UILabel *fromId;
///特别关注
@property (nonatomic, strong) UILabel *specialAttLabel;
///气泡view 子控件一般加这上面
@property (nonatomic, strong) UIView *bubbleView;
///气泡img
@property (nonatomic, strong) UIImageView *bubleimg;
///已读未读按钮
@property (nonatomic, strong) UIButton *receipteBtn;
///时间lab
@property (nonatomic, strong) UILabel *timeLabel;
///阅后即焚倒计时
@property (nonatomic, strong) UILabel *timeLab;
///阅后即焚时钟图标
@property (nonatomic, strong) UIImageView *burnIcon;
///是否是历史消息
@property(nonatomic,assign) BOOL isHistoryMessage;
///发送状态loadingview
@property (nonatomic, strong) UIView *sendStatusView;
//菊花view
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
///重发按钮
@property (nonatomic, strong) UIButton *retryBtn;


///im消息多选状态刷新 记录当前
@property (nonatomic,assign) BOOL isIMMsgMoreSelectLoad;
///消息多选按钮
@property (nonatomic, strong) UIButton *moreSelectBtn;

@property (nonatomic, assign) id<ChatViewCellDelegate>delegate;
///消息对象
@property (nonatomic, strong) ECMessage *displayMessage;

#pragma mark - 创建方法
////创建cell
- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier;
///创建cell 通知专属 HXChatNotifitionCell
- (instancetype)initWithNotifitionIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier;
#pragma mark - 设置数据源
//设置cell的数据
- (void)bubbleViewWithData:(ECMessage *)message;
///更新消息发送状态
- (void)updateMessageSendStatus:(ECMessageState)state;
#pragma mark - 外部获取高度回调
///根据消息内容获取占用的高度
+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody;
///根据message获取高度
+ (CGFloat)getHightOfCellViewWithMessage:(ECMessage *)message;
#pragma mark - 点击事件
///单击事件
- (void)bubbleViewTapGesture:(id)sender;
///双击事件
- (void)doubleTextTapGesture:(id)sender;



@end
