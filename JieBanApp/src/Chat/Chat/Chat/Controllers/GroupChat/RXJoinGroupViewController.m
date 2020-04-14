//
//  RXJoinGroupViewController.m
//  Chat
//
//  Created by 胡伟 on 2019/8/29.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXJoinGroupViewController.h"

@interface RXJoinGroupViewController ()

@property (nonatomic, weak) RXGroupHeadImageView *avatarView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *tipLabel;

@property (nonatomic, copy) finishBlock block;
@end

@implementation RXJoinGroupViewController

- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = languageStringWithKey(@"加入群聊");
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
    
    UIView *infoView = [[UIView alloc] init];
    infoView.backgroundColor = [UIColor whiteColor];
    infoView.layer.cornerRadius = 5;
    infoView.layer.masksToBounds = YES;
    [self.view addSubview:infoView];
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view).insets(UIEdgeInsetsMake(97, 22, 0, 22));
        make.height.mas_equalTo(206);
    }];
    
    RXGroupHeadImageView *avatarView = [[RXGroupHeadImageView alloc] init];
    [infoView addSubview:avatarView];
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.top.equalTo(infoView).offset(36);
        make.centerX.equalTo(infoView);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [infoView addSubview:nameLabel];
    nameLabel.numberOfLines = 2;
    nameLabel.font = [UIFont systemFontOfSize:16];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(infoView);
        make.width.lessThanOrEqualTo(@200);
        make.top.equalTo(avatarView.mas_bottom).offset(20);
        make.height.mas_equalTo(44);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    [infoView addSubview:tipLabel];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(infoView);
        make.bottom.equalTo(infoView).offset(-25);
        make.left.right.equalTo(infoView);
        make.height.mas_equalTo(16);
    }];
    
    UIButton *joinButton = [[UIButton alloc] init];
    [self.view addSubview:joinButton];
    [joinButton setTitle:languageStringWithKey(@"加入该群聊") forState:UIControlStateNormal];
    [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    joinButton.titleLabel.font = [UIFont systemFontOfSize:16];
    joinButton.backgroundColor = ThemeColor;
    joinButton.layer.cornerRadius = 5;
    joinButton.layer.masksToBounds = YES;
    [joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoView.mas_bottom).offset(64);
        make.centerX.equalTo(infoView);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(180);
    }];
    [joinButton addTarget:self action:@selector(joinButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _avatarView = avatarView;
    _nameLabel = nameLabel;
    _tipLabel = tipLabel;
}

- (void)setDataSource:(NSDictionary *)dataSource {
    _dataSource = dataSource;
    _nameLabel.text = dataSource[@"name"];
    _tipLabel.text = dataSource[@"count"] ? [NSString stringWithFormat:@"群内已有%@人", dataSource[@"count"]] : @"";
    NSArray *members = [KitGroupMemberInfoData getSequenceMembersforGroupId:dataSource[@"groupid"] memberCount:9];
    if (members.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.avatarView createHeaderViewH:50 withImageWH:50 groupId:dataSource[@"groupid"] withMemberArray:members];
        });
    }
    else {
        [[ECDevice sharedInstance].messageManager queryGroupMembers:dataSource[@"groupid"] completion:^(ECError *error, NSString *groupId, NSArray *members) {
            if (error.errorCode == ECErrorType_NoError && members.count > 0) {
                [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.avatarView createHeaderViewH:50 withImageWH:50 groupId:dataSource[@"groupid"] withMemberArray:[KitGroupMemberInfoData getSequenceMembersforGroupId:dataSource[@"groupid"] memberCount:9]];
                });
            }
        }];
    }
}

- (void)joinButtonClicked {
    KitGroupMemberInfoData *info = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:Common.sharedInstance.getAccount withGroupId:_dataSource[@"groupid"]];
    [SVProgressHUD show];
    if (info) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"已在群组中")];
    } else {
        //加入群
        [[RestApi sharedInstance] joinGroupChatWithConfirm:1 Declared:@"fromQRCode" GroupId:_dataSource[@"groupid"] Members:@[[[Common sharedInstance] getAccount]] UserName:_dataSource[@"owner"] didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSInteger code = [dict[@"statusCode"] integerValue];
            if (code == 000000) {
                //请求群组成员信息
                [self.navigationController popViewControllerAnimated:NO];
                if (self.block) {
                    self.block(YES);
                }
                [SVProgressHUD dismiss];
            }else if (code == 590038){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"已在群组中")];
            }else if (code == 590010){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"该群组已解散")];
            }else if (code == 113608){
                [SVProgressHUD showErrorWithStatus:dict[@"statusMsg"]];
            }else{
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"扫码加群失败")];
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"扫码加群失败")];
        }];
    }
}

- (void)joinGroup:(finishBlock)block {
    _block = block;
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
