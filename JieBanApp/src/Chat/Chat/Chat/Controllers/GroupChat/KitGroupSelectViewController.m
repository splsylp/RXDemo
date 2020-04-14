//
//  KitGroupSelectViewController.m
//  Chat
//
//  Created by yongzhen on 17/2/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "KitGroupSelectViewController.h"
#define kMaxVideoCount 8
#define kMaxVoiceMeetingCount 15
#define kMaxVidyoMeetingCount 20
#define kMaxBroadMeetingCount 50

@interface KitGroupSelectViewController ()<UITableViewDelegate,UITableViewDataSource,HYTSelectedMediaContactsCellDelegate>
@property (assign,nonatomic)NSInteger maxSelectCount;//当前选择的最大成员数
//@property (strong,nonatomic)ECGroup *currentGroup;//当前群组
//@property (copy,nonatomic)NSString *currentGroupID;//当前群组ID
@property (strong,nonatomic)UITableView *memberTableView;



@end

@implementation KitGroupSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.conferenceType == 3) {
        self.maxSelectCount = kMaxVidyoMeetingCount - self.selectMembers.count;

        NSMutableArray *allMembers = [KitGroupMemberInfoData getSelectCompanyDataWithGroupId:self.groupId];
        self.allMembersArray = [NSArray arrayWithArray:allMembers];
        
    } else if (self.conferenceType == 4) {
        self.maxSelectCount = kMaxBroadMeetingCount;
        self.selectMembers = [NSMutableArray arrayWithCapacity:0];
        //自己直接添加
        //2017yxp8.15
        NSMutableArray *allMembers = [KitGroupMemberInfoData getSelectCompanyDataWithGroupId:self.groupId];
        
        self.allMembersArray = [NSArray arrayWithArray:allMembers];
    } else {
        if (self.isFromVoiceConfMeeting) {
            self.maxSelectCount = kMaxVoiceMeetingCount;
        } else {
            self.maxSelectCount = kMaxVideoCount;
        }
        
        if (self.allMembersArray) {
//            if (self.allMembersArray.count <= self.maxSelectCount) {
                //默认只发起人被选中
                __block NSMutableArray *temArray = [NSMutableArray array];
                [self.allMembersArray enumerateObjectsUsingBlock:^(NSDictionary * dataInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([dataInfo[Table_User_account] isEqualToString:[Common sharedInstance].getAccount]) {
                        [temArray addObject:dataInfo];
                        * stop = YES;
                    }
                }];
                self.selectMembers =  [NSMutableArray arrayWithArray:temArray];
//            }else{
//                self.selectMembers = [[self.allMembersArray subarrayWithRange:NSMakeRange(0, self.maxSelectCount)] mutableCopy];
//            }
        }else{
            self.selectMembers = [NSMutableArray arrayWithCapacity:0];
        }
    }
    
    
    //创建列表
    [self createMemberList];
    //创建界面UI
    [self createUI];
}
#pragma mark 界面UI
-(void)createUI{
    self.title = languageStringWithKey(@"选择参会成员");
    //取消
    [self setBarItemTitle:languageStringWithKey(@"取消") titleColor:APPMainUIColorHexString target:self action:@selector(atCancel) type:NavigationBarItemTypeLeft];
    NSInteger count = self.maxSelectCount;
    if (self.allMembersArray.count > 0) {
        count = self.allMembersArray.count > self.maxSelectCount ?self.maxSelectCount :self.allMembersArray.count;
    }
    //确定
    NSString *title = [NSString stringWithFormat:@"%@(%lu/%ld)",languageStringWithKey(@"确定"),(unsigned long)_selectMembers.count,(long)count];
    [self setBarItemTitle:title titleColor:APPMainUIColorHexString target:self action:@selector(selectMemberFinish) type:NavigationBarItemTypeRight];
    
    
}
#pragma mark 创建成员列表
-(void)createMemberList{
    self.memberTableView = [[UITableView alloc] init];
    self.memberTableView.frame = CGRectMake(0,kTotalBarHeight, kScreenWidth,kScreenHeight-kTotalBarHeight);
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
    self.memberTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.memberTableView];
    if (iOS11) {
        // 这里代码针对ios11之后，tableveiw 刷新时候，闪动，跳动的问题
        self.memberTableView.estimatedRowHeight = 0;
        self.memberTableView.estimatedSectionHeaderHeight = 0;
        self.memberTableView.estimatedSectionFooterHeight = 0;
    }
}
#pragma mark cancel
-(void)atCancel{
    if (self.conferenceType == 3||self.conferenceType == 4) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController.view removeFromSuperview];
        [Chat sharedInstance].groupListForMeeting = nil;
    }
}

#pragma mark tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allMembersArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    HYTSelectedMediaContactsCell * cell = [self.memberTableView dequeueReusableCellWithIdentifier:@"HYTSelectedMediaContactsCell"];
    if (cell == nil) {
        cell = [HYTSelectedMediaContactsCell classFromNib:@"HYTSelectedMediaContactsCell"];
        cell.titleLabel.text = @"";
        cell.subTitleLabel.text = @"";
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.userHeadImageView.hidden = NO;
        cell.selectedButton.userInteractionEnabled = NO;
        cell.selectedButton.hidden = NO;
    }
    cell.tag = indexPath.row;
    cell.selectedButton.tag = cell.tag;
    cell.userInteractionEnabled = YES;
    NSDictionary * dataInfo = [_allMembersArray objectAtIndex:indexPath.row];
    if (dataInfo) {
       // NSDictionary *memberInfo = [[Common sharedInstance].componentDelegate getDicWithId:dataInfo[Table_User_account] withType:0];
        
        cell.titleLabel.text = dataInfo[Table_User_member_name]?dataInfo[Table_User_member_name]:dataInfo[Table_User_account];
//        cell.subTitleLabel.text =clientShowInfomation?(HXLevelisFristAndSecond([dataInfo[Table_User_Level] integerValue],dataInfo[Table_User_account])?hiddenMobileAndShowDefault:dataInfo[Table_User_mobile]):dataInfo[Table_User_mobile];
        
        NSString *photoUrl = dataInfo[Table_User_avatar];
        NSString *md5 = dataInfo[Table_User_urlmd5];
        if (!KCNSSTRING_ISEMPTY(photoUrl) || !KCNSSTRING_ISEMPTY(md5)) {
            [cell.userHeadImageView setImageWithURLString:dataInfo[Table_User_avatar] urlmd5:dataInfo[Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(cell.userHeadImageView.size, cell.titleLabel.text,dataInfo[Table_User_account]) withRefreshCached:NO];
        } else {
            cell.userHeadImageView.image = ThemeDefaultHead(cell.userHeadImageView.size,cell.titleLabel.text,dataInfo[Table_User_account]);
        }
        
    }
    
    if ([self isSelectMember:dataInfo]) {
        //是否是已经选择的成员---本次选择
        cell.selectedButton.selected = YES;
        if (self.conferenceType == 3 || self.conferenceType == 4) {
            cell.userInteractionEnabled = NO;
        }
    }else{
        cell.selectedButton.selected = NO;
    }
    
    return cell;
}

- (BOOL)isSelectMember:(NSDictionary *)dataInfo {

    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"account CONTAINS[cd] %@",dataInfo[Table_User_account]];
    NSArray *myArray =[self.selectMembers filteredArrayUsingPredicate:predicate];
    if(myArray.count>0) {
        return YES;
    }
    if ([KSCNSTRING_ISNIL([Common sharedInstance].getAccount) isEqualToString: dataInfo[Table_User_account]]) {
        return YES;
    }
    return NO;
}

- (void)selectedMediaContactsCell:(HYTSelectedMediaContactsCell *)dialingTableViewCell selected:(BOOL)selected{
    
    NSInteger row = dialingTableViewCell.tag;
    
    id data = [self.allMembersArray objectAtIndex:row];
    
    if ([data isKindOfClass:[NSDictionary class]] && [data[@"account"] isEqual:[Common sharedInstance].getAccount]) {
        NSLog(@"自己发起的会议不可取消自己");
        return;
    }
    //此时改变按钮状态
    dialingTableViewCell.selectedButton.selected = !dialingTableViewCell.selectedButton.selected;
    
    if (selected) {
        if ( self.selectMembers.count < self.maxSelectCount) {
            [self.selectMembers addObject:data];
            
            NSInteger count = self.maxSelectCount;
            if (self.allMembersArray.count > 0) {
                count = self.allMembersArray.count > self.maxSelectCount ?self.maxSelectCount :self.allMembersArray.count;
            }
            NSString *title = [NSString stringWithFormat:@"%@(%lu/%ld)",languageStringWithKey(@"确定"),(unsigned long)_selectMembers.count,(long)count];
            
            [self setBarItemTitle:title titleColor:APPMainUIColorHexString target:self action:@selector(selectMemberFinish) type:NavigationBarItemTypeRight];
        }else{
            NSString *tep = nil;
            if (isEnLocalization) {
                tep =[NSString stringWithFormat:@"%@%ld",languageStringWithKey(@"最多可选"),(long)self.maxSelectCount];
            }else{
                tep = [NSString stringWithFormat:@"%@%ld人",languageStringWithKey(@"最多可选"),(long)self.maxSelectCount];
            }
            [UIAlertView showAlertView:tep message:nil click:nil okText:languageStringWithKey(@"好")];
            
            dialingTableViewCell.selectedButton.selected = NO;
        }
        
        
    }else{
        [self.selectMembers removeObject:data];
        NSInteger count = self.maxSelectCount;
        if (self.allMembersArray.count > 0) {
            count = self.allMembersArray.count > self.maxSelectCount ?self.maxSelectCount :self.allMembersArray.count;
        }
        NSString *title = [NSString stringWithFormat:@"%@(%lu/%ld)",languageStringWithKey(@"确定"),(unsigned long)_selectMembers.count,(long)count];
        [self setBarItemTitle:title titleColor:APPMainUIColorHexString target:self action:@selector(selectMemberFinish) type:NavigationBarItemTypeRight];
    }
    
}

- (void)didSelectPersonCell:(HYTSelectedMediaContactsCell *)dialingTableViewCell{
    UIButton* button = dialingTableViewCell.selectedButton;
    //    button.selected= !button.selected;
    [self selectedMediaContactsCell:dialingTableViewCell selected:!button.isSelected];
}

- (void)didSelectPersonCellWithHeadImg:(HYTSelectedMediaContactsCell *)dialingTableViewCell{
    NSDictionary * dataInfo = [_allMembersArray objectAtIndex:dialingTableViewCell.tag];
    [self pushViewController:@"RXContactorInfosViewController" withData:dataInfo[Table_User_account] withNav:YES];
}

//0,根据account获取，1根据手机号获取
-(NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type
{
    if (!Id) {
        return nil;
    }
    NSDictionary* dict = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressWithId:withType:" :[NSArray arrayWithObjects:Id,[NSNumber numberWithInt:type], nil]];
    return dict;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
    
    
}

#pragma mark 确定
-(void)selectMemberFinish{
    if ([AppModel sharedInstance].isInConf) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"当前正在会议中")];
        return ;
    }
    
    if (self.selectMembers.count == 0) {
        [UIAlertView showAlertView:languageStringWithKey(@"请选择参会人员") message:nil click:nil okText:languageStringWithKey(@"确定")];
        return;
    }
    
    if (self.conferenceType == 3) {
        [[AppModel sharedInstance] runModuleFunc:@"Vidyo" :@"vidyoConferenceSelectMembers:InConference:" :@[self.selectMembers,[NSNumber numberWithBool:self.isFromVideoMeeting]]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.conferenceType == 4) {
        NSMutableArray *userPhones = [NSMutableArray array];
        for (NSDictionary *dic in self.selectMembers) {
            NSString *account = [dic objectForKey:Table_User_account];
            [userPhones addObject:account];
        }
        NSDictionary *params = @{USERID: [[Chat sharedInstance] getAccount] ,
                                 PASSWORD:@"123456",
                                 ROOMTYPE:@"1",
                                 BOARDTYPE:@"0",
                                 USERS:userPhones,
                                 SendIMWhenExit:@"1",
                                 BOARDURL: [Chat sharedInstance].getBoardUrl};
        [[AppModel sharedInstance] runModuleFunc:@"Board":@"createBoardWithParams:andPresentVC:":@[params, self.chatVC]];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (self.isFromVoiceConfMeeting == 0) {
            if(self.isFromVideoMeeting){
                NSMutableArray * confMembers = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary * dic in self.selectMembers) {
                    if (![dic[Table_User_account] isEqualToString:[Common sharedInstance].getAccount]) {
                        ECAccountInfo *account = [[ECAccountInfo alloc] init];
                        account.accountType = ECAccountType_AppNumber;
                        account.accountId = dic[Table_User_account];
                        account.userName = dic[Table_User_member_name];
                        [confMembers addObject:account];
                    }
                }
                [[AppModel sharedInstance] runModuleFunc:@"FusionMeeting" :@"startConferenceWithMembers:" :@[confMembers] hasReturn:NO];
            }else{
                
                //音频会议要用手机号
                NSMutableArray *members = [NSMutableArray array];
                for (NSDictionary *dict in self.selectMembers) {
                    NSMutableDictionary *dictM = [dict mutableCopy];
                    NSString *account = dict[Table_User_account];
                    NSDictionary *personInfo = [self getDicWithId:account withType:0];
                    NSString *mobile = personInfo[Table_User_mobile];
                    [dictM setValue:mobile forKey:Table_User_mobile];
                    [dictM setValue:@"0" forKey:@"isVoip"];
                    //        [dictM removeObjectForKey:Table_User_account];
                    [members addObject:dictM];
                    
                }
                [[AppModel sharedInstance] runModuleFunc:@"NewVoiceMeeting" :@"startVoiceMeetingView:Type:" :@[members,[NSNumber numberWithInt:0]]];
            }
        } else {
            NSMutableArray *members = [NSMutableArray array];
            for (NSDictionary *dict in self.selectMembers) {
                NSMutableDictionary *dictM = [dict mutableCopy];
                NSString *account = dict[Table_User_account];
                NSDictionary *personInfo = [self getDicWithId:account withType:0];
                NSString *mobile = personInfo[Table_User_mobile];
                [dictM setValue:mobile forKey:Table_User_mobile];
                NSString *strIsVoip = [NSString stringWithFormat:@"%ld", (long)_isAppConf];
                [dictM setValue:strIsVoip forKey:@"isVoip"];
                [members addObject:dictM];
            }
            [[AppModel sharedInstance] runModuleFunc:@"VoiceMeeting" :@"startVoiceConfMeetingView:Type:" :@[members,[NSNumber  numberWithInteger:_isAppConf]]];
            
        }
        
        [self.navigationController.view removeFromSuperview];
        [Chat sharedInstance].groupListForMeeting = nil;
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
