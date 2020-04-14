//
//  RecordsTableViewController.h
//  Chat
//
//  Created by ywj on 2017/1/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordsTableViewController : UITableViewController
//外界调用 传入参数
- (instancetype)initWithSession:(ECSession *)session andSearchStr:(NSString *)searchStr andMessageArr:(NSArray *)messageArr;
@end
