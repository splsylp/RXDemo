//
//  MRCTableViewController.h
//  UserCenter
//
//  Created by 王明哲 on 2016/10/13.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseViewController.h"
#import "ReactiveCocoa.h"

typedef void (^DidSelectBlock)(NSIndexPath *indexPath);

@interface MRCTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
///数据源
@property (nonatomic, retain) NSArray *dataSource;
///可变数据源
@property (nonatomic, retain) NSArray *mutDataSource;
///删除的数据
@property (nonatomic, retain) NSMutableArray *deleteSource;
///控制器字典
@property (nonatomic, retain) NSDictionary *VCAffineDic;
///section字典
@property (nonatomic, retain) NSDictionary *sectionDic;
///header颜色
@property (nonatomic, retain) UIColor *headerColor;
//footer颜色
@property (nonatomic, retain) UIColor *footerColor;
///header文本颜色
@property (nonatomic, retain) UIColor *headerTextColor;
///footer文本颜色
@property (nonatomic, retain) UIColor           *footerTextColor;
///header高度
@property (nonatomic, assign) NSInteger headerHeight;
///row高度
@property (nonatomic, assign) NSInteger rowHeight;
///footer高度
@property (nonatomic, assign) NSInteger footerHeight;
///水印视图
@property (nonatomic, retain) UIView *waterView;
@property (nonatomic, weak, readonly) UITableView *tableView;

- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)identifier
                  forIndexPath:(NSIndexPath *)indexPath;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
