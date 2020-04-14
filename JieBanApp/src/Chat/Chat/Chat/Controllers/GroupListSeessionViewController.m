//
//  GroupListSeessionViewController.m
//  Chat
//
//  Created by mac on 2017/1/16.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "GroupListSeessionViewController.h"
#import "SessionViewCell.h"
#import "ECSession.h"
#import "RXGroupHeadImageView.h"
#import "RXNaviMenuView.h"
#import "ChatViewController.h"

extern CGFloat NavAndBarHeight;
@interface GroupListSeessionViewController ()
@property (nonatomic, strong) NSMutableArray *sessionArray;
@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, strong) ECGroupNoticeMessage *message;
@property (nonatomic, strong) UIView * linkview;

@property (nonatomic, strong) UIView *menuView;//背景view
@property (nonatomic, strong) NSMutableArray * companyData;
@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic, strong) UIButton *unreadCountBtn;//未读消息条数
@property (nonatomic, strong) UIImageView * noMsgImageView;//暂无沟通记录
@end

@implementation GroupListSeessionViewController{
    UITableViewCell * _memoryCell;
    //LinkJudge linkjudge;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    _companyData=nil;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    self.view.backgroundColor =[UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    
    [self setTitle:languageStringWithKey(@"我的群组")];
    
    [self createTableView];
    self.sessionArray = [NSMutableArray arrayWithCapacity:0];
    self.groupList = [NSMutableArray arrayWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onMesssageChanged object:nil];//msgchanged
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareDisplay) name:KNotification_DeleteLocalSessionMessage object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onReceivedGroupNotice object:nil];//群组通知
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkSuccess:) name:KNOTIFICATION_onConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReloadSessionGroup:) name:
     KNotice_ReloadSessionGroup object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareDisplay) name:kDeleteMessage object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getGroupListCount];
    });
    [self prepareDisplay];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_update_session_im_message_num object:nil];
    //创建音视频入口
    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_add_01.png") highlightedImg:ThemeImage(@"title_bar_add_on_01.png")  target:self action:@selector(createNavAction:) type:NavigationBarItemTypeRight];
    
    [self prepareDisplay];
    
}

//创建表格
-(void)createTableView{
    if (self.tabBarController) {
        self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0.0f, 0, kScreenWidth, kScreenHeight-kTotalBarHeight-49) style:UITableViewStylePlain];
    } else {
        self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0.0f, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    }
    self.tableView.backgroundColor=self.view.backgroundColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor=[UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];;
    [self.view addSubview:self.tableView];
    
}

#pragma mark 弹窗  创建群聊、语音和视频会议
-(void)createNavAction:(id)sender
{
    __weak typeof(self)weak_self=self;
    RXNaviMenuView *naviMenuView =[RXNaviMenuView presentModalDialogWithRect:CGRectZero WidthDelegate:nil withPos:EContentPosTOPWithNaviK withTapAtBackground:YES];
    [naviMenuView updateSubViewLayout:CGRectMake(self.view.frame.size.width - 112 - 5, kTotalBarHeight, 112, 179)];
    naviMenuView.fetchTitleArray =  ^ NSArray*(void) {
        //        return [NSArray arrayWithObjects:@"发起群聊",@"语音会议",@"视频会议",nil];
        return [NSArray arrayWithObjects:languageStringWithKey(@"发起群聊"),nil];
    };
    naviMenuView.fetchImageArray=^NSArray*(void)
    {
        return [NSArray arrayWithObjects:@"icon_groupchat",nil];
    };
    naviMenuView.selectRowAtIndex =  ^(RXNaviMenuView *naviMenuView,NSInteger index){
        
        switch (index) {
            case 100:
            {
                //发起群聊
                DDLogInfo(@"---------------发起群聊");
                UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{} WithType:SelectObjectType_CreateGroupChatSelectMember];
                [self pushViewController:groupVC];
            }
                break;
            case 101:
            {
                //语音会议
                DDLogInfo(@"---------------语音会议");
                UIViewController *voiceMeetingVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{} WithType:SelectObjectType_CreatePhoneMeetingSelectMember];
                [self pushViewController:voiceMeetingVC];
            }
                break;
            case 102:
            {
                //视频会议
                UIViewController *videoMeetingVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{} WithType:SelectObjectType_CreateVideoMeetingSelectMember];
                [self pushViewController:videoMeetingVC];
            }
                break;
            case 103:
            {
#pragma mark vidyo会议入口
                //vidyo会议
                //                DDLogInfo(@"---------------vidyo会议");
                //                VidyoSelectViewController *vidyoSelectVC = [[VidyoSelectViewController alloc]init];
                //                    if ([VidyoHelper shareInstance].vidyoClientStarted) {
                //                        [SVProgressHUD showErrorWithStatus:@"当前已处于会议中" duration:1.2];
                //                    }else{
                //                        if ([[Chat sharedInstance] getMobile]) {
                //                            KitCompanyAddress *addressBook = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:[[Chat sharedInstance] getMobile]];
                //                            NSMutableArray *list = [NSMutableArray arrayWithArray:[VidyoHelper shareInstance].vidyoMembers];
                //                            [list removeAllObjects];
                //                            [list insertObject:addressBook atIndex:0];
                //                            vidyoSelectVC.memeberArr = list;
                //                            [self presentViewController:vidyoSelectVC animated:YES completion:nil];
                //                        }
                //                    }
            }
                break;
            default:
                break;
        }
    };
}
/*
 -(void)updateLoginStates:(LinkJudge)link {
 
 if (link == success) {
 _tableView.tableHeaderView = nil;
 [_linkview removeFromSuperview];
 _linkview = nil;
 } else {
 
 [_linkview removeFromSuperview];
 _linkview = nil;
 
 _linkview = [[UIView alloc]initWithFrame:CGRectMake(0, 0.0, kScreenWidth, 45.0f)];
 _linkview.backgroundColor = [UIColor colorWithRed:1.00f green:0.87f blue:0.87f alpha:1.00f];
 if (link==failed) {
 UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 30, 30)];
 image.image = ThemeImage(@"messageSendFailed.png");
 UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, kScreenWidth-50 , 45)];
 label.backgroundColor = [UIColor clearColor];
 label.font = ThemeFontMiddle;
 label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
 label.text = @"无法连接到服务器";
 [_linkview addSubview:image];
 [_linkview addSubview:label];
 [KitGlobalClass sharedInstance].isLogin=NO;
 
 } else if(link == linking) {
 UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kScreenWidth-10 , 45)];
 label.font = ThemeFontMiddle;
 label.backgroundColor = [UIColor clearColor];
 label.text = @"连接中...";
 label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
 [_linkview addSubview:label];
 }
 
 else if(link == relinking) {
 UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kScreenWidth-10 , 45)];
 label.font = ThemeFontMiddle;
 label.backgroundColor = [UIColor clearColor];
 label.text = @"正在重连中，请稍后...";
 label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
 [_linkview addSubview:label];
 }
 
 _tableView.tableHeaderView = _linkview;
 }
 }*/


-(void)topviewshow
{
    [self.groupList removeAllObjects];
    for (ECSession *session in self.sessionArray) {
        if([session.sessionId hasPrefix:@"g"]) {
            [self.groupList addObject:session];
        }
    }
    if(self.groupList && self.groupList.count>0)
    {
        NSMutableArray *timeArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *sessionDic =[[NSMutableDictionary alloc]init];
        for(NSUInteger i =self.groupList.count-1; i<self.groupList.count;i--)
        {
            ECSession* session=self.groupList[i];
            NSString *strTop =[NSString stringWithFormat:@"%@_cur_top",session.sessionId];
            NSString *topStr=[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
            
            if([topStr isEqualToString:strTop])
            {
                //置顶
                [self.groupList removeObjectAtIndex:i];
//                NSDate *date =[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                
                NSString *dateStr = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                if ([dateStr isKindOfClass:[NSDate class]]) {
                    dateStr = [NSDate getTimeStrWithDate:(NSDate *)dateStr];
                    NSLog(@"11");//.
                }
                [timeArray addObject:dateStr];
                [sessionDic setObject:session forKey:dateStr];
                //break;
            }
        }
        
        NSArray *sortArray =[timeArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSComparisonResult result = [obj1 compare:obj2];
            switch(result)
            {
                case NSOrderedAscending:
                    return NSOrderedDescending;
                case NSOrderedDescending:
                    return NSOrderedAscending;
                case NSOrderedSame:
                    return NSOrderedSame;
                default:
                    return NSOrderedSame;
            }
        }];
        
        for(int i=0;i<sortArray.count;i++)
        {
            
            NSString *dateStr =sortArray[i];
            for(NSString *dateSess in sessionDic.allKeys)
            {
                if([dateStr isEqualToString:dateSess])
                {
                    ECSession* session =[sessionDic objectForKey:dateSess];
                    [self.groupList insertObject:session atIndex:i];
                }
            }
//            NSDate *date =sortArray[i];
//            for(NSDate *dateSess in sessionDic.allKeys)
//            {
//                if([date isEqualToDate:dateSess])
//                {
//                    ECSession* session =[sessionDic objectForKey:dateSess];
//                    [self.groupList insertObject:session atIndex:i];
//                }
//            }
        }
    }
}

//外界关闭控制器的方法
-(void)shouldDismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 获取群组列表个数
- (void)getGroupListCount{
    [[ECDevice sharedInstance].messageManager queryOwnGroupsWith:ECGroupType_All completion:^(ECError *error, NSArray *groups) {
        if (error.errorCode == ECErrorType_NoError) {
            if(groups.count > 0){
                [[KitMsgData sharedInstance] addGroupIDs:groups];
            }else{
                [[KitMsgData sharedInstance] deleteAllGroupInfo];
            }
        }else{
            if(error&&error.errorDescription){
                DDLogInfo(@"群组列表获取失败----reason:%@",error);
            }
        }
    }];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.groupList.count == 0) {
        return 170.0f;
    }
    return 60.0f*[ChatTools isIphone6PlusProPortionHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECSession * session;
    if (self.groupList.count == 0) {
        return;
    }
    
    session = [self.groupList objectAtIndex:indexPath.row];
    
    session.isAt = NO;
    [[KitMsgData sharedInstance] updateSession:session];
    
    session.unreadCount = 0;
    if (session.type == 100) {
        //系统通知
        //NSArray *array =[session.text componentsSeparatedByString:@"\""];
        //[self pushViewController:@"GroupNoticeViewController" withData:nil withNav:YES];
        
    } else {
        //聊天界面入口
        ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:session.sessionId];
        //        [self pushViewController:@"ChatViewController" withData:session.sessionId withNav:YES];
        [self pushViewController:chatVC];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.groupList.count == 0) {
        return 1;
    }else{
        return _groupList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (self.groupList.count == 0) {
        static NSString *noMessageCellid = @"sessionnomessageCellidentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noMessageCellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noMessageCellid];
        }
        [self.noMsgImageView removeFromSuperview];
        UIImage * noMsgImage = ThemeImage(languageStringWithKey(@"nosession"));
        self.noMsgImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - noMsgImage.size.width)/2, 100, noMsgImage.size.width, noMsgImage.size.height)];
        self.noMsgImageView.image = noMsgImage;
        [cell.contentView addSubview:self.noMsgImageView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        return cell;
    }
    
    static NSString *sessioncellid = @"sessionCellidentifier";
    SessionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sessioncellid];
    
    if (cell == nil) {
        
        cell = [[SessionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sessioncellid];
        
        cell.backgroundColor=[UIColor clearColor];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    cell.portraitImg.hidden = NO;
    cell.groupHeadView.hidden = YES;
    
    ECSession* session = [_groupList objectAtIndex:indexPath.row];
    cell.session = session;
    //系统通知type=100
    if (session.type == 100) {
        
        cell.nameLabel.text = session.sessionId;
        cell.portraitImg.image = ThemeImage(@"logo80x80.png");
    } else {
        
        //群组消息
        if([session.sessionId hasPrefix:@"g"])
        {
            cell.nameLabel.text = [[Common sharedInstance] getOtherNameWithPhone:session.sessionId];
            
            [self loadGroupHeadImage:cell withGroupId:session.sessionId];
        }else
        {
            //个人聊天
            NSString * sessionStr = session.sessionId;
            cell.contentLabel.text = session.text;
            
            //cell复用时取消当前异步下载线程，解决头像错乱问题
            [cell.portraitImg sd_cancelCurrentImageLoad];
            
            NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:sessionStr withType:0];
            NSString *sex=@"";
            if(companyInfo)
            {
                cell.nameLabel.text = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
                sex = companyInfo[Table_User_sex];
                NSString *headImageUrl = companyInfo[Table_User_avatar];
                NSString *userStatus = companyInfo[Table_User_status];
                
                if([userStatus isEqualToString:@"3"])
                {
                    cell.portraitImg.image = ThemeDefaultHead(cell.portraitImg.size, RXleaveJobImageHeadShowContent,sessionStr);
                }else
                {
                    if([headImageUrl hasPrefix:@"http"] && companyInfo[@"urlmd5"])
                    {
                        [cell.portraitImg setImageWithURLString:headImageUrl urlmd5:companyInfo[@"urlmd5"] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(cell.portraitImg.size, companyInfo[Table_User_member_name],sessionStr) withRefreshCached:NO];
                    }else
                    {
                        cell.portraitImg.image = ThemeDefaultHead(cell.portraitImg.size, companyInfo[Table_User_member_name],sessionStr);
                        
                    }
                }
            }else
            {
                cell.nameLabel.text = sessionStr;
                cell.portraitImg.image = ThemeDefaultHead(cell.portraitImg.size, sessionStr,sessionStr);
            }
        }
    }
    //时间，内容和未读显示
    NSArray* message = [[KitMsgData sharedInstance] getLatestHundredMessageOfSessionId:session.sessionId andSize:15 andASC:YES];
    if(message.count<1 && session.type!=100)
    {
        cell.contentLabel.text=@"";
        cell.dateLabel.text=@"";
        
    }else
    {
        cell.contentLabel.text = session.text;
        cell.dateLabel.text = [ChatTools getSessionDateDisplayString:session.dateTime];
    }
    
    if (session.unreadCount == 0) {
        cell.unReadLabel.hidden =YES;
    }else{
        if ((int)session.unreadCount>99) {
            cell.unReadLabel.text = @"...";
        }else{
            cell.unReadLabel.text = [NSString stringWithFormat:@"%d",(int)session.unreadCount];
        }
        cell.unReadLabel.hidden =NO;
    }
    
    //置顶颜色
    NSString *strTop =[NSString stringWithFormat:@"%@_cur_top",session.sessionId];
    NSString *topStr=[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
    
    if([topStr isEqualToString:strTop])
    {
        cell.backgroundColor =[UIColor colorWithHex:0xeeeeeeff];
    }else{
        cell.backgroundColor =[UIColor whiteColor];
    }
    return cell;
}
//置顶颜色
- (UIColor *)colorWithHex:(int)color {
    
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
-(void)loadGroupHeadImage:(SessionViewCell *)cell withGroupId:(NSString *)groupId
{
    NSArray *members =[KitGroupMemberInfoData getSequenceMembersforGroupId:groupId memberCount:9];
    
    cell.portraitImg.image = ThemeImage(@"icon_groupdefaultavatar");
    if(members.count==1)
    {
        KitGroupMemberInfoData *info =members[0];
        if([info.role isEqualToString:@"1"] || [info.role isEqualToString:@"2"])
        {
            cell.portraitImg.image = ThemeImage(@"icon_groupdefaultavatar");
            return;
        }
    }
    
    if(members.count>1){
        //直接加载头像 先查看本地 后加载网络
        cell.portraitImg.hidden = YES;
        cell.groupHeadView.hidden=NO;
        [cell.groupHeadView createHeaderViewH:cell.portraitImg.width withImageWH:cell.portraitImg.width groupId:groupId withMemberArray:members];
        
    }else{
        if ([[Common sharedInstance].cacheGroupMemberRequestArray containsObject:groupId]) {
            return;
        }else{
            [[Common sharedInstance].cacheGroupMemberRequestArray addObject:groupId];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                [[ECDevice sharedInstance].messageManager queryGroupMembers:groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
                    [[Common sharedInstance].cacheGroupMemberRequestArray removeObject:groupId];
                    
                    if (error.errorCode == ECErrorType_NoError && members.count>0) {
                        [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                        [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
                        //wwl 群组头像刷新改为通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:groupId];
                    }
                }];
            });
        }
        
    }
    
}

#pragma mark 编辑按钮
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//侧滑删除置顶功能
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"删除") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self deleteCell:indexPath];
    }];
    __weak ECSession* session = [_groupList objectAtIndex:indexPath.row];
    UITableViewRowAction *topRowAction;
    if(session.type!=100)
    {
        NSString *top_key = [NSString stringWithFormat:@"%@_cur_top", session.sessionId];
        NSString *top_str =[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
        typeof(self)weak_self=self;
        if([top_str isEqualToString:top_key])
        {
            topRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"取消置顶") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                
                [[AppModel sharedInstance] setSession:session.sessionId IsTop:NO completion:^(ECError *error, NSString *seesionId) {
                    
                    if (error.errorCode == ECErrorType_NoError) {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
                        [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        DDLogInfo(@"取消置顶成功 seesionId = %@  error.errorCode = %ld",seesionId,(long)error.errorCode);
                        [weak_self sendIMMessageIsTop:false sessionId:session.sessionId];
                        //                        [weak_self prepareDisplay];
                    }
                }];
            }];
        }else
        {
            topRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"置顶") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
               
                [[AppModel sharedInstance] setSession:session.sessionId IsTop:YES completion:^(ECError *error, NSString *seesionId) {
                    if (error.errorCode == ECErrorType_NoError) {
                        [[NSUserDefaults standardUserDefaults] setObject:top_key forKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
                        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                         NSString *str = [NSDate getCurrentTimeStr];
                        [[NSUserDefaults standardUserDefaults]setObject:str forKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,session.sessionId]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        DDLogInfo(@"置顶成功 seesionId = %@  error.errorCode = %ld",seesionId,(long)error.errorCode);
                        [weak_self sendIMMessageIsTop:true sessionId:session.sessionId];
                        //                        [weak_self  prepareDisplay];
                    }
                }];
            }];
        }
        topRowAction.backgroundColor=[UIColor lightGrayColor];
        
        return @[deleteRowAction,topRowAction];
    }
    
    return @[deleteRowAction];
    
}
///置顶/取消置顶之后，发送CMD消息
- (void)sendIMMessageIsTop:(BOOL)isTop sessionId:(NSString *)sessionId{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"isTop"] = @(isTop);
    mDic[@"sessionId"] = sessionId;
    mDic[@"type"] = @(ChatMessageTypeTopterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete && !iOS8){
        [self deleteCell:indexPath];
    }
}
//时间显示内容
- (NSString *)getDateDisplayString:(long long) miliSeconds{
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.day==myCmps.day) {
        // dateFmt.dateFormat = @"今天 HH:mm:ss";
        
        dateFmt.dateFormat=@"HH:mm";
    } else if((nowCmps.day-myCmps.day)==1) {
        // dateFmt.dateFormat = @"昨天 HH:mm:ss";
        dateFmt.dateFormat=languageStringWithKey(@"昨天");
    }else if((nowCmps.day-myCmps.day)==2) {
        // dateFmt.dateFormat = @"昨天 HH:mm:ss";
        dateFmt.dateFormat=languageStringWithKey(@"前天");
    }
    else if(nowCmps.year != myCmps.year){
        dateFmt.dateFormat = @"yyyy-MM-dd";
    }  else {
        dateFmt.dateFormat = @"MM-dd";
    }
    return [dateFmt stringFromDate:myDate];
}

- (void)deleteCell:(NSIndexPath *)indexPath;{
    [SVProgressHUD showWithStatus:languageStringWithKey(@"删除中")];
    ECSession* session = [self.groupList objectAtIndex:indexPath.row]; dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (session.type == 100) {
            [[KitMsgData sharedInstance] clearGroupMessageTable];
        } else {
            [[Common sharedInstance] deleteAllMessageOfSession:session.sessionId];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        });
    });
}
#pragma mark - 通知相关
//刷新列表
-(void)prepareDisplay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sessionArray removeAllObjects];
        [self.sessionArray addObjectsFromArray:[[KitMsgData sharedInstance] getMyCustomSession]];
        [self topviewshow];
        [self.tableView reloadData];
    });
}

//-(void)linkSuccess:(NSNotification *)link {
//    ECError* error = link.object;
//    if (error.errorCode == ECErrorType_NoError) {
//        [self updateLoginStates:success];
//    } else if (error.errorCode == ECErrorType_Connecting) {
//        [self updateLoginStates:linking];
//    }else if (error.errorCode == 999998) {
//        [self updateLoginStates:relinking];
//    }
//    else {
//        [self updateLoginStates:failed];
//    }
//}
//刷新沟通界面显示群组信息
- (void)ReloadSessionGroup:(NSNotification *)not{
    NSString* groupId = not.object;
    if (KCNSSTRING_ISEMPTY(groupId)) {
        [self.tableView reloadData];
    }else{
        for (int i = 0; i<_sessionArray.count; i++) {
            
            ECSession* session = [_sessionArray objectAtIndex:i];
            if ([session.sessionId isEqualToString:groupId]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

@end
