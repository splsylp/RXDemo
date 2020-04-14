//
//  RXPersoninfoControll.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/7/9.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXBaseViewController.h"

@interface RXPersoninfoControll : RXBaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableViewCell *chatInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *chatTopCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *chatNewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *chatCleanCell;

@end
