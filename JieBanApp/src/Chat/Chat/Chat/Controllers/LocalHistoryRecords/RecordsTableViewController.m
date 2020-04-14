//
//  RecordsTableViewController.m
//  Chat
//
//  Created by ywj on 2017/1/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "RecordsTableViewController.h"
#import "SessionViewCell.h"
#import "NSAttributedString+Color.h"
#import "ChatViewController.h"

#import "GroupListCard.h"

@interface RecordsTableViewController ()
//记录传入的参数
@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, strong) ECSession *session;
@property (nonatomic, strong) NSArray *messageArr;

@end

@implementation RecordsTableViewController

//外界调用 传入参数 
- (instancetype)initWithSession:(ECSession *)session andSearchStr:(NSString *)searchStr andMessageArr:(NSArray *)messageArr {
    if (self = [super init]) {
        _searchStr = searchStr;
        _session = session;
        _messageArr = messageArr;
        [self setupUI];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(iOS7){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    ///注册xib
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupListCard" bundle:nil] forCellReuseIdentifier:@"grouplistcard"];
    //wwl 群组信息刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSessionGroup:) name:
     KNotice_ReloadSessionGroup object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
}

- (void)setupUI {
    //群组消息
    if([_session.sessionId hasPrefix:@"g"]){
        self.navigationItem.title = [[Common sharedInstance] getOtherNameWithPhone:_session.sessionId];
    }else{
        NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:_session.sessionId withType:0];
        if(companyInfo){
            self.navigationItem.title = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
        }
    }
    //聊天记录数统计
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    label.text = [NSString stringWithFormat:@"  共%zd条和\"%@\"相关聊天记录",_messageArr.count,_searchStr];
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    self.tableView.tableHeaderView = label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //聊天记录
    GroupListCard *groupCell = [tableView dequeueReusableCellWithIdentifier:@"grouplistcard"];
    groupCell.currentSearchText = self.searchStr;
    groupCell.session = _session;
    groupCell.message = _messageArr[indexPath.row];
    return groupCell;
}
//刷新沟通界面显示群组信息
- (void)reloadSessionGroup:(NSNotification *)not{
    NSString *groupId = not.object;
    if (KCNSSTRING_ISEMPTY(groupId)) {
        [self.tableView reloadData];
    }else{
        for (int i = 0; i<self.messageArr.count; i++) {
            ECSession* session = [_messageArr objectAtIndex:i];
            if ([session.sessionId isEqualToString:groupId]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //聊天界面入口
    ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:_session.sessionId andRecodMessage:_messageArr[indexPath.row]];
    chatVC.dataSearchFrom = @{@"fromePage":@"searchDetail"};
    [self.navigationController pushViewController:chatVC animated:YES];
}


@end
