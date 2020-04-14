//
//  ChatViewController.h
//  Chat
//
//  Created by 杨大为 on 2017/1/6.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import "BaseViewController.h"
#import "RXCollectData.h"
#import "ECLocationPoint.h"
#import "ChatMoreActionBar.h"

#define KNOTIFICATION_onReceivedGroupNickNameModifyNotice @"KNOTIFICATION_onReceivedGroupNickNameModifyNotice" //群昵称修改通知


typedef enum {
    UserState_None=0,
    UserState_Write,
    UserState_Record,
}UserState;

@interface ChatViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    int hhInt;
    int mmInt;
    int ssInt;
    BOOL p2pFlag;
    BOOL isGroup;
    NSArray *allMembers;
    
}
@property (nonatomic, strong) NSString* sessionId;
@property (nonatomic, assign) BOOL isBurnAfterRead;
@property (nonatomic, assign) BOOL isAppear;
@property (nonatomic, strong) NSMutableArray *messageArray;
//标题
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) ChatMoreActionBar * moreActionBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,copy)NSString * time;
//记录当前播放的语音
@property (nonatomic,strong)ECMessage *voiceMessage;

//外界调用接口
- (instancetype)initWithSessionId:(NSString *)sessionId;
//从搜索历史记录进来的时候
- (instancetype)initWithSessionId:(NSString *)aSessionId andRecodMessage:(ECMessage *)recordMessage;

- (void)addReceviceDataWithBurnMessage:(ECMessage *)message;
@end
