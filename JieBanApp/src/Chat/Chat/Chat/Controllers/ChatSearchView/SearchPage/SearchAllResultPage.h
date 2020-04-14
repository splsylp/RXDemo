//
//  SearchAllResultPage.h
//  trrrrasssss
//
//  Created by mac on 2017/4/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchAllChatView.h"

@interface SearchAllResultPage : BaseViewController

@property (nonatomic, strong) SearchAllChatView *searchAllView;
//- (void)reloadSearchAllResult:(NSString *)text withSessions:(NSMutableArray *)arr withVC:(BaseViewController *)baseVC withSearchBar:(UISearchBar *)searchBar;
- (void)reloadSearchText:(NSString *)text withSessions:(NSMutableArray *)sessions withSearBar:(UISearchBar *)searchB  withCurrentVC:(BaseViewController *)baseVC;

@end
