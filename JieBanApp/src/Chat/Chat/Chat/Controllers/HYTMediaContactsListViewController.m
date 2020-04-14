//
//  HYTMediaContactsListViewController.m
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-5.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "HYTMediaContactsListViewController.h"
#import "KitAddressBookManager.h"
#import "HYTSelectedMediaContactsCell.h"
#import "RXDeptSelectTableViewCell.h"
#import "RXCommonSelectedDialog.h"
#import "KitCompanyAddress.h"
#import "KitCompanyData.h"
#import "KitCompanyDeptNameData.h"
#import "ChatViewController.h"
#import "CustomScrollView.h"
#import "RXSelectContactSectionView.h"
#import "RXSearchTextView.h"
#import "RXSelectJoinMeetView.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIView+WaitingView.h"
#import "NSAttributedString+Color.h"
#import "RXCompanyUpManager.h"

#pragma mark - zmfg 语音会议相关
//#import "RXMeettingViewController.h"
#pragma mark - zmfg 通讯录相关
//#import "RXContactorInfosViewController.h"
#pragma mark - zmfg 白板相关
//#import "BoardCoopHelper.h"
#pragma mark - zmfg 视频会议相关
//#import "MultiVideoConfViewController.h"
#define kVIDYOMAXCOUNT 5
#define kMAXSELECTEDCOUNT 50
#define KTYPE_VIDYOMEETTING @"ktype_vidyomeetting"

static BOOL isFirst =YES;

typedef NS_ENUM(NSInteger, RXSelectContactType) {
    
    /** 点对点聊天邀请其它成员加入创建群组 */
    SelectContact_ChatRoomCreateGroup,
    
    /** 创建视频会议(vidyo) */
    SelectContact_CreateVidyoRoom,

    /** 加入1688会议(vidyo) */
    SelectContact_InviteMeetRoom,
    
    
};

@interface HYTMediaContactsListViewController ()<HYTSelectedMediaContactsCellDelegate,selectSectionViewDelegate,DeleteContactDelgate,RXSearchTextViewDelagate,RXSelectedDeptCellDelegate>{
    NSMutableArray *addressSearchData;
    
    BOOL isCompanyShow;
    BOOL isPhoneShow;
    BOOL isShowMygroup;//显示群组(用于转发)
    BOOL isSharedNum;
    NSInteger selectDeptIndex;
    
    BOOL isAnon_sender;
    
    UIButton * AllSelect;//全选按钮
    BOOL isSelect;
    BOOL isGroupInvite;
    
    NSString * MeettingTyle;
    
//    CGFloat customScrollViewHeight;
    CGFloat addContactViewHeight;
    
    NSUInteger deptLevel;
    NSMutableArray *arrayCount;
    BOOL isInputMeetting;
    BOOL isRefuesh;
    BOOL isInputUserInfo;
    
    NSString * member;//点对点邀请
    NSArray * _members;//群组邀请
    BOOL isGroup;
    
    BOOL isBurn;//是否为阅后即焚
    BOOL isAnon;//是否为匿名聊天
    BOOL selectBurn;
    
    BOOL isFileCoopreate;
    BOOL isVidyoShow;//vidyo
    BOOL isVidyo;
//    NSInteger maxSelectedCount;
    
    RXSelectContactType selectType;
}
@property (nonatomic, strong)UITableView *tableView;
//@property (nonatomic, strong) CustomScrollView * customScrollView;
@property (nonatomic, strong) RXSelectContactSectionView * phoneView;
@property (nonatomic, strong) RXSelectContactSectionView * companyView;
@property (strong, nonatomic) RXSelectContactSectionView *myGroupVIew;
@property (nonatomic, strong) RXSearchTextView * searchView;
@property (nonatomic, strong) UILabel * phoneNumLab;//搜索的号码或者陌生号码
//企业联系人
@property (strong,nonatomic) NSMutableArray* addressBook;

@property (strong,nonatomic) NSMutableDictionary* addJson;
@property(nonatomic,retain)NSMutableArray *companyData;//企业所有员工
@property(nonatomic,retain)NSMutableArray *resultJson;
@property (strong, nonatomic) NSMutableArray *DeptArray;
@property (strong, nonatomic) NSMutableArray *MainDeptArray;
@property (strong, nonatomic) NSMutableDictionary *personDictionary;
@property (strong, nonatomic) NSMutableDictionary *DeptDictionary;
@property (strong, nonatomic) NSMutableArray *currentListArray;//搜索后的联系人和部门
@property (strong,nonatomic)NSMutableArray* companyDeptList;//企业部门和联系人
@property(nonatomic,retain)NSMutableArray *otherDeptList;
@property (strong, nonatomic) NSMutableArray *idArray;
@property (strong, nonatomic) NSMutableArray *deptGradeArray;//层次分级
@property (strong, nonatomic) NSMutableDictionary *deptGradeDic;//层次分级
@property (strong, nonatomic) NSMutableDictionary *idDict;
//手机联系人
@property (nonatomic, strong) NSMutableDictionary *localAddressBook;
@property (nonatomic, strong) NSArray *allAddressKeys;
//最近联系人
@property (nonatomic, strong) NSMutableArray * recentlyContactData;
//企业和手机联系人
@property (nonatomic, strong) NSMutableArray * allContactData;

//存储联系人和部门选中状态
@property (nonatomic, strong) NSMutableDictionary * selectDeptStatusDic;
@property (nonatomic, strong) NSMutableDictionary * selectPersonStatusDic;

@property (strong, nonatomic) NSString *DeptPerSon;
@property (strong, nonatomic) NSString *DeptName;
@property (strong, nonatomic)  NSString *P_department_id;
@property (strong, nonatomic)  NSString *P_partet_id;

@property (strong,nonatomic)UIButton *leftButton;
@property (strong,nonatomic)UIButton *rightButton;

@property (nonatomic,strong) NSString * groupId;//群组id


@property (nonatomic,strong) NSArray *searchArray;


@property (nonatomic, strong)NSMutableArray *existMemArray;
@property (strong,nonatomic)NSMutableArray *callList;
@property (strong,nonatomic)NSMutableArray *totalList;
@property (nonatomic,strong) NSMutableArray * vidyoRoomSelectList;//vidyo
@property (strong,nonatomic) NSMutableArray* selectedList;//获取邀请加入的成员

@end


@implementation HYTMediaContactsListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
-(void)removeIncludeMember:(NSMutableArray * )array
{
    NSArray *members = [self.data objectForKey:@"members"];
    for (int i=0; i<array.count; i++) {
        KitAddressBook *book = [array objectAtIndex:i];
        for (NSString *voipaccount in members) {
            if ([book.voipaccount isEqualToString:voipaccount]) {
                [array removeObject:book];
                i--;
                break;
            }
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* style;
    if ([self.data isKindOfClass:[NSDictionary class]]) {
        style = [self.data objectForKey:@"style"];
         if ([style isEqualToString:KTYPE_VIDYOMEETTING]){
            selectType = SelectContact_CreateVidyoRoom;
             isVidyo = YES;
         }else if ([style isEqualToString:KINVITE_JOINMEEtting]){
             _existMemArray = [self.data objectForKey:@"existMeetMemberList"];
         }
    }
    
    self.P_department_id = @"0";
    MeettingTyle = [NSString stringWithFormat:KVOICETYPE_RONXINMEETTING];;//默认容信参会
    self.DeptArray = [[NSMutableArray alloc]init];
    self.deptGradeArray=[[NSMutableArray alloc]init];
    self.personDictionary = [NSMutableDictionary dictionary];
    self.selectDeptStatusDic = [NSMutableDictionary dictionary];
    self.selectPersonStatusDic = [NSMutableDictionary dictionary];
    _vidyoRoomSelectList = [NSMutableArray array];
    
    //手机通讯录
    [self getMobileAddress];
    
    //最近联系人数据
    [self reloadCompanyRecentlyContactData];

     [self createSearchView];
    [self showNavView];
    
    [self reloadCompanyData];
    
   
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCurrentIndex:) name:kNotification_update_current_index object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notConnetNet:) name:kNetConnectFail object:nil];

}

#pragma 导航显示view 及 对应的参数赋值
-(void)showNavView
{
    UIView *titleView =[[UIView alloc]initWithFrame:CGRectMake(0.0, 9.5, 100*fitScreenWidth, 25.0)];
    titleView.backgroundColor =[UIColor clearColor];
    titleView.layer.cornerRadius=3;
    titleView.layer.masksToBounds=YES;
    self.navigationItem.titleView=titleView;
    
    NSString* style;
    if ([self.data isKindOfClass:[NSDictionary class]]) {
        style = [self.data objectForKey:@"style"];
    }
    
    if (style && [style isEqualToString:KTYPE_VOICEMEETTING]) {
        
        [self setBarButtonWithNormalImg:[UIImage imageNamed:@"title_bar_prompt_01"]
                         highlightedImg:[UIImage imageNamed:@"title_bar_prompt_01"]
                                 target:self
                                 action:@selector(onClickRightPrompt)
                                   type:NavigationBarItemTypeRight];
        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
        
        _leftButton.frame=CGRectMake(0.0, 0.0, 50*fitScreenWidth, 25.0);
        _leftButton.tag=1000;
        [_leftButton setTitle:@"手机参会" forState:UIControlStateNormal];
        _leftButton.titleLabel.font=[UIFont systemFontOfSize:11.0*fitScreenWidth];
        [_leftButton setTitleColor:[UIColor colorWithRed:0.42f green:0.82f blue:0.60f alpha:1.00f] forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"title_tab_left"] forState:UIControlStateNormal];
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"title_tab_left_on"] forState:UIControlStateHighlighted];
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"title_tab_left_on"] forState:UIControlStateSelected];
        [_leftButton addTarget:self action:@selector(onClickTypeJoinMeetBtn:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:_leftButton];
        _rightButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame=CGRectMake(50.0*fitScreenWidth, 0.0, 50*fitScreenWidth, 25.0);
        _rightButton.tag=1001;
        [_rightButton setTitle:@"容信参会" forState:UIControlStateNormal];
        _rightButton.titleLabel.font=[UIFont systemFontOfSize:11.0*fitScreenWidth];
        [_rightButton setTitleColor:[UIColor colorWithRed:0.42f green:0.82f blue:0.60f alpha:1.00f] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"title_tab_right"] forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"title_tab_right_on"] forState:UIControlStateHighlighted];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"title_tab_right_on"] forState:UIControlStateSelected];
        _rightButton.selected=YES;
        [_rightButton addTarget:self action:@selector(onClickTypeJoinMeetBtn:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:_rightButton];
        
        
    }else if([style isEqualToString:KTYPE_BURNCHATTING])//阅后即焚
    {
        isBurn = YES;
        _titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100*fitScreenWidth, 25.0)];
        _titleLabel.text=@"选择联系人";
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.backgroundColor= [UIColor clearColor];
        [titleView addSubview:_titleLabel];
    }else if([style isEqualToString:KTYPE_ANONCHATTING])//匿名讨论
    {
        isAnon = YES;
        isGroup = YES;
        _titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100*fitScreenWidth, 25.0)];
        _titleLabel.text=@"选择联系人";
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.backgroundColor= [UIColor clearColor];
        [titleView addSubview:_titleLabel];
    }else if ([style isEqualToString:KTYPE_GROUPCHATTING]) {
        self.groupId = nil;
        member = [self.data objectForKey:@"member"];//点对点邀请创建群聊
        isGroup = YES;
        _titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100*fitScreenWidth, 25.0)];
        _titleLabel.text=@"选择联系人";
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.backgroundColor= [UIColor clearColor];
        [titleView addSubview:_titleLabel];
        
    }else if ([style isEqualToString:KTYPE_VOICEMEETTING]) {
        //电话会议 由tabbar中加号键发起
        MeettingTyle = [NSString stringWithFormat:KVOICETYPE_TELEPHONEMEETTING];//默认容信参会
        _titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100*fitScreenWidth, 25.0)];
        _titleLabel.text=@"选择联系人";
        
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.backgroundColor= [UIColor clearColor];
        [titleView addSubview:_titleLabel];
    }else if([style isEqualToString:KTYPE_VIDYOMEETTING])
    {
        
        self.groupId = ((ECGroup *)[self.data objectForKey:@"group_info"]).groupId;
        _members = (NSArray *)[self.data objectForKey:@"members"];
        isGroup = YES;
        _titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100*fitScreenWidth, 25.0)];
        _titleLabel.text=@"最多邀请5人";
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.backgroundColor= [UIColor clearColor];
        [titleView addSubview:_titleLabel];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(5, 0, 40, 40)];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [button setTitleColor:[UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:.3] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(dismissCurrentView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = leftItem;
    }else if ([style isEqualToString:KTYPE_VIDEOMEETTING]){
        _titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100*fitScreenWidth, 25.0)];
        _titleLabel.text=@"选择联系人";
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.backgroundColor= [UIColor clearColor];
        [titleView addSubview:_titleLabel];
    }


    _addressBook =  [[NSMutableArray alloc]initWithArray:[[KitAddressBookManager sharedInstance] allVOIPContacts]];
    isGroupInvite = [self isGroupMemberInvite];
    if (isGroupInvite&&[self.data objectForKey:@"group_info"]) {//群主邀请人加入已创建的群组
        [self removeIncludeMember:_addressBook];
        _selectedList = [[NSMutableArray alloc]init];
    }else if ([self.data isKindOfClass:[KXJson class]] ||
              [style isEqualToString:KINVITE_JOINMEEtting]){//会议中邀请人
        _selectedList =[[NSMutableArray alloc]init];
    }else{//创建会议或者群组，再邀请联系人
        if (_selectedList.count == 0) {
            KitCompanyAddress *addressBook = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:[RXUser sharedInstance].mobile];
            
            KitCompanyDeptNameData * deptData = [KitCompanyDeptNameData getCompanyDeptInfoDataWithDepartmentName:[[RXUser sharedInstance]departName]];
            if (deptData) {
                addressBook.department_id = deptData.department_id;
            }
            if (addressBook) {
                _selectedList  =  [NSMutableArray arrayWithObject:addressBook];
            }
            if (_vidyoMemeberList.count >0 ) {
                [_selectedList removeObject:addressBook];
            }
            [self.selectPersonStatusDic setValue:@"1" forKey:addressBook.nameId];
            [self checkPersonSelected:addressBook.nameId];
        }
    }
}

//取消
-(void)dismissCurrentView{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - zmfg  VidyoHelper相关
//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [[VidyoHelper shareInstance].addList removeAllObjects];
//}
////vidyo确定
//-(void)presentVidyoSelectedVC{
//    [[VidyoHelper shareInstance].vidyoMembers addObjectsFromArray:_selectedList];
//    [[VidyoHelper shareInstance].addList addObjectsFromArray:_selectedList];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateVidyoMember" object:self.selectedList];
//    
//    if (_isFromVidyoVC) {
//        [VidyoHelper shareInstance].isPTP = NO;
//         [[VidyoHelper shareInstance]sendMessageOfInvitationMember:[VidyoHelper shareInstance].vidyoMembers vidyoRooms:[VidyoHelper shareInstance].roomsData];
//    }
//        [self.view endEditing:YES];
//        [self dismissViewControllerAnimated:YES completion:nil];
//}
- (void)createNavLeftBarItems{
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(-15, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"title_bar_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"title_bar_back"] forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:self action:@selector(onClickBackNavigationBar) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(25, 0, 40, 40)];
    [button2 setTitle:@"关闭" forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button2 setTitleColor:[UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:.3] forState:UIControlStateHighlighted];
    [button2 addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];

    
    UIView* frameView = [[UIView alloc] initWithFrame:CGRectMake(-15, 0, 80, 40)];
    [frameView addSubview:button];
    [frameView addSubview:button2];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameView];
    self.navigationItem.leftBarButtonItem = buttonItem;

}

//手机通讯录
-(void)getMobileAddress
{
    self.localAddressBook = [[KitAddressBookManager sharedInstance] NewallContactsBySorted];
    self.allAddressKeys = [self.localAddressBook.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
        if (KCNSSTRING_ISEMPTY(letter2)) {
            return NSOrderedDescending;
        }else if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
}

//容信参会和手机参会提示
-(void)onClickRightPrompt
{
    RXSelectJoinMeetView *selectJoinMeetView =[RXSelectJoinMeetView presentModalDialogWithRect:CGRectZero WidthDelegate:nil withPos:EContentPosunconditionalK withTapAtBackground:YES];
    [selectJoinMeetView updateSubViewLayout:CGRectMake(30*fitScreenWidth, 110+44*fitScreenWidth, kScreenWidth-60*fitScreenWidth, 155*fitScreenWidth)];
    
}

- (void)onClickTypeJoinMeetBtn:(UIButton *)btn{
    
    UIButton *selectBtn =(UIButton *)btn;
    
    switch (selectBtn.tag) {
        case 1000:
        {
            //手机参会
            [_leftButton setSelected:YES];
            [_rightButton setSelected:NO];
             MeettingTyle = [NSString stringWithFormat:KVOICETYPE_TELEPHONEMEETTING];
        }
            break;
        case 1001:
        {
            //容信参会
            [_rightButton setSelected:YES];
            [_leftButton setSelected:NO];
            MeettingTyle = [NSString stringWithFormat:KVOICETYPE_RONXINMEETTING];
        }
            break;
            
        default:
            break;
    }
   
}

- (void)onClickBackNavigationBar{

    if (!isCompanyShow&&!isPhoneShow && isVidyoShow) {
        [self popViewController];
    }else{
        if (isPhoneShow) {
            isPhoneShow = !isPhoneShow;
        }else if (isVidyoShow){
            isVidyoShow = !isVidyoShow;
        }else {
            [self selectSectionView:1 Layer:@"0"];
            isCompanyShow = !isCompanyShow;
        }
        [self reloadCompanyData];
        [self.tableView reloadData];
    }
    deptLevel = 0;
}

#pragma mark ----- 确定按钮 点击创建 聊天室 或者 会议室 群组邀请好友


-(void)inviteBtnClicked
{
    #pragma mark - zmfg 白板相关
//    if ([[self.data objectForKey:@"boardFlag"] integerValue]) {
//        __weak __typeof(self) weakSelf = self;
//        [[BoardCoopHelper sharedInstance] createBoardRoomWithVC:weakSelf
//                                                         UserID:[RXUser sharedInstance].mobile
//                                                       password:@"123456"
//                                                       roomType:1
//                                                      boardType:HXAddEntryBoard
//                                                          users:_selectedList.mutableCopy
//                                                    finishBlock:^(ECWBSSRoom *room) {
//                                                        
//                                                    }];
//        return;
//    }

    
    self.message = [self.data objectForKey:@"msg"];
    if (self.message) {
       
        for (KitAddressBook *book in _selectedList) {
            ECMessage *message = [[ECMessage alloc]initWithReceiver:book.mobilenum body:self.message.messageBody];
            message.userData = self.message.userData;
            [[ChatMessageManager sharedInstance]  sendMessage:message  type:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
        }
        [self popViewController];
        
    }else{
        isInputMeetting = YES;//创建聊天
        // 邀请好友
        if ([self isGroupMemberInvite]&&[self.data objectForKey:@"group_info"]) {
            if (_selectedList && _selectedList.count > 0) {
                
                ECGroup *groupInfo = [self.data objectForKey:@"group_info"];
                NSMutableArray *inviteMembers = [[NSMutableArray alloc]init];
                for (KitAddressBook *book in _selectedList) {
                    
                    if(!KCNSSTRING_ISEMPTY(book.mobilenum)){
                     
                        [inviteMembers addObject:book.mobilenum];
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"此账号未通过审核"];
                    }
                    
                }
                MBProgressHUD* hud2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud2.labelText = @"正在邀请好友";
                hud2.removeFromSuperViewOnHide = YES;
                [[ECDevice sharedInstance].messageManager inviteJoinGroup:groupInfo.groupId reason:[NSString stringWithFormat:@"我是%@",[[RXUser sharedInstance] username]] members:inviteMembers confirm:1 completion:^(ECError *error, NSString *groupId, NSArray *members) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    if(error.errorCode ==ECErrorType_NoError){
                        
                        //邀请成员 不需要通知对方 直接入库操作
                        for(int i=0;i<members.count;i++)
                        {
                            KitGroupMemberInfoData *memberInfo =[[KitGroupMemberInfoData alloc]init];
                            NSString *memberPhone =[members objectAtIndex:i];
                            memberInfo.memberId=memberPhone;
                            memberInfo.groupId=groupId;
                            memberInfo.role=@"3";
                            [KitGroupMemberInfoData insertGroupMemberInfoData:memberInfo];
                            
                        }
                        
                        [SVProgressHUD showSuccessWithStatus:@"邀请成功" duration:1];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Invite_Group object:nil];
                        
                        [super popViewController];
                        
                        ECMessage* message = [[ECMessage alloc]init];
                        NSMutableArray *nameArr = [NSMutableArray array];
                        for (NSString * data in inviteMembers) {
                            
                            KitCompanyAddress * book = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:data];
                            [nameArr addObject:book.name];
//                            if ([book.mobilenum isEqualToString:[RXUser sharedInstance].mobile]) {
//                                [nameArr insertObject:book atIndex:0];
//                            }
                            
                        }
                        if ([[self.data objectForKey:@"isAnon_sender"] isEqualToString:@"1"]) {
                            message = [[ChatMessageManager sharedInstance] sendGroupNoticeMessage:[NSString stringWithFormat:@"%@ 邀请 %@ 加入群组",[RXUser sharedInstance].username,[nameArr componentsJoinedByString:@", "]] GroupId:groupId AnonMode:YES  BurnMode:NO];
                        }else{
                            message = [[ChatMessageManager sharedInstance] sendGroupNoticeMessage:[NSString stringWithFormat:@"%@ 邀请 %@ 加入群组",[RXUser sharedInstance].username,[nameArr componentsJoinedByString:@", "]] GroupId:groupId AnonMode:NO  BurnMode:NO];
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
                    }else
                    {
                        
                        if(error.errorCode==171139)
                        {
                            [SVProgressHUD showErrorWithStatus:@"网络不给力"];
                            return ;
                        }
                        [SVProgressHUD showErrorWithStatus:@"邀请失败"];
                    }
                }];
            }
            return;
        }
        
        // 创建语音,视频会议
        if(_selectedList && (_selectedList.count>0 || _vidyoRoomSelectList.count > 0))
        {
            NSString* style = [self.data objectForKey:@"style"];
            if (style && [style isEqualToString:KTYPE_VOICEMEETTING]) {//音频会议
                //添加自己
                KitCompanyAddress * addressBook = [[KitCompanyAddress alloc] init];
                addressBook.mobilenum = [[RXUser sharedInstance] mobile];
                addressBook.voipaccount = [[RXUser sharedInstance]voipaccount];
                addressBook.name = [[RXUser sharedInstance]username];
                addressBook.photourl = [[RXUser sharedInstance]head_url];
                KitCompanyDeptNameData * deptData = [KitCompanyDeptNameData getCompanyDeptInfoDataWithDepartmentName:[[RXUser sharedInstance]departName]];
                if (deptData) {
                    addressBook.department_id = deptData.department_id;
                }
                [_selectedList insertObject:addressBook atIndex:0];
                
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"autoClose",@"1",@"autoDelete",[MeettingTyle isEqualToString:KVOICETYPE_RONXINMEETTING]?@"1":@"0",@"autoJoin",[NSNumber numberWithInt:1],@"voiceMod",nil];
                NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"chatInfo",_selectedList,@"user",@"who",@"managerStyle",@"createMeetChatRoom",@"style",MeettingTyle,KTYPE_VOICEMEETTING,nil];
                [self pushViewController:@"RXMeettingViewController" withData: [KXJson jsonWithObject:info] withNav:NO];
                
            }else if (style && [style isEqualToString:KTYPE_VIDEOMEETTING]){//视频会议
                #pragma mark - zmfg 视频会议相关
//                MultiVideoConfViewController *VideoConfview = [[MultiVideoConfViewController alloc] init];
//                VideoConfview.navigationItem.hidesBackButton = YES;
//                VideoConfview.inviteMembers = _selectedList;
//                int randomNumber =arc4random()%1000000+1000000;
//                NSString *rand =[NSString stringWithFormat:@"%d",randomNumber];
//                VideoConfview.Confname = rand;
//                VideoConfview.curVideoConfId = nil;
//                VideoConfview.backView = self;
//                VideoConfview.isCreator = YES;
//                VideoConfview.isAutoClose = YES;
//                [self.navigationController pushViewController:VideoConfview animated:YES];
//                [VideoConfview createMultiVideoWithAutoClose:YES andIsPresenter:NO andiVoiceMod:1 andAutoDelete:YES andIsAutoJoin:YES];
                
            }else if (style && [style isEqualToString:KTYPE_GROUPCHATTING]) {//创建群聊
            
                MBProgressHUD* hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud1.labelText = @"正在创建群组";
                hud1.removeFromSuperViewOnHide = YES;
                
                ECGroup * newgroup = [[ECGroup alloc] init];
                
                newgroup.name = [NSString stringWithFormat:@"%@发起的会话",[[RXUser sharedInstance]username].length>0?[[RXUser sharedInstance]username]:@"自己"];//默认群组名称：××发起的会话
                newgroup.declared = @"";
                newgroup.mode = 0;
                newgroup.owner = [[RXUser sharedInstance] mobile];
                newgroup.scope = ECGroupType_VIP;//默认1000人群
                NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
                newgroup.createdTime = [NSString stringWithFormat:@"%lld", (long long)tmp];
                
                __weak __typeof(self)weakSelf = self;
                [[ECDevice sharedInstance].messageManager createGroup:newgroup completion:^(ECError *error, ECGroup *group) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                    if (error.errorCode == ECErrorType_NoError) {
                        
                        [[KitMsgData sharedInstance] addGroupIDs:@[group]];
                        KitGroupInfoData *groupData =[[KitGroupInfoData alloc]init];
                        groupData.groupName=group.name;
                        groupData.groupId=group.groupId;
                        groupData.declared=group.declared;;
                        groupData.owner=group.owner;
//                        groupData.isAnonymity = group.isAnonymity;
                        groupData.createTime=group.createdTime;
                        groupData.type=group.type;
                        groupData.memberCount=group.memberCount;
                        [KitGroupInfoData insertGroupInfoData:groupData];
                        weakSelf.groupId = group.groupId;
                        if (_selectedList.count == 0) {
                            
                        }else{
                            
                            MBProgressHUD* hud2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud2.labelText = @"正在邀请好友";
                            hud2.removeFromSuperViewOnHide = YES;
                            
                            NSMutableArray * inviteArray = [[NSMutableArray alloc]init];
                            for (KitAddressBook * book in _selectedList) {
                                NSString* phone = book.mobilenum;
                                if (phone.length>0) {
                                    [inviteArray addObject:phone];
                                }
                            }
                            
                            [[ECDevice sharedInstance].messageManager inviteJoinGroup:self.groupId reason:@"" members:inviteArray confirm:1 completion:^(ECError *error, NSString *groupId, NSArray *members) {
                                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                                if(error.errorCode ==ECErrorType_NoError)
                                {
#pragma mark -红包- -------------修改聊天界面入口
                                    ChatViewController* viewController = [[NSClassFromString(@"RedpacketDemoViewController") alloc] initWithSessionId:strongSelf.groupId];
                                    viewController.data = groupId;
                                    SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
                                    if ([viewController respondsToSelector:aSelector]) {
                                        IMP aIMP = [viewController methodForSelector:aSelector];
                                        void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
                                        setter(viewController, aSelector, groupId);
                                    }
                                    [weakSelf.navigationController setViewControllers:[NSArray arrayWithObjects:[weakSelf.navigationController.viewControllers objectAtIndex:0],viewController, nil] animated:YES];
                                    
                                    NSMutableArray *nameArr = [NSMutableArray array];
                                    for (NSString * data in members) {
                                        if (![data isEqualToString:[RXUser sharedInstance].mobile]) {
                                            KitCompanyAddress * book = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:data];
                                            [nameArr addObject:book.name];
                                        }
                                        
                                    }
                                    ECMessage* message1 = [[ChatMessageManager sharedInstance] sendGroupNoticeMessage:[NSString stringWithFormat:@"%@ 邀请 %@ 加入群组",[RXUser sharedInstance].username,[nameArr componentsJoinedByString:@", "]] GroupId:groupId AnonMode:NO  BurnMode:NO];
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message1];
                                    
                                }
                                else
                                {
                                    if(error.errorCode==171139)
                                    {
                                        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
                                    }else
                                    {
                                        if(!KCNSSTRING_ISEMPTY(error.errorDescription))
                                        {
                                            [SVProgressHUD showErrorWithStatus:error.errorDescription];
                                        }else
                                        {
                                            [SVProgressHUD showErrorWithStatus:@"邀请失败"];
                                        }
                                    }
                                }
                                
                            }];
                        }
                    }
                    else{
                        [SVProgressHUD showErrorWithStatus:@"发起群聊失败"];
                    }
                }];
            }else if (style && [style isEqualToString:KTYPE_BURNCHATTING]) {//快速入口，阅后即焚
                KitCompanyAddress * book = [_selectedList lastObject];
//                ChatViewController * BurnChatVC = [[ChatViewController alloc] initWithSessionId:book.mobilenum];
//                BurnChatVC.data = book.mobilenum;
//                BurnChatVC.isBurnAfterRead = YES;
//                [self.navigationController setViewControllers:[NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0],BurnChatVC, nil] animated:YES];
#pragma mark -红包- -------------修改聊天界面入口
                ChatViewController* BurnChatVC = [[NSClassFromString(@"RedpacketDemoViewController") alloc] initWithSessionId:book.mobilenum];
                BurnChatVC.data = book.mobilenum;
                BurnChatVC.isBurnAfterRead = YES;
                BurnChatVC.data = _groupId;
                SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
                __weak typeof(self)mySelf = self;
                if ([BurnChatVC respondsToSelector:aSelector]) {
                    IMP aIMP = [BurnChatVC methodForSelector:aSelector];
                    void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
                    setter(BurnChatVC, aSelector,mySelf.groupId);
                }
                [mySelf.navigationController setViewControllers:[NSArray arrayWithObjects:[mySelf.navigationController.viewControllers objectAtIndex:0],BurnChatVC, nil] animated:YES];
            }else if (style && ([style isEqualToString:KTYPE_GROUPCHATTING]||[style isEqualToString:KTYPE_ANONCHATTING])) {//创建群聊 （包括匿名讨论）
                
                MBProgressHUD* hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud1.labelText = @"正在创建群组";
                hud1.removeFromSuperViewOnHide = YES;
                
                ECGroup * newgroup = [[ECGroup alloc] init];
                
//                if (isAnon) {
//                    newgroup.name = @"匿名讨论";
//                    newgroup.isAnonymity = YES;
//                }else{
//                }
                newgroup.name = [NSString stringWithFormat:@"%@发起的会话",[[RXUser sharedInstance]username].length>0?[[RXUser sharedInstance]username]:@"自己"];//默认群组名称：××发起的会话
                
                newgroup.declared = @"";
                newgroup.mode = 0;
                newgroup.owner = [[RXUser sharedInstance] mobile];
                newgroup.scope = ECGroupType_VIP;//默认1000人群
                NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
                newgroup.createdTime = [NSString stringWithFormat:@"%lld", (long long)tmp];
                
                __weak __typeof(self)weakSelf = self;
                [[ECDevice sharedInstance].messageManager createGroup:newgroup completion:^(ECError *error, ECGroup *group) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                    if (error.errorCode == ECErrorType_NoError) {
                        
                        
                        if (_selectedList.count == 0) {
                            
                        }else{
                            
                            MBProgressHUD* hud2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud2.labelText = @"正在邀请好友";
                            hud2.removeFromSuperViewOnHide = YES;
                            
                            NSMutableArray * inviteArray = [[NSMutableArray alloc]init];
                            for (KitAddressBook * book in _selectedList) {
                                NSString* phone = book.mobilenum;
                                if (phone.length>0) {
                                    [inviteArray addObject:phone];
                                }
                            }
                            
                            [[ECDevice sharedInstance].messageManager inviteJoinGroup:newgroup.groupId reason:@"" members:inviteArray confirm:1 completion:^(ECError *error, NSString *groupId, NSArray *members) {
                                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                                if(error.errorCode ==ECErrorType_NoError)
                                {
                                    [[KitMsgData sharedInstance] addGroupIDs:@[group]];
                                    
                                    KitGroupInfoData *groupData =[[KitGroupInfoData alloc]init];
                                    groupData.groupName=group.name;
                                    groupData.groupId=group.groupId;
                                    groupData.declared=group.declared;;
                                    groupData.owner=group.owner;
//                                    groupData.isAnonymity = group.isAnonymity;
                                    groupData.createTime=group.createdTime;
                                    groupData.type=group.type;
                                    groupData.memberCount=group.memberCount;
                                    [KitGroupInfoData insertGroupInfoData:groupData];
                                    self.groupId = group.groupId;
#pragma mark -红包- -------------修改聊天界面入口
                                    ChatViewController* viewController = [[NSClassFromString(@"RedpacketDemoViewController") alloc] initWithSessionId:strongSelf.groupId];
                                    viewController.data = groupId;
                                    SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
                                    if ([viewController respondsToSelector:aSelector]) {
                                        IMP aIMP = [viewController methodForSelector:aSelector];
                                        void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
                                        setter(viewController, aSelector, groupId);
                                    }
                                    [weakSelf.navigationController setViewControllers:[NSArray arrayWithObjects:[weakSelf.navigationController.viewControllers objectAtIndex:0],viewController, nil] animated:YES];
                                    
                                    
                                    ECMessage* message2 = [[ECMessage alloc]init];
                                    NSMutableArray *nameArr = [NSMutableArray array];
                                    for (NSString * data in members) {
                                        if (![data isEqualToString:[RXUser sharedInstance].mobile]) {
                                            KitCompanyAddress * book = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:data];
                                            [nameArr addObject:book.name];
                                        }
                                        
                                    }
                                    
                                    message2 = [[ChatMessageManager sharedInstance] sendGroupNoticeMessage:[NSString stringWithFormat:@"%@ 邀请 %@ 加入群组",[RXUser sharedInstance].username,[nameArr componentsJoinedByString:@", "]] GroupId:groupId AnonMode:NO  BurnMode:NO];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message2];
                                    
                                }
                                else
                                {
                                    // [strongSelf showToast:[NSString stringWithFormat:@"%@",error.errorDescription]];
                                    if(error.errorCode==171139)
                                    {
                                        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
                                        return ;
                                    }
                                    
                                    if(!KCNSSTRING_ISEMPTY(error.errorDescription))
                                    {
                                        [SVProgressHUD showErrorWithStatus:error.errorDescription];
                                    }else
                                    {
                                        [SVProgressHUD showErrorWithStatus:@"发起失败"];
                                    }
                                }
                                
                            }];
                        }
                    }else{
                        [strongSelf showToast:[NSString stringWithFormat:@"%@",error.errorDescription]];
                    }
                }];
            }else if (style && [style isEqualToString:KTYPE_VIDYOMEETTING]){//vidyo会议
            
//                [[VidyoHelper shareInstance].vidyoMembers addObjectsFromArray:_selectedList];
//                [VidyoHelper shareInstance].vidyoVC.members = [VidyoHelper shareInstance].vidyoMembers;
//                [[VidyoHelper shareInstance] sendMessageOfInvitationMember:[VidyoHelper shareInstance].vidyoMembers vidyoRooms:[VidyoHelper shareInstance].roomsData];//发送邀请消息
//                
//                [[VidyoHelper shareInstance].vidyoVC reloadVideoViews];
//                [self popViewController];
                
            }
            else{//邀请
                
                __weak __typeof(self)weakSelf = self;
                if (_selectedList.count > 0) {
                    
                    NSMutableArray *addnewMember =[[NSMutableArray alloc]init];
                    
                    for(int i=0;i<self.selectedList.count;i++)
                    {
                        KitAddressBook *addressBook =self.selectedList[i];
                        
                        NSString *mobile =addressBook.mobilenum;
                        if (![_existMemArray containsObject:mobile]) {
                            
                            [addnewMember addObject:mobile];
                        }
                        
                    }
                    if(addnewMember.count<=0)
                    {
                        [SVProgressHUD showErrorWithStatus:@"请邀请未加入会议的成员"];
                        return;
                    }
                    
                    if(style && [style isEqualToString:KINVITE_JOINMEEtting])
                    {
                        NSString *curRoomNumber =[self.data objectForKey:@"curChatroomId"];
                        NSString *roomType =[self.data objectForKey:KTYPE_VOICEMEETTING]?[self.data objectForKey:KTYPE_VOICEMEETTING]:[self.data objectForKey:KTYPE_VIDEOMEETTING];
                        
                        if(!KCNSSTRING_ISEMPTY(roomType))
                        {
                            if([roomType isEqualToString:KVOICETYPE_TELEPHONEMEETTING])
                            {
                                //电话会议
                                [[ECDevice sharedInstance].meetingManager inviteMembersJoinMultiMediaMeeting:curRoomNumber andIsLoandingCall:YES andMembers:addnewMember completion:^(ECError *error, NSString *meetingNumber) {
                                    if(error.errorCode==ECErrorType_NoError)
                                    {
                                        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:weakSelf.selectedList,@"user",nil];
                                        [weakSelf popViewController:info];
                                    }else
                                    {
                                        [SVProgressHUD showErrorWithStatus:@"邀请失败"];
                                    }
                                }];
                            }else if([roomType isEqualToString:KVOICETYPE_RONXINMEETTING])
                            {
                                //容信会议邀请
                                
                                [[ECDevice sharedInstance].meetingManager inviteMembersJoinMultiMediaMeeting:curRoomNumber andIsLoandingCall:NO andMembers:addnewMember completion:^(ECError *error, NSString *meetingNumber) {
                                    if(error.errorCode==ECErrorType_NoError)
                                    {
                                        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:weakSelf.selectedList,@"user",nil];
                                        [weakSelf popViewController:info];
                                        
                                    }else
                                    {
                                        [SVProgressHUD showErrorWithStatus:@"邀请失败"];
                                    }
                                }];
                                
                                // [super popViewController];
                            }
                        }
                    }else
                    {
                        MBProgressHUD* hud2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud2.labelText = @"正在邀请好友";
                        hud2.removeFromSuperViewOnHide = YES;
                        
                        NSMutableArray * inviteArray = [[NSMutableArray alloc]init];
                        for (KitAddressBook * book in _selectedList) {
                            NSString* phone = book.mobilenum;
                            if (phone.length>0) {
                                [inviteArray addObject:phone];
                            }
                        }
                        // __weak __typeof(self)weakSelf = self;
                        [[ECDevice sharedInstance].messageManager inviteJoinGroup:self.groupId reason:@"" members:inviteArray confirm:2 completion:^(ECError *error, NSString *groupId, NSArray *members) {
                            //__strong __typeof(weakSelf)strongSelf = weakSelf;
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            if(error.errorCode ==ECErrorType_NoError)
                            {

#pragma mark -红包- -------------修改聊天界面入口
                                ChatViewController* viewController = [[NSClassFromString(@"RedpacketDemoViewController") alloc] initWithSessionId:weakSelf.groupId];
                                viewController.data = groupId;
                                SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
                                if ([viewController respondsToSelector:aSelector]) {
                                    IMP aIMP = [viewController methodForSelector:aSelector];
                                    void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
                                    setter(viewController, aSelector,groupId);
                                }
                                [weakSelf.navigationController setViewControllers:[NSArray arrayWithObjects:[weakSelf.navigationController.viewControllers objectAtIndex:0],viewController, nil] animated:YES];
                            }
                            else
                            {
                                if(error.errorCode==171139)
                                {
                                    [SVProgressHUD showErrorWithStatus:@"网络不给力"];
                                    return ;
                                }
                                if(!KCNSSTRING_ISEMPTY(error.errorDescription))
                                {
                                    [SVProgressHUD showErrorWithStatus:error.errorDescription];
                                    return;
                                }
                                [SVProgressHUD showErrorWithStatus:@"邀请失败"];
                            }
                            
                        }];
                    }
                    
                }
            }
        }else{
            //请选择联系人
        }
    }
    
}

-(void)popViewController:(NSDictionary *)dic
{
    #pragma mark - zmfg KXADTransitionController这个是不是弃用了
//    KXADTransitionController *transitionController = (KXADTransitionController *)self.transitionController;
//    if (!transitionController) {
//        transitionController = (KXADTransitionController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
//    }
//    NSArray *viewControllers = [transitionController viewControllers];
//    UIViewController *UpperLayerView =viewControllers[viewControllers.count-2];
    #pragma mark - zmfg 语音会议相关
//    if([UpperLayerView isKindOfClass:[RXMeettingViewController class]])
//    {
//        RXMeettingViewController *meetView =(RXMeettingViewController *)UpperLayerView;
//        meetView.popViewData =dic;
//        [transitionController popViewController];
//    }
    
}
//发起语音会议邀请
-(void)appendIMMessage:(NSString *)meetRoomNo
{
    for (int i = 1; i < _selectedList.count; i++) {
        
         KitAddressBook* addressBook = _selectedList[i];
        BOOL isVideoMeetting=NO;
        if([self.data hasValueForKey:KTYPE_VIDEOMEETTING])
        {
            isVideoMeetting=YES;
        }
         NSDictionary* userParas = [NSDictionary dictionaryWithObjectsAndKeys:isVideoMeetting?kRONGXINVIDEOMEETTING:kRONGXINVOICEMEETTING,kRonxinMessageType,meetRoomNo,kCCPInterphoneConfNo,nil];
         NSString *userdataStr=[NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
         NSString *text =isVideoMeetting?@"我发起了视频会议":@"我发起了语音群聊会议";
         ECMessage *message =[[ECMessage alloc]init];
         message.messageId=meetRoomNo;
         message.sessionId=addressBook.mobilenum;
         message.messageState=ECMessageState_Receive;
         message.isRead=YES;
         message.userData = userdataStr;
         ECTextMessageBody *body =[[ECTextMessageBody alloc]init];
         message.messageBody=body;
         message.from=[[RXUser sharedInstance] mobile];
         message.to=addressBook.mobilenum;
         message.messageState=ECMessageState_Sending;
         ECTextMessageBody * textmsg = (ECTextMessageBody *)message.messageBody;
         textmsg.text=text;
         NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
         NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
         message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
       
        [[ECDevice sharedInstance].messageManager sendMessage:message progress:self   completion:^(ECError *error,  ECMessage *amessage)
         {
             if(error.errorCode==ECErrorType_NoError)
            {
               [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
            }
        }];
    }
    
}

//Toast错误信息
-(void)showToast:(NSString *)message
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}


-(void)notConnetNet:(NSNotification *)noti
{
    if([noti.object isEqualToString:@"网络连接已中断"])
    {
        [SVProgressHUD dismiss];
        [self.tableView.pullToRefreshView stopAnimating];
    }
}

- (void)reloadCompanyRecentlyContactData{

    self.recentlyContactData = [NSMutableArray arrayWithCapacity:0];
    [self.recentlyContactData addObjectsFromArray:[[KitMsgData sharedInstance] getMyCustomSession]];
    
    for (int i = 0; i < self.recentlyContactData.count;) {
        ECSession * data = self.recentlyContactData[i];
        if ([data.sessionId isEqualToString:@"系统通知"]) {
            [self.recentlyContactData removeObjectAtIndex:i];
        }else if ([data.sessionId hasPrefix:@"g"]){
            [self.recentlyContactData removeObjectAtIndex:i];
        }else{
            KitCompanyAddress * address = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:data.sessionId];
            if (address ) {
                [self.recentlyContactData replaceObjectAtIndex:i withObject:address];
                i++;
            }else{
                [self.recentlyContactData removeObjectAtIndex:i];
            }
            
        }
    }
    
}

- (void)addContact:(KitCompanyAddress *)address{

    if (self.allContactData.count > 0) {
        for (int i = 0; i < self.allContactData.count; i ++) {
            KitCompanyAddress * book = [self.allContactData objectAtIndex:i];
            if ([book.mobilenum isEqualToString:address.mobilenum]||[address.mobilenum isEqualToString:[[RXUser sharedInstance] mobile]]) {
                break;
            }
            if (i == self.allContactData.count - 1) {
                [self.allContactData addObject:address];
            }
        }
    }else{
        [self.allContactData addObject:address];
    }
}

- (void)reloadDeptAndContactSelectStatus{
    
    self.companyData =[KitCompanyAddress getCompanyAddressArray];
    NSMutableArray *mainDept =[KitCompanyDeptNameData getCompanyDeptArray];
    
    [self.selectPersonStatusDic removeAllObjects];
    [self.selectDeptStatusDic removeAllObjects];
    for (KitCompanyAddress * addr in self.companyData) {
        //初始化联系人选中状态  “0”不选中  “1”选中
        if(addr.mobilenum)
        {
            if ([addr.mobilenum isEqualToString:[RXUser sharedInstance].mobile]) {
                [self.selectPersonStatusDic setValue:@"1" forKey:addr.nameId];
                [self updateCurrentIndex:nil];
            }else{
             [self.selectPersonStatusDic setValue:@"0" forKey:addr.nameId];
            }
        }
    }
    for(int i =0;i<mainDept.count;i++)
    {
        KitCompanyDeptNameData *mainDeptData =mainDept[i];
        //mainDeptData=mainDept[i];
        
        //初始化部门选中状态  “0”不选中  “1”选中
        [self.selectDeptStatusDic setValue:@"0" forKey:mainDeptData.department_id];
    }
    
}

-(void)reloadCompanyData
{
    self.DeptPerSon =[NSString stringWithFormat:@"Dept"];
    _companyData =[[NSMutableArray alloc] init];
    _companyDeptList=[[NSMutableArray alloc] init];
    _otherDeptList =[[NSMutableArray alloc] init];
    NSMutableArray *mainDept =[[NSMutableArray alloc]init];
    self.DeptArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.personDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
    self.DeptDictionary =[[NSMutableDictionary alloc]initWithCapacity:0];
    self.allContactData = [NSMutableArray arrayWithCapacity:0];
    self.companyData =[KitCompanyAddress getCompanyAddressArray];
    mainDept =[KitCompanyDeptNameData getCompanyDeptArray];
    [self.DeptArray addObjectsFromArray:mainDept];
    __weak typeof(self)weak_self=self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weak_self)strong_self=weak_self;
        NSArray * phoneArr = [[KitAddressBookManager sharedInstance] allContactsPhone];
        [strong_self.allContactData addObjectsFromArray:self.companyData];
        for (int i = 0; i < self.allContactData.count; i ++) {//删除自己
            KitCompanyAddress * book = [self.allContactData objectAtIndex:i];
            if ([book.mobilenum isEqualToString:[[RXUser sharedInstance] mobile]]) {
                [strong_self.allContactData removeObject:book];
            }
        }
        if (!isGroupInvite) {
            for (int i = 0; i< phoneArr.count; i ++) {
                KitAddressBook * addressBook = [phoneArr objectAtIndex:i];
                KitCompanyAddress * book = [[KitCompanyAddress alloc] init];
                book.name = addressBook.name;
                NSArray * mobileKey = addressBook.phones.allKeys;
                NSString * mobile = @"";
                if (mobileKey.count>0) {
                    mobile = addressBook.phones[mobileKey[0]];
                }
                book.mobilenum = mobile;
                book.voipaccount = addressBook.voipaccount;
                book.photourl = addressBook.photourl;
                book.urlmd5 = addressBook.urlmd5;
                book.fnmname = addressBook.firstLetter;
                book.signature = addressBook.signature;
                book.sex = addressBook.sex;
                [strong_self addContact:book];
            }
        }
    });
    
    
    for (KitCompanyAddress * book in self.companyData) {
        if ([book.department_id isEqualToString:self.P_department_id]) {
            [_companyDeptList addObject:book];
        }
    }
    
    for(int i =0;i<mainDept.count;i++)
    {
        KitCompanyDeptNameData *mainDeptData =mainDept[i];
        //mainDeptData=mainDept[i];
        
        if([mainDeptData.parent_dept isEqualToString:self.P_department_id])
        {
            [_companyDeptList addObject:mainDeptData];
        }else{
            
            [_otherDeptList addObject:mainDeptData];
        }

    }
    
    self.personDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
    self.DeptDictionary =[[NSMutableDictionary alloc]initWithCapacity:0];
    
    if(_companyDeptList.count>0)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weak_self)strong_self=weak_self;
            //成员
            NSInteger personNum = [_companyData count];
            for (int j=0; j<personNum; j++) {
                KitCompanyData *hytCom =_companyData[j];
                NSMutableArray *array = [[NSMutableArray alloc]init];
                
                if([hytCom.department_id rangeOfString:@","].location !=NSNotFound)
                {
                    NSArray *MoreDepatArray =[hytCom.department_id componentsSeparatedByString:@","];
                    for(int i=0;i<MoreDepatArray.count;i++)
                    {
                        if ([strong_self.personDictionary hasValueForKey:MoreDepatArray[i]]) {
                            array = [strong_self.personDictionary objectForKey:MoreDepatArray[i]];
                        }else{
                            array = [NSMutableArray array];
                            [strong_self.personDictionary setObject:array forKey:MoreDepatArray[i]];
                        }
                        [array addObject:hytCom];
                    }
                    
                }else
                {
                    if ([strong_self.personDictionary hasValueForKey:hytCom.department_id]) {
                        array = [strong_self.personDictionary objectForKey:hytCom.department_id];
                    }else{
                        array = [NSMutableArray array];
                        [strong_self.personDictionary setObject:array forKey:hytCom.department_id];
                    }
                    [array addObject:hytCom];
                }
            }
            //部门
            NSInteger personDeptNum = [mainDept count];
            // NSInteger otherDeptCount =[_otherDeptList count];
            for (int m=0; m<personDeptNum; m++) {
                KitCompanyDeptNameData *deptData =deptData =mainDept[m];
                
                NSMutableArray *array = nil;
                if ([strong_self.DeptDictionary hasValueForKey:deptData.parent_dept]) {
                    array=[strong_self.DeptDictionary objectForKey:deptData.parent_dept];
                    //                [arrayA addObject:arrayA];
                    // [weak_self.DeptDictionary setObject:arrayA forKey:deptData.parent_dept];
                }else{
                    array = [NSMutableArray array];
                    
                    [strong_self.DeptDictionary setObject:array forKey:deptData.parent_dept];
                }
                [array addObject:deptData];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [strong_self.tableView reloadData];
                [strong_self.tableView.pullToRefreshView stopAnimating];
            });
        });
        
    }else
    {
        if(curRequestCount==1)
        {
            [SVProgressHUD showErrorWithStatus:@"请求数据失败"];
            curRequestCount=0;
        }else
        {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:KNotification_ADDCOUNTQUEST];
            
            [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeClear];
            [self reloadCompanyBook];
        }
    }

}

#pragma mark 添加企业通讯录
- (void)reloadCompanyBook
{
    __weak typeof(self) weak_self = self;
    
    [RXCompanyUpManager reloadCompanyBook:^(NSMutableArray *personArray, NSMutableArray *deptArray, NSError *error, BOOL iszip, BOOL isAddCountQuest, NSDictionary *json, NSString *path) {
        //防止服务器返回数据为空,一直请求数据
        if (error) {
            [KitGlobalClass sharedInstance].isRecodeInsertSplite = NO;
            __strong typeof(weak_self)strong_self=weak_self;
            
            for (int i = 0; i < strong_self.addressBook.count; i++) {
                KitAddressBook* addressBook = [strong_self.addressBook objectAtIndex:i];
                if ([addressBook.mobilenum isEqualToString:[[RXUser sharedInstance] mobile]]) {
                    [strong_self.addressBook removeObjectAtIndex:i];
                    [strong_self.addressBook insertObject:addressBook atIndex:0];
                    break;
                }
            }
            for (int i = 0; i < strong_self.addressBook.count; i++) {
                KitAddressBook* addressBook = [strong_self.addressBook objectAtIndex:i];
                for(int j = 0;j < strong_self.companyData.count;j++){
                    KitCompanyAddress *companyAdr =[[KitCompanyAddress alloc]init];
                    NSString* mobilenum = companyAdr.mobilenum;
                    if ([mobilenum isEqualToString:addressBook.mobilenum]) {
                        [strong_self.addressBook removeObjectAtIndex:i];
                        --i;
                        break;
                    }
                }
            }
            // NSMutableArray* fronArray = [NSMutableArray array];
            for (int i = 0; i < strong_self.addressBook.count; i++) {
                KitAddressBook* addressBook = [strong_self.addressBook objectAtIndex:i];
                KitCompanyAddress *newData =[[KitCompanyAddress alloc]init];
                newData.mobilenum=addressBook.mobilenum;
                newData.name=addressBook.name;
                newData.photourl=addressBook.photourl;
                newData.voipaccount=addressBook.voipaccount;
                //[weak_self.companyData addObject:newData];
                [strong_self.companyData insertObject:newData atIndex:i];
            }
            [strong_self.tableView.pullToRefreshView stopAnimating];
            [strong_self.tableView reloadData];
        }else{
            curRequestCount ++;
            KXJson *jsonCount =[json objectForKey:@"body"];
            if (iszip) {
                
                if (isAddCountQuest) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        //部门更新
                        for (int i = 0; i < deptArray.count; i++) {
                            NSDictionary * dept = deptArray[i];
                            [self.selectDeptStatusDic setValue:@"0" forKey:[dept objectForKey:@"did"]];
                        }
                        //成员更新
                        for(int i=0;i<personArray.count;i++){
                            NSDictionary *person =personArray[i];
                            [self.selectPersonStatusDic setValue:@"0" forKey:[person objectForKey:@"uid"]];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"遍历结束了,欢迎下次再来 ,谢谢");
                            
                            [self.tableView reloadData];
                            [self.tableView.pullToRefreshView stopAnimating];
                        });
                        
                    });
                }else{
                    
                    
                    [self.DeptArray removeAllObjects];
                    for (int i=0; i<[deptArray count]; i++) {
                        KitCompanyDeptNameData * data = [[KitCompanyDeptNameData alloc] init];
                        NSDictionary * dataJson = deptArray[i];
                        data.department_id = ISSTRING_ISSTRING([dataJson objectForKey:@"did"]);
                        data.department_name = ISSTRING_ISSTRING([dataJson objectForKey:@"dnm"]);
                        data.parent_dept = ISSTRING_ISSTRING([dataJson objectForKey:@"dpid"]);
                        [weak_self.DeptArray addObject:data];
                    }
                    
                    
                    weak_self.resultJson =personArray;
                    [weak_self.personDictionary removeAllObjects];
                    for ( NSDictionary *dic in weak_self.resultJson) {
                        //KXJson *person = [personJson getJsonForIndex:j];
                        
                        NSMutableArray *array = nil;
                        if ([weak_self.personDictionary hasValueForKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"udid"]]]) {
                            array = [weak_self.personDictionary objectForKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"udid"]]];
                        }else{
                            array = [NSMutableArray array];
                            [weak_self.personDictionary setObject:array forKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"udid"]]];
                        }
                        [array addObject:dic];
                    }
                    
                    [self.DeptDictionary removeAllObjects];
                    for (int m=0; m<[weak_self.DeptArray count]; m++) {
                        KitCompanyDeptNameData * data = [weak_self.DeptArray objectAtIndex:m];
                        NSString *deptId = data.parent_dept;
                        
                        if ([weak_self.DeptDictionary hasValueForKey:deptId]) {
                            NSMutableArray *arrayA=[[NSMutableArray alloc]initWithArray:[weak_self.DeptDictionary objectForKey:deptId]];
                            [arrayA addObject:[weak_self.DeptArray objectAtIndex:m]];
                            
                            [weak_self.DeptDictionary setObject:arrayA forKey:deptId];
                        }else{
                            NSMutableArray* arrayB = [[NSMutableArray array] init];
                            [arrayB addObject:[weak_self.DeptArray objectAtIndex:m]];
                            [weak_self.DeptDictionary setObject:arrayB forKey:deptId];
                        }
                    }
                    
                    //第一个企业主架构
                    [weak_self.companyDeptList removeAllObjects];
                    if (weak_self.personDictionary[weak_self.P_department_id]) {
                        [weak_self.companyDeptList addObjectsFromArray:weak_self.personDictionary[weak_self.P_department_id]];
                    }
                    if (weak_self.DeptDictionary[weak_self.P_department_id]) {
                        [weak_self.companyDeptList addObjectsFromArray:weak_self.DeptDictionary[weak_self.P_department_id]];
                    }
                    
                    [weak_self.tableView.pullToRefreshView stopAnimating];
                    
                    for (int i = 0; i < weak_self.addressBook.count; i++) {
                        KitAddressBook* addressBook = [weak_self.addressBook objectAtIndex:i];
                        if ([addressBook.mobilenum isEqualToString:[[RXUser sharedInstance] mobile]]) {
                            [weak_self.addressBook removeObjectAtIndex:i];
                            [weak_self.addressBook insertObject:addressBook atIndex:0];
                            break;
                        }
                        
                    }
                    for (int i = 0; i < weak_self.addressBook.count; i++) {
                        KitAddressBook* addressBook = [weak_self.addressBook objectAtIndex:i];
                        NSString* mobilenum = [[RXUser sharedInstance] mobile];
                        if ([mobilenum isEqualToString:addressBook.mobilenum]) {
                            [weak_self.addressBook removeObjectAtIndex:i];
                            --i;
                        }
                    }
                    for (int i = 0; i < weak_self.addressBook.count; i++) {
                        KitAddressBook* addressBook = [weak_self.addressBook objectAtIndex:i];
                        NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:addressBook.mobilenum,@"mtel",addressBook.name,@"unm",addressBook.photourl,@"url",addressBook.voipaccount,@"voip",nil];
                        [weak_self.resultJson addObject:dic];
                        
                    }
                    for (int i = 0; i <  weak_self.resultJson.count; i++) {
                        NSDictionary* person = weak_self.resultJson [i];
                        NSString* mobile = [person objectForKey:@"mtel"];
                        if ([[[RXUser sharedInstance] mobile] isEqualToString:mobile]) {
                            [weak_self.resultJson removeObjectAtIndex:i];
                            [weak_self.resultJson insertObject:person atIndex:0];
                            break;
                        }
                    }
                    
                    if(![KitGlobalClass sharedInstance].isRecodeInsertSplite)
                    {
                        
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            [KitGlobalClass sharedInstance].isRecodeInsertSplite=YES;
                            if(deptArray.count>0)
                            {
                                [KitCompanyDeptNameData insertCompanyDeptArray:deptArray];
                            }
                            
                            if(personArray.count>0)
                            {
                                [KitCompanyAddress insertCompanyAddressInfo:personArray];
                            }
                            
                            [KitGlobalClass sharedInstance].isRecodeInsertSplite =NO;
                            //判断还有什么文件没有下载完成
                            NSLog(@"..........请求通讯录入库完成之后的时间......");
                            [[KitAddressBookManager sharedInstance]updateAddressContacts];
                            
                        });
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"遍历结束了,欢迎下次再来 ,谢谢");
                        
                        [weak_self.tableView reloadData];
                        
                    });
                }
            }else{
                
                // 提取部门
                KXJson *deptJson =[jsonCount getJsonForKey:@"dept"];
                if (isAddCountQuest) {
                    
                    KXJson *updatePerson =[jsonCount getJsonForKey:@"person"];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        //部门更新
                        for (int i = 0; i < deptJson.count; i++) {
                            KXJson * dept = [deptJson getJsonForIndex:i];
                            [self.selectDeptStatusDic setValue:@"0" forKey:[dept getStringForKey:@"did"]];
                        }
                        //成员更新
                        
                        for(int i=0;i<updatePerson.count;i++){
                            KXJson *person =[updatePerson getJsonForIndex:i];
                            [self.selectPersonStatusDic setValue:@"0" forKey:[person getStringForKey:@"uid"]];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"遍历结束了,欢迎下次再来 ,谢谢");
                            
                        });
                        
                    });
                }else{
                    NSMutableArray *perArray =[[NSMutableArray alloc]init];
                    
                    [self.DeptArray removeAllObjects];
                    for (int i=0; i<[deptJson count]; i++) {
                        KitCompanyDeptNameData * data = [[KitCompanyDeptNameData alloc] init];
                        KXJson * dataJson = [deptJson getJsonForIndex:i];
                        data.department_id = ISSTRING_ISSTRING([dataJson getStringForKey:@"did"]);
                        data.department_name = ISSTRING_ISSTRING([dataJson getStringForKey:@"dnm"]);
                        data.parent_dept = ISSTRING_ISSTRING([dataJson getStringForKey:@"dpid"]);
                        [weak_self.DeptArray addObject:data];
                    }
                    
                    KXJson *allPersonData =[jsonCount getJsonForKey:@"person"];
                    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fnm" ascending:YES]];
                    
                    if([allPersonData.json isKindOfClass:[NSDictionary class]])
                    {
                        //NSLog(@"------------------------[NSDictionary class]--------------");
                        NSDictionary *allDic =allPersonData.json;
                        
                        for(NSDictionary *dic in allDic)
                        {
                            [perArray addObject:dic];
                        }
                        [perArray sortUsingDescriptors:sortDescriptors];
                        
                    }else if ([allPersonData.json isKindOfClass:[NSArray class]])
                    {
                        //NSLog(@"------------------------[NSArray class]--------------");
                        perArray =allPersonData.json;
                    }
                    weak_self.resultJson =perArray;
                    [weak_self.personDictionary removeAllObjects];
                    for ( NSDictionary *dic in self.resultJson) {
                        
                        NSMutableArray *array = nil;
                        if ([weak_self.personDictionary hasValueForKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"udid"]]]) {
                            array = [weak_self.personDictionary objectForKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"udid"]]];
                        }else{
                            array = [NSMutableArray array];
                            [weak_self.personDictionary setObject:array forKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"udid"]]];
                        }
                        [array addObject:dic];
                    }
                    
                    [self.DeptDictionary removeAllObjects];
                    for (int m=0; m<[weak_self.DeptArray count]; m++) {
                        KitCompanyDeptNameData * data = [weak_self.DeptArray objectAtIndex:m];
                        NSString *deptId = data.parent_dept;
                        
                        if ([weak_self.DeptDictionary hasValueForKey:deptId]) {
                            NSMutableArray *arrayA=[[NSMutableArray alloc]initWithArray:[weak_self.DeptDictionary objectForKey:deptId]];
                            [arrayA addObject:[weak_self.DeptArray objectAtIndex:m]];
                            
                            [weak_self.DeptDictionary setObject:arrayA forKey:deptId];
                        }else{
                            NSMutableArray* arrayB = [[NSMutableArray array] init];
                            [arrayB addObject:[weak_self.DeptArray objectAtIndex:m]];
                            [weak_self.DeptDictionary setObject:arrayB forKey:deptId];
                        }
                    }
                    
                    //第一个企业主架构
                    [weak_self.companyDeptList removeAllObjects];
                    if (weak_self.personDictionary[weak_self.P_department_id]) {
                        [weak_self.companyDeptList addObjectsFromArray:weak_self.personDictionary[weak_self.P_department_id]];
                    }
                    if (weak_self.DeptDictionary[weak_self.P_department_id]) {
                        [weak_self.companyDeptList addObjectsFromArray:weak_self.DeptDictionary[weak_self.P_department_id]];
                    }
                    
                    [weak_self.tableView.pullToRefreshView stopAnimating];
                    
                    for (int i = 0; i < weak_self.addressBook.count; i++) {
                        KitAddressBook* addressBook = [weak_self.addressBook objectAtIndex:i];
                        if ([addressBook.mobilenum isEqualToString:[[RXUser sharedInstance] mobile]]) {
                            [weak_self.addressBook removeObjectAtIndex:i];
                            [weak_self.addressBook insertObject:addressBook atIndex:0];
                            break;
                        }
                        
                    }
                    for (int i = 0; i < weak_self.addressBook.count; i++) {
                        KitAddressBook* addressBook = [weak_self.addressBook objectAtIndex:i];
                        NSString* mobilenum = [[RXUser sharedInstance] mobile];
                        if ([mobilenum isEqualToString:addressBook.mobilenum]) {
                            [weak_self.addressBook removeObjectAtIndex:i];
                            --i;
                        }
                    }
                    
                    for (int i = 0; i < weak_self.addressBook.count; i++) {
                        KitAddressBook* addressBook = [weak_self.addressBook objectAtIndex:i];
                        NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:addressBook.mobilenum,@"mtel",addressBook.name,@"unm",addressBook.photourl,@"url",addressBook.voipaccount,@"voip",nil];
                        [weak_self.resultJson addObject:dic];
                        
                    }
                    for (int i = 0; i <  weak_self.resultJson.count; i++) {
                        NSDictionary* person = weak_self.resultJson [i];
                        NSString* mobile = [person objectForKey:@"mtel"];
                        if ([[[RXUser sharedInstance] mobile] isEqualToString:mobile]) {
                            [weak_self.resultJson removeObjectAtIndex:i];
                            [weak_self.resultJson insertObject:person atIndex:0];
                            break;
                        }
                    }
                    
                    if(![KitGlobalClass sharedInstance].isRecodeInsertSplite)
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            if(weak_self.resultJson.count>0)
                            {
                                [KitGlobalClass sharedInstance].isRecodeInsertSplite =YES;
                                [KitCompanyAddress insertCompanyAddressInfo:weak_self.resultJson];
                            }
                            [KitGlobalClass sharedInstance].isRecodeInsertSplite=NO;
                            
                        });
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"遍历结束了,欢迎下次再来 ,谢谢");
                        
                        [weak_self.tableView reloadData];
                        [self.tableView.pullToRefreshView stopAnimating];
                    });
                }
            }
        }
    }];
    
}

- (BOOL)isGroupMemberInvite
{
    if ([self.data isKindOfClass:[NSDictionary class]]) {
        if ([self.data hasValueForKey:@"group_info"]||[[self.data objectForKey:@"style"] isEqualToString:KTYPE_GROUPCHATTING]||[[self.data objectForKey:@"style"] isEqualToString:KTYPE_BURNCHATTING]||[[self.data objectForKey:@"style"] isEqualToString:KTYPE_ANONCHATTING] ||[[self.data objectForKey:@"style"]isEqualToString:KTYPE_VIDYOMEETTING]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkSelected:(NSString*)mobile
{
    if (KCNSSTRING_ISEMPTY(mobile)) {
        return NO;
    }
    if (isVidyo && _selectedList.count >= 5- _vidyoMemeberList.count) {
        return NO;
    }
    for(int i = 0; i < _selectedList.count ;i++){
        KitAddressBook* temp = [_selectedList objectAtIndex:i];
        if ([temp.mobilenum isEqualToString:mobile]) {
            return YES;
            break;
        }
    }
    if (isVidyoShow) {
        for (NSDictionary * dic in self.vidyoRoomSelectList) {
            NSString * selectId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            if ([selectId isEqualToString:mobile]) {
                return YES;
                break;
            }
        }
    }
    return NO;
}

- (BOOL)checkDeptSelected:(NSString*)deptId
{
    if (KCNSSTRING_ISEMPTY(deptId)) {
        return NO;
    }
    NSString * statusStr = [self.selectDeptStatusDic objectForKey:deptId];
    if ([statusStr isEqualToString:@"1"] ) {
        return YES;
    }
    return NO;
}

- (BOOL)checkPersonSelected:(NSString*)nameId
{
    NSString * nameIdStr;
    if (![nameId isKindOfClass:[NSString class]]) {
        nameIdStr = [NSString stringWithFormat:@"%d",[nameId intValue]];
    }else{
        nameIdStr = [NSString stringWithFormat:@"%@",nameId];
    }
    if (KCNSSTRING_ISEMPTY(nameIdStr)) {
        return NO;
    }
    NSString * statusStr = [self.selectPersonStatusDic objectForKey:nameIdStr];
    if ([statusStr isEqualToString:@"1"]) {
        return YES;
    }
   
    return NO;
}

-(void)setBarButtonWithNormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg target:(id)target action:(SEL)action type:(NavigationBarItemType)type{
    [super setBarButtonWithNormalImg:normalImg highlightedImg:highlightedImg target:target action:action type:type];
      [self createNavLeftBarItems];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //判断是否会议中返回 是否联系人详情中返回
    if (!isInputMeetting) {
        [self reloadDeptAndContactSelectStatus];
        //点对点邀请创建群聊
        if (member) {
            KitCompanyAddress * memberBook = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:member];
            [_selectedList addObject:memberBook];
            [self.selectPersonStatusDic setValue:@"1" forKey:memberBook.nameId];
            [self deptSelectStatus:memberBook.department_id isSelect:YES];
            [self updateCurrentIndex:nil];
        }else if (_members){
            for (NSString * data in _members) {
                KitCompanyAddress * memberBook = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:data];
                [self.selectPersonStatusDic setValue:@"1" forKey:memberBook.nameId];
                [self deptSelectStatus:memberBook.department_id isSelect:YES];
            }
        }
    }
    if (isVidyo) {
        for (KitCompanyAddress *address in _vidyoMemeberList) {
            [self.selectPersonStatusDic setValue:@"1" forKey:address.nameId];
            [self deptSelectStatus:address.department_id isSelect:YES];
        }
        for (KitCompanyAddress *addressbook in _selectedList) {
            [self checkPersonSelected:addressbook.nameId];
            [self.selectPersonStatusDic setValue:@"1" forKey:addressbook.nameId];
        }
    }
    isShowMygroup = [[self.data objectForKey:@"isTransmitNum"]boolValue];
    isSharedNum = [[self.data objectForKey:@"isSharedNum"]boolValue];
    _isFromVidyoVC = [[self.data objectForKey:@"isFromVidyoVC"]boolValue];
    
    [self.tableView reloadData];
}

- (void)isAnon_senderClick:(NSNotification *)noti{
    
    NSString * str = [noti.userInfo objectForKey:@"isAnon_sender"];
    if ([str isEqualToString:@"1"]) {
        isAnon_sender = YES;
    }else{
        isAnon_sender = NO;
    }
}
// 创建搜索view
-(void)createSearchView
{
    CGFloat y=0;
    if(iOS7)
    {
        y=64.0;
    }
    self.searchView = [[RXSearchTextView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 38*fitScreenWidth)];
    self.searchView.delgate = self;
    self.searchView.searchTextView.delegate = self;
    self.searchView.customScrollView.delegate = self;
    if (isGroup || selectType == SelectContact_CreateVidyoRoom) {
        self.searchView.placeholderLabel.text = @"搜索";
    }else{
        self.searchView.placeholderLabel.text = @"搜索或邀请陌生号码";
    }
    
    [self.view addSubview:self.searchView];
    if (isVidyo) {
        if (_selectedList.count == 0) {
            [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:[NSString stringWithFormat:@"确定(%d/%lu)",0,5-self.vidyoMemeberList.count] titleColor:@"BFBFBF" target:self action:nil type:NavigationBarItemTypeRight];
        }else{
            [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:[NSString stringWithFormat:@"确定(%d/%lu)",(int)[_selectedList count],5-self.vidyoMemeberList.count] titleColor:@"75D29D" target:self action:@selector(presentVidyoSelectedVC) type:NavigationBarItemTypeRight];
        }
    }else{
      [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:@"确定" titleColor:@"BFBFBF" target:self action:@selector(inviteBtnClicked) type:NavigationBarItemTypeRight];
    }
  
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44*fitScreenWidth + y, kScreenWidth, kScreenHeight - 44*fitScreenWidth - y)];
   
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    __weak typeof(self) weak_self = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        isRefuesh = YES;//刷新
        //增量下载通讯录
        weak_self.otherDeptList =[[NSMutableArray alloc]init];
        weak_self.otherDeptList =[KitCompanyAddress getCompanyAddressArray];
        
    
        if(self.otherDeptList.count>0)
        {
            //所有数据下载成功 进行增量下载
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:KNotification_ADDCOUNTQUEST];
            //移除存进数据库的记录,刷新数据库
            
        }else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",KNotification_ADDCOUNTQUESTTime,[RXUser sharedInstance].mobile]];
        }
        weak_self.DeptName=@"";
        [weak_self reloadCompanyBook];
    }];
    
    self.tableView.pullToRefreshView.backgroundColor = [UIColor clearColor];

}
//添加selectList中没有的联系人
- (void)addContactToSelectList:(KitCompanyAddress *)book{

    if ([_existMemArray containsObject:book.mobilenum]) {
        return;
    }
    int num = (int)self.selectedList.count;
    if (num) {
        for (int i = 0; i < num; i ++) {
            KitCompanyAddress * addr = [self.selectedList objectAtIndex:i];
            if ([book.mobilenum isEqualToString:addr.mobilenum]) {
                break;
            }
            if (i == num - 1) {
                [self.selectedList addObject:book];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_current_index object:self userInfo:nil];
            }
        }
    }else{
        [self.selectedList addObject:book];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_current_index object:self userInfo:nil];
    }
}

- (void)addContactClick{

    //NSInteger phoneNumLength = self.phoneNumLab.text.length;
    NSMutableArray * phoneArr = [NSMutableArray arrayWithCapacity:0];
    [phoneArr addObjectsFromArray:[[KitAddressBookManager sharedInstance] allContactsPhone]];
    for (int i = 0; i < phoneArr.count; i ++) {
        KitAddressBook * book = [phoneArr objectAtIndex:i];
        KitCompanyAddress * companyAddr = [[KitCompanyAddress alloc] init];
        companyAddr.name = book.name;
        companyAddr.photourl = book.photourl;
        companyAddr.urlmd5 = book.urlmd5;
        companyAddr.fnmname = book.firstLetter;
        companyAddr.signature = book.signature;
        companyAddr.voipaccount = book.voipaccount;
        [phoneArr replaceObjectAtIndex:i withObject:companyAddr];
    }
    [phoneArr addObjectsFromArray:self.companyData];
    
    if (! [self isMobileNumber:self.phoneNumLab.text withIsFixedNumber:YES]) {
        [SVProgressHUD showErrorWithStatus:@"请输入有效号码"];
    }else{
        for (int i = 0; i < phoneArr.count; i ++) {
            KitCompanyAddress * addr = [phoneArr objectAtIndex:i];
            if ([self.phoneNumLab.text isEqualToString:addr.mobilenum]) {
                [self addContactToSelectList:addr];
            }else if (i == phoneArr.count - 1) {
                //陌生号码
                KitCompanyAddress * address = [[KitCompanyAddress alloc] init];
                address.name = [self.phoneNumLab.text substringToIndex:3];
                address.mobilenum = self.phoneNumLab.text;
                [self addContactToSelectList:address];
            }else{
                continue;
            }
        }
    }
    
    self.searchView.searchTextView.text = @"";
    self.searchView.placeholderLabel.hidden = NO;
    self.phoneNumLab.text = @"";
    addContactViewHeight = 0;
    CGFloat y=0;
    if(iOS7)
    {
        y=64.0;
    }
//    self.backgroundView.frame = CGRectMake(0, 44*fitScreenWidth + y + addContactViewHeight, kScreenWidth, 45);
    self.tableView.frame = CGRectMake(0, 44*fitScreenWidth + y + addContactViewHeight, kScreenWidth, kScreenHeight - 44*fitScreenWidth - y - addContactViewHeight);
//    self.addContactView.hidden = YES;
    [self.tableView reloadData];
}



#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.searchView.searchTextView resignFirstResponder];
    
    
}
#pragma mark RXSearchTextViewDelegate

- (void)SearchTextViewCancelAction{
    [self.tableView reloadData];
}

- (void)SearchTextViewDidChange{
    
    CGFloat y=0;
    if(iOS7)
    {
        y=64.0;
    }
    
    self.phoneNumLab.text = self.searchView.searchTextView.text;
    
    if ([self.searchView.searchTextView.text length] == 0) {
        addContactViewHeight = 0;
//        self.backgroundView.frame = CGRectMake(0, 44*fitScreenWidth + y + addContactViewHeight, kScreenWidth, 45);
        self.tableView.frame = CGRectMake(0, 44*fitScreenWidth + y  + addContactViewHeight, kScreenWidth, kScreenHeight - 44*fitScreenWidth - y - addContactViewHeight);
    }else{
        if (!isGroup &&  [self isMobileNumber:self.phoneNumLab.text withIsFixedNumber:YES]) {
            addContactViewHeight = 44*fitScreenWidth;
//            self.backgroundView.frame = CGRectMake(0, 44*fitScreenWidth + y + addContactViewHeight, kScreenWidth, 45);
            self.tableView.frame = CGRectMake(0, 44*fitScreenWidth + y + addContactViewHeight, kScreenWidth, kScreenHeight - 44*fitScreenWidth - y  - addContactViewHeight);
        }
    }
    [self.tableView addWaitingView];
    _searchArray =[self.searchView SearchPersonResultWithCompanyData:self.allContactData ResultJson:nil];
    [self.tableView removeWaitingView];
    [self.tableView reloadData];
}

#pragma mark  选中联系人刷新视图
-(void)updateCurrentIndex:(NSNotification *)notification
{
//    if (_members) {
//        for (NSString * data in _members) {
//            if (![data isEqualToString:[RXUser sharedInstance].mobile] ) {
//                for (int i = 0; i < _selectedList.count; ) {
//                    KitCompanyAddress * book = [_selectedList objectAtIndex:i];
//                    if ([data isEqualToString:book.mobilenum]) {
//                        [_selectedList removeObject:book];
//                        break;
//                    }else {
//                        i ++;
//                    }
//                }
//            }
//        }
//    }

    if (isVidyo) {
        if (_selectedList.count == 0) {
             [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:[NSString stringWithFormat:@"确定(%d/%lu)",(int)[_selectedList count],kVIDYOMAXCOUNT-self.vidyoMemeberList.count] titleColor:@"BFBFBF" target:self action:nil type:NavigationBarItemTypeRight];
        }else{
            [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:[NSString stringWithFormat:@"确定(%d/%lu)",(int)[_selectedList count],kVIDYOMAXCOUNT-self.vidyoMemeberList.count] titleColor:@"75D29D" target:self action:@selector(presentVidyoSelectedVC) type:NavigationBarItemTypeRight];
        }
    }else{
        if (_selectedList.count == 0) {
            [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:@"确定" titleColor:@"BFBFBF" target:self action:nil type:NavigationBarItemTypeRight];
        }else{
            if (isSharedNum || isShowMygroup) {
                [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:[NSString stringWithFormat:@"确定(%d)",(int)[_selectedList count]] titleColor:@"75D29D" target:self action:@selector(inviteBtnClicked) type:NavigationBarItemTypeRight];
            }else if (isBurn){
                [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:[NSString stringWithFormat:@"确定"] titleColor:@"75D29D" target:self action:@selector(inviteBtnClicked) type:NavigationBarItemTypeRight];
            }else{
                [self setBarButtonItemWithNormalImg:nil highlightedImg:nil titleText:[NSString stringWithFormat:@"确定(%d/%d)",(int)[_selectedList count],kMAXSELECTEDCOUNT] titleColor:@"75D29D" target:self action:@selector(inviteBtnClicked) type:NavigationBarItemTypeRight];
            }
        }
    }

    int allCount = 0;
    //当前的 联系人和部门
    NSArray * personArray = [self.personDictionary objectForKey:self.P_department_id];
    for (int i = 0; i < personArray.count; i ++) {
        id personData = [personArray objectAtIndex:i];
        if ([personData isKindOfClass:[KitCompanyAddress class]]) {
            KitCompanyAddress * book = (KitCompanyAddress *)personData;
            NSString * str = [self.selectPersonStatusDic objectForKey:book.nameId];
            if ([str isEqualToString:@"1"]) {
                allCount++;
            }else{
                break;
            }
        }else{
            NSDictionary * book = (NSDictionary *)personData;
            NSString * str = [self.selectPersonStatusDic objectForKey:[NSString stringWithFormat:@"%d",[[book objectForKey:@"uid"] intValue]]];
            if ([str isEqualToString:@"1"]) {
                allCount++;
            }else{
                break;
            }
        }
    }
    for (KitCompanyDeptNameData * data in self.DeptArray) {
        if ([data.parent_dept isEqualToString:self.P_department_id]) {
            NSString * str = [self.selectDeptStatusDic objectForKey:data.department_id];
            if ([str isEqualToString:@"1"]) {
                allCount++;
            }else{
                break;
            }
        }
    }
    
    CGFloat y=0;
    if(iOS7)
    {
        y=64.0;
    }
    
    if (_selectedList.count == 0 || (( _selectedList.count == 1 && ![[self.data objectForKey:@"style"] isEqualToString:KINVITE_JOINMEEtting]) && (([self.data isKindOfClass:[NSDictionary class]]&&![self.data objectForKey:@"group_info"])||([self.data isKindOfClass:[KXJson class]]&& ![self.data getStringForKey:@"style"])))) {
        self.tableView.frame = CGRectMake(0, 44*fitScreenWidth + y + addContactViewHeight, kScreenWidth, kScreenHeight - 44*fitScreenWidth - y - addContactViewHeight);
        [self.tableView reloadData];

    }else{
        self.tableView.frame = CGRectMake(0, 44*fitScreenWidth + y + addContactViewHeight, kScreenWidth, kScreenHeight - 44*fitScreenWidth - y  - addContactViewHeight);
        [self.tableView reloadData];
    }

    [self.searchView.customScrollView.contactArr removeAllObjects];
    [self.searchView.customScrollView.contactArr addObjectsFromArray:_selectedList];
    if (_vidyoRoomSelectList.count > 0) {
        [_selectedList addObjectsFromArray:_vidyoRoomSelectList];
    }
    if (_selectedList.count > 0) {
        self.searchView.imgView.hidden = YES;
    }else{
        self.searchView.imgView.hidden = NO;
    }
    [self.searchView.customScrollView.picScollView reloadData];
    self.searchView.selectList = _selectedList;
    self.searchView.customScrollView.frame = CGRectMake(0, 2*fitScreenWidth,  _selectedList.count * 36,36*fitScreenWidth);
    CGFloat margin = self.searchView.imgView.hidden ? 0 : 20;
    CGFloat searchX = MIN(CGRectGetMaxX(self.searchView.customScrollView.frame)+margin, 6 * 36);
      self.searchView.searchTextView.frame = CGRectMake(searchX, 2*fitScreenWidth, kScreenWidth-searchX, 36*fitScreenWidth);
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.searchView.imgView.hidden = YES;
    if (_selectedList.count == 0) {
        self.searchView.searchTextView.frame = CGRectMake(5, 2*fitScreenWidth, kScreenWidth - 5, 36*fitScreenWidth);
    }
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (_selectedList.count == 0) {
        self.searchView.searchTextView.frame = CGRectMake(CGRectGetMaxX(self.searchView.imgView.frame), 2*fitScreenWidth, kScreenWidth - CGRectGetMaxX(self.searchView.imgView.frame), 36*fitScreenWidth);
        self.searchView.imgView.hidden = NO;
    }else{
        self.searchView.imgView.hidden = YES;
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    if ([textView.text length] == 0) {
        
        self.searchArray =nil;
        self.searchArray=[[NSArray alloc]init];
        [self.searchView.placeholderLabel setHidden:NO];
//        [self.searchView.cancelButton setHidden:YES];
        self.searchView.imgView.hidden = YES;
        
    }else{
        [self.searchView.placeholderLabel setHidden:YES];
        [self.searchView.cancelButton setHidden: NO];

    }
    [self.searchView.delgate SearchTextViewDidChange];
}
#pragma mark customSrollViewDelegate
- (void)deleteContact:(NSInteger)index{

    KitCompanyAddress * book = [self.selectedList objectAtIndex:index];
    if (book.nameId) {
        [self.selectPersonStatusDic setValue:@"0" forKey:book.nameId];
        if (![book.nameId isEqualToString:book.mobilenum]) {
            [self deptSelectStatus:book.department_id isSelect:NO];
        }
    }
    
    [_selectedList removeObjectAtIndex:index];
//    [_vidyoRoomSelectList removeObjectAtIndex:index];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_current_index object:self userInfo:nil];
}

#pragma mark tableViewDelegate tableViewDataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.searchView.searchTextView.text.length>0)  {
        return nil;
    }
    else{
        if (isPhoneShow) {
            return self.allAddressKeys;
        }else{
            return nil;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchView.searchTextView.text length] == 0 && ((isPhoneShow && [self.allAddressKeys count] == 0)||(isCompanyShow&& self.companyDeptList.count == 0))) {
        return 200;
    }
    if (isCompanyShow && [self.searchView.searchTextView.text length] == 0&& ([[_companyDeptList objectAtIndex:indexPath.row] isKindOfClass:[KitCompanyDeptNameData class]] || [[_companyDeptList objectAtIndex:indexPath.row] isKindOfClass:[KXJson class]])) {
        return 50;
    }
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.searchView.searchTextView.text length] == 0) {
        if (!isCompanyShow&&!isPhoneShow&& !isVidyoShow) {
            if (selectType == SelectContact_InviteMeetRoom) {
                return 1;
            }
            if (!isGroupInvite || isShowMygroup) {
                return 3;
            }else{
                return 2;
            }
            return 3;
        }else if (isCompanyShow){
            return 1;
        }else{
            if (self.allAddressKeys.count == 0) {
                return 1;
            }
            return self.allAddressKeys.count;
        }
    }else{
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if ([self.searchView.searchTextView.text length] == 0) {
        if (!isCompanyShow&&!isPhoneShow) {
            if (section == 0 || (section == 1 && !isGroupInvite) || (section == 1 && isShowMygroup) ) {
                return 50;
            }else{
                return 30;
            }
        }else if (isCompanyShow) {
            if (self.companyDeptList.count == 0&&self.companyData.count == 0) {
                return 0;
            }
            return 40;
        }else{
            if ([self.allAddressKeys count] == 0) {
                return 0;
            }
            return 20;
        }
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if ([self.searchView.searchTextView.text length] != 0) {
        return nil;
    }
    if (!isCompanyShow&&!isPhoneShow) {
        if (section == 0&&!isGroupInvite) {
            self.phoneView = [[RXSelectContactSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50) Tag:0 Layer:@"Person"];
            self.phoneView.delegate = self;
            self.phoneView.titleLab.text = @"手机联系人";
            int phoneNumCount = 0;
            for (int i = 0; i < self.allAddressKeys.count; i ++) {
                phoneNumCount += [(NSArray *)self.localAddressBook[self.allAddressKeys[i]] count];
            }
            self.phoneView.numLab.text = [NSString stringWithFormat:@"(%d)",phoneNumCount];
            return self.phoneView;
        }else if ((section == 0&&isGroupInvite)||(section == 1&&!isGroupInvite)) {
            self.companyView = [[RXSelectContactSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50) Tag:1 Layer:@"Dept"];
            self.companyView.delegate = self;
            self.companyView.titleLab.text = @"企业联系人";
            NSArray * Arr = [KitCompanyAddress getCompanyAddressArray];
            
            int PYContactCount = (int)[Arr count];
            self.companyView.numLab.text = [NSString stringWithFormat:@"(%d)",(int)(PYContactCount)];
            
            return self.companyView;
        }else if (section == 1 && isShowMygroup){
            self.myGroupVIew = [[RXSelectContactSectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50) Tag:2 Layer:@"myGroup"];
            self.myGroupVIew.delegate = self;
            self.myGroupVIew.titleLab.text = @"选择群组";
            
            return self.myGroupVIew;
        }
        else{
            
            UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth, 20)];
            titleLab.text = @"   最近联系人";
            titleLab.backgroundColor = [UIColor whiteColor];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.textColor = [UIColor lightGrayColor];
            return titleLab;
        }
    }else {
        if (isPhoneShow) {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
            headView.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
            
            // 文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-15, 20)];
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithRGB:0x666666];
            [headView addSubview:label];
            if (self.searchView.searchTextView.text == 0) {
                label.text = self.allAddressKeys[section];
            }else{
                NSArray * array = self.localAddressBook[self.allAddressKeys[section]];
                if (array.count > 0) {
                    KitAddressBook * addr = [array objectAtIndex:0];
                    if(addr.firstLetter.length>0)
                    {
                        label.text = [NSString stringWithFormat:@"%c",[addr.firstLetter characterAtIndex:0]];
                    }
                }
            }
            
            return headView;
        }else {
            
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
            view.backgroundColor = [UIColor whiteColor];
            
            UIScrollView * scrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
            scrolView.backgroundColor = [UIColor whiteColor];
            scrolView.showsHorizontalScrollIndicator = NO;
            scrolView.showsVerticalScrollIndicator = NO;
            [view addSubview:scrolView];
            
//            [view addSubview:AllSelect];
            
            //CGSize beforeSize = CGSizeMake(0, 0);
            CGFloat beforePointX = 0;
            NSUInteger num = deptLevel;
            
            for (int i = 0; i < num; i ++) {
                self.companyView = [[RXSelectContactSectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 40) Tag:1+i Layer:self.idArray[i]];
                self.companyView.delegate = self;
                self.companyView.titleLab.font = [UIFont systemFontOfSize:16];
//                self.companyView.titleLab.textColor = [UIColor colorWithIntRed:117 green:210 blue:157 alpha:255];
                if (deptLevel == 1+i) {
                    self.companyView.titleLab.textColor = [UIColor colorWithIntRed:151 green:158 blue:168 alpha:255];
                }else{
                    self.companyView.titleLab.textColor = [UIColor colorWithIntRed:117 green:210 blue:157 alpha:255];
                }
                CGSize size;
                CGFloat PointX;
                if (i == 0) {
                    //self.companyView.titleLab.text = @"  获取失败";
                    if([[RXUser sharedInstance] companyname].length>0)
                    {
                        self.companyView.titleLab.text=[NSString stringWithFormat:@"  %@",[[RXUser sharedInstance] companyname]];
                    }
                    size = [self.companyView.titleLab.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.companyView.titleLab.font,NSFontAttributeName, nil]];
                    self.companyView.frame = CGRectMake(0, 0, size.width + 10, 40);
                    self.companyView.titleLab.frame = CGRectMake(5, (self.companyView.frame.size.height - 20)/2, 100, 30);
                    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 16, self.companyView.frame.size.width + 10, 16)];
                    PointX = imageView.frame.origin.x + imageView.frame.size.width;
                    UIImage * img = [UIImage imageNamed:@"enter_icon_02"];
                    imageView.image = [img stretchableImageWithLeftCapWidth:1 topCapHeight:0];
                    imageView.userInteractionEnabled = NO;
                    [self.companyView addSubview:imageView];
                }else{
                    self.companyView.titleLab.text = [self.idDict objectForKey:self.idArray[i]];
                    size = [self.companyView.titleLab.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.companyView.titleLab.font,NSFontAttributeName, nil]];
                    self.companyView.frame = CGRectMake(beforePointX, 0, size.width + 20, 40);
                    self.companyView.backgroundColor = [UIColor clearColor];
                    self.companyView.titleLab.frame = CGRectMake(0, (self.companyView.frame.size.height - 20)/2, 100, 30);
                    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-24,16, self.companyView.frame.size.width + 20, 16)];
                    PointX = beforePointX + imageView.frame.size.width - 20;
                    UIImage * img = [UIImage imageNamed:@"enter_icon_02"];
                    imageView.image = [img stretchableImageWithLeftCapWidth:1 topCapHeight:0];
                    imageView.userInteractionEnabled = NO;
                    [self.companyView addSubview:imageView];
                }
                scrolView.contentSize = CGSizeMake(self.companyView.frame.size.width + self.companyView.frame.origin.x, 0);
                self.companyView.img.hidden = YES;
                self.companyView.line.hidden = YES;
                beforePointX = PointX;
               // beforeSize = size;
                [scrolView addSubview:self.companyView];
            }
            return view;
        }
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchView.searchTextView.text length] != 0) {
        return [_searchArray count];
    }
    
    if (!isCompanyShow&&!isPhoneShow) {
        if (section == 0&&!isGroupInvite) {
            return 0;
        }else if ((section == 0&&isGroupInvite)||(section == 1&&!isGroupInvite)) {
            return 0;
        }else{
            if (section == 1 && isShowMygroup) {
                return 0;
            }
            return [self.recentlyContactData count];
        }
    }else {
        if (isCompanyShow) {
            if (self.companyDeptList.count == 0) {
                return 1;
            }
            return [_companyDeptList count];
        }else{
            if ([self.allAddressKeys count] == 0) {
                return 1;
            }
            NSArray * array = self.localAddressBook[self.allAddressKeys[section]];
            return [array count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([self.companyDeptList count] == 0) {
        UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"nocompanyCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nocompanyCell"];
            UILabel *label =[[UILabel alloc]init];
            label.frame=CGRectMake(40, kScreenHeight/4, kScreenWidth-80, 30);
            label.backgroundColor =[UIColor clearColor];
            label.textAlignment=NSTextAlignmentCenter;
            label.text=@"未加入(未获取)企业通讯录";
            label.textColor =[UIColor grayColor];
            label.alpha=.7;
            [cell.contentView addSubview:label];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    if ([self.searchView.searchTextView.text length] != 0 ) {
       NSMutableArray *   companyArr = [NSMutableArray arrayWithArray:_searchArray];
        return [self fillCompanyContactTableViewCell:indexPath CompanyData:companyArr];
    }else{
        if (isCompanyShow && self.companyDeptList.count>0 && ([[_companyDeptList objectAtIndex:indexPath.row] isKindOfClass:[KitCompanyDeptNameData class]] || [[_companyDeptList objectAtIndex:indexPath.row] isKindOfClass:[KXJson class]])) {

            return [self fillDeptTableViewCell:indexPath CompanyData:self.companyDeptList];
        
        }else if (isPhoneShow){//手机联系人
            return [self fillPhoneNumTableViewCell:indexPath];
        }else{//企业联系人
            NSMutableArray * companyArr = [NSMutableArray arrayWithCapacity:0];
            if (!isCompanyShow&&!isPhoneShow) {
                companyArr = [NSMutableArray arrayWithArray:self.recentlyContactData];
            }else{

                companyArr = [NSMutableArray arrayWithArray:[self.searchView SearchPersonResultWithCompanyData:_companyDeptList ResultJson:_resultJson]];
            }
            return [self fillCompanyContactTableViewCell:indexPath CompanyData:companyArr];
        }
    }
}

#pragma mark
- (UITableViewCell *)fillDeptTableViewCell:(NSIndexPath *)indexPath CompanyData:(NSMutableArray *)companyArr
{
    NSString *kTableViewCellIdentify = [NSString stringWithFormat:@"dept_table_cell_identify"];
    RXDeptSelectTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentify];
    if (!cell) {
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        cell = [RXDeptSelectTableViewCell classFromNib:@"RXDeptSelectTableViewCell"];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRGB:0xC8C7CC];
        
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
        [cell.contentView addSubview:lineView];
        
    }
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.selectDept.hidden = NO;
 
    KitCompanyDeptNameData *deptData;
    KXJson *deptJson;
    deptData = [companyArr objectAtIndex:indexPath.row];
    deptJson = [companyArr objectAtIndex:indexPath.row];
    
    if([deptData isKindOfClass:[KXJson class]])
    {
        //获取个数
        arrayCount =[[NSMutableArray alloc]init];
        
        NSInteger count =  [self getCompanyNum:nil withKxjson:deptJson];
        cell.deptLab.text =[NSString stringWithFormat:@"%@(%d)",ISSTRING_ISSTRING([deptJson getStringForKey:@"dnm"]) ,(int)count];
        if ([self checkDeptSelected:ISSTRING_ISSTRING([deptJson getStringForKey:@"did"])]) {
            
            [cell.selectDept setSelected:YES];
            cell.selectDept.userInteractionEnabled = YES;
            NSInteger memberCount = 0;
            for (NSString * book in _members) {
                KitCompanyAddress * data = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:book];
                if ([data.department_id isEqualToString:ISSTRING_ISSTRING([deptJson getStringForKey:@"did"])]) {
                    memberCount += 1;
                }
            }
            if (_members && memberCount == count) {//该部门成员已全部是群成员，该部门也禁止被选择或取消
                cell.selectDept.userInteractionEnabled = NO;
            }
        }else{
            [cell.selectDept setSelected:NO];
            if (_selectedList.count >= kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo) {
                cell.selectDept.userInteractionEnabled = NO;
            }
            if (isVidyo && _selectedList.count >= kVIDYOMAXCOUNT-_vidyoMemeberList.count) {
                cell.selectDept.userInteractionEnabled = NO;
            }
        }
    }else
    {
        if([deptData isKindOfClass:[KitCompanyDeptNameData class]]){
            
            arrayCount =[[NSMutableArray alloc]init];
            NSInteger count =  [self getCompanyNum:deptData withKxjson:nil];
            cell.deptLab.text = [NSString stringWithFormat:@"%@(%ld)",deptData.department_name,(long)count];
            if ([self checkDeptSelected:deptData.department_id]) {
               
                [cell.selectDept setSelected:YES];
                cell.selectDept.userInteractionEnabled= YES;
                
                NSInteger memberCount = 0;
                for (NSString * book in _members) {
                    KitCompanyAddress * data = [KitCompanyAddress getCompanyAddressInfoDataWithMobilenum:book];
                    if ([data.department_id isEqualToString:deptData.department_id]) {
                        memberCount += 1;
                    }
                }
                if (_members && memberCount == count) {//该部门成员已全部是群成员，该部门也禁止被选择或取消
                    cell.selectDept.userInteractionEnabled = NO;
                }
            }else{
                [cell.selectDept setSelected:NO];
                if (_selectedList.count >= kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo)  {
                    cell.selectDept.userInteractionEnabled = NO;
                }
                if (isVidyo && _selectedList.count >=kVIDYOMAXCOUNT-_vidyoMemeberList.count) {
                    cell.selectDept.userInteractionEnabled = NO;
                }
            }
        }
    }
    return cell;
}

- (UITableViewCell *)fillPhoneNumTableViewCell:(NSIndexPath *)indexPath{//手机联系人
    if (isVidyoShow) {
        #pragma mark - zmfg vidyoRooms会议室 这个还要吗 原来在RXUser里 2504-2520
//        if ([RXUser sharedInstance].vidyoRooms.count == 0) {
//            UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"noRoomCell"];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noRoomCell"];
//                UILabel *label =[[UILabel alloc]init];
//                label.frame=CGRectMake(kScreenWidth/2-80, kScreenHeight/4, 160, 30);
//                label.backgroundColor =[UIColor clearColor];
//                label.textAlignment=NSTextAlignmentCenter;
//                label.text=@"暂无会议室";
//                label.textColor =[UIColor grayColor];
//                label.alpha=.7;
//                [cell.contentView addSubview:label];
//            }
//            
//            return cell;
//            
//        }
        
        HYTSelectedMediaContactsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"RXSelectedVidyoRoomCell"];
        if (cell == nil) {
            
            for(UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            cell = [HYTSelectedMediaContactsCell classFromNib:@"HYTSelectedMediaContactsCell"];
            cell.titleLabel.text = @"";
            cell.subTitleLabel.text = @"";
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.tag = indexPath.row;
        cell.section = indexPath.section;
        cell.selectedButton.userInteractionEnabled=YES;
        #pragma mark - zmfg vidyoRooms会议室 这个还要吗 原来在RXUser里 2539-2547
//        NSArray * vidyoRooms = [RXUser sharedInstance].vidyoRooms;
//        NSDictionary * vidyoRoom = [vidyoRooms objectAtIndex:indexPath.row];
//        
//        [cell.selectedButton setSelected:[self checkSelected:[NSString stringWithFormat:@"%@",[vidyoRoom objectForKey:@"id"]]]];
//        
//        cell.userHeadImageView.image= [UIImage imageNamed:@"default_avatar_01"];
//        cell.titleLabel.text = [vidyoRoom objectForKey:@"roomName"];
//        cell.subTitleLabel.text = [vidyoRoom objectForKey:@"confNum"];
        return cell;
        
    }else if ([self.allAddressKeys count] == 0) {
        UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"noContactCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noContactCell"];
            UILabel *label =[[UILabel alloc]init];
            label.frame=CGRectMake(kScreenWidth/2-80, kScreenHeight/4, 160, 30);
            label.backgroundColor =[UIColor clearColor];
            label.textAlignment=NSTextAlignmentCenter;
            label.text=@"暂无联系人";
            label.textColor =[UIColor grayColor];
            label.alpha=.7;
            [cell.contentView addSubview:label];
        }
        
        return cell;
    }
    
    HYTSelectedMediaContactsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"RXSelectedMediaContactsCell"];
    if (cell == nil) {
        
        for(UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        cell = [HYTSelectedMediaContactsCell classFromNib:@"HYTSelectedMediaContactsCell"];
        cell.titleLabel.text = @"";
        cell.subTitleLabel.text = @"";
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.tag = indexPath.row;
    cell.section = indexPath.section;
    
    //NSMutableArray * locationPhoneNumArr = [NSMutableArray arrayWithArray:self.localAddressBook[self.allAddressKeys[indexPath.section]]];
    KitAddressBook *adressData = self.localAddressBook[self.allAddressKeys[indexPath.section]][indexPath.row];
    NSDictionary *mobileDic =adressData.phones;
    NSString *keyMobile=nil;
    if(mobileDic.count>0)
    {
        keyMobile=mobileDic.allKeys[0];
    }
    NSString *mobilenum =[mobileDic objectForKey:keyMobile];
    
    cell.selectedButton.userInteractionEnabled=YES;
    
    //是否选中
    if ([mobilenum isEqualToString:[[RXUser sharedInstance] mobile]] && indexPath.row==0) {
      
        cell.selectedButton.userInteractionEnabled = NO;
       
    }
    if ([self checkSelected:mobilenum]) {
        for (KitCompanyAddress *address in self.companyData) {
            if ([address.mobilenum isEqualToString:mobilenum]) {
                [self checkPersonSelected:address.nameId];
            }
        }
        [cell.selectedButton setSelected:YES];
      
    
        BOOL ismember = YES;
        for (NSString * book in _members) {
            if (![book isEqualToString:mobilenum]) {
                ismember = NO;
            }
        }
        if (ismember && _members) {//群聊已有的群员禁止选择或取消
            cell.selectedButton.userInteractionEnabled = NO;
        }
    }else{
        [cell.selectedButton setSelected:NO];
    }
    NSString *urlStr =adressData.photourl;
    if(!KCNSSTRING_ISEMPTY(urlStr))
    {
        NSURL *url =[NSURL URLWithString:urlStr];
        [cell.userHeadImageView setImageWithURL:url placeholderImage:[adressData.sex isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"] options:SDWebImageRefreshCached];
       
    }else
    {
        cell.userHeadImageView.image=[adressData.sex isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"];
    }
    
    cell.titleLabel.text = adressData.name;
    cell.subTitleLabel.text = mobilenum;
    
    cell.selectedButton.hidden = NO;
    if ([_existMemArray containsObject:adressData.mobilenum]) {
        cell.selectedButton.hidden = YES;
        [cell.selectedButton setSelected:YES];
        cell.selectedButton.userInteractionEnabled = YES;
    }
    return cell;
}

- (UITableViewCell *)fillCompanyContactTableViewCell:(NSIndexPath *)indexPath CompanyData:(NSMutableArray *)companyArr{
    
    if (isCompanyShow && [self.companyDeptList count] == 0) {
        UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"nocompanyCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nocompanyCell"];
            UILabel *label =[[UILabel alloc]init];
            label.frame=CGRectMake(kScreenWidth/2-80, kScreenHeight/4, 160, 30);
            label.backgroundColor =[UIColor clearColor];
            label.textAlignment=NSTextAlignmentCenter;
            label.textColor =[UIColor grayColor];
            label.tag = 100;
            label.alpha=.7;
            [cell.contentView addSubview:label];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UILabel * titleLab = (UILabel *)[cell.contentView viewWithTag:100];
        if (self.companyData.count == 0) {
            titleLab.text=@"未加入企业通讯录";
        }else{
            titleLab.text = @"没有联系人";
        }
        
        return cell;
    }
    
    HYTSelectedMediaContactsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kHYTSelectedMediaContactsCell];
    if (cell == nil) {
        
        for(UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        cell = [HYTSelectedMediaContactsCell classFromNib:@"HYTSelectedMediaContactsCell"];
        cell.titleLabel.text = @"";
        cell.subTitleLabel.text = @"";
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.tag = indexPath.row;
    cell.section = indexPath.section;
    
    KitCompanyAddress *adressData = [[KitCompanyAddress alloc] init];
    if ([companyArr[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        NSDictionary * person = companyArr[indexPath.row];
        if ([person objectForKey:@"dnm"]) {
            [self fillDeptTableViewCell:indexPath CompanyData:companyArr];

        }else{
            adressData.name = ISSTRING_ISSTRING([person objectForKey:@"unm"]);
            adressData.nameId = ISSTRING_ISSTRING([person objectForKey:@"uid"]);
            adressData.pyname = ISSTRING_ISSTRING([person objectForKey:@"py"]);
            adressData.signature = ISSTRING_ISSTRING([person objectForKey:@"sign"]);
            adressData.fnmname = ISSTRING_ISSTRING([person objectForKey:@"fnm"]);
            adressData.photourl = ISSTRING_ISSTRING([person objectForKey:@"url"]);
            adressData.urlmd5 = ISSTRING_ISSTRING([person objectForKey:@"md5"]);
            adressData.place = ISSTRING_ISSTRING([person objectForKey:@"up"]);
            adressData.mail = ISSTRING_ISSTRING([person objectForKey:@"mail"]);
            adressData.mobilenum = ISSTRING_ISSTRING([person objectForKey:@"mtel"]);
            adressData.voipaccount = ISSTRING_ISSTRING([person objectForKey:@"voip"]);
            adressData.department_id = ISSTRING_ISSTRING([person objectForKey:@"udid"]);
            adressData.sex =ISSTRING_ISSTRING([person objectForKey:@"sex"]);
        }
    }else{
        adressData = companyArr[indexPath.row];
    }
    if (self.selectedList.count >= kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo) {
        cell.selectedButton.userInteractionEnabled = NO;
    }else{
        if (isVidyo && self.selectedList.count >= kVIDYOMAXCOUNT-_vidyoMemeberList.count) {
            cell.selectedButton.userInteractionEnabled = NO;
        }
//    cell.selectedButton.userInteractionEnabled=YES;
    }
    
    
    if ([adressData.mobilenum isEqualToString:[[RXUser sharedInstance] mobile]]) {
//        [cell.selectedButton setSelected:YES];
        cell.selectedButton.userInteractionEnabled = NO;
    }

    if ([self checkPersonSelected:adressData.nameId]) {
            [cell.selectedButton setSelected:YES];
            cell.selectedButton.userInteractionEnabled = YES;
        BOOL ismember = YES;
        for (NSString * book in _members) {
            if (![book isEqualToString:adressData.mobilenum]) {
                ismember = NO;
            }
        }
        if (ismember && _members) {//群聊已有的群员禁止选择或取消
            cell.selectedButton.userInteractionEnabled = NO;
            
        }
    }else{
        
        [cell.selectedButton setSelected:NO];
    }
    
    cell.selectedButton.hidden = NO;
    if ([_existMemArray containsObject:adressData.mobilenum]) {
      
        [cell.selectedButton setSelected:YES];
        cell.selectedButton.hidden = YES;
        cell.selectedButton.userInteractionEnabled = NO;
        
    }
    
    NSString *urlStr =adressData.photourl;
    
    if(!KCNSSTRING_ISEMPTY(urlStr))
    {
        NSURL *url =[NSURL URLWithString:urlStr];
        [cell.userHeadImageView setImageWithURL:url placeholderImage:[ISSTRING_ISSTRING(adressData.sex) isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"] options:SDWebImageRefreshCached];
        
    }else
    {
        cell.userHeadImageView.image=[ISSTRING_ISSTRING(adressData.sex) isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"];
    }
    
    cell.titleLabel.attributedText = [NSAttributedString attributeChinaesewithContent:adressData.name keyWords:self.searchView.searchTextView.text firstLetter:adressData.fnmname pinyin:adressData.pyname chinaese:adressData.name colors:[UIColor redColor]];
    cell.subTitleLabel.attributedText =  [NSAttributedString attributeStringWithContent:adressData.mobilenum keyWords:self.searchView.searchTextView.text colors:[UIColor redColor]];
    cell.positionLabel.text = adressData.place?[NSString stringWithFormat:@"(%@)",adressData.place]:@"";
    
    CGSize size = [adressData.name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil]];
    cell.titleLabel.frame = CGRectMake(cell.titleLabel.originX, cell.titleLabel.originY, size.width, cell.titleLabel.size.height);
    cell.positionLabel.frame = CGRectMake(cell.titleLabel.originX + size.width, cell.positionLabel.originY, cell.positionLabel.width, cell.positionLabel.height);
    
    return  cell;
}

//部门对应的子部门数量或者成员个数
-(NSInteger )getCompanyNum:(KitCompanyDeptNameData *)ComanyDeptData withKxjson:(KXJson *)jsonData
{
    
    if([jsonData isKindOfClass:[KXJson class]] && jsonData.count>0)
    {
        NSString *deptDid =[jsonData getStringForKey:@"did"];
        
        if ([self.DeptDictionary hasValueForKey:deptDid]) {
            
            NSArray * array = [self.DeptDictionary objectForKey:deptDid];
            for (KXJson * data in array) {
                [self getCompanyNum:nil withKxjson:data];
            }
        }
        if ([self.personDictionary hasValueForKey:deptDid])
        {
            [arrayCount addObjectsFromArray:[self.personDictionary objectForKey:deptDid]];
            
        }
    }else if ([ComanyDeptData isKindOfClass:[KitCompanyDeptNameData class]] && ComanyDeptData){
        
        if ([self.DeptDictionary hasValueForKey:ComanyDeptData.department_id]) {
            
            NSArray * array = [self.DeptDictionary objectForKey:ComanyDeptData.department_id];
            for (KitCompanyDeptNameData * data in array) {
                [self getCompanyNum:data withKxjson:nil];
            }
        }
        if ([self.personDictionary hasValueForKey:ComanyDeptData.department_id])
        {
            [arrayCount addObjectsFromArray:[self.personDictionary objectForKey:ComanyDeptData.department_id]];
        }
    }
    
    return arrayCount.count;
}

- (void)handleAction:(id)sender
{
    [self.searchView.searchTextView resignFirstResponder];
    
    // 邀请好友
    if ([self isGroupMemberInvite]) {
        if (_selectedList && _selectedList.count > 0) {
            [self pushViewController:@"RXFriendJoinViewController" withData:[NSDictionary dictionaryWithObjectsAndKeys:self.data, @"group_info", _selectedList, @"members", nil] withNav:YES];
        }
        return;
    }
    // 创建语音群聊会议
    if(_selectedList && _selectedList.count>0)
    {
        NSString* style = [self.data getStringForKey:@"style"];
        if (style && [style isEqualToString:@"teleconference"]) {
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:[[RXUser sharedInstance]appid],@"appid",@"1",@"autoClose",@"1",@"autoDelete",@"1",@"autoJoin",[NSNumber numberWithInt:1],@"voiceMod",nil];
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"chatInfo",_selectedList,@"user",@"who",@"managerStyle",@"createMeetChatRoom",@"style",nil];
        [self pushViewController:@"RXMeettingViewController" withData: [KXJson jsonWithObject:info] withNav:NO];
        }    
    }

   
}

#pragma mark
#pragma mark RXDeptSelectDelegate
- (void)selectedDeptCell:(RXDeptSelectTableViewCell *)dialingTableViewCell selected:(BOOL)selected{
    
    NSInteger row = dialingTableViewCell.tag;
    KitCompanyDeptNameData *deptData =[[KitCompanyDeptNameData alloc]init];
    KXJson *deptJson;
    if ([self.searchView.searchTextView.text length] == 0) {
        deptData =_companyDeptList[row];
        deptJson =_companyDeptList[row];
    }else{
        deptData = [self.currentListArray objectAtIndex:row];
    }
    
    NSString * idStr = @"";
    NSString * Parent_idStr = @"";
    
    if([deptData isKindOfClass:[KXJson class]])
    {
        idStr = ISSTRING_ISSTRING([deptJson getStringForKey:@"did"]);
        Parent_idStr = ISSTRING_ISSTRING([deptJson getStringForKey:@"dpid"]);
    }else
    {
        if([deptData isKindOfClass:[KitCompanyDeptNameData class]]){
            idStr = deptData.department_id;
            Parent_idStr = deptData.parent_dept;
        }
    }
    
    if (selected) {
        
        
        NSMutableArray * arr = [NSMutableArray array];
        if ([self.personDictionary objectForKey:idStr]) {
            [arr addObjectsFromArray:[self.personDictionary objectForKey:idStr]];
        }
        if ([self.DeptDictionary objectForKey:idStr]) {
            [arr addObjectsFromArray:[self.DeptDictionary objectForKey:idStr]];
        }
        if (arr) {
            
            NSString* style;
            if ([self.data isKindOfClass:[NSDictionary class]]) {
                style = [self.data objectForKey:@"style"];
            }
            if ([style isEqualToString:KTYPE_BURNCHATTING]){//阅后即焚
                if ([arr count]>1 || self.selectedList.count >1) {
                    dialingTableViewCell.selectDept.selected = NO;
                    return;
                }
            }
            
            [self addPersonWithSelectArr:self.selectedList AddArr:arr];
            [self deptSelectStatus:Parent_idStr isSelect:YES];
        }
        [self.selectDeptStatusDic setValue:@"1" forKey:idStr];
        
    }else{
        [self DeleteDept:@[deptData]];
        [self deptSelectStatus:Parent_idStr isSelect:NO];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_current_index object:self userInfo:nil];
}
#pragma mark   部门和员工  迭代

- (void)deptSelectStatus:(NSString *)parent_deptId isSelect:(BOOL)temp{
    if ([parent_deptId isEqualToString:@"0"]) {
        return;
    }
    
    
    if (temp) {
        int i = 0;
        int j = 0;
        NSArray * personArray = self.personDictionary[parent_deptId];
        NSArray * deptArray = self.DeptDictionary[parent_deptId];
        KitCompanyAddress * addr = personArray.lastObject;
        KitCompanyDeptNameData * deptData = deptArray.lastObject;
        if ([addr isKindOfClass:[KitCompanyAddress class]]) {
            //查询部门联系人是否全选中
            for (KitCompanyAddress * book in self.personDictionary[parent_deptId]) {
                NSString * personStatusStr = [self.selectPersonStatusDic objectForKey:book.nameId];
                if ([personStatusStr isEqualToString:@"0"]) {
                    break;
                }
                
                if ((_selectedList.count > kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo) ||(isVidyo && _selectedList.count >= kVIDYOMAXCOUNT-_vidyoMemeberList.count)) {
                    return;
                }else{
                i++;
                }
            }
        }else{
            for (NSDictionary * book in self.personDictionary[parent_deptId]) {
                NSString * personStatusStr = [self.selectPersonStatusDic objectForKey:[book objectForKey:@"uid"]];
                if ([personStatusStr isEqualToString:@"0"]) {
                    break;
                }
                if ((_selectedList.count > kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo) || (isVidyo && _selectedList.count >= kVIDYOMAXCOUNT-_vidyoMemeberList.count)) {
                    return;
                }else{
                i++;
                }
            }
        }
        
        if ([deptData isKindOfClass:[KitCompanyDeptNameData class]]) {
            //查询子部门是否全选中
            for (KitCompanyDeptNameData * data in self.DeptDictionary[parent_deptId]) {
                NSString * deptStatusStr = [self.selectDeptStatusDic objectForKey:data.department_id];
                if ([deptStatusStr isEqualToString:@"0"]) {
                    break;
                }
                j++;
            }
        }else{
            for (NSDictionary * data in self.DeptDictionary[parent_deptId]) {
                NSString * deptStatusStr = [self.selectDeptStatusDic objectForKey:[data objectForKey:@"did"]];
                if ([deptStatusStr isEqualToString:@"0"]) {
                    break;
                }
                if ((_selectedList.count > kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo) || (isVidyo && _selectedList.count >= kVIDYOMAXCOUNT-_vidyoMemeberList.count)) {
                    return;
                }else{
                j++;
                }
            }
        }
        
        int personCount =(int) personArray.count;
        int deptCount = (int)deptArray.count;
        if (i == personCount&&j == deptCount) {
            [self.selectDeptStatusDic setValue:@"1" forKey:parent_deptId];
            
            //递归
            for (KitCompanyDeptNameData * data in self.DeptArray) {
                if ([data.department_id isEqualToString:parent_deptId]) {
                    [self deptSelectStatus:data.parent_dept isSelect:temp];
                    break;
                }
            }
        }
    }else{
        
        [self.selectDeptStatusDic setValue:@"0" forKey:parent_deptId];
        
        for (KitCompanyDeptNameData * data in self.DeptArray) {
            if ([data.department_id isEqualToString:parent_deptId]) {
                [self deptSelectStatus:data.parent_dept isSelect:temp];
                break;
            }
        }
    }
}

- (void)DeleteDept:(NSArray *)deptArr{
    NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    for (int j = 0; j < deptArr.count; j++) {
        KitCompanyDeptNameData * dept = [deptArr objectAtIndex:j];
        if ([dept isKindOfClass:[KitCompanyDeptNameData class]] || [dept isKindOfClass:[KXJson class]]) {
            if ([dept isKindOfClass:[KitCompanyDeptNameData class]]) {
                [self.selectDeptStatusDic setValue:@"0" forKey:dept.department_id];
                //查询部门联系人
                for (KitCompanyAddress * addr in self.companyData) {
                    if ([addr.department_id isEqualToString:dept.department_id]) {
                        [dataArr addObject:addr];
                    }
                }
                //查询子部门
                for (KitCompanyDeptNameData * data in self.DeptArray) {
                    if ([data.parent_dept isEqualToString:dept.department_id]) {
                        [dataArr addObject:data];
                    }
                }
            }else{
                KXJson * deptJson = (KXJson *)dept;
                NSDictionary * Dic = deptJson.json;
                NSString * deptId = [NSString stringWithFormat:@"%d",[[Dic objectForKey:@"did"] intValue]];
                [self.selectDeptStatusDic setValue:@"0" forKey:deptId];
                //查询部门联系人
                for (KitCompanyAddress * addr in self.companyData) {
                    if ([deptId isEqualToString:addr.department_id]) {
                        [dataArr addObject:addr];
                    }
                }
                //查询子部门
                for (KitCompanyDeptNameData * data in self.DeptArray) {
                    if ([data.parent_dept isEqualToString:dept.department_id]) {
                        [dataArr addObject:data];
                    }
                }
            }
            if (dataArr.count > 0) {
                [self DeleteDept:dataArr];
            }
        }else{
            NSString * idStr;
            if ([dept isKindOfClass:[NSDictionary class]]) {
                NSDictionary * dic = (NSDictionary *)dept;
                idStr = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"udid"] intValue]];
            }else{
                idStr = dept.department_id;
            }
            for (int i = 0; i < self.selectedList.count; ) {
                KitCompanyAddress * addr = [self.selectedList objectAtIndex:i];
                if ([addr.department_id isEqualToString:idStr]) {
                    [self.selectPersonStatusDic setValue:@"0" forKey:addr.nameId];
                    [self.selectedList removeObject:addr];
                }else{
                    i ++;
                }
            }
        }
    }
}

- (void)addPersonWithSelectArr:(NSArray *)selectArray AddArr:(NSArray *)addArr{

    NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    for (int j = 0; j < addArr.count; j ++) {
        KitCompanyAddress * addr1 = [addArr objectAtIndex:j];
        
        if (_existMemArray&&[_existMemArray containsObject:addr1.mobilenum]) {

        }else{
            if ([addr1 isKindOfClass:[KitCompanyDeptNameData class]]||[addr1 isKindOfClass:[KXJson class]]) {
                if ([addr1 isKindOfClass:[KitCompanyDeptNameData class]]) {
                    KitCompanyDeptNameData * dept = [addArr objectAtIndex:j];
//                    [self.selectDeptStatusDic setValue:@"1" forKey:dept.department_id];
                    //查询部门联系人
                    for (KitCompanyAddress * addr in self.companyData) {
                        if ([dept.department_id isEqualToString:addr.department_id]) {
                            if ((dataArr.count >= kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo)) {
                                _selectedList = dataArr;
                                [self.selectDeptStatusDic setValue:@"0" forKey:dept.department_id];
                                [self.selectPersonStatusDic setObject:@"0" forKey:addr.nameId];
                                return;
                            }else{
                                 [dataArr addObject:addr];
                                [self.selectDeptStatusDic setValue:@"1" forKey:dept.department_id];
                                 [self.selectPersonStatusDic setObject:@"1" forKey:addr.nameId];
//                                [self.selectDeptStatusDic removeAllObjects];
                            }
                        }
                    }
                    //查询子部门
                    for (KitCompanyDeptNameData * data in self.DeptArray) {
                        if ([data.parent_dept isEqualToString:dept.department_id]) {
                            [dataArr addObject:data];
                        }
                    }
                }else{
                    KXJson * deptJson = (KXJson *)addr1;
                    NSDictionary * Dic = deptJson.json;
                    NSString * deptId = [NSString stringWithFormat:@"%d",[[Dic objectForKey:@"did"] intValue]];
                    [self.selectDeptStatusDic setValue:@"1" forKey:deptId];
                    //查询部门联系人
                    for (KitCompanyAddress * addr in self.companyData) {
                        if ([deptId isEqualToString:addr.department_id]) {
                            [dataArr addObject:addr];
                        }
                    }
                    //查询子部门
                    for (KitCompanyDeptNameData * data in self.DeptArray) {
                        if ([data.parent_dept isEqualToString:deptId]) {
                            [dataArr addObject:data];
                        }
                    }
                }
                if (dataArr.count > 0) {
                    [self addPersonWithSelectArr:self.selectedList AddArr:dataArr];
                }
            }else{
                if (selectArray.count == 0) {
                    if ([addr1 isKindOfClass:[NSDictionary class]]) {
                        NSDictionary * dic = (NSDictionary *)addr1;
                        KitCompanyAddress *searchBook =[[KitCompanyAddress alloc] init];
                        searchBook.name =[dic objectForKey:@"unm"];
                        searchBook.nameId = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"uid"] intValue]];
                        searchBook.pyname = [dic objectForKey:@"py"];
                        searchBook.fnmname = [dic objectForKey:@"fnm"];
                        searchBook.photourl =[dic objectForKey:@"url"];
                        searchBook.urlmd5 =[dic objectForKey:@"md5"];
                        searchBook.place = [dic objectForKey:@"up"];
                        searchBook.mobilenum = [dic objectForKey:@"mtel"];
                        searchBook.voipaccount =[dic objectForKey:@"voip"];
                        searchBook.mail = [dic objectForKey:@"mail"];
                        searchBook.department_id = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"udid"] intValue]];
                        searchBook.sex =[NSString stringWithFormat:@"%d",[[dic objectForKey:@"sex"] intValue]];
                        [self.selectPersonStatusDic setValue:@"1" forKey:searchBook.nameId];
                        [self.selectedList addObject:searchBook];
                    }else{
                        if ([addr1 isKindOfClass:[KitCompanyAddress class]]) {
                            [self.selectPersonStatusDic setValue:@"1" forKey:addr1.nameId];
                            [self.selectedList addObject:addr1];
                        }
                    }
                }else{
                    for (int i = 0; i < selectArray.count; i ++) {
                        KitCompanyAddress * addr2 = [selectArray objectAtIndex:i];
                        if ([addr1 isKindOfClass:[NSDictionary class]]) {
                            NSDictionary * JsonDic = (NSDictionary *)addr1;
                            if ([[JsonDic objectForKey:@"mtel"] isEqualToString:addr2.mobilenum]) {
                                break;
                            }
                        }else{
                            if ([addr1.mobilenum isEqualToString:addr2.mobilenum]) {
                                break;
                            }
                        }
                        if (i == selectArray.count - 1) {
                            if ([addr1 isKindOfClass:[NSDictionary class]]) {
                                NSDictionary * dic = (NSDictionary *)addr1;
                                KitCompanyAddress *searchBook =[[KitCompanyAddress alloc] init];
                                searchBook.name =[dic objectForKey:@"unm"];
                                searchBook.nameId = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"uid"] intValue]];
                                searchBook.pyname = [dic objectForKey:@"py"];
                                searchBook.fnmname = [dic objectForKey:@"fnm"];
                                searchBook.photourl =[dic objectForKey:@"url"];
                                searchBook.urlmd5 =[dic objectForKey:@"md5"];
                                searchBook.place = [dic objectForKey:@"up"];
                                searchBook.mobilenum = [dic objectForKey:@"mtel"];
                                searchBook.voipaccount =[dic objectForKey:@"voip"];
                                searchBook.mail = [dic objectForKey:@"mail"];
                                searchBook.department_id = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"udid"] intValue]];
                                searchBook.sex =[NSString stringWithFormat:@"%d",[[dic objectForKey:@"sex"] intValue]];
                                [self.selectPersonStatusDic setValue:@"1" forKey:searchBook.nameId];
                                [self.selectedList addObject:searchBook];
                               
                            }else{
                                if ([addr1 isKindOfClass:[KitCompanyAddress class]]) {
                                   
                                    if ((self.selectedList.count >= kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo) || (isVidyo && _selectedList.count >= kVIDYOMAXCOUNT-_vidyoMemeberList.count)) {
                                         [self.selectPersonStatusDic setValue:@"0" forKey:addr1.nameId];
                                        
                                        return;
                                    }else{
                                    [self.selectedList addObject:addr1];
                                    [self.selectPersonStatusDic setValue:@"1" forKey:addr1.nameId];
                                    
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
    }
}

- (void)didSelectDeptCell:(RXDeptSelectTableViewCell *)dialingTableViewCell{

    if (isCompanyShow) {
        deptLevel ++;
        selectDeptIndex = dialingTableViewCell.tag;
        [self.searchView.searchTextView resignFirstResponder];
        //searchTextView.text=nil;
        
       // NSMutableArray *array =[KitCompanyData getCompanyArray];
//        BOOL isMoreCount =NO;
//        if(array.count>0)
//        {
//            isMoreCount=YES;
//        }
        
        KitCompanyDeptNameData *companyDept;
        KXJson *deptJson;
        if ([self.searchView.searchTextView.text length] == 0) {
            companyDept =_companyDeptList[selectDeptIndex];
            deptJson =_companyDeptList[selectDeptIndex];
        }else{
            companyDept = [self.currentListArray objectAtIndex:selectDeptIndex];
        }
        
        if([companyDept isKindOfClass:[KXJson class]])
        {
            isFirst=YES;
            self.P_department_id= ISSTRING_ISSTRING([deptJson getStringForKey:@"did"]);
            NSString *dnmStr =ISSTRING_ISSTRING([deptJson getStringForKey:@"dnm"]);
            if(!KCNSSTRING_ISEMPTY(dnmStr))
            {
                self.DeptName = dnmStr;
            }
            [self.idArray addObject:self.P_department_id];
            [self.idDict setObject:self.DeptName forKey:self.P_department_id];
        }else{
            
            if ([companyDept isKindOfClass:[KitCompanyDeptNameData class]]){
                isFirst=YES;
                self.P_department_id= companyDept.department_id;
                self.DeptName = companyDept.department_name;
                self.P_partet_id=companyDept.parent_dept;
                [self.idArray addObject:self.P_department_id];
                
                [self.idDict setObject:companyDept.department_name forKey:self.P_department_id];
                
                //层次
                
                NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:self.P_department_id,self.DeptName, nil];
                [self.deptGradeArray addObject:dic];
            }
            
        }
        [self.companyDeptList removeAllObjects];
        if([self.personDictionary hasValueForKey:self.P_department_id]){
            self.DeptPerSon =[NSString stringWithFormat:@"Person"];
            //[self.companyDeptList addObjectsFromArray:[self.personDictionary objectForKey:self.P_department_id]];
            //按order字段排序
            NSArray *array =[self.personDictionary objectForKey:self.P_department_id];
            NSArray *orderArray=   (NSArray *)[array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                if([obj1 isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *dic1 =obj1;
                    NSDictionary *dic2 =obj2;
                    if([dic1 objectForKey:@"order"] > [dic2 objectForKey:@"order"])
                    {
                        return NSOrderedDescending;
                    }
                    
                    return NSOrderedAscending;
                }else
                {
                    KitCompanyAddress *companyAddress1 = obj1;
                    KitCompanyAddress *companyAddress2 = obj2;
                    //NSOrderedDescending NSOrderedAscending
                    if(companyAddress1.order > companyAddress2.order)
                    {
                        return  NSOrderedDescending;
                    }
                    return  NSOrderedAscending;
                }
            }];
            
            [self.companyDeptList addObjectsFromArray:orderArray];

        }
        if ([self.DeptDictionary hasValueForKey:self.P_department_id]) {
            self.DeptPerSon =[NSString stringWithFormat:@"Dept"];
            [self.companyDeptList addObjectsFromArray:[self.DeptDictionary objectForKey:self.P_department_id]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_current_index object:self userInfo:nil];
        [self.tableView reloadData];
        
    }

    if (_selectedList.count >= kMAXSELECTEDCOUNT && !isSharedNum && !isShowMygroup && !isVidyo) {
        [SVProgressHUD showErrorWithStatus:@"单次邀请上限为50人" duration:1.0f];
    }else if (isVidyo && _selectedList.count >= kVIDYOMAXCOUNT-_vidyoMemeberList.count){
      [SVProgressHUD showErrorWithStatus:@"vidyo单次邀请上限为5人" duration:1.0f];
    }
}

#pragma mark HYTSelectedMediaContactsCellDelegate

-(void)selectedMediaContactsCell:(HYTSelectedMediaContactsCell*)dialingTableViewCell selected:(BOOL)selected
{
    // 选中或者未选中  _selectedList获取邀请加入的成员
    NSInteger row = dialingTableViewCell.tag;
    NSInteger section = dialingTableViewCell.section;
    NSDictionary *vidyoRoom = nil;
    KitCompanyAddress* addressBook = [[KitCompanyAddress alloc]init];
    if ([self.searchView.searchTextView.text length] != 0) {
        addressBook = [[self.searchView SearchPersonResultWithCompanyData:self.allContactData ResultJson:nil] objectAtIndex:row];
    }else{
        
        if (isPhoneShow) {//手机联系人
            KitAddressBook * address = [self.localAddressBook [self.allAddressKeys[section]] objectAtIndex:row];
         
            NSDictionary *mobileDic =address.phones;
            NSString *keyMobile=nil;
            if(mobileDic.count>0)
            {
                keyMobile=mobileDic.allKeys[0];
            }
                    addressBook.mobilenum = [mobileDic objectForKey:keyMobile];
                    addressBook.name = address.name;
                    addressBook.nameId = [mobileDic objectForKey:keyMobile];
                    addressBook.photourl = address.photourl;
                    addressBook.voipaccount = address.voipaccount;
            for (KitCompanyAddress *companyAddress in self.companyData) {
                if ([address.mobilenum isEqualToString:companyAddress.mobilenum]) {
                    addressBook = companyAddress;
                    [self.selectPersonStatusDic setValue:@"1" forKey:addressBook.nameId];
                    if (![addressBook.nameId isEqualToString:addressBook.mobilenum]) {
                        [self deptSelectStatus:addressBook.department_id isSelect:YES];
                    }
                }
            }
   
        }else if (isVidyoShow){//vidyo
            #pragma mark - zmfg vidyoRooms会议室 这个还要吗 原来在RXUser里
//         vidyoRoom = [[RXUser sharedInstance].vidyoRooms objectAtIndex:row];
        }
        else{
            if (isCompanyShow) {//企业架构
                id data = [self.companyDeptList objectAtIndex:row];
                if ([data isKindOfClass:[KitCompanyAddress class]]) {
                    addressBook = (KitCompanyAddress *)data;
                }else{
                    NSDictionary * dic = (NSDictionary *)data;
                    addressBook.name =[dic objectForKey:@"unm"];
                    addressBook.nameId = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"uid"] intValue]];
                    addressBook.pyname = [dic objectForKey:@"py"];
                    addressBook.fnmname = [dic objectForKey:@"fnm"];
                    addressBook.photourl =[dic objectForKey:@"url"];
                    addressBook.urlmd5 =[dic objectForKey:@"md5"];
                    addressBook.place = [dic objectForKey:@"up"];
                    addressBook.mobilenum = [dic objectForKey:@"mtel"];
                    addressBook.voipaccount =[dic objectForKey:@"voip"];
                    addressBook.mail = [dic objectForKey:@"mail"];
                    addressBook.department_id = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"udid"] intValue]];
                    addressBook.sex =[NSString stringWithFormat:@"%d",[[dic objectForKey:@"sex"] intValue]];
                }
            }else{//最近联系人
                addressBook = [self.recentlyContactData objectAtIndex:row];
            }
        }
        
    }
    
    if (!addressBook.nameId) {
        addressBook.nameId = addressBook.mobilenum;
    }
    if (selected) {
        if (isVidyoShow) {
            if (self.vidyoRoomSelectList.count == 1 && selectType == SelectContact_InviteMeetRoom) {
                [SVProgressHUD showWithStatus:@"只限加入一个会议室"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_current_index object:self userInfo:nil];
                return;
            }
            [self.vidyoRoomSelectList addObject:vidyoRoom];
        }
        NSString* style;
        if ([self.data isKindOfClass:[NSDictionary class]]) {
            style = [self.data objectForKey:@"style"];
        }
        if ([style isEqualToString:KTYPE_BURNCHATTING]){//阅后即焚
//            [_selectedList removeAllObjects];
            for (int i = 0 ; i < _selectedList.count; ) {
                KitCompanyAddress * book = [_selectedList objectAtIndex:i];
                if ([[[RXUser sharedInstance] mobile] isEqualToString:book.mobilenum]) {
                    i ++;
                }else {
                    if (!book.nameId) {
                        book.nameId = book.mobilenum;
                    }
                    [self.selectPersonStatusDic setValue:@"0" forKey:book.nameId];
                    if (![book.nameId isEqualToString:book.mobilenum]) {
                        [self deptSelectStatus:book.department_id isSelect:NO];
                    }
                    [_selectedList removeObject:book];
                }
            }
            
        }
        if (self.searchView.searchTextView.text || self.searchView.searchTextView.text.length > 0) {
                self.searchView.searchTextView.text = nil;
                self.searchView.placeholderLabel.hidden = NO;
        }
        [_selectedList addObject:addressBook];
        [self.selectPersonStatusDic setValue:@"1" forKey:addressBook.nameId];
        if (![addressBook.nameId isEqualToString:addressBook.mobilenum]) {
            [self deptSelectStatus:addressBook.department_id isSelect:YES];
        }
    }else{
        if (isVidyoShow) {
            for (NSDictionary * dic in self.vidyoRoomSelectList) {
                NSString * selectId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
                NSString * removeId = [NSString stringWithFormat:@"%@",[vidyoRoom objectForKey:@"id"]];
                if ([selectId isEqualToString:removeId]) {
                    [self.vidyoRoomSelectList removeObject:dic];
                    break;
                }
            }
        }else{
            for (KitCompanyAddress * addr in self.selectedList) {
                if ([addr.mobilenum isEqualToString:addressBook.mobilenum]) {
                    [self.selectedList removeObject:addr];
                    [self.selectPersonStatusDic setValue:@"0" forKey:addr.nameId];
                    if (![addressBook.nameId isEqualToString:addressBook.mobilenum]) {
                        [self deptSelectStatus:addr.department_id isSelect:NO];
                    }
                    break;
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_current_index object:self userInfo:nil];
}

- (void)didSelectPersonCell:(HYTSelectedMediaContactsCell *)dialingTableViewCell{
        NSInteger row = dialingTableViewCell.tag;
        NSInteger section = dialingTableViewCell.section;
        
        KitCompanyAddress *cpmpanyDa = [[KitCompanyAddress alloc] init];
        if ([self.searchView.searchTextView.text length] == 0) {
            if (isPhoneShow){//手机联系人
                cpmpanyDa = [self.localAddressBook[self.allAddressKeys[section]] objectAtIndex:row];
            }else{//企业联系人
                NSMutableArray * companyArr = [NSMutableArray arrayWithCapacity:0];
                if (!isCompanyShow&&!isPhoneShow) {
                    companyArr = [NSMutableArray arrayWithArray:self.recentlyContactData];
                }else{
                    companyArr = [NSMutableArray arrayWithArray:_companyDeptList];
                }
                cpmpanyDa = [companyArr objectAtIndex:row];
            }
        }else{
            // NSMutableArray * companyArr = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray * companyArr = [NSMutableArray arrayWithArray:[self.searchView SearchPersonResultWithCompanyData:self.allContactData ResultJson:nil]];
            cpmpanyDa = [companyArr objectAtIndex:row];
        }
        
        KitAddressBook *book = [[KitAddressBook alloc] init];
        NSString *departmentId =@"";
        if([cpmpanyDa isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *itemJson =[self.companyDeptList objectAtIndex:row];
            book.name = [NSString stringWithFormat:@"%@",[itemJson objectForKey:@"unm"]];
            book.nickname = [NSString stringWithFormat:@"%@",[itemJson objectForKey:@"unm"]];
            NSString *mobile = [NSString stringWithFormat:@"%@",[itemJson objectForKey:@"mtel"]];
            if (!KCNSSTRING_ISEMPTY(mobile)) {
                [book.phones setObject:mobile forKey:@"手机号"];
            }
            book.mobilenum = mobile;
            book.place =[itemJson objectForKey:@"up"];
            book.voipaccount = [itemJson objectForKey:@"voip"];
            book.signature = [itemJson objectForKey:@"sign"];
            book.urlmd5 = [itemJson objectForKey:@"md5"];
            book.photourl = [itemJson objectForKey:@"url"];
            book.sex =ISSTRING_ISSTRING([itemJson objectForKey:@"sex"]);
            departmentId =ISSTRING_ISSTRING([itemJson objectForKey:@"udid"]);
            book.place =[itemJson objectForKey:@"up"];
        }else
        {
            if ([cpmpanyDa isKindOfClass:[KitCompanyAddress class]]) {
                book.name = cpmpanyDa.name;
                book.nickname = cpmpanyDa.name;
                NSString *mobile = cpmpanyDa.mobilenum;
                if (!KCNSSTRING_ISEMPTY(mobile)) {
                    [book.phones setObject:mobile forKey:@"手机号"];
                }
                book.mobilenum = mobile;
                book.voipaccount = cpmpanyDa.voipaccount;
                book.signature = cpmpanyDa.signature;
                book.urlmd5 = cpmpanyDa.urlmd5;
                book.photourl = cpmpanyDa.photourl;
                book.sex=cpmpanyDa.sex;
                book.place=cpmpanyDa.place;
                departmentId =cpmpanyDa.department_id;
            }else{
                book = (KitAddressBook *)cpmpanyDa;
            }
            
        }
        
        isInputMeetting = YES;
    if ([RXUser sharedInstance].companyname) {
        NSString *companyName =[RXUser sharedInstance].companyname;
        [book.others setObject:companyName forKey:@" 公司名称"];
    }
        
        //部门
        KitCompanyDeptNameData *deptInfo;
        if([departmentId rangeOfString:@","].location !=NSNotFound)
        {
            NSArray *array = [self getDepartmentArray:departmentId];
            for(int i =0;i<array.count;i++)
            {
                deptInfo =[KitCompanyDeptNameData quaryCompany:[NSString stringWithFormat:@"%@",array[i]]];
                if(deptInfo)
                {
                    [book.others setObject:deptInfo.department_name forKey:[NSString stringWithFormat:@" 部门%d",i+1]];
                }
            }
        }else
        {
            deptInfo =[KitCompanyDeptNameData quaryCompany:[NSString stringWithFormat:@"%@",departmentId]];
            if(deptInfo)
            {
                [book.others setObject:deptInfo.department_name forKey:@" 部门"];
            }
        }
        
        NSString *place = [NSString stringWithFormat:@"%@",book.place];
        if (!KCNSSTRING_ISEMPTY(place)) {
            [book.others setObject:place forKey:@" 职位"];
        }
        if (isVidyo && _selectedList.count < kVIDYOMAXCOUNT- self.vidyoMemeberList.count) {
            dialingTableViewCell.selectedButton.selected = !dialingTableViewCell.selectedButton.selected;
            [self selectedMediaContactsCell:dialingTableViewCell selected:dialingTableViewCell.selectedButton.selected];
        }else if (_selectedList.count == kVIDYOMAXCOUNT - self.vidyoMemeberList.count && dialingTableViewCell.selectedButton.selected){
            dialingTableViewCell.selectedButton.selected = NO;
            [self selectedMediaContactsCell:dialingTableViewCell selected:dialingTableViewCell.selectedButton.selected];
        }else{
            if (!isVidyo) {
                 [self pushViewController:@"RXContactorInfosViewController" withData:book withNav:YES];
            }
        }
}

#pragma mark selectSectionViewDelegate
- (void)selectSectionView:(NSInteger)index Layer:(NSString *)layer{

    if (index == 0) {
        if (!isPhoneShow) {
            isPhoneShow = !isPhoneShow;
        }
    }else if(index == 1){
        if (isCompanyShow) {
            deptLevel = index;
            for (NSUInteger i = self.idArray.count - 1; i > index - 1; i --) {
                [self.idDict removeObjectForKey:self.idArray[i]];
                [self.idArray removeObjectAtIndex:i];
            }
            self.P_department_id = layer;
            [self.companyDeptList removeAllObjects];
            if (self.personDictionary[self.idArray[index-1]]) {
                [self.companyDeptList addObjectsFromArray:self.personDictionary[self.idArray[index-1]]];
                
            }
            if (self.DeptDictionary[self.idArray[index-1]]) {
                [self.companyDeptList addObjectsFromArray:self.DeptDictionary[self.idArray[index-1]]];
            }
            
        }else{
            isCompanyShow = !isCompanyShow;
            deptLevel ++;
            self.P_department_id = @"0";
            self.idArray = [[NSMutableArray alloc]init];
            [self.idArray addObject:@"0"];
            self.idDict = [[NSMutableDictionary alloc] init];
        }
    }else{
        NSNumber *mygroupNum = [NSNumber numberWithBool:isShowMygroup];
       ECMessage *message  = [self.data objectForKey:@"msg"];
        if (message) {
             [self pushViewController:@"GroupListViewController" withData:@{@"msg":message,@"isShowMyGroup":mygroupNum} withNav:YES];
        }

    }
    [self.tableView reloadData];
}

#pragma mark - 左右按钮带背景图片和文字的
-(void)setBarButtonItemWithNormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg titleText:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type
{
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    CGRect btnFrame = CGRectMake(15, 0, titleSize.width+10*fitScreenWidth, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setBackgroundImage:normalImg forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIView* frameView = [[UIView alloc] initWithFrame:btnFrame];
    [frameView addSubview:button];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameView];
    if (type == NavigationBarItemTypeLeft) {
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
    else{
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
}

#pragma mark 正则判断手机号码地址格式
- (BOOL)isMobileNumber:(NSString *)mobileNum withIsFixedNumber:(BOOL)isFixedNumber
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|7[0-9]|8[0-35-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|7[8]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[6]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
    NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-9]|\\d{3})\\d{7,8}$";
    
    NSString * PHS2 = @"^\\d{3,15}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs;
    NSPredicate *regextestphs2;
    if(isFixedNumber)
    {
        regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
        regextestphs2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS2];
    }
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestphs evaluateWithObject:mobileNum] == YES)
        || ([regextestphs2 evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
