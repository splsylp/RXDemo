//
//  SearchAllDetailResultPage.m
//  Chat
//
//  Created by mac on 2017/4/23.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "SearchAllDetailResultPage.h"
#import "NSAttributedString+Color.h"
#import "ChatViewController.h"
#import "ChatSearchHeaderCard.h"
#import "SearchFooterCard.h"
#import "SearchContentCard.h"
#import "RecordsTableViewController.h"
#import "SearchPublicResultCard.h"
#import "GroupListCard.h"


#define requestFristCount   10
#define loadMorePublicCount   10

@interface SearchAllDetailResultPage ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate>{
    UISearchBar * searchbar;
    BOOL  isSearchResult;//是否是搜索结果
    BOOL isNoMoreData;//没有更多数据了
}

@property(nonatomic,strong)UITableView *searchTableView;
@property(nonatomic,strong)UIView *noSearchResultView;//没有结果
@property(nonatomic,strong)UILabel *noResultlabel;
@property(nonatomic,strong)UIView *footView;
@property(nonatomic,strong)UILabel * textLable;
@property (nonatomic, strong) UIActivityIndicatorView  *loadMoreActivityView;
@property (nonatomic, assign) BOOL  isLoadMoreMessage;//是否正在加载

@property (nonatomic, strong) NSString *searchChatText;
@property (nonatomic, strong) NSMutableArray *dataLists;
@property (nonatomic, strong) NSMutableDictionary *dataDic;

///大通讯录使用
@property(nonatomic ,assign) NSInteger page;

@end

@implementation SearchAllDetailResultPage

//懒加载
- (NSMutableArray *)dataLists{
    if (_dataLists == nil) {
        _dataLists = [NSMutableArray new];
    }
    return _dataLists;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.transform = CGAffineTransformIdentity;

    self.view.backgroundColor = RGBA(238, 238, 238, 1.0);
    [self setBarItemTitle:languageStringWithKey(@"取消") titleColor:ThemeColor target:self action:@selector(backView)];
    
    NSDictionary *dic = self.data[@"homeData"];
    _dataDic = [NSMutableDictionary dictionaryWithDictionary:self.data];
    _fromSelect = [self.data[@"fromPage"] integerValue];
    _searchChatText = self.data[@"searchT"];
    [self createSearchBar];
    [self initUI];
    //wwl 群组信息刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSessionGroup:) name:KNotice_ReloadSessionGroup object:nil];
    if (isLargeAddressBookModel && _fromSelect == SEARCH_CHAT_PERSON) {
        [self loadData];
    }else{
        self.dataLists = [NSMutableArray arrayWithArray:dic[@"data"]];
        [self.searchTableView reloadData];
    }
}

- (void)initUI{
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight) style:UITableViewStylePlain];
    self.searchTableView.backgroundColor = self.view.backgroundColor;
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    self.searchTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.searchTableView];
    self.searchTableView.hidden = NO;
    ///注册xib
    [self.searchTableView registerNib:[UINib nibWithNibName:@"GroupListCard" bundle:nil] forCellReuseIdentifier:@"grouplistcard"];
    
    [self initTableViewFootView];
    
    _noSearchResultView = [[UIView alloc] initWithFrame:self.searchTableView.bounds];
    _noSearchResultView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_noSearchResultView];
    
    _noResultlabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, kScreenHeight/3, 200, 25)];
    _noResultlabel.text = languageStringWithKey(@"无结果");
    _noResultlabel.backgroundColor = [UIColor clearColor];
    _noResultlabel.font = ThemeFontLarge;
    _noResultlabel.textColor = [UIColor colorWithRed:0.68f green:0.68f blue:0.68f alpha:1.00f];
    _noResultlabel.textAlignment = NSTextAlignmentCenter;
    [_noSearchResultView addSubview:_noResultlabel];
    _noSearchResultView.hidden = YES;

    [self setupTableViewHeader:YES footer:YES];
}
- (void)initTableViewFootView{
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTotalBarHeight)];
    _footView.backgroundColor = _searchTableView.backgroundColor;
    _footView.tag = 101;
    _textLable = [[UILabel alloc] init];
    _textLable.text = languageStringWithKey(@"正在搜索");
    _textLable.bounds = CGRectMake(0, 0, 70, 40);
    _textLable.center = _footView.center;
    _textLable.textAlignment = NSTextAlignmentCenter;
    _textLable.font = ThemeFontLarge;
    _loadMoreActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadMoreActivityView.center = CGPointMake(CGRectGetMinX(_textLable.frame)-10, _footView.center.y);
    _loadMoreActivityView.bounds = CGRectMake(0, 0, 20, 20);
    [_footView addSubview:_textLable];
    // [_loadMoreActivityView startAnimating];
    [_footView addSubview:_loadMoreActivityView];
}
- (void)createSearchBar{
    searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 68, 44)];
    searchbar.delegate = self;
    if (_fromSelect == 0) {
        searchbar.placeholder = languageStringWithKey(@"搜索联系人");
    }else if (_fromSelect == 1 || _fromSelect == 5) {
        searchbar.placeholder = languageStringWithKey(@"搜索群组");
    } else if (_fromSelect == 2) {
        searchbar.placeholder = languageStringWithKey(@"搜索聊天记录");
    }else if (_fromSelect == 3) {
        searchbar.placeholder = languageStringWithKey(@"搜索服务号");
    }
    searchbar.text = self.data[@"searchT"];
    
    [searchbar setBackgroundImage:[UIColor createImageWithColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [searchbar setImage:ThemeImage(@"搜索公众号.png") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    //    [searchbar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [searchbar sizeToFit];
    
    //    [searchbar layoutSubviews];
    //    searchbar.backgroundColor = [UIColor clearColor];
    //searchbar.tintColor =UIColorFromRGB(0x62b651);//光标颜色
    //[searchbar setContentMode:UIViewContentModeLeft];
    searchbar.keyboardType = UIKeyboardAppearanceDefault;
//    [searchbar becomeFirstResponder];

    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:searchbar];
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (iOS11) {
        negativeSeperator.width = -10;
    } else {
        //ios10系统下搜索框会往左偏移
        negativeSeperator.width = 10;
    }
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSeperator, buttonItem, nil];
}
#pragma backView
- (void)backView{
    [searchbar resignFirstResponder];
    [super popViewController];
}

#pragma resignFirstResponder
- (void)cancelResignFirstResponder{
    [searchbar resignFirstResponder];
}
///请求联系人信息
- (void)loadData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[@"selectIndex"] = @(_fromSelect);
    dic[@"array"] = self.data[@"session"];
    dic[@"page"] = @(self.page);
    dic[@"pageSize"] = @(20);

    if (isLargeAddressBookModel) {
        [SVProgressHUD showWithStatus:nil];
    }
    [[Common sharedInstance] searchWithType:RXSearchTypeChatDetail keyword:self.searchChatText otherData:dic completed:^(id response, NSError *error) {
        [SVProgressHUD dismiss];
        if ([response[0] isKindOfClass:[KitCompanyAddress class]]) {
            [self.searchTableView.mj_header endRefreshing];
            [self.searchTableView.mj_footer endRefreshing];
            NSArray<KitCompanyAddress *> *dataArr = response;
            if (self.page == 0) {
                [self.dataLists removeAllObjects];
            }
            [self.dataLists addObjectsFromArray:dataArr];
            if (dataArr.count < 20) {
                [self.searchTableView.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            [self.dataLists removeAllObjects];
            NSDictionary *dic = [response firstObject];
            if (dic) {
                self.dataLists = [NSMutableArray arrayWithArray:dic[@"data"]];
            } else {
                self.dataLists = nil;
            }
        }
        if (self.dataLists.count > 0) {
            self.noSearchResultView.hidden = YES;
        } else{
            self.noSearchResultView.hidden = NO;
        }
        self.page++;
        [self.searchTableView reloadData];
    }];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataLists.count == 0) {
        return 0;
    }
    return self.dataLists.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {//组头
        static NSString *headerMessageCellid = @"headerCell";
        ChatSearchHeaderCard *cell = [tableView dequeueReusableCellWithIdentifier:headerMessageCellid];
        if (cell == nil) {
            cell = [[ChatSearchHeaderCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerMessageCellid];
        }
        cell.headerTitleText = [_dataDic objectForKey:@"title"];
        return cell;
    } else {
        if (_fromSelect == SEARCH_CHAT_PERSON) {//联系人
            GroupListCard *groupCell = [tableView dequeueReusableCellWithIdentifier:@"grouplistcard"];
            groupCell.currentSearchText = self.searchChatText;

            NSDictionary *searchPersonDict = _dataLists[indexPath.row - 1];
            if ([searchPersonDict isKindOfClass:[KitCompanyAddress class]] && isLargeAddressBookModel) {
                KitCompanyAddress *address = (KitCompanyAddress *)searchPersonDict;
                groupCell.address = address;
                return groupCell;
            }
            NSDictionary *dict = nil;
            NSString *mobileStr = @"";
            NSString *accountStr = @"";
            int type = 1;
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
        }else if (_fromSelect == SEARCH_CHAT_GROUPS){//群组
            GroupListCard *groupCell = [tableView dequeueReusableCellWithIdentifier:@"grouplistcard"];
            groupCell.currentSearchText = self.searchChatText;
            groupCell.group = _dataLists[indexPath.row - 1];
            return groupCell;
        }else{//聊天记录 _fromSelect == SEARCH_CHAT_RECORD
            GroupListCard *groupCell = [tableView dequeueReusableCellWithIdentifier:@"grouplistcard"];
            groupCell.currentSearchText = self.searchChatText;
            groupCell.recordDic = _dataLists[indexPath.row - 1];
            return groupCell;
        }
//        else if (_fromSelect == SEARCH_CHAT_GROUP) {//群聊
//            static NSString *contentMessageCellid = @"searchGroupContentCell";
//            SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
//            if (cell == nil) {
//                cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
//                cell.backgroundColor = [UIColor clearColor];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleGray;
//            cell.portraitImg.hidden = NO;
//            cell.groupHeadView.hidden = YES;
//            NSDictionary *groupsMem = [_dataLists objectAtIndex:indexPath.row - 1];
//            ECGroup *group = groupsMem[@"group"];
//            ECGroupMember *memberGroup = groupsMem[@"groupMember"];
//            [self loadGroupAddress:cell withSessionId:group.groupId withDisplay:memberGroup.display];
//            return cell;
//        }else if (_fromSelect == SEARCH_CHAT_FRIENDCIRCLE) {//同事圈
//            static NSString *contentMessageCellid = @"searchFriendCirclesContentCell";
//            SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
//            if (cell == nil) {
//                cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleGray;
//            cell.portraitImg.hidden = NO;
//            cell.groupHeadView.hidden = YES;
//
//            NSDictionary *friendDic = [_dataLists objectAtIndex:indexPath.row - 1];
//            NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:friendDic[@"sender"] withType:0];
//            return  [self fillFriendsCellWithIndexPath:indexPath withDic:dic withFriend:friendDic];
//        }else {//公众号等
//            static NSString *contentMessageCellid = @"searchGContentCell";
//            SearchPublicResultCard *cell =[tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
//            if(!cell){
//                cell = [[SearchPublicResultCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
//            }
//            cell.backgroundColor = [UIColor whiteColor];
//            NSDictionary *publicDic = [_dataLists objectAtIndex:indexPath.row - 1];
//            [cell setPublicSearchDic:publicDic cellIndex:indexPath searchString:_searchChatText];
//            return cell;
//        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {//组头
        return 44.0f;
    } else {
        return 60.0f * FitThemeFont;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if (indexPath.row == 0) {
        return;
    }
    if (_fromSelect == SEARCH_CHAT_PERSON) {//联系人
        NSDictionary *searchPersonDict =  [_dataLists objectAtIndex:indexPath.row - 1];
        NSDictionary *dic = nil;
        
        NSString *mobileStr = @"";
        
        if ([searchPersonDict isKindOfClass:[KitCompanyAddress class]]) {
            KitCompanyAddress *address = (KitCompanyAddress *)searchPersonDict;
            if (isLargeAddressBookModel) {//将此人入库
                [[KitCompanyAddress sharedInstance] updateCompanyAddressInfoDataDB:address];
            }
            if ([[Common sharedInstance] canChat:address.personLevel account:address.account]) {
                ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:address.account];
                [self pushViewController:chatVC];
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
        ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:dic[Table_User_account]];
        chatVC.dataSearchFrom = @{@"fromePage":@"searchDetail"};
        [self pushViewController:chatVC];
    }else if (_fromSelect == SEARCH_CHAT_GROUPS) {//群组
        ECGroup *searchPersonGroup =  _dataLists[indexPath.row - 1];
        //聊天界面入口
        BaseViewController *chatVC = [[AppModel sharedInstance] runModuleFunc:@"Chat" :@"getChatViewControllerWithSessionId:" :@[searchPersonGroup.groupId]];
        chatVC.data = searchPersonGroup;
        [self pushViewController:chatVC];
    }else if (_fromSelect == SEARCH_CHAT_RECORD) {//聊天记录
        NSDictionary *searchDict =  [_dataLists objectAtIndex:indexPath.row - 1];
        NSArray *searchMessageArr = searchDict[@"searchMessageArr"];
        ECSession *session = searchDict[@"searchSession"];
        if (searchMessageArr.count > 1) {//进入历史页面
            RecordsTableViewController *recordsVC = [[RecordsTableViewController alloc] initWithSession:session andSearchStr:self.searchChatText andMessageArr:searchMessageArr];
            [self pushViewController:recordsVC];
        }else{
            //聊天界面入口
            ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:session.sessionId andRecodMessage:searchMessageArr.firstObject];
            chatVC.dataSearchFrom = @{@"fromePage":@"searchDetail"};
            [self pushViewController:chatVC];
        }
    }
//    else if (_fromSelect == SEARCH_CHAT_GROUP) {//群聊
//        NSDictionary *groupsMem =  [_dataLists objectAtIndex:indexPath.row - 1];
//        ECGroup *group = groupsMem[@"group"];
//        //            ECGroupMember *memberGroup = groupsMem[@"groupMember"];
//        ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:group.groupId];
//        [self pushViewController:chatVC];
//    }else {//公众号等
//        NSDictionary *publicDic = [_dataLists objectAtIndex:indexPath.row - 1];
//        [self pushViewController:@"HXPublicDetailsViewController" withData: @{@"style":@"fromSearchIMPublic",@"PublicNumDic":publicDic}  withNav:YES];
//    }
}

#pragma privite method -

//wwl 刷新沟通界面显示群组信息
- (void)reloadSessionGroup:(NSNotification *)not{
    NSString *groupId = not.object;
    if (KCNSSTRING_ISEMPTY(groupId)) {
        [self.searchTableView reloadData];
    }else{
        for (UITableViewCell *cell in [_searchTableView visibleCells]) {
            if ([cell isKindOfClass:[GroupListCard class]]) {
                if ([[[(GroupListCard *)cell group] groupId] isEqualToString:groupId]) {
                    [(GroupListCard *)cell reloadImage];
                }
            }
//            if ([cell isKindOfClass:[SearchContentCard class]]) {
//                if ([[[(SearchContentCard *)cell session] sessionId] isEqualToString:groupId]) {
//                    [self loadGroupHeadImage:(SearchContentCard *)cell withGroupId:groupId];
//                }
//            }
        }
    }
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchBar.text.length == 0){
        [self changeSomeStateAndUI];
        return;
    }
    self.searchTableView.tableFooterView = [[UIView alloc] init];
    self.searchChatText = searchBar.text;
    self.page = 0;
    ///请求数据
    [self loadData];
}

//cancel button clicked...
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self backView];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!iOS13) {    
        UIButton *cancelButton = [searchBar valueForKey:@"_cancelButton"];
        [cancelButton setTitleColor:ThemeColor forState:UIControlStateNormal];
    }
}



#pragma netWorkRequestData
- (void)searchPublicData{
//    if(KCNSSTRING_ISEMPTY(_searchString))
//    {
//        [self showCustomToast:@"请输入搜索内容"];
//        return;
//    }
//    
//    [self showProgressWithMsg:nil];
//    __weak typeof(self)weak_self =self;
//    [self cancelResignFirstResponder];
//    isNoMoreData=NO;
//    [HYTApiClient getPublicSearchDataSig:kPublicSigStr account:kPublicAccount searchStr:_searchString  publicId:0 limit:requestFristCount didFinishLoadedMK:^(NSDictionary *json, NSString *path) {
//        
//        // KXJson* head = [json getJsonForKey:@"head"];
//        NSString *statuscode = [json objectForKey:@"statusCode"];
//        
//        [weak_self closeProgress];
//        if([statuscode isEqualToString:@"000000"])
//        {
//            id data =[json objectForKey:@"data"];
//            if([data isKindOfClass:[NSString class]])
//            {
//                return ;
//            }
//            
//            NSArray *searArray =(NSArray *)data;
//            
//            if(searArray.count>0)
//            {
//                if(searArray.count>=requestFristCount)
//                {
//                    [weak_self modifyPromptLoading:NO withPromptStr:@"正在搜索"];
//                    _searchTableView.tableFooterView=_footView;
//                }
//                weak_self.searchTableView.hidden=NO;
//                weak_self.noSearchResultView.hidden=YES;
//                [_searchArray removeAllObjects];
//                weak_self.searchArray =[NSMutableArray arrayWithArray:searArray];
//                [weak_self.searchTableView setContentOffset:CGPointMake(0,0) animated:NO];
//                [weak_self.searchTableView reloadData];
//                
//                
//            }else
//            {
//                weak_self.searchTableView.tableFooterView =[[UIView alloc]init];
//                weak_self.searchTableView.hidden=YES;
//                weak_self.noSearchResultView.hidden=NO;
//                weak_self.noResultlabel.text=@"无结果";
//            }
//        }else
//        {
//            NSString *statu = [json objectForKey:@"status"];
//            if([statu isEqualToString:@"618999"]){
//                weak_self.searchTableView.tableFooterView =[[UIView alloc]init];
//                weak_self.searchTableView.hidden=YES;
//                weak_self.noSearchResultView.hidden=NO;
//                weak_self.noResultlabel.text=@"无结果";
//            }else{
//                NSString *msgError =[json objectForKey:@"msg"];
//                [ATMHud showMessage:msgError?msgError:@"查询失败"];
//            }
//        }
//        
//    } didFailLoadedMK:^(NSError *error, NSString *path) {
//        [weak_self closeProgress];
//        [weak_self showProgressWithMsg:path];
//        weak_self.searchTableView.tableFooterView =[[UIView alloc]init];
//        weak_self.searchTableView.hidden=YES;
//        weak_self.noSearchResultView.hidden=NO;
//        weak_self.noResultlabel.text=@"无法连接网络";
//    }];
}

//加载更多数据
- (void)loadMoreData{
//    if(_dataLists.count>0)
//    {
//        NSDictionary *lastDic =_dataLists.lastObject;
//        __weak typeof(self)weak_self =self;
//        isNoMoreData =NO;
//        [HYTApiClient getPublicSearchDataSig:kPublicSigStr account:kPublicAccount searchStr:_searchString publicId:[lastDic integerValueForKey:@"id"] limit:loadMorePublicCount didFinishLoadedMK:^(NSDictionary *json, NSString *path) {
//            
//            // KXJson* head = [json getJsonForKey:@"head"];
//            NSString *statuscode = [json objectForKey:@"statusCode"];
//            
//            weak_self.isLoadMoreMessage=NO;
//            
//            // [weak_self closeProgress];
//            if([statuscode isEqualToString:@"000000"])
//            {
//                id data =[json objectForKey:@"data"];
//                if([data isKindOfClass:[NSString class]])
//                {
//                    return ;
//                }
//                
//                NSArray *searArray =(NSArray *)data;
//                
//                if(searArray.count>0)
//                {
//                    if(searArray.count<loadMorePublicCount)
//                    {
//                        isNoMoreData =YES;
//                        [weak_self modifyPromptLoading:YES withPromptStr:@"没有更多的搜索结果"];
//                    }
//                    
//                    [weak_self.searchArray addObjectsFromArray:searArray];
//                    [weak_self.searchTableView reloadData];
//                }else
//                {
//                    isNoMoreData =YES;
//                    [weak_self modifyPromptLoading:YES withPromptStr:@"没有更多的搜索结果"];
//                }
//            }
//        } didFailLoadedMK:^(NSError *error, NSString *path) {
//            [weak_self showProgressWithMsg:path];
//            weak_self.isLoadMoreMessage=NO;
//        }];
//    }
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [searchbar resignFirstResponder];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.isDragging && _searchTableView.tableFooterView.tag == 101) {
        if (scrollView.contentOffset.y >= fmaxf(.0f, scrollView.contentSize.height - scrollView.frame.size.height) + 5 && !isNoMoreData && _dataLists.count>=requestFristCount){
            if (!_isLoadMoreMessage) {
                self.isLoadMoreMessage = YES;
                [self loadMoreData];
            }
        }
    }
}
- (void)setIsLoadMoreMessage:(BOOL)isLoadMoreMessage{
    if(isLoadMoreMessage){
        [_loadMoreActivityView startAnimating];
    }else{
        [_loadMoreActivityView stopAnimating];
    }
    _isLoadMoreMessage=isLoadMoreMessage;
}
#pragma change _loadMoreActivityView state and text
- (void)modifyPromptLoading:(BOOL)isHidden withPromptStr:(NSString *)promptStr{
    if(isHidden){
        //_textLable.width=150;
        _textLable.bounds = CGRectMake((kScreenWidth-150)/2, 0, 150, 40);
    }else{
        //_textLable.width=70;
        _textLable.bounds = CGRectMake((kScreenWidth-70)/2, 0, 70, 40);
    }
    _loadMoreActivityView.hidden = isHidden;
    _textLable.text = promptStr;
}
//设置一些状态 以及数据清除等
- (void)changeSomeStateAndUI{
    self.searchChatText = @"";
    [_dataLists removeAllObjects];
    isNoMoreData =NO;
    self.searchTableView.hidden=NO;
    self.searchTableView.tableFooterView =[[UIView alloc]init];
    self.noSearchResultView.hidden=YES;
    [self.searchTableView reloadData];
    [self.searchTableView.mj_footer endRefreshingWithNoMoreData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}
- (void)setupTableViewHeader:(BOOL)header footer:(BOOL)footer {//
    if (!isLargeAddressBookModel || _fromSelect != SEARCH_CHAT_PERSON) {
        return;
    }
    MJWeakSelf;
    if (header) {
        MJRefreshNormalHeader *headerRefresh = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.page = 0;
            [weakSelf loadData];
        }];
        self.searchTableView.mj_header = headerRefresh;
    } else {
        self.searchTableView.mj_header = nil;
    }
    if (footer) {
        MJRefreshAutoNormalFooter *footerRefresh = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf loadData];
        }];
        [footerRefresh setTitle:@"" forState:MJRefreshStateNoMoreData];
        self.searchTableView.mj_footer = footerRefresh;
    } else {
        self.searchTableView.mj_footer = nil;
    }
}




//群聊里的人
//- (SearchContentCard *)loadGroupAddress:(SearchContentCard *)cell withSessionId:(NSString *)groupId withDisplay:(NSString *)display{
//    cell.nameLabel.text = [[Common sharedInstance] getOtherNameWithPhone:groupId];
//    [self loadGroupHeadImage:cell withGroupId:groupId];
//    cell.contentLabel.text = display;
//    return cell;
//}
//
//- (void)loadGroupHeadImage:(SearchContentCard *)cell withGroupId:(NSString *)groupId{
//    cell.portraitImg.image = ThemeImage(@"icon_groupdefaultavatar");
//
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSArray *members = [KitGroupMemberInfoData getSequenceMembersforGroupId:groupId memberCount:9];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(members.count == 1){
//                KitGroupMemberInfoData *info = members.firstObject;
//                if([info.role isEqualToString:@"1"] ||
//                   [info.role isEqualToString:@"2"]){
//                    cell.portraitImg.image = ThemeImage(@"icon_groupdefaultavatar");
//                    return;
//                }
//            }
//            if(members.count > 1){
//                //直接加载头像 先查看本地 后加载网络
//                cell.portraitImg.hidden = YES;
//                cell.groupHeadView.hidden=NO;
//                [cell.groupHeadView createHeaderViewH:cell.portraitImg.width withImageWH:cell.portraitImg.width groupId:groupId withMemberArray:members];
//            }else{
//                if ([[Common sharedInstance].cacheGroupMemberRequestArray containsObject:groupId]) {
//                    return;
//                }else{
//                    [[Common sharedInstance].cacheGroupMemberRequestArray addObject:groupId];
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        [[ECDevice sharedInstance].messageManager queryGroupMembers:groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
//                            [[Common sharedInstance].cacheGroupMemberRequestArray removeObject:groupId];
//                            if (error.errorCode == ECErrorType_NoError && members.count>0) {
//                                [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
//                                [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
//                                //wwl 群组头像刷新改为通知
//                                [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:groupId];
//                            }
//                        }];
//                    });
//                }
//            }
//        });
//    });
//}
/////同事圈
//- (UITableViewCell *)fillFriendsCellWithIndexPath:(NSIndexPath *)indexPath withDic:(NSDictionary *)companyInfo withFriend:(NSDictionary *)friendDic{
//    UITableViewCell *cell = (UITableViewCell *)[self.searchTableView dequeueReusableHeaderFooterViewWithIdentifier:@"searchFriendContentCell"];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchFriendContentCell"];
//        UIImageView *picImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
//        picImage.tag = 100;
//        picImage.layer.cornerRadius = picImage.frame.size.width/2;
//        picImage.layer.masksToBounds = YES;
//        picImage.contentMode = UIViewContentModeScaleAspectFill;
//        [cell.contentView addSubview:picImage];
//
//        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 80, 20)];
//        nameLab.font = ThemeFontLarge;
//        nameLab.tag = 101;
//        [cell.contentView addSubview:nameLab];
//
//        UILabel *positionLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.right+10, 5, 150, 20)];
//        positionLab.tag=103;
//        positionLab.textColor=[UIColor lightGrayColor];
//        positionLab.font = ThemeFontLarge;
//        positionLab.backgroundColor =[UIColor clearColor];
//        [cell.contentView addSubview:positionLab];
//
//        UILabel *phoneNumLab = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 100, 16)];
//        phoneNumLab.tag = 102;
//        phoneNumLab.font = ThemeFontMiddle;
//        phoneNumLab.textColor = [UIColor lightGrayColor];
//        [cell.contentView addSubview:phoneNumLab];
//        // 分割线
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(picImage.right, 54, kScreenWidth-picImage.right, 1)];
//        lineView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
//        [cell.contentView addSubview:lineView];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    //    cell.backgroundView = [[WaterBackView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 55)];
//    UIImageView *picImage = (UIImageView *)[cell.contentView viewWithTag:100];
//    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:101];
//    UILabel *phoneNumLab = (UILabel *)[cell.contentView viewWithTag:102];
//
//    NSString *strPP = companyInfo[Table_User_avatar];
//    NSString *md5 = companyInfo[Table_User_urlmd5];
//    if (!KCNSSTRING_ISEMPTY(strPP)) {
//#if isHeadRequestUserMd5
//        [picImage setImageWithURLString:strPP urlmd5:md5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(picImage.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]) withRefreshCached:NO];
//#else
//        [picImage sd_setImageWithURL:[NSURL URLWithString:companyInfo[Table_User_avatar]] placeholderImage:ThemeDefaultHead(picImage.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
//#endif
//    }else{
//        [picImage sd_cancelCurrentImageLoad];
//        picImage.image = ThemeDefaultHead(picImage.size, companyInfo[Table_User_member_name],companyInfo[Table_User_account]);
//    }
//    nameLab.text = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
//    phoneNumLab.text = friendDic[@"content"];
//    return cell;
//}

@end
