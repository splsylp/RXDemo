//
//  SearchAllChatView.m
//  Chat
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "SearchAllChatView.h"
#import "NSAttributedString+Color.h"

#import "ChatSearchHeaderCard.h"
#import "SearchFooterCard.h"
#import "SearchContentCard.h"
#import "RecordsTableViewController.h"
#import "ChatViewController.h"
#import "SearchAllDetailResultPage.h"
#import "SearchPublicResultCard.h"
#import "GroupListCard.h"
#import "SearchResPersonCell.h"
#import "SessionViewController.h"

@interface SearchAllChatView ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong) UIView *noSearchResultView;//没有结果
@property(nonatomic,strong) UILabel *noResultlabel;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *searchChatText;
@property (nonatomic, strong) BaseViewController *currentSearchViewController;
@property (nonatomic, strong) NSMutableArray *sessions;

@property (nonatomic, strong) NSArray *dataSource;

@end


@implementation SearchAllChatView

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[];
    }
    return _dataSource;
}

#pragma mark - Init -
- (instancetype)init{
    if (self = [super init]) {
        [self internalInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self internalInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        [self internalInit];
    }
    return self;
}

- (void)internalInit{
    self.animationTime = 0.8;
    self.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = MainTheme_ViewBackgroundColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsMultipleSelection = NO;
    //    self.tableView.alwaysBounceVertical = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.tableView];
    self.tableView.hidden = NO;
    ///注册xib
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupListCard" bundle:nil] forCellReuseIdentifier:@"grouplistcard"];
    
    _noSearchResultView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    _noSearchResultView.backgroundColor = self.backgroundColor;
    [self addSubview:_noSearchResultView];
    
    _noResultlabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, kScreenHeight/3, 200, 25)];
    _noResultlabel.text = languageStringWithKey(@"无结果");
    _noResultlabel.backgroundColor = [UIColor clearColor];
    _noResultlabel.font = ThemeFontLarge;
    _noResultlabel.textColor = [UIColor colorWithRed:0.68f green:0.68f blue:0.68f alpha:1.00f];
    _noResultlabel.textAlignment = NSTextAlignmentCenter;
    [_noSearchResultView addSubview:_noResultlabel];
    _noSearchResultView.hidden = YES;
    //wwl 群组信息刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSessionGroup:) name:
     KNotice_ReloadSessionGroup object:nil];
}

//wwl
//刷新沟通界面显示群组信息
- (void)reloadSessionGroup:(NSNotification *)not{
    NSString *groupId = not.object;
    if (KCNSSTRING_ISEMPTY(groupId)) {
        [self.tableView reloadData];
    }else{
        for (UITableViewCell *cell in [_tableView visibleCells]) {
            if ([cell isKindOfClass:[GroupListCard class]]) {
                if ([[[(GroupListCard *)cell group] groupId] isEqualToString:groupId]) {
                    [(GroupListCard *)cell reloadImage];
                }
            }
            //            else if ([cell isKindOfClass:[SearchContentCard class]]) {
            //                if ([[[(SearchContentCard *)cell session] sessionId] isEqualToString:groupId]) {
            //                    [self loadGroupHeadImage:(SearchContentCard *)cell withGroupId:groupId];
            //                }
            //            }
        }
    }
}

- (void)loadCardView {
    [self.tableView reloadData];
}

- (void)reloadSearchText:(NSString *)text withSessions:(NSMutableArray *)sessions withVC:(BaseViewController *)currentVC withSearchB:(UISearchBar *)searcB {
    _sessions = [NSMutableArray arrayWithArray:sessions];
    _currentSearchViewController = currentVC;
    _searchChatText = text;
    _textF = searcB;
    
    self.tableView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
//    self.transform = CGAffineTransformMakeTranslation(0, -(kScreenHeight-kTotalBarHeight-44));
    if (isLargeAddressBookModel) {
        [SVProgressHUD showWithStatus:nil];
    }
    [[Common sharedInstance] searchWithType:RXSearchTypeChat keyword:text otherData:@{@"array":sessions} completed:^(id response, NSError *error) {
        [SVProgressHUD dismiss];
        NSArray *arr = response;
        self.dataSource = arr;
        if ([text isEqualToString:@""]) {
            self.tableView.hidden = NO;
            self.noSearchResultView.hidden = YES;
            [self loadCardView];
        } else {
            if (arr.count > 0) {
                self.tableView.hidden = NO;
                self.noSearchResultView.hidden = YES;
                [self loadCardView];
            }else{
                self.tableView.hidden = YES;
                self.noSearchResultView.hidden = NO;
            }
        }
    }];
}

- (void)dismissThePopView{
    [UIView animateWithDuration:self.animationTime animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataSource;
    //做一点非空判断
    if (section >= array.count) {
        return 0;
    }
    //例子 @{@"data":@[],@"footerTitle":@"更多",@"key":SearchPart,@"title":@""}
    NSDictionary *homePart = [array objectAtIndex:section];
    NSArray *dataArr = homePart[@"data"];
    if (dataArr.count > 3) {
        return 4;
    } else{
        return dataArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //例子 @{@"data":@[],@"footerTitle":@"更多",@"key":SearchPart,@"title":@""}
    if (self.dataSource.count<=0) {
        return UITableViewCell.new;
    }
    NSDictionary *homePart = [self.dataSource objectAtIndex:indexPath.section];
    NSArray *dataArr = homePart[@"data"];
    SearchPart partKey = [homePart[@"key"] integerValue];
    if (indexPath.row == 3) {//大于3时 最后一个cell 为查看更多
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = ThemeFontLarge;
        cell.textLabel.text = homePart[@"footerTitle"];
        return cell;
    } else {
        if (partKey == SEARCH_CHAT_PERSON) {//联系人
            GroupListCard *groupCell = [tableView dequeueReusableCellWithIdentifier:@"grouplistcard"];
            groupCell.currentSearchText = self.searchChatText;
            
            NSDictionary *searchPersonDict = dataArr[indexPath.row];
            if ([searchPersonDict isKindOfClass:[KitCompanyAddress class]] && isLargeAddressBookModel) {
                KitCompanyAddress *address = (KitCompanyAddress *)searchPersonDict;
                groupCell.address = address;
                return groupCell;
            }
            
            NSDictionary *dict = nil;
            NSString *mobileStr = @"";
            NSString *accountStr = @"";
            if ([searchPersonDict isKindOfClass:[KitCompanyAddress class]]) {
                KitCompanyAddress *address = (KitCompanyAddress *)searchPersonDict;
                mobileStr = address.mobilenum;
                accountStr = address.account;
            }else{
                mobileStr = searchPersonDict[@"mobile"];
                accountStr = searchPersonDict[@"account"];
            }
            
            if(isSearchIndex_Account){
                dict = [[Chat sharedInstance].componentDelegate getDicWithId:accountStr?accountStr:mobileStr withType:0];
            }else{
                dict = [[Chat sharedInstance].componentDelegate getDicWithId:accountStr?accountStr:mobileStr withType:1];
            }
            
            /// eagle 这里取值为空，另外取值
            if (!dict) {
                DDLogInfo(@"获取数据为空");
                dict = [[Chat sharedInstance].componentDelegate getDicWithId:accountStr?accountStr:mobileStr withType:!isSearchIndex_Account?0:1];
                
            }
            groupCell.contactDic = dict;
            return groupCell;
        }else if (partKey == SEARCH_CHAT_GROUPS) {//群组
            GroupListCard *groupCell = [tableView dequeueReusableCellWithIdentifier:@"grouplistcard"];
            groupCell.currentSearchText = self.searchChatText;
            groupCell.group = dataArr[indexPath.row];
            return groupCell;
        }else{
            //聊天记录 partKey == SEARCH_CHAT_RECORD
            GroupListCard *groupCell = [tableView dequeueReusableCellWithIdentifier:@"grouplistcard"];
            groupCell.currentSearchText = self.searchChatText;
            groupCell.recordDic = dataArr[indexPath.row];
            return groupCell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataSource.count<=0) {
        return nil;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 44)];
    nameLabel.font = ThemeFontMiddle;
    nameLabel.textColor = [UIColor lightGrayColor];
    [headerView addSubview:nameLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 43, kScreenWidth - 30, 1)];
    lineView.backgroundColor = ColorEFEFEF;
    [headerView addSubview:lineView];
    
    //例子 @{@"data":@[],@"footerTitle":@"更多",@"key":SearchPart,@"title":@""}
    NSDictionary *homePart = [self.dataSource objectAtIndex:section];
    nameLabel.text = homePart[@"title"];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {//大于3时 最后一个cell 为查看更多
        return 44.0f;
    }else{
        return 60.0f*FitThemeFont;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //例子 @{@"data":@[],@"footerTitle":@"更多",@"key":SearchPart,@"title":@""}
    NSDictionary *homePart = [self.dataSource objectAtIndex:indexPath.section];
    NSArray *dataArr = homePart[@"data"];
    SearchPart partKey = [[homePart objectForKey:@"key"] integerValue];
    //收键盘
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    if (indexPath.row == 3) {//更多
        NSDictionary *dic = @{@"homeData": homePart, @"fromPage":[NSNumber numberWithInteger:partKey], @"session":_sessions,@"title":homePart[@"title"], @"searchT":_searchChatText};
        if (partKey == SEARCH_CHAT_PERSON) {//联系人
            [self.currentSearchViewController pushViewController:@"SearchAllDetailResultPage" withData:dic];
        } else if (partKey == SEARCH_CHAT_GROUPS) {//群组
            [self.currentSearchViewController pushViewController:@"SearchAllDetailResultPage" withData:dic];
        } else if (partKey == SEARCH_CHAT_RECORD) {//聊天记录
            [self.currentSearchViewController pushViewController:@"SearchAllDetailResultPage" withData:dic];
        }
    } else {
        if (partKey == SEARCH_CHAT_PERSON) {//联系人
            NSDictionary *searchPersonDict = dataArr[indexPath.row];
            NSDictionary *dic = nil;
            
            NSString *mobileStr = @"";
            
            if ([searchPersonDict isKindOfClass:[KitCompanyAddress class]]) {
                KitCompanyAddress *address = (KitCompanyAddress *)searchPersonDict;
                if (isLargeAddressBookModel) {//将此人入库
                    [[KitCompanyAddress sharedInstance] updateCompanyAddressInfoDataDB:address];
                }
                if ([[Common sharedInstance] canChat:address.personLevel account:address.account]) {
                    ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:address.account];
                    [self.currentSearchViewController pushViewController:chatVC];
                }else {
                    [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"没有沟通权限")];
                }
                return;
            }else{
                mobileStr = searchPersonDict[@"mobile"];
            }
            
            dic = [[Chat sharedInstance].componentDelegate getDicWithId:mobileStr withType:isSearchIndex_Account?0:1];
            
            if ([dic[Table_User_account] isEqualToString:[[Chat sharedInstance] getAccount]]) {
                return;
            }
            BOOL isMyFriend = [HXMyFriendList isMyFriend:dic[Table_User_account]];
            //            NSInteger userLevel = [dic[Table_User_Level] integerValue];
            //            NSInteger myLevel = [[Common sharedInstance].getUserLevel integerValue];
            //            if ( isMyFriend || [dic[Table_User_account] isEqualToString:[Common sharedInstance].getAccount]) {
            
            
            ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:dic[Table_User_account]];
            [self.currentSearchViewController pushViewController:chatVC];
            //            } else {
            //                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"请添加好友")];
            //                UIViewController *contactorInfosVC = [[Chat sharedInstance].componentDelegate getContactorInfosVCWithData:dic[Table_User_account]];
            //                [self.currentSearchViewController pushViewController:contactorInfosVC];
            //            }
        } else if (partKey == SEARCH_CHAT_GROUPS) {//群组
            ECGroup *searchPersonGroup =  dataArr[indexPath.row];
            //聊天界面入口
            BaseViewController *chatVC = [[AppModel sharedInstance] runModuleFunc:@"Chat" :@"getChatViewControllerWithSessionId:" :@[searchPersonGroup.groupId]];
            chatVC.data = searchPersonGroup;
            if (chatVC) {
                UIViewController *sessionVC;
                if (self.currentSearchViewController.navigationController.childViewControllers.count > 0) {
                    sessionVC = self.currentSearchViewController.navigationController.childViewControllers[0];
                }
                if (sessionVC && [sessionVC isKindOfClass:[SessionViewController class]]) {
                    [self.currentSearchViewController.navigationController popToViewController:sessionVC animated:NO];
                    [sessionVC.navigationController pushViewController:chatVC animated:YES];
                } else{
                    [self.currentSearchViewController pushViewController:chatVC];
                }
            }
        } else if (partKey == SEARCH_CHAT_RECORD) {//聊天记录
            NSDictionary *searchDict = dataArr[indexPath.row];
            NSArray *searchMessageArr = searchDict[@"searchMessageArr"];
            ECSession *session = searchDict[@"searchSession"];
            if (searchMessageArr.count > 1) {//进入历史页面
                RecordsTableViewController *recordsVC = [[RecordsTableViewController alloc] initWithSession:session andSearchStr:self.searchChatText andMessageArr:searchMessageArr];
                [self.currentSearchViewController pushViewController:recordsVC];
            }else{
                //聊天界面入口
                ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:session.sessionId andRecodMessage:searchMessageArr.firstObject];
                chatVC.dataSearchFrom = @{@"fromePage":@"searchDetail"};
                [self.currentSearchViewController pushViewController:chatVC];
            }
        }
    }
}

#pragma privite method -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didScrollRegisBoad)]) {
        [self.delegate didScrollRegisBoad];
    }
}

- (void)dismissKeyboard {
    if ([_textF isFirstResponder]) {
        [_textF resignFirstResponder];
    }
}

- (NSDictionary *)getShareCard:(NSString *)message{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dict;
}

@end
