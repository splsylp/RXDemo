//
//  RXGroupMembersViewController.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/9/15.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "HYTAtGroupMemberViewController.h"
#import "HYTSelectedMediaContactsCell.h"
#import "UIView+WaitingView.h"
#import "ChatSearchView.h"
#import "RXAtTableViewCell.h"
#import "NSString+Ext.h"
#import "UISearchBar+RXAdd.h"

@interface HYTAtGroupMemberViewController ()<UITableViewDataSource,UITableViewDelegate,HYTSelectedMediaContactsCellDelegate,UISearchBarDelegate>
{
    UIButton *_rightItem;
}
@property(nonatomic, strong) NSMutableArray * memberArr;
@property(nonatomic, strong) NSString * groupId;
@property(nonatomic, strong)ECGroup *currentGroup;
@property(nonatomic, strong) UITableView * tableView;

@property(nonatomic, strong) UISearchBar * searchbar;
@property (nonatomic, strong) UIView *searchLinkView;
@property (nonatomic, strong) NSArray *searchArray;


@property (nonatomic, strong) NSMutableArray *selectArray;
//记录是否已经选好@的人
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation HYTAtGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = languageStringWithKey(@"选择提醒的人");
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.data && [self.data isKindOfClass:[NSString class]]) {
        self.groupId = self.data;
    }
    self.memberArr = [NSMutableArray arrayWithCapacity:0];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
//    _rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
//    _rightItem.frame = CGRectMake(0, 0, 40, 40);
//    [_rightItem setTitle:@"确定" forState:UIControlStateNormal];
////    [_rightItem setTitleColor:[UIColor colorWithRGB:0x45cd87] forState:UIControlStateNormal];
//    [_rightItem setTitleColor:ThemeColor forState:UIControlStateNormal];
//    [_rightItem addTarget:self  action:@selector(rightItemAction:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightItem];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ThemeImage(@"title_bar_back") style:UIBarButtonItemStylePlain target:self action:@selector(willPopViewController)];
    
    
    [self setupSearchBar];
    
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = CGRectMake(0.0f, 44.0f, kScreenWidth,kScreenHeight-kTotalBarHeight-44);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    if (iOS11) {
        // 这里代码针对ios11之后，tableveiw 刷新时候，闪动，跳动的问题
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    [self getMemberList];
    
    UIView *waterView = [self getWatermarkViewWithFrame:CGRectMake(0.0, 0.0 , kScreenWidth, kScreenHeight) mobile:[[Chat sharedInstance] getStaffNo] name:[[Chat sharedInstance] getUserName] backColor:[UIColor whiteColor]];
    [self.view addSubview:waterView];
    [self.view sendSubviewToBack:waterView];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GroupMemberNickNameList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //是否选好人 默认为NO
    self.isSelected = NO;
}

#pragma mark 创建searchVC
- (void)setupSearchBar{
    
    _searchLinkView = [[UIView alloc] init];
    _searchLinkView.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    _searchLinkView.frame = CGRectMake(0, 0, kScreenWidth, 44);
    [self.view addSubview:_searchLinkView];
    
    // 创建searchBar
    self.searchbar=[[UISearchBar alloc]init];
    self.searchbar.delegate = self;
    self.searchbar.frame=CGRectMake(0, 0.0f, kScreenWidth, 44);
    [self.searchLinkView addSubview:self.searchbar];
    self.searchbar.placeholder = languageStringWithKey(@"搜索");
    self.searchbar.searchBarStyle = UISearchBarStyleMinimal;
    UITextField *txfSearchField = [self.searchbar rx_getSearchTextFiled];
    txfSearchField.borderStyle = UITextBorderStyleNone;
    txfSearchField.layer.cornerRadius = 3;
    txfSearchField.clipsToBounds = YES;
    txfSearchField.font = SystemFontLarge;
    txfSearchField.backgroundColor = [UIColor whiteColor];
    
    
}

#pragma mark -UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableView addWaitingView];
    _searchArray =[self SearchPersonResultWithMemberData:self.memberArr];
    [self.tableView removeWaitingView];
    [self.tableView reloadData];
    
}



- (void)popViewController{
    if (!self.isSelected) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GroupMemberNickNameList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [super popViewController];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.tableView.visibleCells&&self.tableView.visibleCells.count>0 ) {
        for (id temp in [self.tableView.visibleCells copy]) {
            
            UITableViewCell *cell = (UITableViewCell *)temp;
            
            if(_memberArr.count>cell.tag)
            {
                KitGroupMemberInfoData * dataInfo =_memberArr[cell.tag];
                #pragma mark zmfg 记录刷新的用户 这个好像没用上
                if(dataInfo /*&& [dataInfo.memberId isEqualToString:[Common sharedInstance].updateMobile]*/)
                {
                    
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:cell.tag inSection:0];
                   
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    break;
                }
            }
        }
    }
    
}

- (void)getMemberList {
    NSInteger groupCount =[KitGroupMemberInfoData getAllMemberCountGroupId:self.groupId];
    if (groupCount > 0) {
        self.memberArr=nil;
        self.memberArr = [NSMutableArray arrayWithCapacity:0];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //获取成员的时间
            DDLogInfo(@"正在加载成员的的时间......");
            NSArray * members = [KitGroupMemberInfoData getAllmemberInfoWithGroupId:self.groupId];
            
            DDLogInfo(@"获取成员的成功后的时间......");
            
            for (KitGroupMemberInfoData * data in members) {
                if (data) {
                    if ([data.memberId isEqualToString:[[Chat sharedInstance] getAccount]]) {
            
                    }
                    else{
                    
                        [self.memberArr addObject:data];
                    }
                }
            }
            DDLogInfo(@"遍历成功后的时间.....");
            //所有人
            [self insertAllGroupMemberItem];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
        
        
    }else{
        
        [self showProgressWithMsg:languageStringWithKey(@"正在获取成员列表...")];
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
            
            if (error.errorCode == ECErrorType_NoError && members.count>0) {
                
                [weakSelf showProgressWithMsg:languageStringWithKey(@"获取成功")];
                
                [members sortedArrayUsingComparator:
                 ^(ECGroupMember *obj1, ECGroupMember* obj2)
                 {
                     if(obj1.role < obj2.role) {
                         return(NSComparisonResult)NSOrderedAscending;
                     }else {
                         return(NSComparisonResult)NSOrderedDescending;
                     }
                     
                 }];
                
                [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
                
                
                if ((self.data && [self.data isKindOfClass:[NSString class]])) {
                    for (KitGroupMemberInfoData * data in members) {
                        if (data) {
                            if ([data.memberId isEqualToString:[[Chat sharedInstance] getAccount]]) {
                                
                            }
                            else{
                                [self.memberArr addObject:data];
                            }
                        }
                    }
                }else{
                    [self.memberArr addObjectsFromArray:members];
                }
                //所有人
                [self insertAllGroupMemberItem];
                
                [weakSelf.tableView reloadData];
            } else {
                [weakSelf closeProgress];
            }
        }];
    }
}
#pragma mark 所有人
-(void)insertAllGroupMemberItem{
    KitGroupMemberInfoData *infoData = [[KitGroupMemberInfoData alloc]init];
    infoData.groupId = self.groupId;
    infoData.memberId = self.groupId;
    infoData.memberName = languageStringWithKey(@"所有人");
    [self.memberArr insertObject:infoData atIndex:0];
}
#pragma MARK - 通知
-(void)updateMemberList
{
   
    [self getMemberList];
    [KitGlobalClass sharedInstance].isNeedUpdate =YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if ([self.searchbar.text length] == 0) {
        return self.memberArr.count;
    }else{
        return _searchArray.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    KitGroupMemberInfoData *infoData = [([self.searchbar.text length] == 0)?self.memberArr:self.searchArray objectAtIndex:indexPath.row];
    if ([infoData.memberId isEqualToString:[[Chat sharedInstance] getAccount]]) {
        return;
    }
    if (![infoData.memberId containsString:@"g"]) {
        NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:infoData.memberId withType:0];
        if (companyInfo && [companyInfo hasValueForKey:@"member_name"]) {
            infoData.memberName = companyInfo[@"member_name"];
        }
    }
    NSDictionary *dict = @{@"memberId":infoData.memberId,@"memberName":infoData.memberName};
    if (dict) {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"GroupMemberNickNameList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSMutableArray *personArr = [[ChatMessageManager sharedInstance].AtPersonArray mutableCopy];
        [personArr addObject:dict];
        NSSet *personSet = [NSSet setWithArray:personArr];
        [ChatMessageManager sharedInstance].AtPersonArray = [personSet.allObjects mutableCopy];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GroupMemberNickNameList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //是否选好人 点击确定后为YES
    self.isSelected = YES;
    [self popViewController];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    RXAtTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"personTableViewCell"];
    if (cell == nil) {
        cell = [[RXAtTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personTableViewCell"];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    cell.userHeadImg.hidden = NO;
    cell.userHeadImg.image = nil;
    cell.groupHeadView.hidden = YES;
    
    KitGroupMemberInfoData * dataInfo = ([self.searchbar.text length] == 0) ? [self.memberArr objectAtIndex:indexPath.row] : [self.searchArray objectAtIndex:indexPath.row];
    NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:dataInfo.memberId withType:0];
    if(companyInfo) {
        cell.userNameLable.text = companyInfo[Table_User_member_name];
        cell.userMobileLable.text = companyInfo[Table_User_mobile];
        cell.positionLab.text = companyInfo[Table_User_position_name]?[NSString stringWithFormat:@"(%@)",companyInfo[Table_User_position_name]]:@"";
        NSString *headImageUrl = companyInfo[Table_User_avatar];
        if (!KCNSSTRING_ISEMPTY(headImageUrl)) {
//             [cell.userHeadImg sd_cancelCurrentImageLoad];
            
            [cell.userHeadImg setImageWithURLString:headImageUrl urlmd5:companyInfo[Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(cell.userHeadImg.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]) withRefreshCached:NO];

        }else{
            [cell.userHeadImg sd_cancelCurrentImageLoad];
            cell.userHeadImg.image = ThemeDefaultHead(cell.userHeadImg.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]);
        }
        CGSize size = [cell.userNameLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
        cell.userNameLable.frame = CGRectMake(cell.userNameLable.originX, 5, size.width, cell.userNameLable.size.height);
        cell.positionLab.frame = CGRectMake(cell.userNameLable.originX + size.width, cell.positionLab.originY, cell.positionLab.width, cell.positionLab.height);
    }else{
        if ([dataInfo.memberId containsString:@"g"]) {//所有人
            if (isEnLocalization) {
                cell.userNameLable.font = ThemeFontMiddle;
            }else{
                cell.userNameLable.font = ThemeFontLarge;
            }
            cell.userNameLable.text = languageStringWithKey(@"所有人");
            CGSize size = [cell.userNameLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
            cell.userNameLable.frame = CGRectMake(cell.userNameLable.originX, (cell.height - cell.userNameLable.height)/2, size.width, cell.userNameLable.height);
            cell.positionLab.text = nil;
            cell.userMobileLable.text = nil;
            NSArray *groupArray =[KitGroupMemberInfoData getSequenceMembersforGroupId:dataInfo.groupId memberCount:9];
            if (groupArray.count <= 0) {
                cell.userHeadImg.image = ThemeImage(@"icon_groupdefaultavatar");
            }else{
                cell.userHeadImg.hidden = YES;
                cell.groupHeadView.hidden = NO;
                [cell.groupHeadView createHeaderViewH:cell.groupHeadView.width withImageWH:cell.groupHeadView.width groupId:dataInfo.groupId withMemberArray:groupArray];
            }
        }else{
            cell.userNameLable.text = KCNSSTRING_ISEMPTY(dataInfo.memberName)?dataInfo.memberId:dataInfo.memberName;
            cell.userMobileLable.text = companyInfo[Table_User_mobile];
            cell.positionLab.text = @"";
            if (!KCNSSTRING_ISEMPTY(dataInfo.headUrl) && !KCNSSTRING_ISEMPTY(dataInfo.headMd5)) {
                // [picImage cancelCurrentImageLoad];
#if isHeadRequestUserMd5
                [cell.userHeadImg setImageWithURLString:dataInfo.headUrl urlmd5:dataInfo.headMd5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(cell.userHeadImg.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]) withRefreshCached:NO];
#else
                [cell.userHeadImg sd_setImageWithURL:[NSURL URLWithString:dataInfo.headUrl] placeholderImage:ThemeDefaultHead(cell.userHeadImg.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
#endif
            }else{
                [cell.userHeadImg sd_cancelCurrentImageLoad];
                cell.userHeadImg.image = ThemeDefaultHead(cell.userHeadImg.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]);
            }
            
            CGSize size = [cell.userNameLable.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
            cell.userNameLable.frame = CGRectMake(cell.userNameLable.originX, 5, size.width, cell.userNameLable.size.height);
            cell.positionLab.frame = CGRectMake(cell.userNameLable.originX + size.width, cell.positionLab.originY, cell.positionLab.width, cell.positionLab.height);
        }
    }
    
    if ([_selectArray containsObject:dataInfo.memberId]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.searchbar resignFirstResponder];
}


//返回搜索联系人的item
- (NSArray *)SearchPersonResultWithMemberData:(NSArray *)memberData {
    
    if(self.searchbar.text.length==0)
    {
        return memberData;
    }else
    {
        NSMutableArray * addressSearchData =[[NSMutableArray alloc] init];
        NSArray *memberDataCopy = [NSArray arrayWithArray:memberData];
        
        if([NSString isIncludeChineseInString:self.searchbar.text])
        {
            for(KitGroupMemberInfoData * data in memberDataCopy)
            {
                NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:data.memberId withType:0];
                if(companyInfo)
                {
                    NSRange nameResult=[companyInfo[Table_User_member_name] rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
                    if(nameResult.length>0)
                    {
                        [addressSearchData addObject:data];
                    }
                }else{
                    
                    if (KCNSSTRING_ISEMPTY(data.memberName)) {
                        if (!KCNSSTRING_ISEMPTY(data.memberId)) {
                            NSRange nameResult=[data.memberId rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
                            if(nameResult.length>0)
                            {
                                [addressSearchData addObject:data];
                            }
                        }
                    }else{
                        NSRange nameResult=[data.memberName rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
                        if(nameResult.length>0)
                        {
                            [addressSearchData addObject:data];
                        }
                    }
                }
                
            }
            
        }else
        {
            for(KitGroupMemberInfoData * data in memberDataCopy)
            {
                //企业通讯录
                NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:data.memberId withType:0];
                NSRange letterResult =NSMakeRange(-1, 0);
                if([Common isAccordWithSearchConditionName:companyInfo[Table_User_member_name] withkeyWords:self.searchbar.text withFirstLetter:companyInfo[Table_User_name_initial]])
                {
                    letterResult=[companyInfo[Table_User_name_initial] rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
                }
                
                NSRange pyResult=[companyInfo[Table_User_name_initial] rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];;
                
                NSRange mobileResult=[companyInfo[Table_User_mobile] rangeOfString:self.searchbar.text ];
                NSRange nameResult;
                if(companyInfo)
                {
                    nameResult=[companyInfo[Table_User_member_name] rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
                }else{
                    
                    if (KCNSSTRING_ISEMPTY(data.memberName)) {
                        if (!KCNSSTRING_ISEMPTY(data.memberId)) {
                            nameResult=[data.memberId rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
                         
                        }
                    }else{
                            nameResult=[data.memberName rangeOfString:self.searchbar.text options:NSCaseInsensitiveSearch];
                      
                    }
                }
                
                
                if(letterResult.length>0 || mobileResult.length>0 || pyResult.length>0 || nameResult.length>0)
                {
                    [addressSearchData addObject:data];
                    
                }
            }
        }
        return addressSearchData;
    }
    
}


@end
