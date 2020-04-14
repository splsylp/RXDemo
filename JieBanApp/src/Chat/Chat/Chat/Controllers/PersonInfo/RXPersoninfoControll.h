//
//  RXPersoninfoControll.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/7/9.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

@protocol RXPersoninfoControllDelegate <NSObject>

- (void)personinfoControll:(UIViewController *)RXPersoninfoControll didSelectedIndexPath:(NSIndexPath *)indexpath;

@end

@interface RXPersoninfoControll : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableViewCell *chatInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *chatTopCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *chatNewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *chatCleanCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *chatHistoryCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *lookChatFileCell;
@property (weak, nonatomic) id <RXPersoninfoControllDelegate> personinfoDelegate;

@end
