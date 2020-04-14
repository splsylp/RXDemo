//
//  CodecsetViewController.m
//  Chat
//
//  Created by yongzhen on 2018/5/9.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "CodecsetViewController.h"

@interface CodecsetViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray *selectedArr; // 已选中的按钮
@property (nonatomic, strong) NSMutableArray *allCodeArr; // 所有的编码方式

@end

@implementation CodecsetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"音视频编码设置";
    self.view.backgroundColor = [UIColor whiteColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ThemeColorImage(ThemeImage(@"title_bar_back"), [UIColor blackColor]) style:UIBarButtonItemStylePlain target:self action:@selector(willPopViewController)];
    
//    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:languageStringWithKey(@"确定") style:UIBarButtonItemStyleDone target:self action:@selector(back)];
//    [barItem setTintColor:[UIColor blackColor]];
//    self.navigationItem.rightBarButtonItem = barItem;
    
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = CGRectMake(0.0f, 0.0f, kScreenWidth,kScreenHeight-kTotalBarHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    if (iOS11) {
        // 这里代码针对ios11之后，tableveiw 刷新时候，闪动，跳动的问题
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    [self getCodecsetList];
    
}
// 获取已经打开和关闭的编码
-(void)getCodecsetList{
    NSMutableArray *allCodeNameArr = [[NSMutableArray alloc]initWithObjects:@"Codec_iLBC",@"Codec_G729",@"Codec_PCMU",@"Codec_PCMA",@"Codec_H264",@"Codec_SILK8K",@"Codec_AMR",@"Codec_VP8",@"Codec_SILK16K",@"Codec_OPUS48",@"Codec_OPUS16",@"Codec_OPUS8", nil];
    
 
    self.allCodeArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<allCodeNameArr.count; i++) {
        
       BOOL res = [[AppModel sharedInstance]getCondecEnabelWithCodec:i];
        
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:allCodeNameArr[i] forKey:@"codeName"];
        [dic setObject:[NSNumber numberWithBool:res] forKey:@"res"];
//       [dic setObject:[NSNumber numberWithBool:res] forKey:allCodeNameArr[i]];
       [self.allCodeArr addObject:dic];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.allCodeArr forKey:CodecSetArr];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

#pragma mark -<Navigation Actions>
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willPopViewController{
    //    if (!self.isSelected) {
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"codecsetList"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //    }
    
    [self popViewController];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - detaSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 12; // Codec_iLBC 等12个
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CodecSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CodecSetCell"];
    
    if (cell == nil) {
        cell = [[CodecSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CodecSetCell"];
    }
    
    NSDictionary *dic = self.allCodeArr[indexPath.row];
    [cell setValeWithDic:dic];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//      NSMutableDictionary *dic = self.allCodeArr[indexPath.row];
//    if ([dic hasValueForKey:@"res"]) {
//        BOOL res = ![dic[@"res"] boolValue];
//        [dic setObject:[NSNumber numberWithBool:res] forKey:@"res"];
//    }
//
////    CodecSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CodecSetCell"];
    CodecSetCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    if (cell.selectedBtn.selected) {
        [cell.selectedBtn setImage:ThemeImage(@"kit_check_on") forState:UIControlStateNormal];
        [[AppModel sharedInstance] setCodecEnabledWithCodec:indexPath.row andEnabled:YES];
    }else{
        [cell.selectedBtn setImage:ThemeImage(@"kit_check") forState:UIControlStateNormal];
        [[AppModel sharedInstance] setCodecEnabledWithCodec:indexPath.row andEnabled:NO];
        
    }
    [self getCodecsetList];
    [self.tableView reloadData];
////    NSDictionary *dic = self.allCodeArr[indexPath.row];
//    [cell setValeWithDic:dic];
//
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
