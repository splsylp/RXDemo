//
//  RXChatRecordsViewController.h
//  Chat
//
//  Created by 杨大为 on 2017/1/6.
//  Copyright © 2017年 ronglian. All rights reserved.
//

@interface RXChatRecordsViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic)UITableView *recordTableView;
@property(nonatomic,copy)NSString *sessionId;//聊天ID
@property(nonatomic,strong)NSMutableArray *messageArray;//消息数据
@property(nonatomic,strong)__block NSMutableArray *searchArray;//搜索数据
@property (strong,nonatomic)ECMessage *voiceMessage;//语音消息

@end
