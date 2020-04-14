//
//  ChatToolView.h
//  ECSDKDemo_OC
//
//  Created by zhangmingfei on 2016/10/18.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXSendFileViewController.h"
//表情
#import "CustomEmojiView.h"

typedef enum {
    ToolbarStatus_None=0,   //初始状态  50
    ToolbarStatus_Emoji,    //表情状态  216
    ToolbarStatus_More,     //更多状态  169
    ToolbarStatus_Record,   //语音状态  50
    ToolbarStatus_Input     //输入状态
}ToolbarStatus;


@protocol ChatToolViewDelegate <NSObject>

//改变tableView的frame
- (void)changeTableViewFrameWithFrame:(CGRect)frame andDuration:(NSTimeInterval)duration;

//停止播放语音
- (void)stopPlayVoice;

//closeProgress 创建会议房间失败的时候
- (void)shouldCloseProgress;

//zmf  add
//语音动画相关
- (void)voiceViewShouldGoWithString:(NSString *)placeString andRecordInfoLabelText:(NSString *)infoText;
//zmf end

@end

@interface ChatToolView : UIView

//键盘的frame
@property (nonatomic, assign) CGFloat keyBoardH;

//记录键盘是否显示
@property (nonatomic, assign) BOOL isDisplayKeyborad;

@property (nonatomic, assign) BOOL resignFirstResponder;

@property (nonatomic, weak) id<ChatToolViewDelegate> delegate;

//记录toolview的状态
@property (nonatomic, assign) ToolbarStatus toolbarStatus;

//表情界面
@property (nonatomic, strong) CustomEmojiView *emojiView;

@property (nonatomic, strong) UIScrollView *moreView;

//加个属性 被踢的时候 按钮点击给提示  1 不在群内   2 群不存在
@property (nonatomic, assign) NSInteger isOutGroup; //不在群内


//接收到非群组的消息后开启定时器
-(void)startTimer;

//视频聊天点击事件 暂时暴露出来 控制器里要用
-(void)videoBtnTap:(id)sender;

//语音聊天点击事件 暂时暴露出来 控制器里要用
- (void)callBtnTap:(id)sender;

//暂时暴露出来 控制器里要用
- (void)toolbarDisplayChangedWithStautas:(ToolbarStatus)toolbarStatus;

//键盘状态根据页面显示来监听，处理10.3系统侧滑tableview的frame计算错误问题
- (void)registerKeyboardNotification;
- (void)removeKeyboardNotification;

//ChatToolView的初始化方法  接收chatViewController传过来的值
- (id)initWithframe:(CGRect)rect andSessionId:(NSString *)sessionId andIsGroup:(BOOL)isGroup;


@property (nonatomic, assign) BOOL isDis;


//发送图片相关
- (NSString *)saveToDocument:(UIImage *)image;
- (NSString *)saveToDocumentWithNoThum:(UIImage *)image ;
- (void)sendMediaMessage:(ECFileMessageBody *)mediaBody;
//键盘回收，暂时暴露 控制器用
- (void)chatVCEndKeyBoard;
- (void)SelectCacheDocumentViewController:(HXSendFileViewController *)viewControllerr didSelectCacheObjects:(NSArray *)aCacheObjects albumObjects:(NSArray *)aAlbumObjects;

//更新草稿
- (void)updateDraftData;
- (void)chatViewDidAppear;
//chatvc delloc时，停止录音
- (void)chatVCDisaWillAppear;
// hanwei
- (void)setIsBurn;
//yxp2017
- (void)setCurInputTextView:(NSString *)text;

-(NSString *)getTextViewText;

- (BOOL)textViewIsFirstResponder;

- (void)textViewResignFirstResponder;

- (void)textViewBecomeFirstResponder;
@end
