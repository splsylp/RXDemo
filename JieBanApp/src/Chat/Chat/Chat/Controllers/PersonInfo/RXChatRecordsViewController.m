//
//  RXChatRecordsViewController.m
//  Chat
//
//  Created by 杨大为 on 2016/12/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXChatRecordsViewController.h"

#define requestMsgCount 15

@interface RXChatRecordsViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UISearchControllerDelegate>
@property (strong,nonatomic)UITableView *recordTableView;
@property (strong,nonatomic)ECMessage *chatVoiceMessage;//语音消息
@property (assign,nonatomic)BOOL isNoMessage;//当前没有聊天记录
//搜索
@property (strong,nonatomic)UISearchBar *searchBar;
@property (strong,nonatomic)UISearchDisplayController *searchController;

//@property (strong,nonatomic)HXNoDataView *noDataView;
@property (copy,nonatomic)NSString *historyMessageID;//历史消息ID
@property (copy,nonatomic)NSString *requestTime;//请求时间
@property (copy,nonatomic)NSString *startTime;//拉取时间

@end

@implementation RXChatRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //默认设置
    [self defaultSetting];
    //创建tableView
    [self createTableView];
    //创建searchVC
    [self createSearchVC];
    //刷新
    [self initRefresh];
    
    NSLog(@"%@ :", self.sessionId);

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
#pragma mark 默认设置
-(void)defaultSetting{
    if (iOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"聊天记录";
    self.view.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f];
    self.messageArray = [NSMutableArray array];
    self.searchArray = [NSMutableArray array];
}
#pragma mark createTableView
-(void)createTableView{
    self.recordTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 44, kScreenWidth, kScreenHeight - 64 - 44) style:UITableViewStylePlain];
    self.recordTableView.backgroundColor = [UIColor clearColor];
    self.recordTableView.delegate = self;
    self.recordTableView.dataSource = self;
    [self.view addSubview:self.recordTableView];
    
}
#pragma mark 创建searchVC
-(void)createSearchVC{
    if (self.searchController) {
        self.searchController = nil;
    }
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    self.searchBar.delegate = self;
    [self.searchBar layoutSubviews];
    self.searchBar.placeholder = @"搜索本地";
    
    if ([self.searchBar respondsToSelector:@selector(barTintColor)]) {
        NSArray *searchSubviews = [self.searchBar.subviews[0] subviews];
        for (UIView *subView in searchSubviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                subView.layer.borderColor = UIColorFromRGB(0xDADBDF).CGColor;
                subView.layer.borderWidth = 0.5;
                subView.layer.cornerRadius = 3.0;
                subView.clipsToBounds = YES;
                break;
            }
        }
    }
    if (iOS7) {
          [self.searchBar setBackgroundImage:[UIColor createImageWithColor:UIColorFromRGB(0xEFEFF4)] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    }else{
        [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBar_bg"]];
    }
    [self.searchBar setImage:[UIImage imageNamed:@"searchBar_search_new"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];
    //创建搜索控制器
    //搜索显示控制器
    self.searchController =[[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    
    [self.searchController setDelegate:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc]init];
    if ([self.searchController.searchResultsTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.searchController.searchResultsTableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([self.searchController.searchResultsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.searchController.searchResultsTableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    self.searchController.searchResultsTableView.backgroundColor=self.view.backgroundColor;
    self.searchController.searchResultsTableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    
    [self.searchController setValue:@"点击键盘上的\"搜索\"按钮查询结果" forKey:@"noResultsMessage"];
    [self.view addSubview:self.searchBar];
}
#pragma mark 刷新
-(void)initRefresh{
    __weak typeof(self)weakSelf = self;
    [self.recordTableView addPullToRefreshWithActionHandler:^{
        //加载历史消息
        [weakSelf loadHistoryData];
    }];
}

#pragma mark scroll
-(void)scrollTableView {
    if (self && self.recordTableView && self.messageArray.count>0) {
        [self.recordTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
#pragma mark 滑动到底部
- (void)scrollToBottom:(BOOL)animated {
    if (self.recordTableView.contentSize.height > self.recordTableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.recordTableView.contentSize.height - self.recordTableView.frame.size.height);
        [self.recordTableView setContentOffset:offset animated:animated];
    }
}
#pragma mark 加载历史消息
-(void)loadHistoryData
{
    if(self.isNoMessage)
    {
        [SVProgressHUD showWithTips:@"没有更多的聊天记录了" duration:1.5];
        [self.recordTableView.pullToRefreshView stopAnimating];
        return;
    }
    if([self.sessionId hasPrefix:@"g"])//群聊记录
    {
        NSString *messtime =nil;
        __weak typeof(self)weak_self =self;
        if(self.messageArray.count>0 && _startTime)
        {
            NSTimeInterval tempMilli = [_startTime longLongValue];
            NSTimeInterval seconds = tempMilli/1000.0;
            NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
            messtime = [NSDate getStringFromDate:myDate dateFormatter:@"yyyy-MM-dd HH:mm:ss"];
        }
        else
        {
            NSDate* date = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            messtime = [dateFormatter stringFromDate:date];
        }
        _requestTime =_startTime;
        [RestApi getHistoryGroupListMessageGroupId:self.sessionId startTime:nil endTime:messtime pageNo:nil pageSize:[NSString stringWithFormat:@"%d",requestMsgCount] msgDecompression:@"1" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSString *stateCode = [dict objectForKey:@"statusCode"];
            if ([stateCode isEqualToString:@"000000"]) {
                NSArray *dataArray = [dict objectForKey:@"result"];
                if (dataArray.count > 0) {
                    CGFloat offsetOfButtom = self.recordTableView.contentSize.height - self.recordTableView.contentOffset.y;
                    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        @autoreleasepool {
//                            [weak_self getMessageData:(NSDictionary *)obj];
                        }
                    }];
                    if (dataArray.count < requestMsgCount) {
                        weak_self.isNoMessage = YES;
                    }
                    [weak_self.recordTableView reloadData];
                    if (weak_self.messageArray.count > requestMsgCount) {
                        weak_self.recordTableView.contentOffset = CGPointMake(0.0, weak_self.recordTableView.contentSize.height - offsetOfButtom);
                    }else{
                        if (weak_self.messageArray.count > 0) {
                            weak_self.recordTableView.contentOffset = CGPointMake(0.0, weak_self.recordTableView.contentSize.height - offsetOfButtom);
                        }else{
                            [weak_self scrollToBottom:YES];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300*NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                                [weak_self scrollTableView];
                            });
                        }
                    }
                }
            }else if ([stateCode isEqualToString:@"560105"]){
                [SVProgressHUD showWithTips:@"没有更多的聊天记录了" duration:1.2];
                weak_self.isNoMessage = YES;
            }else{
                [SVProgressHUD showWithTips:@"拉取消息失败" duration:1.2];
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            [weak_self.recordTableView.pullToRefreshView stopAnimating];
        }];
        return;
    }else{//点对点单聊
        __weak typeof(self)weak_self = self;
        
        [RestApi getHistoryMyChatMessageWithAccount:[[Chat sharedInstance]getMobile] withAppid:[[Chat sharedInstance]getAppid] version:0 msgId:self.historyMessageID pageSize:requestMsgCount talker:self.sessionId order:2 didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSString *stateCode = [dict objectForKey:@"statusCode"];
            if ([stateCode isEqualToString:@"000000"]) {
                NSArray *dataArray = [dict objectForKey:@"statusCode"];
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            NSLog(@"%@", error);
        }];
//        __weak typeof(self)weak_self =self;
//        [HYTApiClient getHistoryMyChatMessageWithAccount:[RXUser sharedInstance].mobile withAppid: [Chat sharedInstance]getAppid version:0 msgId:_getHistorymsgID pageSize:requestCount talker:self.sessionId order:2 didFinishLoaded:^(KXJson *json, NSString *path) {
//            NSLog(@"........%@",json);
//            
//            [DemoGlobalClass sharedInstance].historyMessageUrl =nil;
//            
//            NSString *stateCode =[json getStringForKey:@"statusCode"];
//            
//            if([stateCode isEqualToString:@"000000"])
//            {
//                NSArray *dataArray =[json getObjectForKey:@"result"];
//                if(dataArray.count>0)
//                {
//                    
//                    //NSArray* reversedArray = [[dataArray reverseObjectEnumerator] allObjects];
//                    
//                    CGFloat offsetOfButtom = self.chatRecordTable.contentSize.height-self.chatRecordTable.contentOffset.y;
//                    
//                    
//                    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        
//                        @autoreleasepool {
//                            [weak_self getMessageData:(NSDictionary *)obj];
//                        }
//                    }];
//                    
//                    if(dataArray.count<requestCount)
//                    {
//                        weak_self.isNoMessage =YES;
//                    }
//                    [self.chatRecordTable reloadData];
//                    
//                    if(weak_self.messageArray.count>requestCount)
//                    {
//                        self.chatRecordTable.contentOffset = CGPointMake(0.0f, weak_self.chatRecordTable.contentSize.height-offsetOfButtom);
//                        
//                    }else
//                    {
//                        
//                        if(weak_self.messageArray.count>0)
//                        {
//                            self.chatRecordTable.contentOffset = CGPointMake(0.0f, weak_self.chatRecordTable.contentSize.height-offsetOfButtom);
//                        }else
//                        {
//                            [weak_self scrollViewToBottom:NO];
//                            
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                                
//                                [weak_self scrollTableView];
//                            });
//                        }
//                        
//                        
//                    }
//                    
//                }
//            }else
//            {
//                
//                if([stateCode isEqualToString:@"560105"])
//                {
//                    [ATMHud showMessage:@"没有更多的聊天记录了"];
//                    weak_self.isNoMessage =YES;
//                    
//                }else
//                {
//                    [ATMHud showMessage:@"拉取消息失败"];
//                }
//            }
//            [weak_self.chatRecordTable.mj_header endRefreshing];
//            
//            
//        } didFailLoaded:^(NSError *error, NSString *path) {
//            // NSLog(@".......%@",error.description);
//            
//            // [SVProgressHUD showErrorWithStatus:error.description];
//            
//            [weak_self.chatRecordTable.mj_header endRefreshing];
//            [DemoGlobalClass sharedInstance].historyMessageUrl =nil;
//            
//        }];
    }
}
#pragma mark UISearchDisplayControllerDelegate
//每次删除搜索框中内容或点击"确认"按钮时并不重新加载数据
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchArray removeAllObjects];
    if(searchBar.text.length>0)
    {
        _searchArray = [self searchLoactionDataWithsearchString:searchBar.text];
    }
    [self.searchController setValue:@"没有找到相关结果" forKey:@"noResultsMessage"];
    [self.searchController.searchResultsTableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    [_searchArray removeAllObjects];
    if(searchText.length>0)
    {
        _searchArray = [self searchLoactionDataWithsearchString:searchText];
    }
    
    [self.searchController setValue:@"没有找到相关结果" forKey:@"noResultsMessage"];
    [self.searchController.searchResultsTableView reloadData];
}

#pragma mark searchLoactionData
-(NSMutableArray *)searchLoactionDataWithsearchString:(NSString *)searchString
{
    NSMutableArray * addressSearchData =[[NSMutableArray alloc] init];
    for(ECMessage *message in self.messageArray)
    {
        if(message.messageBody.messageBodyType ==MessageBodyType_Text)
        {
            ECTextMessageBody *textBody =(ECTextMessageBody *)message.messageBody;
            NSRange nameResult=[textBody.text rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if(nameResult.length>0)
            {
                [addressSearchData addObject:message];
            }
        }
    }
    return addressSearchData;
}

#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchArray.count > 0) {
        return self.searchArray.count;
    }else{
        return self.messageArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
