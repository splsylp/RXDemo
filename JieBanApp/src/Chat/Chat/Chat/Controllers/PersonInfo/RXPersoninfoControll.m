//
//  RXPersoninfoControll.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/7/9.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXPersoninfoControll.h"
#import "RXCommonDialog.h"
#import "RXChatMemberView.h"
#import "RXMyFriendList.h"
@interface RXPersoninfoControll ()
@property(nonatomic,retain)NSString *mobile;
@property (retain, nonatomic) UITableView * tableView;
@property (retain, nonatomic) IBOutlet UILabel *topLable;
@property (retain, nonatomic) IBOutlet UILabel *noticeLabel;
@property (retain, nonatomic) IBOutlet UILabel *clearMsgLabel;
@property (retain, nonatomic) IBOutlet UILabel *chatRLabel;
@property (strong, nonatomic) IBOutlet UILabel *lookChatFileLabel;
@property (strong, nonatomic) IBOutlet UIImageView *lookChatFileImgView;
@property (strong, nonatomic) IBOutlet UIImageView *clearChatImgView;
@property (strong, nonatomic) IBOutlet UIImageView *chatHistoryImgView;

@end

@implementation RXPersoninfoControll

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topLable.text = languageStringWithKey(@"置顶聊天");
    self.topLable.font = ThemeFontLarge;
    self.noticeLabel.text = languageStringWithKey(@"消息免打扰");
    self.noticeLabel.font = ThemeFontLarge;
    self.clearMsgLabel.text = languageStringWithKey(@"清空聊天记录");
    self.clearMsgLabel.font = ThemeFontLarge;
    self.chatRLabel.text = languageStringWithKey(@"查看聊天记录");
    self.lookChatFileLabel.text = languageStringWithKey(@"查看聊天文件");
    self.lookChatFileImgView.image = ThemeImage(@"enter_icon_02");
    self.clearChatImgView.image = ThemeImage(@"enter_icon_02");
    self.chatHistoryImgView.image = ThemeImage(@"enter_icon_02");
    self.chatRLabel.font = ThemeFontLarge;
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    self.title=languageStringWithKey(@"聊天详情");
    if (isEnLocalization) {
        self.topLable.font = self.noticeLabel.font = self.clearMsgLabel.font = self.chatRLabel.font =ThemeFontSmall;
    }
    self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, kTotalBarHeight, kScreenWidth, kScreenHeight-kTotalBarHeight)];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
//    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.backgroundColor =[UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    // 添加成员(UIScrollView *)[self.chatInfoCell.contentView viewWithTag:100]
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 75*fitScreenWidth)];
    scrollView.backgroundColor=[UIColor clearColor];
    [self.chatInfoCell.contentView addSubview:scrollView];
    RXChatMemberView *memberView =[[RXChatMemberView alloc]initWithFrame:CGRectMake(0, 0, 64*fitScreenWidth, 64*fitScreenWidth)];
    memberView.backgroundColor =[UIColor clearColor];
    DDLogInfo(@"memberView----%@",NSStringFromCGRect(memberView.frame));
    [scrollView addSubview:memberView];
    
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [memberView addGestureRecognizer:singleRecognizer];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(memberView.right, 10, 40*fitScreenWidth, 40*fitScreenWidth);
    [addBtn setBackgroundImage:ThemeImage(@"btn_add") forState:UIControlStateNormal];
    [addBtn setBackgroundImage:ThemeImage(@"btn_add") forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(onClickAddButton:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addBtn];
    
    //判断权限能否建群
    NSDictionary* dict = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressWithId:withType:" :[NSArray arrayWithObjects:self.data,[NSNumber numberWithInt:0], nil]];
    NSString *personLevel = dict[@"personLevel"];
    addBtn.hidden = ![Common.sharedInstance canCreatGroup:personLevel account:self.data];
    
    if([self.data isKindOfClass:[NSString class]] && self.data)
    {
         _mobile=self.data;
        
        NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:self.mobile withType:0];
       
        
        if(companyInfo.count>0)
        {
            memberView.nameLabel.text=companyInfo[Table_User_member_name];
            NSString *headUrl = companyInfo[Table_User_avatar];
            NSString *md5 = companyInfo[Table_User_urlmd5];
            NSString *userStatus = companyInfo[Table_User_status];
            if([userStatus isEqualToString:@"3"])
            {
                memberView.headerIconView.image = ThemeDefaultHead(memberView.headerIconView.size, RXleaveJobImageHeadShowContent,self.mobile);
            }else
            {
                [memberView.headerIconView setImageWithURLString:headUrl urlmd5:md5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(memberView.headerIconView.size, companyInfo[Table_User_member_name],self.mobile) withRefreshCached:NO];
            }
        }else
        {
            /// eagle 这里可能是手机通讯录
            id addBook = [[AppModel sharedInstance]runModuleFunc:@"KitAddressBookManager" :@"checkAddressBook:" :@[self.mobile] hasReturn:YES];
            NSDictionary *dic = [addBook yy_modelToJSONObject];
            if ([dic hasValueForKey:@"name"] && isOpenPhoneContact) {
                memberView.nameLabel.text = [dic valueForKey:@"name"];
                memberView.headerIconView.image = ThemeDefaultHead(memberView.headerIconView.size, memberView.nameLabel.text,nil);
            }else{
                memberView.nameLabel.text= @"无名称";
                memberView.headerIconView.image = ThemeDefaultHead(memberView.headerIconView.size, memberView.nameLabel.text,self.mobile);
            }
        }
    }
    
    //新消息通知
    NSString *notice_key = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount], self.mobile];
    
    NSString *isNotice =[[NSUserDefaults standardUserDefaults]objectForKey:notice_key];
    if(KCNSSTRING_ISEMPTY(isNotice))
    {
        [[self chatNewSwitch] setOn:NO];
    }else
    {
        [[self chatNewSwitch] setOn:YES];
        
    }
    if(!IsHengFengTarget)
    {
        [[self chatNewSwitch] addTarget:self action:@selector(didSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    //置顶
    NSString *top_key = [NSString stringWithFormat:@"%@_cur_top", self.mobile];
    NSString *top_str = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,self.mobile]];
    if ([top_key isEqualToString:top_str]) {
        [[self chatTopSwitch] setOn:YES];
    }else{
        [[self chatTopSwitch] setOn:NO];
    }
    [[self chatTopSwitch] addTarget:self action:@selector(didSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    // 清除聊天记录
    __weak typeof(self) weak_self = self;
    [self.chatCleanCell whenTapped:^{
        [weak_self onClickCleanButton:nil];
    }];
    //查看聊天记录
    [self.chatHistoryCell whenTapped:^{
        [weak_self onGetMessageHistory];
    }];
    
}
#pragma mark 查看聊天记录
-(void)onGetMessageHistory{
    RXChatRecordsViewController *chatRecordVC =[[RXChatRecordsViewController alloc]init];
    chatRecordVC.sessionId =(NSString *)self.data;
    [self pushViewController:chatRecordVC];
}
-(void)handleSingleTap{
    
    UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:self.mobile];
    [self pushViewController:contactorInfosVC];
}

- (void)onClickAddButton:(UIButton *)btn{
    NSDictionary *exceptData = @{@"members":@[_mobile]};
    UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:exceptData WithType:SelectObjectType_CreateGroupChatSelectMember];
    [self pushViewController:groupVC];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)didSwitchChanged:(id)sender
{
    //置顶
    typeof(self)weak_self=self;
    if(sender ==[self chatTopSwitch])
    {
        // NSString *top_key = [NSString stringWithFormat:@"%@_top", self.data];
        NSString *cur_top_key = [NSString stringWithFormat:@"%@_cur_top", _mobile];
        
        if([self chatTopSwitch].isOn==YES)
        {
            // [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:top_key];
            //[[NSUserDefaults standardUserDefaults] setObject:cur_top_key forKey:SETUPTOP];
            
          
            [[AppModel sharedInstance] setSession:_mobile IsTop:YES completion:^(ECError *error, NSString *seesionId) {
                if (error.errorCode == ECErrorType_NoError) {
                    [[NSUserDefaults standardUserDefaults] setObject:cur_top_key forKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,_mobile]];
                    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                     NSString *str = [NSDate getTimeStrWithDate:date];
                    [[NSUserDefaults standardUserDefaults]setObject:str forKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,_mobile]];
                    DDLogInfo(@"设置置顶成功 seesionId = %@  error.errorCode = %ld",seesionId,(long)error.errorCode);
                    [weak_self sendIMMessageIsTop:YES sessionId:seesionId];
                }
            }];
            
        }else
        {
            // [[NSUserDefaults standardUserDefaults]removeObjectForKey:top_key];
            //[[NSUserDefaults standardUserDefaults]removeObjectForKey:cur_top_key];
            
            
            [[AppModel sharedInstance] setSession:_mobile IsTop:NO completion:^(ECError *error, NSString *seesionId) {
                if (error.errorCode == ECErrorType_NoError) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,_mobile]];
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,_mobile]];
                    DDLogInfo(@"取消置顶成功 seesionId = %@  error.errorCode = %ld",seesionId,(long)error.errorCode);
                    [weak_self sendIMMessageIsTop:NO sessionId:seesionId];
                }
            }];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else if(sender ==[self chatNewSwitch])
    {
        NSString *notice_key = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount], self.mobile];
        __weak typeof (self)weak_self =self;
        if([self chatNewSwitch].isOn==YES)
        {
            [[ECDevice sharedInstance] setMuteNotification:self.mobile isMute:YES completion:^(ECError *error) {
                if (error.errorCode == ECErrorType_NoError) {
                    NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
                    [userGroupId  setObject:@"1" forKey:notice_key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[KitMsgData sharedInstance]updateMessageNoticeid:self.mobile withNoticeStatus:1];
                    [weak_self sendIMMessageisNotice:YES sessionId:weak_self.mobile];
                } else {
                    [weak_self chatNewSwitch].on = ![weak_self chatNewSwitch].on;
                }
            }];
            
            
        }else
        {
            [[ECDevice sharedInstance] setMuteNotification:self.mobile isMute:NO completion:^(ECError *error) {
                if (error.errorCode == ECErrorType_NoError) {
                    NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
                    [userGroupId removeObjectForKey:notice_key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[KitMsgData sharedInstance]updateMessageNoticeid:weak_self.mobile withNoticeStatus:0];
                    [weak_self sendIMMessageisNotice:NO sessionId:weak_self.mobile];
                } else {
                    [weak_self chatNewSwitch].on = ![weak_self chatNewSwitch].on;
                }
            }];
    
        }
    }else
    {
        return;
    }
    
}
//   设置/取消新消息通知 发送CMD消息
- (void)sendIMMessageisNotice:(BOOL)isNotice sessionId:(NSString *)sessionId{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"isMute"] = @(isNotice);
    mDic[@"sessionId"] = sessionId;
    mDic[@"type"] = @(ChatMessageTypeMessageNoticeterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
}
//置顶/取消置顶之后，发送CMD消息
- (void)sendIMMessageIsTop:(BOOL)isTop sessionId:(NSString *)sessionId{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"isTop"] = @(isTop);
    mDic[@"sessionId"] = sessionId;
    mDic[@"type"] = @(ChatMessageTypeTopterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
}

- (UISwitch *)chatTopSwitch
{
    return (UISwitch *)[self.chatTopCell.contentView viewWithTag:100];
}

- (UISwitch *)chatNewSwitch
{
    return (UISwitch *)[self.chatNewCell.contentView viewWithTag:101];
}

- (void)onClickCleanButton:(id)sender {
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:languageStringWithKey(@"清空聊天记录") subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
        if (index == 1) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KitMsgData sharedInstance] deletemessageid:self.mobile];
                if ([self.personinfoDelegate respondsToSelector:@selector(personinfoControll:didSelectedIndexPath:)]) {
                    NSIndexPath *idx = [NSIndexPath indexPathForRow:2 inSection:0];
                    [self.personinfoDelegate personinfoControll:self didSelectedIndexPath:idx];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:self.mobile];
                });
            });
        }
    }];
}
#pragma mark     tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1 || section == 2) {
        if(IsHengFengTarget)
        {
            return 1;
        }
        return 2;
    }
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.chatInfoCell;
    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            
                case 0://置顶
            {
               
                self.chatTopCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return self.chatTopCell;
            }
                break;
            case 1://新消息通知
            {
                self.chatNewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return self.chatNewCell;
            }
                break;
        }
    }else if (indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
                return self.chatHistoryCell;
                break;
            case 1:
                return self.lookChatFileCell;
                break;
        }
    }
    //清除聊天记录
    self.chatCleanCell.separatorInset = UIEdgeInsetsMake(0, kScreenWidth, 0, 0);
    return self.chatCleanCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == 0) {
        return 0;
    }else{
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {//个人信息
        return 80*fitScreenWidth;
    }
    return  44*FitThemeFont;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 1://查看聊天文件
            {
                RXChatFilesViewController *vc = [RXChatFilesViewController new];
                vc.sessionId = self.data;
                [self pushViewController:vc];
            }
                break;
        }
    }
}

@end
