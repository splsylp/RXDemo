//
//  RXPersoninfoControll.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/7/9.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXPersoninfoControll.h"
#import "SevenSwitch.h"
#import "HYTGroupMemberView.h"
#import "HYTVoipInfoData.h"
#import "HYTCompanyAddress.h"
#import "RXCommonDialog.h"
#import "RXChatMemberView.h"
@interface RXPersoninfoControll ()
@property(nonatomic,retain)NSString *mobile;
@property (retain, nonatomic) UITableView * tableView;
@end

@implementation RXPersoninfoControll

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"聊天详情";

    
    self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.backgroundColor =[UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    // 添加成员(UIScrollView *)[self.chatInfoCell.contentView viewWithTag:100]
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 75*fitScreenWidth)];
    scrollView.backgroundColor=[UIColor clearColor];
    [self.chatInfoCell.contentView addSubview:scrollView];
    //HYTGroupMemberView *memberView = [HYTGroupMemberView classFromNib:@"HYTGroupMemberView"];
    RXChatMemberView *memberView =[[RXChatMemberView alloc]initWithFrame:CGRectMake(0, 0, 64*fitScreenWidth, 64*fitScreenWidth)];
    memberView.backgroundColor =[UIColor clearColor];
    NSLog(@"memberView----%@",NSStringFromCGRect(memberView.frame));
    //[memberView.headerIconView setImageWithURLString:self.book.photourl urlmd5:self.book.urlmd5 placeholderImage:[UIImage imageNamed:@"avatar_01"]];
    
    // memberView.nameLabel.text =!KCNSSTRING_ISEMPTY(self.book.name)?self.book.name:self.book.nickname;
    //memberView.origin = CGPointMake(4, 3);
    [scrollView addSubview:memberView];
    
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [memberView addGestureRecognizer:singleRecognizer];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(memberView.right, 10, 40*fitScreenWidth, 40*fitScreenWidth);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"groups_add_icon"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"groups_add_icon_on"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(onClickAddButton:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addBtn];
    
    if([self.data isKindOfClass:[NSString class]] && self.data)
    {
         _mobile=self.data;
        
        memberView.nameLabel.text=[[DemoGlobalClass sharedInstance] getOtherNameWithPhone:self.mobile];
        NSString *photoUrl =[[DemoGlobalClass sharedInstance] getOtherIMageUrlWithPhonto:self.mobile];
        NSString *sex =[[DemoGlobalClass sharedInstance] getOtherSexWithPhone:self.mobile];
        [memberView.headerIconView setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[sex isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"] options:SDWebImageRefreshCached];

    }
    
    //新消息通知
    NSString *notice_key = [NSString stringWithFormat:@"%@_notice", self.mobile];
    
    NSString *isNotice =[[NSUserDefaults standardUserDefaults]objectForKey:notice_key];
    if(KCNSSTRING_ISEMPTY(isNotice))
    {
        [[self chatNewSwitch] setOn:YES];
    }else
    {
        [[self chatNewSwitch] setOn:NO];
        
    }
    
    [[self chatNewSwitch] addTarget:self action:@selector(didSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    //置顶
    
    NSString *top_key = [NSString stringWithFormat:@"%@_cur_top", self.mobile];
    NSString *top_str =[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,self.mobile]];
    
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
   
}

-(void)handleSingleTap{
    
//    HYTAddressBook * data = [[HYTAddressBook alloc] init];
//    HYTCompanyAddress * address = [HYTCompanyAddress getCompanyAddressInfoDataWithMobilenum:self.mobile];
//    if (address) {
//        data.name = address.name;
//        data.mobilenum = address.mobilenum;
//        data.phones = [NSMutableDictionary dictionaryWithObjectsAndKeys:address.mobilenum,@"手机号", nil];
//        HYTCompanyDeptNameData * deptData = [HYTCompanyDeptNameData quaryCompany:address.department_id];
//        data.others = [NSMutableDictionary dictionaryWithObjectsAndKeys:isCreateCompanyName,@"公司名称",address.place,@"职位",deptData.department_name,@"部门", nil];
//        data.urlmd5 = address.urlmd5;
//        data.photourl = address.photourl;
//        data.signature = address.signature;
//        data.firstLetter = address.fnmname;
//        data.voipaccount = address.voipaccount;
//        data.sex =address.sex;
//    }else{
//        data.name = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:self.mobile];
//        data.mobilenum = self.mobile;
//        data.phones = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.mobile,@"手机号", nil];
//        data.photourl = [[DemoGlobalClass sharedInstance] getOtherIMageUrlWithPhonto:self.mobile];
//        data.sex =[[DemoGlobalClass sharedInstance] getOtherSexWithPhone:self.mobile];
//    }
    [self pushViewController:@"RXContactorInfosViewController" withData:self.mobile withNav:YES];
}

- (void)onClickAddButton:(UIButton *)btn{

    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: KTYPE_GROUPCHATTING,@"style",_mobile, @"member", nil];
    [self pushViewController:@"HYTMediaContactsListViewController" withData:data withNav:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
//    CGRect frame = self.view.bounds;
//    if (iOS7) {
//        
//        frame.size.height=44*3 + 100 + 64;
//        self.tableView.frame=frame;
//        self.tableView.scrollEnabled = NO;
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        
//        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frameWidth, -20)];
//        statusView.backgroundColor = [UIColor whiteColor];
//        [self.navigationController.navigationBar addSubview:statusView];
//    }else{
//        frame.size.height=44*3 + 100;
//        self.tableView.frame=frame;
//        self.tableView.scrollEnabled = NO;
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    }

}
-(void)didSwitchChanged:(id)sender
{
       //置顶
    if(sender ==[self chatTopSwitch])
    {
       // NSString *top_key = [NSString stringWithFormat:@"%@_top", self.data];
        NSString *cur_top_key = [NSString stringWithFormat:@"%@_cur_top", _mobile];
        
        if([self chatTopSwitch].isOn==YES)
        {
           // [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:top_key];
            //[[NSUserDefaults standardUserDefaults] setObject:cur_top_key forKey:SETUPTOP];
            
            [[NSUserDefaults standardUserDefaults] setObject:cur_top_key forKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,_mobile]];
            NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
            [[NSUserDefaults standardUserDefaults]setObject:date forKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,_mobile]];
            
        }else
        {
           // [[NSUserDefaults standardUserDefaults]removeObjectForKey:top_key];
            //[[NSUserDefaults standardUserDefaults]removeObjectForKey:cur_top_key];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,_mobile]];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,_mobile]];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else if(sender ==[self chatNewSwitch])
    {
        NSString *notice_key = [NSString stringWithFormat:@"%@_notice", self.mobile];
        
         if([self chatNewSwitch].isOn==YES)
        {
            NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
            [userGroupId removeObjectForKey:notice_key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else
        {
            NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
            [userGroupId  setObject:@"1" forKey:notice_key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else
    {
        return;
    }
    
}
- (UISwitch *)chatTopSwitch
{
    return (UISwitch *)[self.chatTopCell.contentView viewWithTag:100];
}

- (UISwitch *)chatNewSwitch
{
    return (UISwitch *)[self.chatNewCell.contentView viewWithTag:101];
}
-(void)onClickCleanButton:(id)sender
{
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMID withTapAtBackground:YES];
    dialog.textLabel.text = @"清除聊天记录";
    dialog.selectButtonAtIndex = ^ (NSInteger index){
        if (index == 1) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在清除聊天内容";
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                
                [[IMMsgDBAccess sharedInstance] deleteMessageOfSession:self.mobile];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:self.mobile];
                    [hud hide:YES afterDelay:1.0];
                });
            });
        }
    };
    
    
}
#pragma mark     tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return 3;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.chatInfoCell;
    }else{
        switch (indexPath.row) {
            case 0:
                self.chatTopCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return self.chatTopCell;
                break;
            case 1:
                self.chatNewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return self.chatNewCell;
                break;
            default:
                return self.chatCleanCell;
                break;
        }
    }
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
    if (indexPath.section == 0) {
        return 80*fitScreenWidth;
    }else{
        switch (indexPath.row) {
            case 0:
                return self.chatTopCell.frameHight;
                break;
            case 1:
                return self.chatNewCell.frameHight;
                break;
            default:
                return self.chatCleanCell.frameHight;
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i=201; ; i++) {
        UIView *lineView = [cell.contentView viewWithTag:i];
        if (!lineView) {
            break;
        }
        lineView.backgroundColor = [UIColor colorWithRGB:0xC8C7CC];
        lineView.frameHight = 1/[[UIScreen mainScreen] scale];
    }
}
@end
