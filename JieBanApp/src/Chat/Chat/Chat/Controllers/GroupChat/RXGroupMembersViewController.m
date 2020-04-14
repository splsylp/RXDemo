//
//  RXGroupMembersViewController.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/9/15.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXGroupMembersViewController.h"
#import "HYTSelectedMediaContactsCell.h"
//水印视图
#include "WaterBackView.h"
#import "RX_KCPinyinHelper.h"
#import "NSString+Ext.h"
#import "UISearchBar+RXAdd.h"


@interface RXGroupMembersViewController ()<UITableViewDataSource,UITableViewDelegate,HYTSelectedMediaContactsCellDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar * searchbar;
@property (nonatomic, strong) UIView *searchLinkView;
@property (nonatomic ,strong) NSMutableArray *searchArr;

@property (nonatomic, copy) NSString * groupId;
@property (nonatomic, copy) ECGroup *currentGroup;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, assign) BOOL isGroupInfo;
@property (nonatomic, assign) BOOL isAuther;//创建者
@property (nonatomic, assign) BOOL isAdmin;//是否是管理员
@property (nonatomic, strong) NSArray *headersArray;
@property (nonatomic, strong) NSArray *listDataSource;
@end

@implementation RXGroupMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = languageStringWithKey(@"群组成员列表");
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.data && [self.data isKindOfClass:[NSString class]]) {
        self.groupId = self.data;
        _style = RXGroupMembersStyleSetAdmin;
    } else if (self.data && [self.data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *groupDic =self.data;
        _currentGroup = [groupDic objectForKey:@"HXGroupId"];
        self.groupId =_currentGroup.groupId;
        _isAuther = [self.currentGroup.owner isEqualToString:[[Chat sharedInstance] getAccount]];
        if ([[groupDic objectForKey:@"HXSelectGroupManager"] isEqualToString:@"1"]) {
            _style = RXGroupMembersStyleSetAdmin;
        }
        else if ([[groupDic objectForKey:@"HXSTransferGroup"] isEqualToString:@"1"]) {
            _style = RXGroupMembersStyleSetOwner;
        }
        else if ([[groupDic objectForKey:@"HXShowMemberInfo"] isEqualToString:@"1"]) {
            _style = RXGroupMembersStyleShowMemberInfo;
        }
        else{
            _style = RXGroupMembersStyleNone;
            _isGroupInfo = YES;
        }
        if (self.currentGroup.isDiscuss) {
            self.title = languageStringWithKey(@"讨论组成员列表");
        } else{
            self.title = languageStringWithKey(@"群组成员列表");
        }
    }
    self.edgesForExtendedLayout =  UIRectEdgeNone;
    
    if (_style == RXGroupMembersStyleSetAdmin) {
        [self setBarItemTitle:languageStringWithKey(@"完成") titleColor:APPMainUIColorHexString target:self action:@selector(setGroupAdmins) type:NavigationBarItemTypeRight];
    }
    
    if(_isAuther || self.currentGroup.isDiscuss) { //讨论组 和群主可以添加成员
        if (_style != RXGroupMembersStyleSetOwner && _style != RXGroupMembersStyleSetAdmin) {
            //创建邀请的按钮
            [self setBarItemTitle:languageStringWithKey(@"添加") titleColor:APPMainUIColorHexString target:self action:@selector(addGroupMember) type:NavigationBarItemTypeRight];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMemberList) name:kNotification_memberChange_Group object:nil];
        }
    }
    self.searchArr = [NSMutableArray array];
    
    [self setupSearchBar];
    
    [self setupUI];
    
    [self getMemberList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchbar resignFirstResponder];
}

#pragma mark 创建searchVC
- (void)setupSearchBar{
    
    _searchLinkView = [[UIView alloc] init];
    _searchLinkView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    _searchLinkView.frame = CGRectMake(0, 0, kScreenWidth, 56);
    [self.view addSubview:_searchLinkView];
    
    // 创建searchBar
    self.searchbar=[[UISearchBar alloc]init];
    self.searchbar.delegate = self;
    self.searchbar.frame=CGRectMake(0, 9.0f, kScreenWidth, 36);
    [self.searchLinkView addSubview:self.searchbar];
    self.searchbar.placeholder = languageStringWithKey(@"搜索");
    self.searchbar.searchBarStyle = UISearchBarStyleMinimal;

    UITextField *txfSearchField = [self.searchbar rx_getSearchTextFiled];
    txfSearchField.borderStyle = UITextBorderStyleNone;
    txfSearchField.layer.cornerRadius = 4;
    txfSearchField.clipsToBounds = YES;
    txfSearchField.font = SystemFontLarge;
    txfSearchField.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 56 - 0.5, kScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    [_searchLinkView addSubview:lineView];

}

- (void)setupUI {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = CGRectMake(0.0f, 56.0f, kScreenWidth,kScreenHeight-kTotalBarHeight-56);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_style == RXGroupMembersStyleSetAdmin) {
        self.tableView.allowsMultipleSelection = YES;
    }
    else {
        self.tableView.allowsMultipleSelection = NO;
    }
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"666666"];
    
    [self.view addSubview:self.tableView];
    if (iOS11) {
        // 这里代码针对ios11之后，tableveiw 刷新时候，闪动，跳动的问题
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    UIView *waterView = [self getWatermarkViewWithFrame:CGRectMake(0.0, 0.0 , kScreenWidth, kScreenHeight) mobile:[[Chat sharedInstance] getStaffNo] name:[[Chat sharedInstance] getUserName] backColor:[UIColor whiteColor]];
    [self.view addSubview:waterView];
    [self.view sendSubviewToBack:waterView];
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark -UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length > 0) {
        [self searchMembersWith:searchBar.text members:_memberArr];
    }else{
        [self cancelButtonClickEvent];
    }
}

- (void)setupCancelButton{
    UIButton *cancelButton = [self.searchbar valueForKey:@"_cancelButton"];
    [cancelButton setTitleColor:ThemeColor forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClickEvent) forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeSearchBarCancelBtnTitleColor:(UIView *)view{
    if (view) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *getBtn = (UIButton *)view;
            [getBtn setEnabled:YES];//设置可用
            [getBtn setUserInteractionEnabled:YES];
            return;
        }else{
            for (UIView *subView in view.subviews) {
                [self changeSearchBarCancelBtnTitleColor:subView];
            }
        }
    } else{
        return;
    }
}

- (void)cancelButtonClickEvent{
    [self.searchbar endEditing:YES];
    self.searchbar.placeholder = languageStringWithKey(@"搜索");
    [self.searchbar setImage:ThemeImage(@"search") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self getMemberList];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchbar isFirstResponder]) {
        [self.searchbar resignFirstResponder];
        [self changeSearchBarCancelBtnTitleColor:self.searchbar];
    }
}

- (void)searchMembersWith:(NSString *)text members:(NSArray *)memebers{
    if (memebers && memebers.count > 0) {
        NSMutableArray *addressSearchData = [NSMutableArray array];
        if([NSString isIncludeChineseInString:text]){
            for (int i = 0; i < memebers.count; i++) {
                KitGroupMemberInfoData *dataInfo = memebers[i];
                NSRange nameResult = [!(KCNSSTRING_ISEMPTY(dataInfo.userName))?dataInfo.userName:dataInfo.memberName rangeOfString:text options:NSCaseInsensitiveSearch];
                if(nameResult.length > 0){
                    [addressSearchData addObject:dataInfo];
                }
            }
        }else{
            for (int i = 0; i < memebers.count; i++) {
                KitGroupMemberInfoData *data = memebers[i];
                NSRange letterResult = NSMakeRange(-1, 0);
                NSString *fnmname = !KCNSSTRING_ISEMPTY(data.fnm)?data.fnm: [RX_KCPinyinHelper quickConvert:!(KCNSSTRING_ISEMPTY(data.userName))?data.userName:data.memberName];
                NSString *pyname =!KCNSSTRING_ISEMPTY(data.pyname)?data.pyname: [RX_KCPinyinHelper pinyinFromChiniseString:!(KCNSSTRING_ISEMPTY(data.userName))?data.userName:data.memberName];
                NSString *mobilenum = data.mobile;
                if([Common isAccordWithSearchConditionName:!(KCNSSTRING_ISEMPTY(data.userName))?data.userName:data.memberName withkeyWords:text withFirstLetter:fnmname]){
                    letterResult = [pyname rangeOfString:text options:NSCaseInsensitiveSearch];
                }
                NSRange pyResult = [fnmname rangeOfString:text options:NSCaseInsensitiveSearch];
                NSRange mobileResult = [mobilenum?:@"" rangeOfString:text options:NSCaseInsensitiveSearch];
                if (ISLEVELMODE && data.level <= [[[Common sharedInstance] getUserLevel] intValue] - 2) {//大于2级不能搜出来
                    mobileResult.length = 0;
                }

                NSRange nameResult = [!(KCNSSTRING_ISEMPTY(data.userName))?data.userName:data.memberName rangeOfString:text options:NSCaseInsensitiveSearch];

                if (letterResult.length > 0 || mobileResult.length > 0 || pyResult.length > 0 || nameResult.length > 0){
                    [addressSearchData addObject:data];
                }
            }
        }
        self.listDataSource = [self sortListDataSource:addressSearchData.copy];
        [self.tableView reloadData];
    } else{
        [self getMemberList];
    }
}

- (void)getMemberList {
    NSArray * members = [KitGroupMemberInfoData getGroupMembers:self.groupId];
    if (members.count > 0) {
        self.memberArr = members;
        self.listDataSource = [self sortListDataSource:members];
        [self.tableView reloadData];
    } else{
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
            [weakSelf closeProgress];
            if (error.errorCode == ECErrorType_NoError && members.count>0) {
                [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
                self.memberArr = members;
                self.listDataSource = [self sortListDataSource:members];
                [self.tableView reloadData];
            }
        }];
    }
}

- (NSArray *)sortListDataSource:(NSArray *)members {
    NSMutableArray *mManagersArr = @[].mutableCopy;
    NSMutableArray *mMembersArr = @[].mutableCopy;
    
    for (KitGroupMemberInfoData * data in members) {
        if (data) {
            if ([data.role isEqualToString:@"2"] && [data.memberId isEqualToString:Common.sharedInstance.getAccount]) {
                self.isAdmin = YES;
            }
            if([data.role isEqualToString:@"1"] && _style != RXGroupMembersStyleSetOwner) {
                [mManagersArr insertObject:data atIndex:0];
            }
            else if([data.role isEqualToString:@"2"]) {
                [mManagersArr addObject:data];
            }
            else {
                [mMembersArr addObject:data];
            }
        }
    }
    
    [mMembersArr sortUsingComparator:^NSComparisonResult(KitGroupMemberInfoData*  _Nonnull obj1, KitGroupMemberInfoData*  _Nonnull obj2) {
        NSString *str1 = [self transformWithString:obj1.userName];
        NSString *str2 = [self transformWithString:obj2.userName];
        return [str1 compare:str2];
    }];
    
    NSMutableArray *mDataSource = @[].mutableCopy;
    NSMutableArray *mHeaders = @[].mutableCopy;
    
    if (mManagersArr.count > 0 && _style != RXGroupMembersStyleSetAdmin) {
        [mDataSource addObject:@{[NSString stringWithFormat:@"%@、%@",languageStringWithKey(@"群主"),languageStringWithKey(@"管理员")]:mManagersArr}];
        [mHeaders addObject:UITableViewIndexSearch];
    }
    
    for (int i = 0; i < mMembersArr.count; i++) {
        NSMutableDictionary *mDic = @{}.mutableCopy;
        KitGroupMemberInfoData *data1 = mMembersArr[i];
        NSString *str1 = [self sortWithString:data1.userName];
        NSMutableArray *mTempArr = @[].mutableCopy;
        [mTempArr addObject:data1];
        for (int j = i + 1; j < mMembersArr.count; j++) {
            KitGroupMemberInfoData *data2 = mMembersArr[j];
            NSString *str2 = [self sortWithString:data2.userName];
            if ([str1 isEqualToString:str2]) {
                [mTempArr addObject:data2];
                i = j;
            }
            else {
                break;
            }
        }
        
        [mDic setObject:mTempArr forKey:str1];
        [mHeaders addObject:str1];
        [mDataSource addObject:mDic];

    }
    self.headersArray = mHeaders.copy;
    return mDataSource.copy;
}

- (NSString *)transformWithString:(NSString *)string {
    if (!string) {
        return @"";
    }
    NSMutableString *ms = [[NSMutableString alloc] initWithString:string];
    CFStringTransform((__bridge CFMutableStringRef)ms, NULL, kCFStringTransformMandarinLatin, NO);
    NSString *bigStr = [ms uppercaseString];
    NSString *cha = [bigStr substringToIndex:1];
    return cha;
}

- (NSString *)sortWithString:(NSString *)string{
    if (!string) return @"";
    NSMutableString *ms = [[NSMutableString alloc] initWithString:string];
    CFStringTransform((__bridge CFMutableStringRef)ms, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)ms, NULL, kCFStringTransformStripCombiningMarks, NO);
    NSString *bigStr = [ms uppercaseString];
    NSString *cha = [bigStr substringToIndex:1];
    return cha;
}

//设置管理员
- (void)setGroupAdmins {
    NSMutableArray *memberIds = @[].mutableCopy;
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        KitGroupMemberInfoData * dataInfo = nil;
        NSDictionary *dic = self.listDataSource[indexPath.section];
        NSString *key = dic.allKeys.firstObject;
        dataInfo = dic[key][indexPath.row];
        if (dataInfo.memberId) {
            [memberIds addObject:dataInfo.memberId];
        }
    }
    [[ECDevice sharedInstance].messageManager setGroupMembersRole:_groupId members:memberIds role:ECMemberRole_Admin completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if (error.errorCode != ECErrorType_NoError) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"添加失败")];
        } else {
            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"添加成功")];
            [KitGroupMemberInfoData updateRoleStateWithMemberIds:memberIds andRole:@"2"];
            [self popViewController];
        }
    }];
}

#pragma mark - 通知
- (void)updateMemberList {
    [self getMemberList];
    [KitGlobalClass sharedInstance].isNeedUpdate = YES;
}

- (void)addGroupMember {
    if(self.currentGroup) {
        NSMutableArray *members = [[NSMutableArray alloc]init];
        NSArray *allMember =[KitGroupMemberInfoData getAllmemberInfoWithGroupId:self.groupId];
        for (KitGroupMemberInfoData *groupMember in allMember) {
            [members addObject:groupMember.memberId];
        }
        NSDictionary *exceptData = @{@"members":members,@"group_info":self.currentGroup.groupId};
        UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:exceptData WithType:SelectObjectType_GroupChatSelectMember];
        [self pushViewController:groupVC];
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.headersArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = self.listDataSource[section];
    NSString *key = dic.allKeys.firstObject;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.text = [NSString stringWithFormat:@"   %@", key];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    label.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = self.listDataSource[section];
    NSString *key = dic.allKeys.firstObject;
    return [dic[key] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KitGroupMemberInfoData * infoData = nil;
    NSDictionary *dic = self.listDataSource[indexPath.section];
    NSString *key = dic.allKeys.firstObject;
    infoData = dic[key][indexPath.row];

    if(_isGroupInfo) {
        UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:infoData.memberId];
        [self pushViewController:contactorInfosVC];
    }
    else if (_style == RXGroupMembersStyleSetAdmin){
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"RXGroupMembersViewDidSelectGroupManagerNotif" object:infoData];
//        [self popViewController];
    }
    else if (_style == RXGroupMembersStyleSetOwner){
        if ([infoData.role isEqualToString:@"1"]) {
            return;
        }
        
        RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
        [dialog showTitle:languageStringWithKey(@"转让群") subTitle:[NSString stringWithFormat:@"%@%@",infoData.memberName,languageStringWithKey(@"将成为该群群主，确定后你将立即失去群主身份")] ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
            if (index == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RXGroupMembersViewDidSelectGroupOwnerNotif" object:infoData];
                [self popViewController];
            }
        }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectContactInfo" object:self userInfo:@{@"memberId":infoData.memberId}];
        [self popViewController];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RXGroupMemberCell *cell = [[RXGroupMemberCell alloc] initWithInTableView:tableView withStyle:_style atIndexPath:indexPath];
    KitGroupMemberInfoData * dataInfo = nil;
    NSDictionary *dic = self.listDataSource[indexPath.section];
    NSString *key = dic.allKeys.firstObject;
    dataInfo = dic[key][indexPath.row];
    cell.mebmerInfo = dataInfo;
    return cell;
}

#pragma mark 编辑按钮
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(iOS8 && indexPath.section!=0 &&  (_isAuther || _isAdmin)) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if(iOS8 && indexPath.section!=0 && (_isAuther || _isAdmin)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

//侧滑删除置顶功能
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:languageStringWithKey(@"删除") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self deleteCell:indexPath];
    }];
    return @[deleteRowAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle==UITableViewCellEditingStyleDelete && !iOS8 && (_isAuther || _isAdmin)) {
        [self deleteCell:indexPath];
    }
}

- (void)deleteCell:(NSIndexPath *)indexPath{
    [SVProgressHUD showWithStatus:languageStringWithKey(@"移出成员中")];
    __weak typeof (self)weak_self =self;
    NSDictionary *dic = self.listDataSource[indexPath.section];
    NSString *key = dic.allKeys.firstObject;
    KitGroupMemberInfoData *currentData = dic[key][indexPath.row];
    
    [[ECDevice sharedInstance].messageManager deleteGroupMember:self.groupId member:currentData.memberId completion:^(ECError *error, NSString *groupId, NSString *member) {
        
        [SVProgressHUD dismiss];
        if (error.errorCode == ECErrorType_NoError) {
            //数据库清空成员信息
            [KitGroupMemberInfoData deleteGroupMemberPhoneInfoDataDB:member withGroupId:weak_self.groupId];

            NSMutableArray *mArr = ((NSArray *)(dic[key])).mutableCopy;
            [mArr removeObject:currentData];
            self.listDataSource[indexPath.section][key] = mArr.copy;
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"移出成功")];
            [KitGlobalClass sharedInstance].isNeedUpdate =YES;
            
        }else{
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"移出失败")];
        }
    }];
}

//长按删除
- (void)cellLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        
        [self deleteCell:indexPath];
    }
}


@end
