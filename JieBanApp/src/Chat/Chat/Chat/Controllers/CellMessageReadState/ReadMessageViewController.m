//
//  ReadMessageViewController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ReadMessageViewController.h"

#define Color [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1]


@interface ReadMessageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *segHeadView;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSMutableArray *cacheUnReadArray;
@property (nonatomic, strong) NSMutableArray *cacheReadArray;
@property (nonatomic, strong) ECMessage *message;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, strong) UILabel *allReadLabel;
@property (nonatomic ,assign) int unreadPageNo; //拉取未读数的页码
@property (nonatomic ,assign) int readPageNo; //拉取已读数的页码
@property (nonatomic ,assign) BOOL isRead;
@end

@implementation ReadMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _memberArray = [NSMutableArray array];
    _message = self.data;
    _cacheUnReadArray = [NSMutableArray array];
    _cacheReadArray = [NSMutableArray array];
    self.unreadPageNo = 1;
    self.readPageNo =1;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = languageStringWithKey(@"消息接收人列表");
    self.edgesForExtendedLayout =  UIRectEdgeNone;

    WS(weakSelf);
    MJRefreshAutoNormalFooter *footerRefresh = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    [footerRefresh setTitle:@"" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footerRefresh;
    if (isLargeAddressBookModel) {
        [self getAllGroupMemberAddressWhenBigAddress];
    }
    WS(weakself)
    self.isRead = NO;
//    [self queryMessageCountWithStateRead:self.isRead  complation:^(NSDictionary *dict, NSString *path) {
//        NSInteger unReadCount = [dict[@"unReadCount"] integerValue];
//        if (unReadCount == 0) {
//            self.isRead = YES;
//            [weakself queryMessageCountWithStateRead:YES];
//        }else {
//            self.isRead = NO;
//            [weakself queryMessageCountWithStateRead:NO];
//        }
//    }];
     [self queryMessageCountWithStateRead:self.isRead];
}

- (void)configView {

    if (!_segment) {
        NSString *item1 = [NSString stringWithFormat:@"%@",languageStringWithKey(@"未读")];
        NSString *item2 = [NSString stringWithFormat:@"%@",languageStringWithKey(@"已读")];
        _segment = [[UISegmentedControl alloc] initWithItems:@[item1,item2]];
        _segment.selectedSegmentIndex = 0;
        _segment.frame = CGRectMake(10, 7.0f, self.view.bounds.size.width-10*2, 30.0f*FitThemeFont);
        [_segment setTintColor:ThemeColor];
        //设置字体大小
        UIFont *font = ThemeFontLarge;
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        [_segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [_segment addTarget:self action:@selector(onclickedSegment:) forControlEvents:UIControlEventValueChanged];
        [_segHeadView addSubview:_segment];
    }
    
    if (!_allReadLabel) {
        _allReadLabel = [UILabel new];
        _allReadLabel.textColor = [UIColor colorWithHexString:@"222222"];
        _allReadLabel.font = ThemeFontLarge;
        [_segHeadView addSubview:_allReadLabel];
        [_allReadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(12);
            make.centerY.mas_offset(0);
            make.right.mas_offset(-12);
        }];
        _allReadLabel.text = languageStringWithKey(@"消息全部已读");
    }
    
//    if (_unreadCount == 0) {//全部已读
//        _allReadLabel.hidden = NO;
//        _segment.hidden = YES;
//    }else {
        _allReadLabel.hidden = YES;
        _segment.hidden = NO;
//    }
    
}
-(UIView *)segHeadView{
    if (!_segHeadView) {
        _segHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0f * FitThemeFont)];
        _segHeadView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_segHeadView];
    }
    return _segHeadView;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.segHeadView.bottom, self.view.bounds.size.width, self.view.bounds.size.height - self.segHeadView.bottom - kTotalBarHeight) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = Color;
        _tableView.tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.top.mas_equalTo(self.segHeadView.mas_bottom);
        }];
    }
    return _tableView;
}
- (void)queryMessageCountWithStateRead:(BOOL)isRead{
//    self.pageNo = 1;
    
    if (isRead) {
        if (self.cacheReadArray.count>0) {
            [self.memberArray removeAllObjects];
            [self.memberArray addObjectsFromArray:self.cacheReadArray];
            if (self.cacheReadArray.count % 50 == 0) {
                [self.tableView.mj_footer resetNoMoreData];
            }
            [self.tableView reloadData];
            return;
        }
        
    }else{
        if (self.cacheUnReadArray.count>0) {
            [self.memberArray removeAllObjects];
            [self.memberArray addObjectsFromArray:self.cacheUnReadArray];
            if (self.cacheUnReadArray.count % 50 == 0) {
                [self.tableView.mj_footer resetNoMoreData];
            }
            [self.tableView reloadData];
            return;
        }
    }
    
    
    @weakify(self)
    [self queryMessageCountWithStateRead:isRead complation:^(NSDictionary *dict, NSString *path) {
        @strongify(self)
        NSInteger readCount = [dict[@"readCount"] integerValue];
        NSInteger unReadCount = [dict[@"unReadCount"] integerValue];
        
        [self saveUnreadCount:unReadCount];
        
        NSArray *resultArr = dict[@"result"];
     
        if (resultArr.count == 50) {
            [self.tableView.mj_footer endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        self.unreadCount = unReadCount;
        if (isRead) {
            [[KitMsgData sharedInstance] updateUnreadCount:unReadCount ofMessageId:self.message.messageId];
            [self.cacheReadArray addObjectsFromArray:resultArr];
            [self.memberArray removeAllObjects];
            [self.memberArray addObjectsFromArray:self.cacheReadArray];
        }else{
            for (NSDictionary *temp in resultArr) {
                NSString *account = temp[@"useracc"];
                [self.cacheUnReadArray addObject:account];
            }
            [self.memberArray removeAllObjects];
            [self.memberArray addObjectsFromArray:self.cacheUnReadArray];
        }
            [self configView];
            [self.segment setTitle:[NSString stringWithFormat:@"%@%@",languageStringWithKey(@"未读"),unReadCount > 0 ? [NSString stringWithFormat:@"(%ld)",(long)unReadCount]:@"(0)"] forSegmentAtIndex:0];
            [self.segment setTitle:[NSString stringWithFormat:@"%@%@",languageStringWithKey(@"已读"),readCount > 0 ? [NSString stringWithFormat:@"(%ld)",(long)readCount]:@"(0)"] forSegmentAtIndex:1];
            [self.tableView reloadData];
        }];
}

- (void)queryMessageCountWithStateRead:(BOOL)isRead complation:(void (^)(NSDictionary *dict, NSString *path))complation {
//    self.pageNo = 1;
    NSString *type = isRead ? @"1":@"2";
    int pageNo = self.isRead?self.readPageNo:self.unreadPageNo;
    //change by keven .使用rest接口时，多终端登录时 同步的pc消息要用version字段查
    NSString *version = nil;
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [numberRegular numberOfMatchesInString:self.message.messageId options:NSMatchingReportProgress range:NSMakeRange(0,self.message.messageId.length)];
    BOOL isPcMsg = count>0?NO:YES;
    if (isPcMsg) {
        NSArray *array = [self.message.messageId componentsSeparatedByString:@"|"];
        if (array.count == 2) {
            version = array.lastObject;
        }
    }
    [[RestApi sharedInstance] getMessageReceiptByMsgId:self.message.messageId version:version type:type userName:[[Chat sharedInstance] getAccount] isReturnList:@"1" pageNo:pageNo didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        if (complation) {
            [self.memberArray removeAllObjects];
            complation(dict,path);
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        NSLog(@"11");
    }];
}

- (void)saveUnreadCount:(NSInteger)unReadCount {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSString stringWithFormat:@"%ld",(long)unReadCount] forKey:[NSString stringWithFormat:@"%@_%@",self.message.messageId,@"CellMessageUnReadCount"]];
    [userDefaults synchronize];
}

-(void)loadMoreData{
//    self.pageNo++;
    self.isRead?self.readPageNo++:self.unreadPageNo++;
    int pageNo = self.isRead?self.readPageNo:self.unreadPageNo;
    NSString *type = self.isRead ? @"1":@"2";
    //change by keven .使用rest接口时，多终端登录时 同步的pc消息要用version字段查
    NSString *version = nil;
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [numberRegular numberOfMatchesInString:self.message.messageId options:NSMatchingReportProgress range:NSMakeRange(0,self.message.messageId.length)];
    BOOL isPcMsg = count>0?NO:YES;
    if (isPcMsg) {
        NSArray *array = [self.message.messageId componentsSeparatedByString:@"|"];
        if (array.count == 2) {
            version = array.lastObject;
        }
    }
    @weakify(self)
    [[RestApi sharedInstance] getMessageReceiptByMsgId:self.message.messageId version:version type:type userName:[[Chat sharedInstance] getAccount] isReturnList:@"1" pageNo:pageNo didFinishLoaded:^(NSDictionary *dict, NSString *path) {
         @strongify(self)
        NSInteger readCount = [dict[@"readCount"] integerValue];
        NSInteger unReadCount = [dict[@"unReadCount"] integerValue];
        
        [self saveUnreadCount:unReadCount];
        
        NSArray *resultArr = dict[@"result"];
        
        if (resultArr.count == 50) {
            [self.tableView.mj_footer endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        self.unreadCount = unReadCount;
        if (self.isRead) {
            [self.cacheReadArray addObjectsFromArray:resultArr];
            [self.memberArray removeAllObjects];
            [self.memberArray addObjectsFromArray:self.cacheReadArray];
        }else{
            for (NSDictionary *temp in resultArr) {
                NSString *account = temp[@"useracc"];
                [self.cacheUnReadArray addObject:account];
            }
            [self.memberArray removeAllObjects];
            [self.memberArray addObjectsFromArray:self.cacheUnReadArray];
            
        }
        
        [self.tableView reloadData];
    } didFailLoaded:^(NSError *error, NSString *path) {
        NSLog(@"%s",__func__);
    }];

}
- (void)onclickedSegment:(UISegmentedControl *)segment {
    DDLogInfo(@"%ld",(long)segment.selectedSegmentIndex);
    switch (segment.selectedSegmentIndex) {
        case 0: {
            self.isRead = NO;
            [self queryMessageCountWithStateRead:self.isRead];
            
        }
            break;
        case 1: {
            self.isRead = YES;
            [self queryMessageCountWithStateRead:self.isRead];
        }
            break;
  
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56 * FitThemeFont;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _memberArray.count;
}

static NSString *cellId = @"cellId";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id contact = [_memberArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[contact isKindOfClass:[ECReadMessageMember class]]?@"HaveReadCell":@"UnReadCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[contact isKindOfClass:[ECReadMessageMember class]]?@"HaveReadCell":@"UnReadCell" ];
        cell.selectionStyle = NO;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 2*FitThemeFont, 37*FitThemeFont, 37*FitThemeFont)];
        imgView.tag = 999;
        imgView.layer.cornerRadius = 4;
        imgView.layer.masksToBounds = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.centerY.mas_offset(0);
            make.size.mas_equalTo(CGSizeMake(37*FitThemeFont, 37*FitThemeFont));
        }];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(65*FitThemeFont, 0, kScreenWidth, 44*FitThemeFont)];
        titleLabel.font = ThemeFontMiddle;
        titleLabel.tag = 998;
        [cell.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(imgView.mas_right).mas_offset(10);
            make.centerY.mas_offset(0);
            make.right.mas_lessThanOrEqualTo(-110);
        }];
        
        
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(65*FitThemeFont, 25*FitThemeFont, kScreenWidth, 15*FitThemeFont)];
        subTitleLabel.font =ThemeFontSmall;
        subTitleLabel.textAlignment = NSTextAlignmentRight;
        subTitleLabel.tag = 997;
        subTitleLabel.textColor = [UIColor colorWithHexString:@"666666"];
        [cell.contentView addSubview:subTitleLabel];
        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-12);
            make.centerY.mas_offset(0);
            make.width.mas_equalTo(100);
        }];
        
    }
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:999];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:998];
    UILabel *subTitleLabel = (UILabel *)[cell.contentView viewWithTag:997];
//    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:996];

    NSString *memberId = nil;
    if ([contact isKindOfClass:[ECReadMessageMember class]]) {
        ECReadMessageMember *member = (ECReadMessageMember*)contact;
        memberId = member.userName;
        subTitleLabel.text = [ChatTools getDateDisplayString:[member.timetmp longLongValue]];
        subTitleLabel.hidden = NO;
    } else if ([contact isKindOfClass:[NSDictionary class]]) {//已读，需要展示时间
        memberId = contact[@"useracc"];
        subTitleLabel.text = [ChatTools getDateDisplayString:[contact[@"time"] longLongValue]];
        subTitleLabel.hidden = NO;
    }else if ([contact isKindOfClass:[NSString class]]) {//未读，不需要展示时间
        memberId = contact;
        subTitleLabel.hidden = YES;
    }
    NSDictionary *memberInfo = [[Common sharedInstance].componentDelegate getDicWithId:memberId withType:0];
    titleLabel.text = @"";
    NSString *name = memberInfo[Table_User_member_name];
    titleLabel.text = name.length > 0? name :memberId;
    [imgView sd_cancelCurrentImageLoad];
    if([memberInfo[Table_User_status] isEqualToString:@"3"]){
        imgView.image = ThemeDefaultHead(imgView.size, RXleaveJobImageHeadShowContent,memberInfo[Table_User_account]);
    }else{
        [imgView setImageWithURLString:memberInfo[Table_User_avatar] urlmd5:memberInfo[Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(imgView.size, memberInfo[Table_User_member_name],memberInfo[Table_User_account]) withRefreshCached:NO];
    }
    return cell;
}

#pragma mark - 大通讯录下要查询群里所有成员信息
- (void)getAllGroupMemberAddressWhenBigAddress{
    dispatch_queue_t queue = dispatch_queue_create("getAllGroupInfo", NULL);
    dispatch_async(queue, ^{
        NSArray<KitGroupMemberInfoData *> *array = [KitGroupMemberInfoData getAllmemberInfoWithGroupId:self.message.sessionId];
        NSMutableArray *accoutList = [[NSMutableArray alloc] init];
        for (KitGroupMemberInfoData *memberInfo in array) {
            [accoutList addObject:[NSString stringWithFormat:@"%@",memberInfo.memberId]];
        }
        [[RestApi sharedInstance] getUserAvatarListByUseraccList:accoutList type:@"2" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSArray *dataArr = dict[@"body"][@"voipinfo"];
            [KitCompanyAddress insertCompanyAddressInfo:dataArr];
            DDLogInfo(@"庚戌年通讯录 %@",[NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } didFailLoaded:nil];
    });
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id contact = [_memberArray objectAtIndex:indexPath.row];
    NSString *memberId = nil;
    if ([contact isKindOfClass:[ECReadMessageMember class]]) {
        ECReadMessageMember *member = (ECReadMessageMember*)contact;
        memberId = member.userName;
    } else if ([contact isKindOfClass:[NSDictionary class]]) {
        memberId = contact[@"useracc"];
    } else if ([contact isKindOfClass:[NSString class]]) {
        memberId = contact;
    }
    UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:memberId];
    [self pushViewController:contactorInfosVC];
    
}


@end
