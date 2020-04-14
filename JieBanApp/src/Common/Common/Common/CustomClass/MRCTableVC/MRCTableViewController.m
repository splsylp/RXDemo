//
//  MRCTableViewController.m
//  UserCenter
//
//  Created by 王明哲 on 2016/10/13.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "MRCTableViewController.h"
#import "MRCTableViewCellStyleValue1.h"

@interface MRCTableViewController ()

@property (nonatomic, weak, readwrite) IBOutlet UITableView *tableView;
@end

@implementation MRCTableViewController

- (void)setView:(UIView *)view {
    [super setView:view];
    
    if ([view isKindOfClass:UITableView.class]) self.tableView = (UITableView *)view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //init data
    _headerHeight = 0;
    self.deleteSource = [NSMutableArray array];
    self.rowHeight = 44 * FitThemeFont;
    
    //tableView
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[MRCTableViewCellStyleValue1 class] forCellReuseIdentifier:@"MRCTableViewCellStyleValue1"];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    //data observer
    [self observerData];
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)observerData {
    @weakify(self)
    [RACObserve(self, dataSource).distinctUntilChanged.deliverOnMainThread subscribeNext:^(id x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
    
    [RACObserve(self, mutDataSource).distinctUntilChanged.deliverOnMainThread subscribeNext:^(id x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
    
    [[RACObserve(self, headerColor) ignore:nil] subscribeNext:^(id x) {
        @strongify(self)
        
        UIView *tableBackView = [UIView new];
        tableBackView.backgroundColor = self.headerColor;
        //水印视图 默认不显示
        
//        _waterView = [self getWatermarkViewWithFrame:CGRectMake(0.0f,64,kScreenWidth,kScreenHeight) mobile:[Common sharedInstance].getStaffNo name:[Common sharedInstance].getUserName backColor:[UIColor whiteColor]];
//        [tableBackView addSubview:_waterView];
//        [tableBackView sendSubviewToBack:_waterView];
        
        self.waterView.hidden = YES;
        self.tableView.backgroundView = tableBackView;
    }];
}

#pragma mark - API
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark - UITableView DataSource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mutDataSource.count?self.mutDataSource.count:self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.mutDataSource.count?self.mutDataSource[section]:self.dataSource[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.headerHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.footerHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView dequeueReusableCellWithIdentifier:@"MRCTableViewCellStyleValue1" forIndexPath:indexPath];
    
    id object = nil;
    if (self.mutDataSource.count) {
        object = self.mutDataSource[indexPath.section][indexPath.row];
    }else {
        object = self.dataSource[indexPath.section][indexPath.row];
    }
    
    [self configureCell:cell atIndexPath:indexPath withObject:object];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=http://192.168.179.194:8888/56001/app/1.0.0/im.plist"]];
    [self didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
    NSString *secStr = [self.sectionDic objectForKey:[NSString stringWithFormat:@"%@",@(section)]];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = _headerColor;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
    header.textLabel.textColor = _headerTextColor;
    header.textLabel.text = secStr.length?[NSString stringWithFormat:@"  %@",secStr]:@"";
    header.textLabel.font = ThemeFontMiddle;
    header.textLabel.left = 10;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = _footerColor;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
    header.textLabel.textColor = _footerTextColor;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
