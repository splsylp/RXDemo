//
//  RXChatRecordsViewController.h
//  Chat
//
//  Created by 杨大为 on 2016/12/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

@interface RXChatRecordsViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,copy)NSString *sessionId;//聊天ID
//@property(nonatomic,copy)NSString *titleName;//标题
@property(nonatomic,strong)NSMutableArray *messageArray;//消息数据
@property(nonatomic,strong)NSMutableArray *searchArray;//搜索数据

@end
