//
//  RXGroupAdminsViewController.m
//  Chat
//
//  Created by apple on 2019/11/19.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXGroupAdminsViewController.h"
#import "RXGroupMembersViewController.h"
#import "RXGroupMemberCell.h"

@interface RXGroupAdminsViewController () <UITableViewDelegate, UITableViewDataSource, GroupMemberCellDelegate>

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation RXGroupAdminsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = languageStringWithKey(@"管理员");
    
    if (self.data && [self.data isKindOfClass:[NSString class]]) {
        self.groupId = self.data;
    } else if (self.data && [self.data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *groupDic = self.data;
        ECGroup *currentGroup = [groupDic objectForKey:@"HXGroupId"];
        self.groupId = currentGroup.groupId;
    }
    
    [self setupUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupData];
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _mainTableView = [[UITableView alloc] init];
    _mainTableView.frame = self.view.bounds;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.backgroundColor = [UIColor colorWithHex:0xF4F4F4];
    _mainTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_mainTableView];
    
    UIView *addAdmView = [UIView new];
    addAdmView.backgroundColor = [UIColor whiteColor];
    addAdmView.frame = CGRectMake(0, 0, kScreenWidth, 44);
    addAdmView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addAdmViewPressed)];
    [addAdmView addGestureRecognizer:tapGesture];
    UIImageView *addImg = [[UIImageView alloc] initWithImage:KKThemeImage(@"add_member")];
    addImg.frame = CGRectMake(16, 11, 22, 22);
    [addAdmView addSubview:addImg];
    
    UILabel *addLbl = [UILabel new];
    addLbl.text = languageStringWithKey(@"添加管理员");
    addLbl.frame = CGRectMake(50, 11, 100, 22);
    [addAdmView addSubview:addLbl];
    _mainTableView.tableFooterView = addAdmView;
}

- (void)setupData {
    [self getMemberList];
}

- (void)getMemberList {
    NSArray * members = [KitGroupMemberInfoData getGroupMembers:self.groupId];
    if (members.count > 0) {
        self.dataSource = [self filterDatas:members];
        [self.mainTableView reloadData];
    } else{
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
            [weakSelf closeProgress];
            if (error.errorCode == ECErrorType_NoError && members.count>0) {
                [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
                [self getMemberList];
            }
        }];
    }
}

- (NSArray *)filterDatas:(NSArray *)members {
    NSMutableArray *mManagersArr = @[].mutableCopy;
    for (KitGroupMemberInfoData * data in members) {
        if (data) {
            if([data.role isEqualToString:@"2"]) {
                [mManagersArr addObject:data];
            }
        }
    }
    return mManagersArr.copy;
}

- (void)addAdmViewPressed {
    RXGroupMembersViewController *GroupMembersVC = [[RXGroupMembersViewController alloc] init];
    GroupMembersVC.data = _groupId;
    [self.navigationController pushViewController:GroupMembersVC animated:YES];
}

//MARK: - TB DELEGATE

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [UIView new];
    v.backgroundColor = [UIColor colorWithHex:0xF4F4F4];
    UILabel *secLabel = [UILabel new];
    secLabel.frame = CGRectMake(16, 0, 300, 40);
    secLabel.font = [UIFont systemFontOfSize:12];
    secLabel.textColor = [UIColor colorWithHex:0x999999];
    secLabel.text = languageStringWithKey(@"管理员");
    [v addSubview:secLabel];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RXGroupMemberCell *cell = [[RXGroupMemberCell alloc] initWithInTableView:tableView withStyle:RXGroupMembersStyleDeleteAdmin atIndexPath:indexPath];
    cell.gmDelegate = self;
    if (self.dataSource.count > 0) {
        KitGroupMemberInfoData * dataInfo = self.dataSource[indexPath.row];
        cell.mebmerInfo = dataInfo;
    }
    return cell;
}


//MARK : - CELL DELEGATE
- (void)deleteAdminAtIndexPath:(NSIndexPath *)indexPath {
    KitGroupMemberInfoData * dataInfo = self.dataSource[indexPath.row];
    [[ECDevice sharedInstance].messageManager setGroupMemberRole:_groupId member:dataInfo.memberId role:ECMemberRole_Member completion:^(ECError *error, NSString *groupId, NSString *memberId) {
        if (error.errorCode == ECErrorType_NoError) {
            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"已移除")];
        }
        else {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"移除失败")];
        }
        [KitGroupMemberInfoData updateRoleStateaMemberId:dataInfo.memberId andRole:@"3"];
        [self getMemberList];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
