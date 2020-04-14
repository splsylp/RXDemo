//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerGroupViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#define CELL_ROW 4
#define CELL_MARGIN 5
#define CELL_LINE_MARGIN 5


#import "RX_MLSelectPhotoPickerGroupViewController.h"
#import "RX_MLSelectPhotoPickerCollectionView.h"
#import "RX_MLSelectPhotoPickerDatas.h"
#import "RX_MLSelectPhotoPickerGroupViewController.h"
#import "RX_MLSelectPhotoPickerGroup.h"
#import "RX_MLSelectPhotoPickerGroupTableViewCell.h"
#import "RX_MLSelectPhotoPickerAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface RX_MLSelectPhotoPickerGroupViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak) RX_MLSelectPhotoPickerAssetsViewController *collectionVc;

@property (nonatomic , weak) UITableView *tableView;
@property (nonatomic , strong) NSArray *groups;

@end

@implementation RX_MLSelectPhotoPickerGroupViewController

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [tableView registerClass:[RX_MLSelectPhotoPickerGroupTableViewCell class] forCellReuseIdentifier:@"cell"];
        tableView.delegate = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        
        NSString *heightVfl = @"V:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        NSString *widthVfl = @"H:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    
    [self tableView];
    
    // 设置按钮
    [self setupButtons];
    
    // 获取图片
    [self getImgs];
    
    self.title = languageStringWithKey(@"选择相册");

    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor, nil]];
    
  
}

- (void) setupButtons{
//    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:languageStringWithKey(@"关闭") style:UIBarButtonItemStyleDone target:self action:@selector(back)];
//    [barItem setTintColor:[UIColor blackColor]];
//    self.navigationItem.rightBarButtonItem = barItem;
    
    self.navigationItem.rightBarButtonItem = [self setBarItemTitle:languageStringWithKey(@"关闭") titleColor:APPMainUIColorHexString target:self action:@selector(back)];
}

- (UIBarButtonItem *)setBarItemTitle:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action  {
    CGSize size = [title sizeWithFont:SystemFontLarge];
    CGRect btnFrame = CGRectMake(0, 0, size.width + 20, 30);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [[button titleLabel] setFont:SystemFontLarge];
    
    [button setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateNormal];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;//APPMainUIColorHexString
}


#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groups.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RX_MLSelectPhotoPickerGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[RX_MLSelectPhotoPickerGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.group = self.groups[indexPath.row];
    
    return cell;
    
}

#pragma mark 跳转到控制器里面的内容
- (void) jump2StatusVc{
    // 如果是相册
    RX_MLSelectPhotoPickerGroup *gp = nil;
    for (RX_MLSelectPhotoPickerGroup *group in self.groups) {
        if ((self.status == PickerViewShowStatusCameraRoll || self.status == PickerViewShowStatusVideo) && ([group.groupName isEqualToString:@"Camera Roll"] || [group.groupName isEqualToString:@"相机胶卷"] || [group.groupName isEqualToString:@"所有照片"])) {//languageStringWithKey(@"相机胶卷") 这里不用转，英文时候，groupname 还是汉语
            gp = group;
            break;
        }else if (self.status == PickerViewShowStatusSavePhotos && ([group.groupName isEqualToString:@"Saved Photos"] || [group.groupName isEqualToString:@"保存相册"])){
            gp = group;
            break;
        }else if (self.status == PickerViewShowStatusPhotoStream &&  ([group.groupName isEqualToString:@"Stream"] || [group.groupName isEqualToString:@"我的照片流"])){
            gp = group;
            break;
        }
    }
    
    if (!gp) return ;
    
    RX_MLSelectPhotoPickerAssetsViewController *assetsVc = [[RX_MLSelectPhotoPickerAssetsViewController alloc] init];
    assetsVc.selectPickerAssets = self.selectAsstes;
    assetsVc.assetsGroup = gp;
    assetsVc.doneString = self.doneString;
    assetsVc.topShowPhotoPicker = self.topShowPhotoPicker;
    assetsVc.groupVc = self;
    assetsVc.minCount = self.minCount;
    [self.navigationController pushViewController:assetsVc animated:NO];
}

#pragma mark -<UITableViewDelegate>
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RX_MLSelectPhotoPickerGroup *group = self.groups[indexPath.row];
    RX_MLSelectPhotoPickerAssetsViewController *assetsVc = [[RX_MLSelectPhotoPickerAssetsViewController alloc] init];
    assetsVc.selectPickerAssets = self.selectAsstes;
    assetsVc.doneString = self.doneString;
    assetsVc.groupVc = self;
    assetsVc.assetsGroup = group;
    assetsVc.topShowPhotoPicker = self.topShowPhotoPicker;
    assetsVc.minCount = self.minCount;
    [self.navigationController pushViewController:assetsVc animated:YES];
}

#pragma mark -<Images Datas>

-(void)getImgs{
    RX_MLSelectPhotoPickerDatas *datas = [RX_MLSelectPhotoPickerDatas defaultPicker];
    
    __weak typeof(self) weakSelf = self;
    
    if (self.status == PickerViewShowStatusVideo){
        // 获取所有的图片URLs
        [datas getAllGroupWithVideos:^(NSArray *groups) {
            self.groups = groups;
            if (self.status) {
                [self jump2StatusVc];
            }
            
            weakSelf.tableView.dataSource = self;
            [weakSelf.tableView reloadData];
            
        }];
        
    }else{
        // 获取所有的图片URLs
        [datas getAllGroupWithPhotos:^(NSArray *groups) {
            self.groups = groups;
            if (self.status) {
                [self jump2StatusVc];
            }
            
            weakSelf.tableView.dataSource = self;
            [weakSelf.tableView reloadData];
            
        }];

    }
}


#pragma mark -<Navigation Actions>
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
