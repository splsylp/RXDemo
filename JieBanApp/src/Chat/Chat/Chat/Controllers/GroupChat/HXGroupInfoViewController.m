//
//  HXGroupInfoViewController.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXGroupInfoViewController.h"
#import "GroupAddCollectionViewCell.h"
#import "GroupDeleCollectionViewCell.h"
#import "GroupMemberCollectionViewCell.h"
#import "RXMyFriendList.h"
#import "HXCommonTableViewCell.h"

#define kShowIconSize ((iPhone5) ? 4 : 5)
#define kMaxNameLength 16

static NSString *identfAddCell = @"groupAddMemberCell";
static NSString *identfDeleteCell = @"groupDeleteMemberCell";
static NSString *identfMemberCell = @"groupMemberCell";

@interface HXGroupInfoViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, GroupAddCollectionViewCellDelegate, GroupDeleCollectionViewCellDelegate, GroupMemberCollectionViewCellDelegate> {
    RXChatFilesViewController *testvc;
}
@property(nonatomic, assign) BOOL isDelStatus;//是否是删除状态
@property(nonatomic, copy) NSString *groupId;
@property(nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, assign) BOOL isOwner;//是否是创建者
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, retain) ECGroup *curGroup;//当前群组
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIButton *deleteGroupBtn;
@property(nonatomic, assign) NSUInteger requestCount;
@property(nonatomic, assign) BOOL isLoadNickName;//刷新群昵称
@property(retain, nonatomic) IBOutlet UILabel *groupNameL;
@property(retain, nonatomic) IBOutlet UILabel *groupSizeL;
@property(retain, nonatomic) IBOutlet UILabel *groupTopL;
@property(retain, nonatomic) IBOutlet UILabel *groupNoticeL;
@property(retain, nonatomic) IBOutlet UILabel *groupClearL;
@property(retain, nonatomic) IBOutlet UILabel *groupNL;
@property(retain, nonatomic) IBOutlet UILabel *groupMemberL;
@property(retain, nonatomic) IBOutlet UILabel *groupRecordL;
@property(retain, nonatomic) IBOutlet UILabel *groupNickL;
@property(retain, nonatomic) IBOutlet UILabel *groupShowNL;
@property(weak, nonatomic) IBOutlet UILabel *QRcode;

@property(strong, nonatomic) IBOutlet UITableViewCell *groupLookFileCell;
@property(strong, nonatomic) IBOutlet UILabel *groupLookFileLabel;

@property(nonatomic, copy) NSString *groupManagersName; // 群管理员名称
@property(nonatomic, assign) BOOL isGroupManager; // 是否是管理员
@property(nonatomic, strong) NSArray *showMembers;//给 collectionView用的，最多只展示4行
@end

@implementation HXGroupInfoViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isDelStatus = NO;
    self.isLoadNickName = YES;
    _requestCount = 0;

    self.view.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    if ([self.data isKindOfClass:[ECGroup class]]) {
        self.curGroup = self.data;
        self.groupId = self.curGroup.groupId;
    } else {
        self.groupId = self.data;
    }
    [self initWithTableViewAndCollectionView];
    
    [self setupUI];
    
    [self initGroupManagerNames];

    [self addNotifications];
//  暂时注释 感觉没什么特别的用处, 可能是为了更新头像
//    if (isLargeAddressBookModel) {
//        [self getAllGroupMemberAddressWhenBigAddress];
//    }
    //不知道有什么用
    [self setCellTag];
    
    [self setGroupOrisDiscussInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getGroupInfo];

    if ([KitGlobalClass sharedInstance].isNeedUpdate) {
        _isDelStatus = NO;
        [self queryGroupMembers];
        [KitGlobalClass sharedInstance].isNeedUpdate = NO;
    }
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectGroupManager:) name:@"RXGroupMembersViewDidSelectGroupManagerNotif" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectGroupOwner:) name:@"RXGroupMembersViewDidSelectGroupOwnerNotif" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryGroupMembers) name:KNotice_InsertGroupMemberArray object:nil];
    
    //接受自己被请出群组的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDelete:) name:KNOTIFICATION_onReceivedGroupNoticeDeleteMine object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMemberList) name:@"updateMemberList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMemberList) name:kNotification_memberChange_Group object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMemberRole:) name:@"ECGroupMessageChangeMemberRoleNotif" object:nil];
    
    //群组信息修改(名称公告)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedChageGroupInfo:) name:@"KNOTIFICATION_onReceivedGroupNoticeChageGroupInfo" object:nil];
    
    //群组人员减少
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedRemoveMemberInGroup:) name:@"kNotification_removeMember_group" object:nil];
    
}

- (void)setGroupOrisDiscussInfo {
    self.groupNameL.text = languageStringWithKey(@"群组名称");
    self.groupSizeL.text = languageStringWithKey(@"群组容量");
    self.groupTopL.text = languageStringWithKey(@"置顶聊天");
    self.groupNoticeL.text = languageStringWithKey(@"消息免打扰");
    self.groupClearL.text = languageStringWithKey(@"清空聊天记录");
    self.groupNL.text = languageStringWithKey(@"群公告");
    self.groupMemberL.text = languageStringWithKey(@"全部群成员");
    self.groupRecordL.text = languageStringWithKey(@"查看聊天记录");
    self.groupNickL.text = languageStringWithKey(@"我在本群的昵称");
    self.groupShowNL.text = languageStringWithKey(@"显示群成员昵称");
    self.QRcode.text = languageStringWithKey(@"群组二维码");

//    self.title = languageStringWithKey(@"群组信息");
    self.title = languageStringWithKey(@"聊天详情");
    

    self.ADCellLineView.backgroundColor = [UIColor colorWithHexString:@"#ededed"];
    if (self.curGroup.isDiscuss) {
        self.groupNameL.text = languageStringWithKey(@"讨论组名称");
        self.groupSizeL.text = languageStringWithKey(@"讨论组容量");
        self.groupNL.text = languageStringWithKey(@"讨论组公告");
        self.groupMemberL.text = languageStringWithKey(@"全部讨论组成员");
        self.groupNickL.text = languageStringWithKey(@"我在本讨论组的昵称");
        self.groupShowNL.text = languageStringWithKey(@"显示讨论组成员昵称");
        self.QRcode.text = languageStringWithKey(@"讨论组二维码");
        self.title = languageStringWithKey(@"讨论组信息");
    }
    if (isEnLocalization) {
        [self setThemeTextFont:ThemeFontMiddle];
    }
    else {
        [self setThemeTextFont:ThemeFontLarge];
    }
}

- (void)setThemeTextFont:(UIFont *) font {
    self.groupNameL.font = self.groupSizeL.font = self.groupTopL.font = self.groupNoticeL.font =
    self.groupClearL.font = self.groupLookFileLabel.font = self.groupNL.font = self.groupMemberL.font =
    self.groupRecordL.font = self.groupNickL.font = self.groupShowNL.font = font;
}

- (void)setCellTag {
    self.groupADCell.tag = 99088;
    self.GroupQRCodeCell.tag = 99087;
}

- (void)setupUI {
    
    self.deleteGroupBtn = (UIButton *) [self.groupDeleteCell viewWithTag:211];
    [self.deleteGroupBtn setBackgroundImage:ThemeImage(@"red_button") forState:UIControlStateNormal];
    [self.deleteGroupBtn setBackgroundImage:ThemeImage(@"red_button") forState:UIControlStateHighlighted];
    
    NSString *notice_key = [NSString stringWithFormat:@"%@_%@_notice", [[Common sharedInstance] getAccount], self.groupId];
    NSString *isNotice = [[NSUserDefaults standardUserDefaults] objectForKey:notice_key];
    if (KCNSSTRING_ISEMPTY(isNotice)) {
        [[self groupNoticeSwitch] setOn:NO];
    } else {
        [[self groupNoticeSwitch] setOn:YES];
    }
    
    [[self groupNoticeSwitch] addTarget:self action:@selector(didSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    NSString *top_key = [NSString stringWithFormat:@"%@_cur_top", self.groupId];
    NSString *top_str = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", SETUPTOP, self.groupId]];
    
    if ([top_key isEqualToString:top_str]) {
        [[self groupTopSwitch] setOn:YES];
    } else {
        [[self groupTopSwitch] setOn:NO];
    }
    [[self groupTopSwitch] addTarget:self action:@selector(didSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [[self groupNickNameSwitch] addTarget:self action:@selector(didSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)getGroupInfo {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@", kGroupInfoGroupNickName, self.groupId]]) {
        [[self groupNickNameSwitch] setOn:YES];
    } else {
        [[self groupNickNameSwitch] setOn:NO];
    }
    KitGroupInfoData *infoData = [KitGroupInfoData getGroupInfoWithGroupId:self.groupId];
    if (infoData) {
        self.curGroup = [[ECGroup alloc] init];
        self.curGroup.name = infoData.groupName;
        self.curGroup.groupId = infoData.groupId;
        self.curGroup.declared = infoData.declared;
        self.curGroup.owner = infoData.owner;
        self.curGroup.scope = infoData.scope;
        self.curGroup.createdTime = infoData.createTime;
        self.curGroup.type = infoData.type;
        self.curGroup.memberCount = infoData.memberCount;
        self.curGroup.isDiscuss = infoData.isDiscuss;
        self.curGroup.type = infoData.type;
        //[self setGroupOrisDiscussInfo];
        self.isOwner = [[[Chat sharedInstance] getAccount] isEqualToString:self.curGroup.owner] || [[[Chat sharedInstance] getMobile] isEqualToString:self.curGroup.owner];//是否是群主
        if (self.curGroup.name.length > kMaxNameLength) {
            self.curGroup.name = [self.curGroup.name substringToIndex:kMaxNameLength];
        }
        [[self groupNameLabel] setText:self.curGroup.name];
        [[self groupADLabel] setText:[self curGroup].declared ? [self curGroup].declared : @""];
        
        [self setGroupBaseInfo];
        [self queryGroupMembers];
        //刷新群组信息
        [self updateGroupDetail];
    } else {
        [self getGroupInfoFromSDK];
    }
}

- (void)updateGroupDetail {
    [[ECDevice sharedInstance].messageManager getGroupDetail:[NSString stringWithFormat:@"%@", self.groupId] completion:^(ECError *error, ECGroup *group) {
        
        if (error.errorCode == ECErrorType_NoError) {
            //入库
            KitGroupInfoData *groupData = [[KitGroupInfoData alloc] init];
            groupData.groupName = group.name;
            groupData.groupId = group.groupId;
            groupData.declared = group.declared;
            groupData.owner = group.owner;
            groupData.createTime = group.createdTime;
            groupData.type = group.type;
            groupData.memberCount = group.memberCount;
            groupData.isDiscuss = group.isDiscuss;
            groupData.scope = group.scope;
            [KitGroupInfoData insertGroupInfoData:groupData];
            //[self setGroupOrisDiscussInfo];
            self.curGroup = group;
            [self setGroupBaseInfo];

            self.title = [NSString stringWithFormat:@"%@(%ld)", languageStringWithKey(@"聊天详情"), (long) group.memberCount];
            [[self groupMemberLabel] setText:[NSString stringWithFormat:@"%@(%ld)>",languageStringWithKey(@"全部群成员"),(long) (long) group.memberCount]];
            self.isOwner = [[[Chat sharedInstance] getAccount] isEqualToString:self.curGroup.owner] || [[[Chat sharedInstance] getMobile] isEqualToString:self.curGroup.owner];//是否是群主
            if (self.curGroup.name.length > kMaxNameLength) {
                self.curGroup.name = [self.curGroup.name substringToIndex:kMaxNameLength];
            }
            [[self groupNameLabel] setText:self.curGroup.name];
            [[self groupADLabel] setText:[self curGroup].declared ? [self curGroup].declared : @""];
            [self.collectionView reloadData];
            [self.tableView reloadData];
        }
    }];
}

- (void)queryGroupMembers {

    NSInteger allMemberCount = [self getGroupMembersCount];

    int memberCount = 0;
    if (self.isOwner || self.curGroup.isDiscuss) {
        if (self.groupMembers.count == 1 ||
                (!self.isOwner && self.curGroup.isDiscuss)) {
            memberCount = kShowIconSize * 10 - 1;
        } else {
            memberCount = kShowIconSize * 10 - 2;
        }
    } else {
        memberCount = kShowIconSize * 10;
    }
    
    if (allMemberCount > 0) {
        //先判断总人数是否大于50
        self.groupMembers = nil;
        self.groupMembers = [[NSMutableArray alloc] init];

        //先获取等级为1的成员 唯一一个
        NSArray<KitGroupMemberInfoData *> *newDataArray = [KitGroupMemberInfoData getMemberInfoWithGroupId:_groupId withCount:memberCount];
        if (newDataArray.count > 0) {
            [self.groupMembers addObjectsFromArray:newDataArray];

            //处理 collectionView 展示的群成员
            NSInteger count = kShowIconSize * 4 - (self.isOwner ? 2 : 1);
            if (self.groupMembers.count > count) {
                self.showMembers = [self.groupMembers subarrayWithRange:NSMakeRange(0, count)];
            } else {
                self.showMembers = self.groupMembers;
            }

            //判断是否有创建者或者管理者
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"role == %@ || role == %@", @"1", @"2"];
            NSArray *createArray = [self.groupMembers filteredArrayUsingPredicate:predicate];
            if (createArray.count == 0) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self queryGroupMembersFromSDK];
                });
            }
            
            BOOL isAdmin = [createArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"memberId = %@", [Common sharedInstance].getAccount]].count;
            
            self.isGroupManager = isAdmin;
        }

        NSString *account = [Common sharedInstance].getAccount;
        KitGroupMemberInfoData *data = [self getGroupCardWithMemberId:account];
        if ([data.memberName isEqualToString:account] ||
                KCNSSTRING_ISEMPTY(data.memberName)) {//如果昵称和账号account相同 需要重置昵称为username
            NSString *userName = [Common sharedInstance].getUserName;
            data.memberName = userName;
            [[self groupNickNameLabel] setText:userName];
            [self modifyMemberCard:data];
        } else {
            [[self groupNickNameLabel] setText:data.memberName];
        }
        [self.collectionView reloadData];
        [self.tableView reloadData];
#warning 没有修改群昵称的推送通知，暂时每次进入刷新一次群昵称
        if (self.isLoadNickName) {
            self.isLoadNickName = NO;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self queryGroupMembersFromSDK];
            });
        }
    } else {
        [self queryGroupMembersFromSDK];
    }
}

- (void)queryGroupMembersFromSDK {
    //是否分页下载
    [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupId completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if (error.errorCode == ECErrorType_NoError && members.count > 0) {
            [members sortedArrayUsingComparator:
             ^(ECGroupMember *obj1, ECGroupMember *obj2) {
                 if (obj1.role < obj2.role) {
                     return (NSComparisonResult) NSOrderedAscending;
                 } else {
                     return (NSComparisonResult) NSOrderedDescending;
                 }
             }];
            [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
            [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
            [self queryGroupMembers];
        }
    }];
}

- (void)setGroupBaseInfo {
    self.groupADLabel.text = (!KCNSSTRING_ISEMPTY(self.curGroup.declared)) ? self.curGroup.declared : @"";
    UILabel *labelNum = (UILabel *) [self.groupSizeCell viewWithTag:101];
    labelNum.font = ThemeFontMiddle;
    NSString *accountStr = @"100";
    switch (self.curGroup.scope) {
        case 0:
        case 1:
            accountStr = @"100";
            break;
        case 2:
            accountStr = @"300";
            break;
        case 3:
            accountStr = @"500";
            break;
        case 4:
            accountStr = @"1000";
            break;
        case 5:
            accountStr = @"2000";
            break;
        default:
            break;
    }
    labelNum.text = accountStr;
}

- (void)initWithTableViewAndCollectionView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTotalBarHeight)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"HXCommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"HXCommonTableViewCell"];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }else{
            make.edges.equalTo(self.view);
        }
    }];
    
    //create CollectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //设置滑动方向 水平方向滑动
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(kScreenWidth / kShowIconSize, kScreenWidth / kShowIconSize);//单元格大小
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, flowLayout.itemSize.height * 10) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = NO;
    //groupMember
    [self.collectionView registerClass:[GroupMemberCollectionViewCell class] forCellWithReuseIdentifier:identfMemberCell];
    //加号
    [self.collectionView registerClass:[GroupAddCollectionViewCell class] forCellWithReuseIdentifier:identfAddCell];
    //删除
    [self.collectionView registerClass:[GroupDeleCollectionViewCell class] forCellWithReuseIdentifier:identfDeleteCell];
    
}

- (void)initGroupManagerNames {
    self.groupManagersName = @"";
    // 管理员
    NSLog(@"groupId = %@",self.groupId);
    NSArray *groupManagers = [KitGroupMemberInfoData getManagersWithGroupId:self.groupId withRole:@"2"];
    for (KitGroupMemberInfoData *member in groupManagers) {
        if (self.groupManagersName.length == 0) {
            self.groupManagersName = member.memberName;
        } else {
            self.groupManagersName = [self.groupManagersName stringByAppendingFormat:@"、%@", member.memberName];
        }
        if ([member.memberId isEqualToString:[[Chat sharedInstance] getAccount]] && !self.curGroup.isDiscuss) {
            self.isGroupManager = YES;
        }
    }
}

#pragma MARK - 通知

- (void)updateMemberList {
    if (self.groupMembers.count > 49) {
        [self getGroupMembersCount];
    } else {
        _isDelStatus = NO;
        [self queryGroupMembers];
    }
}

#pragma mark UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isOwner || self.curGroup.isDiscuss || self.isGroupManager) {
        if (self.showMembers.count < 1 || self.curGroup.type == 99) {
            return self.showMembers.count;
        } else {
            if (self.showMembers.count == 1 || (!self.isOwner && self.curGroup.isDiscuss)) {
                return self.showMembers.count + 1;
            }
            return self.showMembers.count + 2;
        }
    } else {
        return self.showMembers.count;
    }
}

- (NSInteger)havedMember:(NSMutableArray *)members {
    for (NSInteger i = 0; i < members.count; i++) {
        KitGroupMemberInfoData *infoData = [self.groupMembers objectAtIndex:i];
        if ([infoData.memberId isEqualToString:[Common sharedInstance].getAccount]) {
            return i;
        }
    }
    return NSNotFound;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isOwner || self.curGroup.isDiscuss || self.isGroupManager) {
        if (self.showMembers.count > 1) {//表示二个人以上
            if (indexPath.row < self.showMembers.count + 2) {
                if (indexPath.row == self.showMembers.count) {
                    GroupAddCollectionViewCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:identfAddCell forIndexPath:indexPath];
                    [addCell.addMemberBtn setBackgroundImage:ThemeImage(@"btn_add") forState:UIControlStateNormal];
                    [addCell.addMemberBtn setBackgroundImage:ThemeImage(@"btn_add") forState:UIControlStateHighlighted];
                    addCell.memberInfoLabel.text = languageStringWithKey(@"添加");
                    addCell.delegate = self;
                    return addCell;
                } else if (indexPath.row == self.showMembers.count + 1 && (self.isOwner || self.isGroupManager)) {
                    GroupDeleCollectionViewCell *deleCell = [collectionView dequeueReusableCellWithReuseIdentifier:identfDeleteCell forIndexPath:indexPath];
                    [deleCell.deleteMemberBtn setBackgroundImage:ThemeImage(@"btn_moveout") forState:UIControlStateNormal];
                    [deleCell.deleteMemberBtn setBackgroundImage:ThemeImage(@"btn_moveout") forState:UIControlStateHighlighted];
                    deleCell.deleteLabel.text = languageStringWithKey(@"移除");
                    deleCell.delegate = self;
                    return deleCell;
                } else {
                    GroupMemberCollectionViewCell *memberCell = [collectionView dequeueReusableCellWithReuseIdentifier:identfMemberCell forIndexPath:indexPath];
                    KitGroupMemberInfoData *groupMember = self.showMembers[indexPath.row];
                    [self setsShowMemberListArray:groupMember withCell:memberCell];

                    memberCell.tag = indexPath.row;
                    memberCell.delegate = self;
                    return memberCell;
                }
            }
        } else if (self.showMembers.count == 1) {
            if (indexPath.row == self.showMembers.count) {
                GroupAddCollectionViewCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:identfAddCell forIndexPath:indexPath];
                [addCell.addMemberBtn setBackgroundImage:ThemeImage(@"btn_add") forState:UIControlStateNormal];
                [addCell.addMemberBtn setBackgroundImage:ThemeImage(@"btn_add") forState:UIControlStateHighlighted];
                addCell.delegate = self;
                return addCell;
            } else {
                GroupMemberCollectionViewCell *memberCell = [collectionView dequeueReusableCellWithReuseIdentifier:identfMemberCell forIndexPath:indexPath];
                KitGroupMemberInfoData *groupMember = self.showMembers[indexPath.row];
                memberCell.tag = indexPath.row;
                [self setsShowMemberListArray:groupMember withCell:memberCell];
                memberCell.delegate = self;
                return memberCell;
            }
        }
    } else {
        GroupMemberCollectionViewCell *memberCell = [collectionView dequeueReusableCellWithReuseIdentifier:identfMemberCell forIndexPath:indexPath];
        KitGroupMemberInfoData *groupMember = self.showMembers[indexPath.row];
        [self setsShowMemberListArray:groupMember withCell:memberCell];
        memberCell.tag = indexPath.row;
        memberCell.delegate = self;
        return memberCell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //点击群组成员进入联系人详情页面
    if (indexPath.row > self.showMembers.count - 1) {
        return;
    }
    KitGroupMemberInfoData *infoData = [self.showMembers objectAtIndex:indexPath.row];
    UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:infoData.memberId];
    [self pushViewController:contactorInfosVC];
}

- (void)setsShowMemberListArray:(KitGroupMemberInfoData *)memberData withCell:(GroupMemberCollectionViewCell *)memberCell {
    [memberCell.headerIconView sd_cancelCurrentImageLoad];
    NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
    //个人 昵称
    if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@", kGroupInfoGroupNickName, self.groupId]]) {
        if (!KCNSSTRING_ISEMPTY(memberData.memberId) && [memberData.memberId isEqualToString:memberData.memberName]) {
            memberData.memberName = [[[Chat sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0] objectForKey:@"memberName"];
        }
        memberCell.nameLabel.text = !KCNSSTRING_ISEMPTY(memberData.memberName) ? memberData.memberName : (companyInfo[Table_User_member_name] ? companyInfo[Table_User_member_name] : @"无名称");
    } else {
        memberCell.nameLabel.text = companyInfo[Table_User_member_name] ? companyInfo[Table_User_member_name] : @"无名称";
    }
    NSString *heagImageUrl = companyInfo[Table_User_avatar];
    NSString *headMd5 = companyInfo[Table_User_urlmd5];
    if (!KCNSSTRING_ISEMPTY(heagImageUrl) && !KCNSSTRING_ISEMPTY(headMd5)) {
#if isHeadRequestUserMd5
        [memberCell.headerIconView setImageWithURLString:heagImageUrl urlmd5:headMd5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(memberCell.headerIconView.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]) withRefreshCached:NO];
#else
        [memberCell.headerIconView sd_setImageWithURL:[NSURL URLWithString:heagImageUrl] placeholderImage:ThemeDefaultHead(memberCell.headerIconView.size, companyInfo[Table_User_member_name], companyInfo[Table_User_account]) options:SDWebImageRefreshCached | SDWebImageRetryFailed];
#endif
    } else {
        [memberCell.headerIconView sd_cancelCurrentImageLoad];
        if (companyInfo) {
            memberCell.headerIconView.image = ThemeDefaultHead(memberCell.headerIconView.size, companyInfo[Table_User_member_name], companyInfo[Table_User_account]);
        } else {
            memberCell.headerIconView.image = ThemeDefaultHead(memberCell.headerIconView.size, memberData.memberId, memberData.memberId);
        }
    }
    NSString *account = companyInfo[Table_User_account];
    if (_isDelStatus && ![account isEqualToString:[[Chat sharedInstance] getAccount]] && ![self.curGroup.owner isEqualToString:account]) {
        if (![self.curGroup.owner isEqualToString:Common.sharedInstance.getAccount] && memberData.role.integerValue == 2) {//群管理不能互踢
            memberCell.deleteBtn.hidden = YES;
        } else {
            memberCell.deleteBtn.hidden = NO;
        }
    } else {
        memberCell.deleteBtn.hidden = YES;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark GroupMemberCollectionViewCellDelegate

- (void)onchickHeadImgMemberIndex:(NSInteger)curIndex withMemberName:(NSString *)name {
    if (_groupMembers.count > 0 && _groupMembers.count > curIndex) {
        KitGroupMemberInfoData *infoData = _groupMembers[curIndex];
        if (_isDelStatus) {
            NSString *memberId = infoData.memberId;
            
            RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
            NSString *msg = [NSString stringWithFormat:@"%@%@%@", languageStringWithKey(@"确认将"), !KCNSSTRING_ISEMPTY(name) ? name : languageStringWithKey(@"该成员"), self.curGroup.isDiscuss ? languageStringWithKey(@"移出讨论组") : languageStringWithKey(@"移出群聊")];
            __weak typeof(self) weak_self = self;
            [dialog showTitle:languageStringWithKey(@"提示") subTitle:msg ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
                if (index == 1) {
                    [[ECDevice sharedInstance].messageManager deleteGroupMember:self.curGroup.groupId member:memberId completion:^(ECError *error, NSString *groupId, NSString *member) {
                        [SVProgressHUD dismiss];
                        if (error.errorCode == ECErrorType_NoError) {

                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_memberChange_Group object:nil];
                            //数据库清空成员信息
                            [KitGroupMemberInfoData deleteGroupMemberPhoneInfoDataDB:member withGroupId:weak_self.curGroup.groupId];
                            [self.groupMembers removeObjectAtIndex:self.selectIndex];
                            [weak_self.collectionView reloadData];
                            [weak_self getGroupMembersCount];
                            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"移出成功")];
                        } else {
                            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"移出失败")];
                        }
                    }];
                }
            }];
        } else {

            if (infoData) {
                BOOL isFriend = [RXMyFriendList isMyFriend:infoData.memberId];
                if (![[AppModel sharedInstance] runModuleFunc:@"Common" :@"isHighLevelOfTwoWithAccount:" :@[infoData.memberId] hasReturn:YES] || isFriend) {
                    UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:infoData.memberId];
                    [self pushViewController:contactorInfosVC];
                }
            }
        }
    }
}

#pragma mark UITableViewDataSource  UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 7;
    } else if (section == 2) {//聊天记录
        return 2;
    } else if (section == 3) {//置顶聊天
        return 2;
    } else if (section == 4) { //本群昵称
        return 2;
    }else if (section == 5) { //清空记录
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *collctionIdentCell = @"collctionIdentCell";
            UITableViewCell *collactionCell = [tableView dequeueReusableCellWithIdentifier:collctionIdentCell];
            if (!collactionCell) {
                collactionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collctionIdentCell];
                [collactionCell.contentView addSubview:_collectionView];
            }
            for (UIView *view in collactionCell.subviews) {
                if([view isKindOfClass:[NSClassFromString(@"_UITableViewCellSeparatorView") class]] && view){
                    view.height = 0.1;
                }
            }
            return collactionCell;
        } else {
            self.memberEnterImageV.image = ThemeImage(@"enter_icon_02");
            return self.groupMemberCell;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                HXCommonTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HXCommonTableViewCell"];
                cell.textLabel.text = languageStringWithKey(@"将讨论组升级为群");
                cell.textLabel.font = ThemeFontLarge;
                cell.arrowImgView.image = ThemeImage(@"enter_icon_02");
                cell.userInteractionEnabled = YES;
                if (!self.curGroup.isDiscuss) {
                    cell.hidden = YES;
                }
                return cell;
            }
                break;
            case 1: {
                self.nameEnterImageV.image = ThemeImage(@"enter_icon_02");
                return self.groupNameCell;
            }
                break;
            case 2:
                {
                    self.qrcodeEnterImageV.image = ThemeImage(@"enter_icon_02");
                    self.qrcodeImageV.image = ThemeImage(@"RXQRcode");
                    self.qrcodeNameL.font = ThemeFontLarge;
                    if (!isOpenScanInSession) {
                        self.GroupQRCodeCell.hidden = YES;
                    }
//                    self.GroupQRCodeCell.hidden = self.curGroup.type == 99;
                    self.GroupQRCodeCell.hidden = YES;
                    return self.GroupQRCodeCell;
                }
                break;
            case 3: {
                self.adEnterImageV.image = ThemeImage(@"enter_icon_02");
                return self.groupADCell;
            }
                break;
            case 4: {
                HXCommonTableViewCell *cell = [self setManagerOrChangeOwnerCellWithType:1];
                if (self.isOwner && !self.curGroup.isDiscuss) {
                    cell.hidden = NO;
                } else {
                    cell.hidden = YES;
                }
                return cell;
            }
                break;
            case 5: {
                HXCommonTableViewCell *cell = [self setManagerOrChangeOwnerCellWithType:0];
                if (self.isOwner && !self.curGroup.isDiscuss) {
                    cell.hidden = NO;
                } else {
                    cell.hidden = YES;
                }
                return cell;
            }
                break;
            case 6: {
                return self.groupSizeCell;
                break;
            }
                break;
            default:
                break;
        }

    } else if (indexPath.section == 2) {
        
        switch (indexPath.row) {
            case 0:
                self.groupRecordImageV.image = ThemeImage(@"enter_icon_02");
                return self.groupRecordCell;
                break;
            case 1:
                self.groupLookFileLabel.text = languageStringWithKey(@"查看聊天文件");
               self.groupLookFileImageV.image = ThemeImage(@"enter_icon_02");
               return self.groupLookFileCell;
                break;
            default:
                break;
        }
    } else if (indexPath.section == 3) {
        
        
        switch (indexPath.row) {
            case 0:
                return self.groupTopCell;
                break;
            case 1:
                return self.groupNewMessNotiCell;
                break;
            default:
                break;
        }
    }else if (indexPath.section == 4) {
        switch (indexPath.row) {
            case 0:
                self.nickEnterImageV.image = ThemeImage(@"enter_icon_02");
                return self.groupNickNameCell;// 我在本群的昵称，屏蔽
                break;
            case 1:
                return self.groupNickNameSwitchCell;
                break;
            default:
                break;
        }
    }else if (indexPath.section == 5) {
        switch (indexPath.row) {
            case 0:
                self.groupClearImageV.image = ThemeImage(@"enter_icon_02");
                self.groupClearMessCell.separatorInset = UIEdgeInsetsMake(0, kScreenWidth, 0, 0);
                return self.groupClearMessCell;
                break;
            case 1:
                if (self.isOwner && !self.curGroup.isDiscuss) {
                    self.groupDeleteCell.separatorInset = UIEdgeInsetsMake(0, kScreenWidth, 0, 0);
                    [self.deleteGroupBtn setTitle:languageStringWithKey(@"解散群组") forState:UIControlStateNormal];
                    self.groupDeleteCell.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
                    self.groupDeleteCell.hidden = self.curGroup.type == 99;
                    return self.groupDeleteCell;
                } else {
                    self.groupExitCell.separatorInset = UIEdgeInsetsMake(0, kScreenWidth, 0, 0);
                    [self.groupExitButton setTitle:languageStringWithKey(@"退出群聊") forState:UIControlStateNormal];
                    self.groupExitCell.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
                    self.groupExitCell.hidden = self.curGroup.type == 99;
                    return self.self.groupExitCell;
                }
                break;
            default:
                break;
        }
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Null"];
}


- (HXCommonTableViewCell *)setManagerOrChangeOwnerCellWithType:(NSInteger)cellType {
    HXCommonTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HXCommonTableViewCell"];
    cell.clipsToBounds = YES;
    cell.textLabel.text = @"";
    cell.titleLabel.text = cellType ? languageStringWithKey(@"群管理员") : languageStringWithKey(@"转让群");
    cell.contentLabel.text = cellType ? _groupManagersName : @"";
    cell.arrowImgView.image = ThemeImage(@"enter_icon_02");
    cell.userInteractionEnabled = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *MyView = [[UIView alloc] init];
    MyView.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    return MyView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        self.groupMemberCell.contentView.hidden = NO;
        return 44.0f;
    }
    if (indexPath.section == 0) {
        NSInteger curCount = self.showMembers.count;

        if (self.isOwner || self.curGroup.isDiscuss || self.isGroupManager) {
            if (self.showMembers.count > 0 && self.curGroup.type != 99) {
                if (self.showMembers.count == 1 || (!self.isOwner && self.curGroup.isDiscuss)) {
                    curCount += 1;
                } else {
                    curCount += 2;
                }
            }
        }
        int col = curCount % kShowIconSize;
        NSInteger rows = (curCount - col) / kShowIconSize;
        if (col != 0) {
            rows += 1;
        }
        return rows * (kScreenWidth / kShowIconSize);
    } else if (indexPath.section == 1) {

        if (self.curGroup.isDiscuss) {
            switch (indexPath.row) {
                case 4:
                case 5:
                    return 0;
                    break;
                case 6: {
                    if (isOpenScanInSession) {
                        return 44 * FitThemeFont;
                    } else {
                        return 0;
                    }
                }
                default:
                    return 44 * FitThemeFont;
                    break;
            }
        } else {
            if (self.isOwner) {
                switch (indexPath.row) {
                    case 0:
                        return 0;
                        break;
                    case 2:{//群组屏蔽二维码
//                        if (self.curGroup.type == 99) {
                            return 0;
//                        }else {
//                            return 44 * FitThemeFont;
//                        }
                        break;
                    }
                    case 4:{
                        if (self.curGroup.type == 99) {
                            return 0;
                        }else {
                            return 44 * FitThemeFont;
                        }
                        break;
                    }
                    case 5:{
                        if (self.curGroup.type == 99) {
                            return 0;
                        }else {
                            return 44 * FitThemeFont;
                        }
                        break;
                    }
                    case 6: {
                        if (isOpenScanInSession) {
                            return 44 * FitThemeFont;
                        } else {
                            return 0;
                        }
                    }
                        break;
                    default:
                        return 44 * FitThemeFont;
                        break;
                }
            } else {
                switch (indexPath.row) {
                    case 0:
                        return 0;
                        break;
                    case 2:{
//                        if (self.curGroup.type == 99) {
                            return 0;
//                        }else {
//                            return 44 * FitThemeFont;
//                        }
                        break;
                    }
                    case 4:
                    case 5:
                        return 0;
                        break;
                    case 6: {
                        if (isOpenScanInSession) {
                            return 44 * FitThemeFont;
                        } else {
                            return 0;
                        }
                    }
                        break;
                    default:
                        return 44 * FitThemeFont;
                        break;
                }
            }
        }
        
        
        
    } else {

        if (indexPath.section == 5) {
            if (indexPath.row >= 1) {
                return self.curGroup.type == 99 ? 0 : 64 * FitThemeFont;
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 2 || indexPath.row == 4) {
                return 0;
            }
        }
        return 44 * FitThemeFont;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            //跳转到群成员列表
            if (self.curGroup) {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.curGroup, @"HXGroupId", nil];
                [self pushViewController:@"RXGroupMembersViewController" withData:dic withNav:YES];
            }
        }
    }

    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        switch (indexPath.row) {
            case 0: {
                NSLog(@"点击了升级为群");

                UIAlertView *WXinstall = [[UIAlertView alloc] initWithTitle:languageStringWithKey(@"将讨论组升级为群") message:languageStringWithKey(@"升级此讨论组为群后，你将成为群主管理该群") delegate:self cancelButtonTitle:languageStringWithKey(@"取消") otherButtonTitles:languageStringWithKey(@"确定"), nil];//一般在if判断中加入
                [WXinstall show];
            }
                break;
            case 1: {
                NSLog(@"群组名称");
                NSString *isCanModify = @"true";
                if (!self.curGroup.isDiscuss && !self.isGroupManager && !self.isOwner) {
                    isCanModify = @"false";
                }
                [self pushViewController:@"RXGroupInfoChangeViewController" withData:[NSDictionary dictionaryWithObjectsAndKeys:KGroupInfoGroupName, KGroupInfoModifyType, self.curGroup, KGroupInfoModify, isCanModify, KGroupInfoModifyJurisdiction, nil] withNav:YES];
            }
                break;
            case 2:
                
                NSLog(@"点击了群二维码");
               // 二维码
               [self pushViewController:@"RXGroupchatQRCodeController" withData:self.curGroup withNav:YES];
                break;
            case 3: {
                NSLog(@"点击了公告");
                NSString *isCanModify = @"true";
                if (!self.curGroup.isDiscuss && !self.isGroupManager && !self.isOwner) {
                    isCanModify = @"false";
                }
                [self pushViewController:@"RXGroupInfoChangeViewController" withData:[NSDictionary dictionaryWithObjectsAndKeys:KGroupInfoGroupDeclared, KGroupInfoModifyType, self.curGroup, KGroupInfoModify, isCanModify, KGroupInfoModifyJurisdiction, nil] withNav:YES];
            }
                break;
            case 4: {
                NSLog(@"点击了设置管理员");
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.curGroup, @"HXGroupId", @"1", @"HXSelectGroupManager", nil];
                [self pushViewController:@"RXGroupAdminsViewController" withData:dic withNav:YES];
            }
                break;
            case 5: {
                NSLog(@"点击了转让群主");
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.curGroup, @"HXGroupId", @"1", @"HXSTransferGroup", nil];
                [self pushViewController:@"RXGroupMembersViewController" withData:dic withNav:YES];
            }
                break;
            case 6: {
               NSLog(@"点击了容量");
            }
                break;
            default:
                break;
        }
        return;

    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            KitGroupMemberInfoData *data = [self getGroupCardWithMemberId:[[Common sharedInstance] getAccount]];
            [self pushViewController:@"RXGroupInfoChageNickVIewController" withData:[NSDictionary dictionaryWithObjectsAndKeys:kGroupInfoGroupNickName, KGroupInfoModifyType, self.curGroup, KGroupInfoModify, self.isOwner ? @"1" : @"0", @"isAdminGroup", data, @"groupMemberCard", nil] withNav:YES];
        }

    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0: {
                [self checkHistoryRecord];
            }
                break;
            case 1: {//查看聊天文件
                RXChatFilesViewController *vc = [RXChatFilesViewController new];
                vc.sessionId = self.groupId;
                [self pushViewController:vc];
            }
                break;
                break;
            default:
                break;
        }
    }else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            [self clearGroupChatRecode];
        }
        
    }
}

//监听点击事件 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:languageStringWithKey(@"取消")]) {
        NSLog(@"你点击了取消");

    } else if ([btnTitle isEqualToString:languageStringWithKey(@"确定")]) {
        NSLog(@"你点击了确定");

        [[RestApi sharedInstance] ModifyGroupAndMemberRoleWithGroupId:self.curGroup.groupId withGroupName:self.curGroup.name withDeclared:nil withPermission:nil withGroupDomain:nil withUserName:nil withUseracc:[[Chat sharedInstance] getAccount] didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSLog(@"升级结束： dict=%@", dict);
            [self updateGroupDetail];
        }   didFailLoaded:^(NSError *error, NSString *path) {
            [SVProgressHUD showErrorWithStatus:@"升级失败"];
        }];

    }//https在iTunes中找，这里的事件是前往手机端App store下载微信
}

#pragma mark - 通知
- (void)didSelectGroupManager:(NSNotification *)notif {
    KitGroupMemberInfoData *kitMember = (KitGroupMemberInfoData *) notif.object;
    NSArray *names = [self.groupManagersName componentsSeparatedByString:@"、"];
    if ([names containsObject:kitMember.memberName]) { // 已经是管理员了
        return;
    }
    [[ECDevice sharedInstance].messageManager setGroupMembersRole:kitMember.groupId members:@[kitMember.memberId] role:ECMemberRole_Admin completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if (error.errorCode != ECErrorType_NoError) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"设置%@为管理员失败", kitMember.memberName]];
        }
    }];
//    [[ECDevice sharedInstance].messageManager setGroupMemberRole:kitMember.groupId member:kitMember.memberId role:ECMemberRole_Admin completion:^(ECError *error, NSString *groupId, NSString *memberId) {
//        if (error.errorCode != ECErrorType_NoError) {
//            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"设置%@为管理员失败", kitMember.memberName]];
//        }
//    }];
}

- (void)didSelectGroupOwner:(NSNotification *)notif {
    KitGroupMemberInfoData *kitMember = (KitGroupMemberInfoData *) notif.object;
    [[ECDevice sharedInstance].messageManager setGroupMemberRole:kitMember.groupId member:kitMember.memberId role:ECMemberRole_Creator completion:^(ECError *error, NSString *groupId, NSString *memberId) {
        if (error.errorCode != ECErrorType_NoError) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"设置%@为管理员失败", kitMember.memberName]];
        }
    }];
}

- (void)changeMemberRole:(NSNotification *)noitf {
    ECChangeMemberRoleMsg *changeMember = (ECChangeMemberRoleMsg *) noitf.object;
    int role = [changeMember.roleDic[@"role"] intValue];
    if ([changeMember.member isEqualToString:[[Chat sharedInstance] getAccount]]
            && role == 2) {
        self.isGroupManager = YES;
        self.isOwner = NO;
    } else if ([changeMember.member isEqualToString:[[Chat sharedInstance] getAccount]]
            && role == 1) {
        self.isOwner = YES;
        self.isGroupManager = NO;
    }
    if (role == 2) {
        if (self.groupManagersName.length == 0) {
            self.groupManagersName = changeMember.nickName;
        } else {
            self.groupManagersName = [self.groupManagersName stringByAppendingFormat:@"、%@", changeMember.nickName];
        }
    } else {
        NSArray *names = [self.groupManagersName componentsSeparatedByString:@"、"];
        NSString *tempGroupManagersName = @"";
        for (NSString *name in names) { // 过滤掉已经不是管理员的人
            if (![name isEqualToString:changeMember.nickName]) {
                if (tempGroupManagersName.length == 0) {
                    tempGroupManagersName = name;
                } else {
                    tempGroupManagersName = [tempGroupManagersName stringByAppendingFormat:@"、%@", changeMember.nickName];
                }
            }
        }
        self.groupManagersName = tempGroupManagersName;
    }
    // 修改数据库
    [KitGroupMemberInfoData updateRoleStateaMemberId:changeMember.member andRole:changeMember.roleDic[@"role"]];
    // 刷新当前页面
    [self getGroupInfo];
    [self queryGroupMembersFromSDK];
}

- (void)notificationDelete:(NSNotification *)notGroupId {
    NSString *groupId = notGroupId.object;
    if (!KCNSSTRING_ISEMPTY(groupId) && [groupId isEqualToString:self.curGroup.groupId]) {

        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:languageStringWithKey(@"提示") message:languageStringWithKey(@"您已被管理员移出该群组") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:languageStringWithKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            [self popRootViewController];
        }];
        [alertVC addAction:doneAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)onReceivedChageGroupInfo:(NSNotification *)sender {
    if ([sender.object isEqualToString:self.groupId]) {
        [self getGroupInfo];
    }
}

- (void)onReceivedRemoveMemberInGroup:(NSNotification *)sender {
    if ([sender.object isEqualToString:self.groupId]) {
        [self updateMemberList];
    }
}


- (void)onClickCleanButton:(id)sender {
    [UIAlertView showAlertView:nil message:[NSString stringWithFormat:@"%@?", languageStringWithKey(@"确定删除群的聊天记录?")] click:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[KitMsgData sharedInstance] deleteMessageOfSession:self.groupId];
            if (self.curGroup) {
                [[KitMsgData sharedInstance] addGroupIDs:@[self.curGroup]];
            }
            if ([self.groupInfodelegate respondsToSelector:@selector(groupInfoView:didSelectedIndexPath:)]) {
                NSIndexPath *idx = [NSIndexPath indexPathForRow:2 inSection:4];
                [self.groupInfodelegate groupInfoView:self didSelectedIndexPath:idx];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:self.groupId];
            });
        });
    }   cancelText:languageStringWithKey(@"取消") okText:languageStringWithKey(@"确定")];
}

- (KitGroupMemberInfoData *)getGroupCardWithMemberId:(NSString *)memberId {
    KitGroupMemberInfoData *infoData = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:memberId withGroupId:self.groupId];
    return infoData;
}

- (UIImageView *)nickEnterImageV {
    UIImageView *nickEnterImageV = (UIImageView *) [self.groupNickNameCell.contentView viewWithTag:1024];
    return nickEnterImageV;
}

- (UIImageView *)qrcodeEnterImageV {
    UIImageView *qrcodeEnterImageV = (UIImageView *) [self.GroupQRCodeCell.contentView viewWithTag:1024];
    return qrcodeEnterImageV;
}

- (UIImageView *)qrcodeImageV {
    UIImageView *qrcodeImageV = (UIImageView *) [self.GroupQRCodeCell.contentView viewWithTag:1025];
    return qrcodeImageV;
}

- (UIImageView *)groupRecordImageV {
    UIImageView *groupRecordImageV = (UIImageView *) [self.groupRecordCell.contentView viewWithTag:1026];
    return groupRecordImageV;
}

- (UIImageView *)groupClearImageV {
    UIImageView *groupClearImageV = (UIImageView *) [self.groupClearMessCell.contentView viewWithTag:1027];
    return groupClearImageV;
}

- (UIImageView *)groupLookFileImageV {
    UIImageView *groupLookFileImageV = (UIImageView *) [self.groupLookFileCell.contentView viewWithTag:1028];
    return groupLookFileImageV;
}

- (UILabel *)qrcodeNameL {
    UILabel *qrcodeNameL = (UILabel *) [self.GroupQRCodeCell.contentView viewWithTag:1001];
    return qrcodeNameL;
}

- (UIImageView *)memberEnterImageV {
    UIImageView *memberEnterImageV = (UIImageView *) [self.groupMemberCell.contentView viewWithTag:1024];
    return memberEnterImageV;
}

- (UIImageView *)adEnterImageV {
    UIImageView *adEnterImageV = (UIImageView *) [self.groupADCell.contentView viewWithTag:1024];
    return adEnterImageV;
}

- (UIImageView *)nameEnterImageV {
    UIImageView *nameEnterImageV = (UIImageView *) [self.groupNameCell.contentView viewWithTag:1024];
    return nameEnterImageV;
}

- (UIButton *)groupExitButton {
    UIButton *tempBtn = (UIButton *) [self.groupExitCell.contentView viewWithTag:211];
    [tempBtn setBackgroundImage:ThemeImage(@"red_button") forState:UIControlStateNormal];
    [tempBtn setBackgroundImage:ThemeImage(@"red_button") forState:UIControlStateHighlighted];
    tempBtn.titleLabel.font = ThemeFontLarge;
    return tempBtn;
}

- (UISwitch *)groupNoticeSwitch {
    return (UISwitch *) [self.groupNewMessNotiCell.contentView viewWithTag:101];
}

- (UISwitch *)groupTopSwitch {
    return (UISwitch *) [self.groupTopCell.contentView viewWithTag:101];
}

- (UILabel *)groupNameLabel {
    UILabel *label = (UILabel *) [self.groupNameCell.contentView viewWithTag:101];
    label.font = ThemeFontMiddle;
    return label;
}

- (UILabel *)groupMemberLabel {
    UILabel *label = (UILabel *) [self.groupMemberCell.contentView viewWithTag:211];
    label.font = SystemFontMiddle;
    return label;
}

- (UILabel *)groupADLabel {
    UILabel *label = (UILabel *) [self.groupADCell.contentView viewWithTag:101];
    label.font = ThemeFontMiddle;
    label.textColor = [UIColor colorWithHexString:@"#b8b8b8"];
    return label;
}

- (UILabel *)groupTypeLabel {
    UILabel *label = (UILabel *) [self.groupSizeCell.contentView viewWithTag:101];
    label.font = ThemeFontMiddle;
    return label;
}

- (UILabel *)groupNickNameLabel {
    UILabel *label = (UILabel *) [self.groupNickNameCell.contentView viewWithTag:101];
    label.font = ThemeFontMiddle;
    return label;
}

- (UISwitch *)groupNickNameSwitch {
    return (UISwitch *) [self.groupNickNameSwitchCell.contentView viewWithTag:101];
}

- (NSArray *)showMembers {
    if (!_showMembers) {
        _showMembers = [NSArray new];
    }
    return _showMembers;
}

#pragma mark 查看聊天记录

- (void)checkHistoryRecord {
    RXChatRecordsViewController *chatRecordVC = [[RXChatRecordsViewController alloc] init];
    if (self.groupId.length > 0) {
        chatRecordVC.sessionId = self.groupId;
    }
    [self pushViewController:chatRecordVC];
}

- (void)clearGroupChatRecode {
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:languageStringWithKey(@"确定删除群的聊天记录") subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
        if (index == 1) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KitMsgData sharedInstance] deletemessageid:self.groupId];
                if (self.curGroup) {
                    [[KitMsgData sharedInstance] addGroupIDs:@[self.curGroup]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:self.groupId];
                    [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"成功")];
                });
           });
        }
    }];
}

//退出群组
- (IBAction)onChickExitGroup:(id)sender {
    __weak typeof(self) weakSelf = self;
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:languageStringWithKey(@"删除并退出后,将不再接受此群组信息") subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
        if (index == 1) {
            [SVProgressHUD showWithStatus:languageStringWithKey(@"正在退出群聊")];
            [[ECDevice sharedInstance].messageManager quitGroup:self.groupId completion:^(ECError *error, NSString *groupId) {
                [SVProgressHUD dismiss];
                if (error.errorCode == ECErrorType_NoError || error.errorCode == 590019) {//已经不在群中
                    [[Common sharedInstance] deleteAllMessageOfSession:weakSelf.groupId];
                    //解散成功 删除缓存
                    [KitGroupInfoData deleteGroupInfoDataDB:groupId];
                    //删除成员缓存
                    [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:weakSelf.groupId];
                    NSArray *pushVCAry = [self.navigationController viewControllers];
                    if (pushVCAry.count > 3) {
                        UIViewController *popVC = [pushVCAry objectAtIndex:pushVCAry.count-3];
                        [self.navigationController popToViewController:popVC animated:YES];
                    } else {
                        [self popRootViewController];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Logout_Group object:groupId];
                } else {
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"退群失败")];
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ClearAllIMMsg object:nil];
        }
    }];
}

// 解散群组
- (IBAction)deleteGroup:(id)sender {
    __weak typeof(self) weakSelf = self;
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:languageStringWithKey(@"解散群组") subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
        if (index == 1) {
            [SVProgressHUD showWithStatus:languageStringWithKey(@"正在解散群")];
            [[ECDevice sharedInstance].messageManager deleteGroup:self.groupId completion:^(ECError *error, NSString *groupId) {
                [SVProgressHUD dismiss];
                if (error.errorCode == ECErrorType_NoError || error.errorCode == 590019) {
                    [[Common sharedInstance] deleteOneGroupInfoGroupId:weakSelf.groupId];
                    NSArray *pushVCAry = [self.navigationController viewControllers];
                    if (pushVCAry.count > 3) {
                        UIViewController *popVC = [pushVCAry objectAtIndex:pushVCAry.count-3];
                        [self.navigationController popToViewController:popVC animated:YES];
                    } else {
                        [self popRootViewController];
                    }
                } else {
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"解散失败")];
                }
            }];

            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ClearAllIMMsg object:nil];
        }
    }];
}

#pragma mark switch

- (void)didSwitchChanged:(UISwitch *)sender {
    if (sender == [self groupNoticeSwitch]) {
        // 新消息通知
        NSString *notice_key = [NSString stringWithFormat:@"%@_%@_notice", [[Common sharedInstance] getAccount], self.groupId];
        BOOL isSwitchNotice = sender.isOn;
        __weak typeof(self) weak_self = self;
        if (!isSwitchNotice) {
            [[ECDevice sharedInstance] setMuteNotification:self.groupId isMute:NO completion:^(ECError *error) {
                if (error.errorCode == ECErrorType_NoError) {
                    [[KitMsgData sharedInstance] updateMessageNoticeid:weak_self.groupId withNoticeStatus:0];

                    NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
                    [userGroupId removeObjectForKey:notice_key];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    [weak_self sendIMMessageisNotice:NO sessionId:weak_self.groupId];

                } else {
                    sender.on = !sender.on;
                }
            }];
        } else {
            [[ECDevice sharedInstance] setMuteNotification:self.groupId isMute:YES completion:^(ECError *error) {
                if (error.errorCode == ECErrorType_NoError) {
                    [[KitMsgData sharedInstance] updateMessageNoticeid:weak_self.groupId withNoticeStatus:1];

                    NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
                    [userGroupId setObject:@"1" forKey:notice_key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [weak_self sendIMMessageisNotice:YES sessionId:weak_self.groupId];
                } else {
                    sender.on = !sender.on;
                }
            }];
        }

    } else if (sender == [self groupTopSwitch]) {
        // 置顶聊天
        NSString *cur_top_key = [NSString stringWithFormat:@"%@_cur_top", self.groupId];
        typeof(self) weak_self = self;
        if ([self groupTopSwitch].isOn == YES) {
            [[AppModel sharedInstance] setSession:self.groupId IsTop:YES completion:^(ECError *error, NSString *seesionId) {
                if (error.errorCode == ECErrorType_NoError) {
                    [[NSUserDefaults standardUserDefaults] setObject:cur_top_key forKey:[NSString stringWithFormat:@"%@%@", SETUPTOP, self.groupId]];
                    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
                     NSString *str = [NSDate getTimeStrWithDate:date];
                    [[NSUserDefaults standardUserDefaults] setObject:str forKey:[NSString stringWithFormat:@"%@%@", SETUPTOPNEWTIME, self.groupId]];
                    DDLogInfo(@"设置置顶成功 seesionId = %@  error.errorCode = %ld", seesionId, (long) error.errorCode);
                    [weak_self sendIMMessageIsTop:YES sessionId:seesionId];
                }
            }];
        } else {
            [[AppModel sharedInstance] setSession:self.groupId IsTop:NO completion:^(ECError *error, NSString *seesionId) {
                if (error.errorCode == ECErrorType_NoError) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@", SETUPTOP, self.groupId]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@", SETUPTOPNEWTIME, self.groupId]];
                    DDLogInfo(@"取消置顶成功 seesionId = %@  error.errorCode = %ld", seesionId, (long) error.errorCode);
                    [weak_self sendIMMessageIsTop:NO sessionId:seesionId];
                }
            }];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        //接口设置状态
        [[AppModel sharedInstance] setSession:self.groupId IsTop:[self groupTopSwitch].isOn completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
    } else if (sender == [self groupNickNameSwitch]) {
        [[NSUserDefaults standardUserDefaults] setBool:![self groupNickNameSwitch].isOn forKey:[NSString stringWithFormat:@"%@%@", kGroupInfoGroupNickName, self.groupId]];
        [self.collectionView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupInfoGroupMembersNickNameSwitch object:self.groupId];
    } else {
        return;
    }
}

//置顶/取消置顶之后，发送CMD消息
- (void)sendIMMessageIsTop:(BOOL)isTop sessionId:(NSString *)sessionId {
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"isTop"] = @(isTop);
    mDic[@"sessionId"] = sessionId;
    mDic[@"type"] = @(ChatMessageTypeTopterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
}

//   设置/取消新消息通知 发送CMD消息
- (void)sendIMMessageisNotice:(BOOL)isNotice sessionId:(NSString *)sessionId {
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"isMute"] = @(isNotice);
    mDic[@"sessionId"] = sessionId;
    mDic[@"type"] = @(ChatMessageTypeMessageNoticeterminal);
    [[ChatMessageManager sharedInstance] sendCmdMessageByDic:mDic];
}

#pragma mark add delete

- (void)onChickAddMember {

    NSMutableArray *members = [[NSMutableArray alloc] init];
    NSArray *allMember = [KitGroupMemberInfoData getAllmemberInfoWithGroupId:self.groupId];
    for (KitGroupMemberInfoData *groupMember in allMember) {
        [members addObject:groupMember.memberId];
    }
    NSDictionary *exceptData = @{@"group_info": self.curGroup.groupId, @"members": members};
    UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:exceptData WithType:SelectObjectType_GroupChatSelectMember];
    [self pushViewController:groupVC];
}

- (void)onChickDeleteMember {
    self.isDelStatus = !self.isDelStatus;
    [self.collectionView reloadData];
}

- (void)onChickDeleteMemberIndex:(NSInteger)curIndex withMemberName:(NSString *)name {
    self.selectIndex = curIndex;
    KitGroupMemberInfoData *groupData = [self.groupMembers objectAtIndex:self.selectIndex];
    NSString *memberId = groupData.memberId;
    
    RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    NSString *msg = [NSString stringWithFormat:@"%@%@%@", languageStringWithKey(@"确认将"), !KCNSSTRING_ISEMPTY(name) ? name : languageStringWithKey(@"该成员"), self.curGroup.isDiscuss ? languageStringWithKey(@"移出讨论组") : languageStringWithKey(@"移出群聊")];
    __weak typeof(self) weak_self = self;
    [dialog showTitle:languageStringWithKey(@"提示") subTitle:msg ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
        if (index == 1) {
            [SVProgressHUD showWithStatus:languageStringWithKey(@"移出成员中")];
            [[ECDevice sharedInstance].messageManager deleteGroupMember:self.curGroup.groupId member:memberId completion:^(ECError *error, NSString *groupId, NSString *member) {
                [SVProgressHUD dismiss];
                if (error.errorCode == ECErrorType_NoError) {
                    [KitGroupMemberInfoData deleteGroupMemberPhoneInfoDataDB:member withGroupId:weak_self.curGroup.groupId];
                    [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"移出成功")];
                    if (groupData.role.integerValue == 2) {
                        [self initGroupManagerNames];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_memberChange_Group object:groupId];
                    // hanwei
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_reloadSessionGroupName object:groupId];
                } else {
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"移出失败")];
                }
            }];
        }
    }];
}

- (NSInteger)getGroupMembersCount {
    NSInteger allMemberCount = [KitGroupMemberInfoData getAllMemberCountGroupId:self.groupId];
    if (allMemberCount > 0) {
        self.title = [NSString stringWithFormat:@"%@(%ld)", languageStringWithKey(@"聊天详情"), (long) allMemberCount];
        [[self groupMemberLabel] setText:[NSString stringWithFormat:@"%@(%ld)>",languageStringWithKey(@"全部群成员"),(long) (long) allMemberCount]];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_reloadSessionGroupName object:self.groupId];
    }
    return allMemberCount;
}

//刷新列表
- (void)updateGroupMemberList {
    _isDelStatus = NO;
    [self.collectionView reloadData];
}

- (void)getGroupInfoFromSDK {
    //查询群组详情
    [SVProgressHUD showWithStatus:languageStringWithKey(@"获取群聊信息")];
    [[ECDevice sharedInstance].messageManager getGroupDetail:[NSString stringWithFormat:@"%@", self.groupId] completion:^(ECError *error, ECGroup *group) {
        [SVProgressHUD dismiss];
        if (error.errorCode == ECErrorType_NoError) {
            //入库
            KitGroupInfoData *groupData = [[KitGroupInfoData alloc] init];
            groupData.groupName = group.name;
            groupData.groupId = group.groupId;
            groupData.declared = group.declared;;
            groupData.owner = group.owner;
            groupData.createTime = group.createdTime;
            groupData.type = group.type;
            groupData.memberCount = group.memberCount;
            groupData.isDiscuss = group.isDiscuss;
            
            NSString *notice_key = [NSString stringWithFormat:@"%@_%@_notice", [[Common sharedInstance] getAccount], self.groupId];
            
            if (group.isNotice == YES) {
                [[self groupNoticeSwitch] setOn:YES];
                NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
                [userGroupId removeObjectForKey:notice_key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[self groupNoticeSwitch] setOn:NO];
                NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
                [userGroupId setObject:@"1" forKey:notice_key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            [KitGroupInfoData insertGroupInfoData:groupData];
            self.curGroup = group;
            
            self.isOwner = [[[Chat sharedInstance] getAccount] isEqualToString:self.curGroup.owner] || [[[Chat sharedInstance] getMobile] isEqualToString:self.curGroup.owner];//是否是群主
            [[self groupNameLabel] setText:self.curGroup.name];
            [[self groupADLabel] setText:[self curGroup].declared ? [self curGroup].declared : @""];
            [self queryGroupMembers];
            [self setGroupBaseInfo];
            
        } else {
            if (error.errorCode == 171139 || error.errorCode == 171141) {
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"请检查网络是否连接")];
            } else if (error.errorCode == 590010) {
                [[Common sharedInstance] deleteAllMessageOfSession:group.groupId];
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"群组不存在")];
            }
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"获取群组信息失败")];
            return;
        }
    }];
}

///修改自己在群里的昵称
- (void)modifyMemberCard:(KitGroupMemberInfoData *)data {
    ECGroupMember *groupMember = [[ECGroupMember alloc] init];
    groupMember.memberId = data.memberId;
    groupMember.groupId = data.groupId;
    groupMember.display = data.memberName;
    groupMember.role = [data.role integerValue];
    groupMember.sex = [data.sex integerValue];
    groupMember.speakStatus = ECSpeakStatus_Allow;
    [[ECDevice sharedInstance].messageManager modifyMemberCard:groupMember completion:^(ECError *error, ECGroupMember *member) {
        if (error.errorCode == ECErrorType_NoError) {
            [KitGlobalClass sharedInstance].isNeedUpdate = YES;
            [KitGroupMemberInfoData insertGroupMemberArray:@[member] withGroupId:member.groupId];
        }
    }];
}

#pragma mark - 大通讯录下要查询群里所有成员信息

- (void)getAllGroupMemberAddressWhenBigAddress {

    dispatch_queue_t queue = dispatch_queue_create("getAllGroupInfo", NULL);
    dispatch_async(queue, ^{
        NSArray<KitGroupMemberInfoData *> *array = [KitGroupMemberInfoData getAllmemberInfoWithGroupId:self.groupId];
        NSMutableArray *accoutList = [[NSMutableArray alloc] init];
        for (KitGroupMemberInfoData *memberInfo in array) {
            [accoutList addObject:[NSString stringWithFormat:@"%@", memberInfo.memberId]];
        }
        [[RestApi sharedInstance] getUserAvatarListByUseraccList:accoutList type:@"2" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSArray *dataArr = dict[@"body"][@"voipinfo"];
            [KitCompanyAddress insertCompanyAddressInfo:dataArr];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }   didFailLoaded:nil];
    });
}
@end
