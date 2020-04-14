//
//  GroupListSeessionViewController.h
//  Chat
//
//  Created by mac on 2017/1/16.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

@interface GroupListSeessionViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UIActionSheetDelegate>

@property (nonatomic,assign)BOOL isLogin;
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,strong) NSDictionary * dict;//红包相关

-(void)prepareDisplay;

@end
