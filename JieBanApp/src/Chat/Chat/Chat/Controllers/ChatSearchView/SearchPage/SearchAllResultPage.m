//
//  SearchAllResultPage.m
//  trrrrasssss
//
//  Created by mac on 2017/4/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "SearchAllResultPage.h"
#import "NSAttributedString+Color.h"

#import "ChatSearchHeaderCard.h"
#import "SearchFooterCard.h"
#import "SearchContentCard.h"
#import "RecordsTableViewController.h"
#import "ChatViewController.h"
#import "SearchAllDetailResultPage.h"

#define HOME [[ChatSearchModule sharedInstance] home]

@interface SearchAllResultPage ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *searchChatText;
@property (nonatomic, strong) UISearchBar *texF;
@property (nonatomic, strong) BaseViewController *currentVC;

@end

@implementation SearchAllResultPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor purpleColor];
    self.view.backgroundColor =[UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];

    self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0.0f, 64.0, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
    self.tableView.backgroundColor=self.view.backgroundColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor=[UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsMultipleSelection = NO;
//    self.tableView.alwaysBounceVertical = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    
}
//- (void)reloadSearchAllResult:(NSString *)text withSessions:(NSMutableArray *)arr withVC:(BaseViewController *)baseVC withSearchBar:(UISearchBar *)searchBar {
//    self.searchAllView = [[SearchAllChatView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.view addSubview:self.searchAllView];
//    self.searchAllView.backgroundColor = [UIColor whiteColor];
//    [self.searchAllView reloadSearchText:text withSessions:arr withVC:baseVC];
//    self.searchAllView.textF = searchBar;
//}

- (void)loadCardView {
    [self.tableView reloadData];
}

   


- (void)reloadSearchText:(NSString *)text withSessions:(NSMutableArray *)sessions withSearBar:(UISearchBar *)searchB withCurrentVC:(BaseViewController *)baseVC {

//    UINavigationController* navigation = [[UINavigationController alloc] init];
//    navigation.navigationBarHidden = YES;
    
    _currentVC = baseVC;
    _searchChatText = text;
    _texF = searchB;
    
    //     if ([HOME count] == 0) {
    
    [self loadCardView];
    [[ChatSearchModule sharedInstance] loadSearchHomeWithText:text withSeesionArray:sessions ForSuccess:^(NSArray *home) {
        
        [self loadCardView];
        
    } error:^(NSInteger code) {
        
    }];
    //     }
    //     else {
    //          [self loadCardView];
    //         [[ChatSearchModule sharedInstance] loadSearchHomeWithText:text withSeesionArray:sessions ForSuccess:^(NSArray *home) {
    //
    //             [self loadCardView];
    //
    //         } error:^(NSInteger code) {
    //
    //         }];
    //     }
    
}


#pragma mark - tableViewDelegate -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [HOME count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < [HOME count]) {
        NSDictionary* homePart = [HOME objectAtIndex:section];
        if (homePart != nil) {
            if ([[homePart objectForKey:@"data"] count] > 3) {
                //                 return [[homePart objectForKey:@"data"] count] + 2;
                return 5;
            }
            else {
                return [[homePart objectForKey:@"data"] count] + 1;
            }
        }
        else {
            return 0;
        }
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *homePart = [HOME objectAtIndex:indexPath.section];
    SearchPart partKey = [[homePart objectForKey:@"key"] integerValue];
    if ([[homePart objectForKey:@"data"] count] > 3) {
        if (indexPath.row == 4) {
            static NSString *footerMessageCellid = @"footerCell";
            SearchFooterCard *cell = [tableView dequeueReusableCellWithIdentifier:footerMessageCellid];
            if (cell == nil) {
                cell = [[SearchFooterCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:footerMessageCellid];
            }
            cell.footerTitleText = [homePart objectForKey:@"footerTitle"];
            return cell;
            
        } else if (indexPath.row == 0) {
            static NSString *headerMessageCellid = @"headerCell";
            ChatSearchHeaderCard *cell = [tableView dequeueReusableCellWithIdentifier:headerMessageCellid];
            if (cell == nil) {
                cell = [[ChatSearchHeaderCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerMessageCellid];
            }
            cell.headerTitleText = [homePart objectForKey:@"title"];
            return cell;
        } else {
            if (partKey == SEARCH_CHAT_PERSON) {//联系人
                
                NSArray* persons = [homePart objectForKey:@"data"];
                NSDictionary *searchPersonDict =  [persons objectAtIndex:indexPath.row - 1];
                NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:searchPersonDict[@"mobile"] withType:1];
                
                return [self fillPersonBooksCellWithIndexPath:indexPath withDic:dic];
                
            }
            else if (partKey == SEARCH_CHAT_GROUP) {//群聊
                static NSString *contentMessageCellid = @"searchGroupContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    cell.backgroundColor=[UIColor clearColor];
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                NSArray* groups = [homePart objectForKey:@"data"];
                NSDictionary *groupsMem =  [groups objectAtIndex:indexPath.row - 1];
                ECGroup *group = groupsMem[@"group"];
                ECGroupMember *memberGroup = groupsMem[@"groupMember"];
                [self loadGroupAddress:cell withSessionId:group.groupId withDisplay:memberGroup.display];
                
                return cell;
            }
            else if (partKey == SEARCH_CHAT_RECORD) {//聊天记录
                static NSString *contentMessageCellid = @"searchRecordContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    cell.backgroundColor=[UIColor clearColor];
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                
                NSArray* recordsArr = [homePart objectForKey:@"data"];
                NSDictionary *searchDict =  [recordsArr objectAtIndex:indexPath.row - 1];
                NSArray *searchMessageArr = searchDict[@"searchMessageArr"];
                ECSession* session = searchDict[@"searchSession"];
                return [self loadSessionDataSearch:cell withSession:session withsearchMessageArr:searchMessageArr];
                
            }
            else if (partKey == SEARCH_CHAT_FRIENDCIRCLE) {//同事圈
                static NSString *contentMessageCellid = @"searchFriendCirclesContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                NSArray* friendsArr = [homePart objectForKey:@"data"];
                NSDictionary *friendDic = [friendsArr objectAtIndex:indexPath.row - 1];
                NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:friendDic[@"sender"] withType:0];
                return  [self fillFriendsCellWithIndexPath:indexPath withDic:dic withFriend:friendDic];
                
            }
            else {//公众号等
                static NSString *contentMessageCellid = @"searchGContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    cell.backgroundColor=[UIColor clearColor];
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                
                return cell;
                
            }
        }
    }  else {
        if (indexPath.row == 0) {
            static NSString *headerMessageCellid = @"headerCell";
            ChatSearchHeaderCard *cell = [tableView dequeueReusableCellWithIdentifier:headerMessageCellid];
            if (cell == nil) {
                cell = [[ChatSearchHeaderCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerMessageCellid];
            }
            cell.headerTitleText = [homePart objectForKey:@"title"];
            return cell;
        }
        //    else if (indexPath.row == [[homePart objectForKey:@"data"] count] + 1) {
        //        static NSString *footerMessageCellid = @"footerCell";
        //        SearchFooterCard *cell = [tableView dequeueReusableCellWithIdentifier:footerMessageCellid];
        //        if (cell == nil) {
        //            cell = [[SearchFooterCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:footerMessageCellid];
        //        }
        //        cell.footerTitleText = [homePart objectForKey:@"footerTitle"];
        //        return cell;
        //    }
        else {
            
            if (partKey == SEARCH_CHAT_PERSON) {//联系人
                
                NSArray* persons = [homePart objectForKey:@"data"];
                NSDictionary *searchPersonDict =  [persons objectAtIndex:indexPath.row - 1];
                NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:searchPersonDict[@"mobile"] withType:1];
                
                return [self fillPersonBooksCellWithIndexPath:indexPath withDic:dic];
                
            }
            else if (partKey == SEARCH_CHAT_GROUP) {//群聊
                static NSString *contentMessageCellid = @"searchGroupContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    cell.backgroundColor=[UIColor clearColor];
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                NSArray* groups = [homePart objectForKey:@"data"];
                NSDictionary *groupsMem =  [groups objectAtIndex:indexPath.row - 1];
                ECGroup *group = groupsMem[@"group"];
                ECGroupMember *memberGroup = groupsMem[@"groupMember"];
                [self loadGroupAddress:cell withSessionId:group.groupId withDisplay:memberGroup.display];
                
                return cell;
            }
            else if (partKey == SEARCH_CHAT_RECORD) {//聊天记录
                static NSString *contentMessageCellid = @"searchRecordContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    cell.backgroundColor=[UIColor clearColor];
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                
                NSArray* recordsArr = [homePart objectForKey:@"data"];
                NSDictionary *searchDict =  [recordsArr objectAtIndex:indexPath.row - 1];
                NSArray *searchMessageArr = searchDict[@"searchMessageArr"];
                ECSession* session = searchDict[@"searchSession"];
                return [self loadSessionDataSearch:cell withSession:session withsearchMessageArr:searchMessageArr];
                
            }
            else if (partKey == SEARCH_CHAT_FRIENDCIRCLE) {//同事圈
                static NSString *contentMessageCellid = @"searchFriendCirclesContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                NSArray* friendsArr = [homePart objectForKey:@"data"];
                NSDictionary *friendDic = [friendsArr objectAtIndex:indexPath.row - 1];
                NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:friendDic[@"sender"] withType:0];
                return  [self fillFriendsCellWithIndexPath:indexPath withDic:dic withFriend:friendDic];
                
            }
            else {//公众号等
                static NSString *contentMessageCellid = @"searchGContentCell";
                SearchContentCard *cell = [tableView dequeueReusableCellWithIdentifier:contentMessageCellid];
                if (cell == nil) {
                    cell = [[SearchContentCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentMessageCellid];
                    cell.backgroundColor=[UIColor clearColor];
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.portraitImg.hidden = NO;
                cell.groupHeadView.hidden = YES;
                
                return cell;
                
            }
            
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* homePart = [HOME objectAtIndex:indexPath.section];
    if ([[homePart objectForKey:@"data"] count] > 3) {
        if (indexPath.row == 4) {
            return 44.0f*[self isIphone6PlusProHeight];
        } else if (indexPath.row == 0) {
            return 44.0f*[self isIphone6PlusProHeight];
        } else {
            return 60.0f*[self isIphone6PlusProHeight];
        }
    } else {
        if (indexPath.row == 0) {
            return 44.0f*[self isIphone6PlusProHeight];
        }
        //        else if (indexPath.row == [[homePart objectForKey:@"data"] count] + 1) {
        //            return 44.0f*[self isIphone6PlusProHeight];
        //        }
        //    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]  - 1) {
        //        return 44.0f*[self isIphone6PlusProHeight];
        //    }
        else {
            return 60.0f*[self isIphone6PlusProHeight];
        }
    }
    //    if (indexPath.row == 0) {
    //        return 44.0f*[self isIphone6PlusProHeight];
    //    }
    //    else if (indexPath.row == [[homePart objectForKey:@"data"] count] + 1) {
    //        return 44.0f*[self isIphone6PlusProHeight];
    //    }
    ////    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]  - 1) {
    ////        return 44.0f*[self isIphone6PlusProHeight];
    ////    }
    //    else {
    //        return 60.0f*[self isIphone6PlusProHeight];
    //    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f*[self isIphone6PlusProHeight];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    NSDictionary* homePart = [HOME objectAtIndex:indexPath.section];
    SearchPart partKey = [[homePart objectForKey:@"key"] integerValue];
    
    if (indexPath.row == 0) {
        
    }  else if (indexPath.row == 4) {
        //更多
        SearchAllDetailResultPage *detailPage = [[SearchAllDetailResultPage alloc] init];
        if (partKey == SEARCH_CHAT_PERSON) {//联系人
               
        }
        else if (partKey == SEARCH_CHAT_GROUP) {//群聊

        }
        else if (partKey == SEARCH_CHAT_RECORD) {//聊天记录
        
        
        }
        else {//公众号等
            
        }
    } else {
        
        if (partKey == SEARCH_CHAT_PERSON) {//联系人
            
            NSArray* persons = [homePart objectForKey:@"data"];
            NSDictionary *searchPersonDict =  [persons objectAtIndex:indexPath.row - 1];
            NSDictionary *dic = [[Chat sharedInstance].componentDelegate getDicWithId:searchPersonDict[@"mobile"] withType:1];
            if ([dic[Table_User_account] isEqualToString:[[Chat sharedInstance] getAccount]]) {
                return;
            }
            ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:dic[Table_User_account]];
            [self pushViewController:chatVC];

//            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:self];
            
//            [navi pushViewController:chatVC animated:YES];
            
        }
        else if (partKey == SEARCH_CHAT_GROUP) {//群聊
            
            NSArray* groups = [homePart objectForKey:@"data"];
            NSDictionary *groupsMem =  [groups objectAtIndex:indexPath.row - 1];
            ECGroup *group = groupsMem[@"group"];
            //            ECGroupMember *memberGroup = groupsMem[@"groupMember"];
            ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:group.groupId];
            [self pushViewController:chatVC];
            
        }
        else if (partKey == SEARCH_CHAT_RECORD) {//聊天记录
            
            NSArray* recordsArr = [homePart objectForKey:@"data"];
            NSDictionary *searchDict =  [recordsArr objectAtIndex:indexPath.row - 1];
            NSArray *searchMessageArr = searchDict[@"searchMessageArr"];
            ECSession* session = searchDict[@"searchSession"];
            
            //如果记录不止一条 跳记录控制器
            if (searchMessageArr.count > 1) {
                RecordsTableViewController *recordsVC = [[RecordsTableViewController alloc] initWithSession:session andSearchStr:self.searchChatText andMessageArr:searchMessageArr];
                [self pushViewController:recordsVC];
            } else {
                //聊天界面入口
                ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:session.sessionId andRecodMessage:searchMessageArr[0]];
                [self pushViewController:chatVC];
            }
            
        } else {//公众号等
            
            
        }
        
    }
    
}

-(CGFloat)isIphone6PlusProHeight
{
    //    if(iPhone6plus)
    //    {
    //        return kScreenHeight/667;
    //    }
    return 1.0;
}

// 有搜索聊天记录
- (SearchContentCard *)loadSessionDataSearch:(SearchContentCard *)cell withSession:(ECSession *)session withsearchMessageArr:(NSArray *)searchMessageArr {
    
    cell.session = session;
    //系统通知type=100
    if (session.type == 100) {
        cell.nameLabel.text = session.sessionId;
        cell.portraitImg.image = ThemeImage(@"logo80x80.png");
    }else {
        
        //群组消息
        if([session.sessionId hasPrefix:@"g"])
        {
            cell.nameLabel.text = [[Common sharedInstance] getOtherNameWithPhone:session.sessionId];
            [self loadGroupHeadImage:cell withGroupId:session.sessionId];
            
        }else
        {
            //个人聊天
            NSString * sessionStr = session.sessionId;
            cell.contentLabel.text = session.text;
            
            
            //cell复用时取消当前异步下载线程，解决头像错乱问题
            [cell.portraitImg sd_cancelCurrentAnimationImagesLoad];
            
            NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:sessionStr withType:0];
            NSString *sex=@"";
            NSString *strPhoto=@"";
            if(companyInfo)
            {
                cell.nameLabel.text = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
                sex = companyInfo[Table_User_sex];
                NSString *headImageUrl = companyInfo[Table_User_avatar];
                if(!KCNSSTRING_ISEMPTY(headImageUrl))
                {
                    strPhoto = headImageUrl;
                }else
                {
                    strPhoto = [[Common sharedInstance] getIMageUrlWithPhone:session.sessionId];
                }
            }else
            {
                cell.nameLabel.text =session.sessionId;
                NSString *imgUrl = @"";
                NSString * sex = @"1";
                
                NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:sessionStr withType:0];
                if (companyInfo) {
                    cell.nameLabel.text = companyInfo[Table_User_member_name]? companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
                    imgUrl = companyInfo[Table_User_avatar];
                    sex = companyInfo[Table_User_sex];
                    
                    if([imgUrl hasPrefix:@"http"])
                    {
                        [cell.portraitImg sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
                        
                    }else
                    {
                        cell.portraitImg.image = [sex isEqualToString:@"1"]?ThemeImage(@"default_avatar_02.png"):ThemeImage(@"default_avatar_01.png");
                    }
                    
                }
                
            }
            if([strPhoto hasPrefix:@"http"])
            {
                [cell.portraitImg sd_setImageWithURL:[NSURL URLWithString:strPhoto] placeholderImage:[sex isEqualToString:@"1"]?ThemeImage(@"default_avatar_02.png"):ThemeImage(@"default_avatar_01.png") options:SDWebImageRefreshCached];
                
            }else
            {
                cell.portraitImg.image = [sex isEqualToString:@"1"]?ThemeImage(@"default_avatar_02.png"):ThemeImage(@"default_avatar_01.png");
            }
        }
    }
    
    //判断是不是搜索 头像两个tableView都可以使用
    if (searchMessageArr.count == 1) {
        ECMessage *message = searchMessageArr[0];
        ECTextMessageBody *body = (ECTextMessageBody*)message.messageBody;
        NSString *showText = body.text;
        //当消息文字过长 搜索的文字显示不出来的时候
        NSRange range = [body.text rangeOfString:_searchChatText];
        if (range.location > 17) {
            NSInteger subLength = (17 -_searchChatText.length)/2;
            showText = [body.text substringFromIndex:(range.location - subLength)];
            showText = [NSString stringWithFormat:@"...%@",showText];
        }
        cell.contentLabel.attributedText = [NSAttributedString attributeStringWithContent:showText keyWords:_searchChatText colors:ThemeColor];
        cell.dateLabel.text = [ChatTools getDateDisplayStringWithSession:message.timestamp.longLongValue];
        cell.unReadLabel.hidden =YES;
        
    } else if (searchMessageArr.count > 1){
        cell.contentLabel.text = [NSString stringWithFormat:@"%zd条相关聊天记录",searchMessageArr.count];
        cell.unReadLabel.hidden =YES;
    } else {
        NSString *notice_key = [NSString stringWithFormat:@"%@_notice", session.sessionId];
        NSString *resultStr = [[NSUserDefaults standardUserDefaults] objectForKey:notice_key];
        //时间，内容和未读显示
        NSArray* message = [[KitMsgData sharedInstance] getLatestHundredMessageOfSessionId:session.sessionId andSize:15];
        if(message.count<1 && session.type!=100)
        {
            cell.contentLabel.text=@"";
            cell.dateLabel.text=@"";
            
        }else
        {
            //如果用户设置了不通知 而且未读消息数大于1 显示有几条数据
            if (session.unreadCount > 0 && [resultStr isEqualToString:@"1"]) {
                NSString *str = [NSString stringWithFormat:@"[%zd条]%@",session.unreadCount,session.text];
                cell.contentLabel.text =str ;
            } else {
                
                cell.contentLabel.text = session.text;
            }
            cell.dateLabel.text = [ChatTools getDateDisplayStringWithSession:session.dateTime];
        }
        
        if (session.unreadCount == 0) {
            cell.unReadLabel.hidden =YES;
        }else{
            //如果用户选择了新消息不提示
            if ([resultStr isEqualToString:@"1"]) {
                cell.unReadLabel.hidden =YES;
            } else {
                
                if ((int)session.unreadCount>99) {
                    cell.unReadLabel.text = @"...";
                }else{
                    cell.unReadLabel.text = [NSString stringWithFormat:@"%d",(int)session.unreadCount];
                }
                cell.unReadLabel.hidden =NO;
            }
            
        }
        
        //置顶颜色
        NSString *strTop =[NSString stringWithFormat:@"%@_cur_top",session.sessionId];
        NSString *topStr=[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
        
        if([topStr isEqualToString:strTop])
        {
            cell.backgroundColor =[UIColor colorWithHex:0xF5FFF1FF];
        }else{
            cell.backgroundColor =[UIColor whiteColor];
        }
        
    }
    //置顶颜色
    NSString *strTop =[NSString stringWithFormat:@"%@_cur_top",session.sessionId];
    NSString *topStr=[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,session.sessionId]];
    
    if([topStr isEqualToString:strTop])
    {
        cell.backgroundColor = [self colorWithHex:0xE5E4E5ff];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
    
}
// 搜索联系人
- (UITableViewCell *)fillPersonBooksCellWithIndexPath:(NSIndexPath *)indexPath withDic:(NSDictionary *)companyInfo {
    
    UITableViewCell * cell = (UITableViewCell *)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"searchPersonContentCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchPersonContentCell"];
        
        UIImageView * picImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
        picImage.tag = 100;
        picImage.layer.cornerRadius=picImage.frame.size.width/2;
        picImage.layer.masksToBounds=YES;
        picImage.contentMode = UIViewContentModeScaleAspectFill;
        //        picImage.layer.borderColor=[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f].CGColor;
        //        picImage.layer.borderWidth=2;
        [cell.contentView addSubview:picImage];
        
        UILabel * nameLab = [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 80, 20)];
        nameLab.font = [UIFont systemFontOfSize:16];
        nameLab.tag = 101;
        [cell.contentView addSubview:nameLab];
        
        UILabel * positionLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.right+10, 5, 150, 20)];
        positionLab.tag=103;
        positionLab.textColor=[UIColor lightGrayColor];
        positionLab.font =[UIFont systemFontOfSize:12];
        positionLab.backgroundColor =[UIColor clearColor];
        [cell.contentView addSubview:positionLab];
        
        UILabel * phoneNumLab = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 100, 16)];
        phoneNumLab.tag = 102;
        phoneNumLab.font = [UIFont systemFontOfSize:14];
        phoneNumLab.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:phoneNumLab];
        
        // 分割线
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(picImage.right, 54, kScreenWidth-picImage.right, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
        [cell.contentView addSubview:lineView];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    //    cell.backgroundView = [[WaterBackView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 55)];
    UIImageView * picImage = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel * nameLab = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel * phoneNumLab = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *labelPosition =(UILabel *)[cell.contentView viewWithTag:103];
    
    NSString * titleLabStr;
    titleLabStr = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
    
    nameLab.attributedText =[NSAttributedString attributeChinaesewithContent:titleLabStr keyWords:self.searchChatText firstLetter:companyInfo[Table_User_name_initial] pinyin:companyInfo[Table_User_name_quanpin] chinaese:titleLabStr colors:[UIColor redColor]];
    
    phoneNumLab.attributedText = [NSAttributedString attributeStringWithContent:companyInfo[Table_User_mobile] keyWords:self.searchChatText colors:[UIColor redColor]];
    
    labelPosition.text = companyInfo[Table_User_posts_name]?[NSString stringWithFormat:@"(%@)", companyInfo[Table_User_posts_name]]:@"";
    
    NSString *strPP = companyInfo[Table_User_avatar];
    if (strPP != nil || ![strPP isEqual:[NSNull null]] || strPP.length > 0 || ![strPP isEqualToString:@"(null)"] || ![strPP isEqualToString:@"<null>"]) {
        [picImage sd_setImageWithURL:[NSURL URLWithString:companyInfo[Table_User_avatar]] placeholderImage:[companyInfo[Table_User_sex] isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"] options:SDWebImageRefreshCached];
    }else{
        picImage.image = [companyInfo[Table_User_sex] isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"];
    }
    
    CGSize size = [titleLabStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil]];
    nameLab.frame = CGRectMake(nameLab.originX, nameLab.originY, size.width, nameLab.size.height);
    labelPosition.frame = CGRectMake(nameLab.originX + size.width, labelPosition.originY, labelPosition.width, labelPosition.height);
    
    return cell;
    
}
//群聊里的人
- (SearchContentCard *)loadGroupAddress:(SearchContentCard *)cell withSessionId:(NSString *)groupId withDisplay:(NSString *)display{
    cell.nameLabel.text = [[Common sharedInstance] getOtherNameWithPhone:groupId];
    [self loadGroupHeadImage:cell withGroupId:groupId];
    cell.contentLabel.text = display;
    
    return cell;
}

#pragma privite method -
- (UIColor *)colorWithHex:(int)color {
    
    float red = (color & 0xff000000) >> 24;
    float green = (color & 0x00ff0000) >> 16;
    float blue = (color & 0x0000ff00) >> 8;
    float alpha = (color & 0x000000ff);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

-(void)loadGroupHeadImage:(SearchContentCard *)cell withGroupId:(NSString *)groupId
{
    NSArray *members =[KitGroupMemberInfoData getMemberInfoWithGroupId:groupId withCount:5];
    
    cell.portraitImg.image = [UIImage imageNamed:@"groups_icon.png"];
    if(members.count==1)
    {
        KitGroupMemberInfoData *info =members[0];
        if([info.role isEqualToString:@"1"] || [info.role isEqualToString:@"2"])
        {
            cell.portraitImg.image = [UIImage imageNamed:@"groups_icon.png"];
            return;
        }
    }
    
    if(members.count>1){
        //直接加载头像 先查看本地 后加载网络
        cell.portraitImg.hidden = YES;
        cell.groupHeadView.hidden=NO;
        [cell.groupHeadView createHeaderViewH:cell.portraitImg.width withImageWH:cell.portraitImg.width groupId:groupId withMemberArray:members];
        
    }else{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [[ECDevice sharedInstance].messageManager queryGroupMembers:groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
                
                if (error.errorCode == ECErrorType_NoError && members.count>0) {
                    NSArray *newMembers = [members sortedArrayUsingComparator:
                                           ^(ECGroupMember *obj1, ECGroupMember* obj2)
                                           {
                                               if(obj1.role < obj2.role) {
                                                   return(NSComparisonResult)NSOrderedAscending;
                                               }else {
                                                   return(NSComparisonResult)NSOrderedDescending;
                                               }
                                           }];
                    
                    
                    if(newMembers.count>1)
                    {
                        NSMutableArray *headArray =[NSMutableArray array];
                        
                        for(int i =0 ;i<((newMembers.count>5)?5:newMembers.count);i++)
                        {
                            ECGroupMember *member = [newMembers objectAtIndex:i];
                            KitGroupMemberInfoData *infodata =[[KitGroupMemberInfoData alloc]init];
                            infodata.memberId=member.memberId;
                            infodata.groupId=groupId;
                            infodata.role=[NSString stringWithFormat:@"%d",(int)member.role];
                            infodata.sex=[NSString stringWithFormat:@"%d",(int)member.sex];
                            [headArray addObject:member];
                        }
                        
                        [cell.groupHeadView createHeaderViewH:cell.portraitImg.width withImageWH:cell.portraitImg.width groupId:groupId  withMemberArray:headArray];
                        
                        cell.portraitImg.hidden = YES;
                        cell.groupHeadView.hidden=NO;
                    }
                    
                    [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
                    [KitGroupMemberInfoData insertGroupMemberArray:newMembers withGroupId:groupId];
                }
            }];
        });
        
    }
    
}

// 同事圈
- (UITableViewCell *)fillFriendsCellWithIndexPath:(NSIndexPath *)indexPath withDic:(NSDictionary *)companyInfo withFriend:(NSDictionary *)friendDic {
    
    UITableViewCell * cell = (UITableViewCell *)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"searchFriendContentCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchFriendContentCell"];
        
        UIImageView * picImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
        picImage.tag = 100;
        picImage.layer.cornerRadius=picImage.frame.size.width/2;
        picImage.layer.masksToBounds=YES;
        picImage.contentMode = UIViewContentModeScaleAspectFill;
        //        picImage.layer.borderColor=[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f].CGColor;
        //        picImage.layer.borderWidth=2;
        [cell.contentView addSubview:picImage];
        
        UILabel * nameLab = [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 80, 20)];
        nameLab.font = [UIFont systemFontOfSize:16];
        nameLab.tag = 101;
        [cell.contentView addSubview:nameLab];
        
        UILabel * positionLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.right+10, 5, 150, 20)];
        positionLab.tag=103;
        positionLab.textColor=[UIColor lightGrayColor];
        positionLab.font =[UIFont systemFontOfSize:12];
        positionLab.backgroundColor =[UIColor clearColor];
        [cell.contentView addSubview:positionLab];
        
        UILabel * phoneNumLab = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 100, 16)];
        phoneNumLab.tag = 102;
        phoneNumLab.font = [UIFont systemFontOfSize:14];
        phoneNumLab.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:phoneNumLab];
        
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(picImage.right, 54, kScreenWidth-picImage.right, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
        [cell.contentView addSubview:lineView];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    //    cell.backgroundView = [[WaterBackView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 55)];
    UIImageView * picImage = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel * nameLab = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel * phoneNumLab = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *labelPosition =(UILabel *)[cell.contentView viewWithTag:103];
    
    //    NSString * titleLabStr;
    //    titleLabStr = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
    
    //    nameLab.attributedText =[NSAttributedString attributeChinaesewithContent:self.searchChatText keyWords:self.searchChatText firstLetter:nil pinyin:nil chinaese:nil colors:[UIColor redColor]];
    
    //    phoneNumLab.attributedText = [NSAttributedString attributeStringWithContent:friendDic[@"content"] keyWords:self.searchChatText colors:[UIColor redColor]];
    
    //    labelPosition.text = companyInfo[Table_User_posts_name]?[NSString stringWithFormat:@"(%@)", companyInfo[Table_User_posts_name]]:@"";
    
    NSString *strPP = companyInfo[Table_User_avatar];
    if (strPP != nil || ![strPP isEqual:[NSNull null]] || strPP.length > 0 || ![strPP isEqualToString:@"(null)"] || ![strPP isEqualToString:@"<null>"]) {
        [picImage sd_setImageWithURL:[NSURL URLWithString:companyInfo[Table_User_avatar]] placeholderImage:[companyInfo[Table_User_sex] isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"] options:SDWebImageRefreshCached];
    }else{
        picImage.image = [companyInfo[Table_User_sex] isEqualToString:@"1"]?[UIImage imageNamed:@"default_avatar_02"]:[UIImage imageNamed:@"default_avatar_01"];
    }
    nameLab.text = companyInfo[Table_User_member_name]?companyInfo[Table_User_member_name]:companyInfo[Table_User_mobile];
    phoneNumLab.text = friendDic[@"content"];
    //    CGSize size = [titleLabStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil]];
    //    nameLab.frame = CGRectMake(nameLab.originX, nameLab.originY, size.width, nameLab.size.height);
    //    labelPosition.frame = CGRectMake(nameLab.originX + size.width, labelPosition.originY, labelPosition.width, labelPosition.height);
    
    return cell;
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 20;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.texF resignFirstResponder];
}
- (void)dismissKeyboard {
    if ([_texF isFirstResponder]) {
        [_texF resignFirstResponder];
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
