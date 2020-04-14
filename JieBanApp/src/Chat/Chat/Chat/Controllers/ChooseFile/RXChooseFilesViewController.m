//
//  RXChooseFilesViewController.m
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/2/20.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXChooseFilesViewController.h"

@interface RXChooseFilesViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *fileList;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RXChooseFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.data isKindOfClass:NSClassFromString(@"ChatToolView")]) {
        self.type = 1;
        self.chooseDelegate = self.data;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, kScreenWidth,self.view.frame.size.height-65.0f) style:UITableViewStylePlain];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.tableView.frame = CGRectMake(0.0f, 0.0f, kScreenWidth,kScreenHeight-kTotalBarHeight);
    } else {
        self.tableView.frame = CGRectMake(0.0f, 0.0f, kScreenWidth,self.view.frame.size.height-44.0f);
    }
    self.tableView.scrollsToTop = YES;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.00f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewWillBeginDragging:)];
    //    [self.tableView addGestureRecognizer:tap];
    
    [self.view addSubview:self.tableView];
    
    
    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_back")
                     highlightedImg:ThemeImage(@"title_bar_back")
                             target:self
                             action:@selector(popViewController:)
                               type:NavigationBarItemTypeLeft];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    self.title = languageStringWithKey(@"文件");
    if (self.type == 1) {
        fileList = [self getAllFileNames:@"tmpDoc"];
        return;
    }
    #pragma mark - zmf 屏蔽
//    [RestApi getNetDistWithMobile:[[Chat sharedInstance] getAccount] queryid:[[Chat sharedInstance] getAccount] type:@"1" didFinishLoaded:^(KXJson *json, NSString *path) {
//        fileList = [[json getJsonForKey:@"body"] getJsonForKey:@"filelist"];
//        
//        [self.tableView reloadData];
//    } didFailLoaded:^(NSError *error, NSString *path) {
//        
//    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int ADHeight = 44;
    CGSize size = [[[fileList objectAtIndex:indexPath.row] getStringForKey:@"filename"] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontSmall,NSFontAttributeName, nil]];
    if (size.width >= 260) {
        int width = (int)size.width;
        int a = width/260;
        int b = width%260?1:0;
        ADHeight = 44*(a + b) - 10;
        return ADHeight;
    }
    return ADHeight;
}
- (NSArray *) getAllFileNames:(NSString *)dirName
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];//获取根目录
    NSArray *files = [fileMgr subpathsAtPath:rootPath];//取得文件列表
    NSArray *sortedPaths = [files sortedArrayUsingComparator:^(NSString * firstPath, NSString* secondPath) {//
        NSString *firstUrl = [rootPath stringByAppendingPathComponent:firstPath];//获取前一个文件完整路径
        NSString *secondUrl = [rootPath stringByAppendingPathComponent:secondPath];//获取后一个文件完整路径
        NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstUrl error:nil];//获取前一个文件信息
        NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondUrl error:nil];//获取后一个文件信息
        id firstData = [firstFileInfo objectForKey:NSFileModificationDate];//获取前一个文件修改时间
        id secondData = [secondFileInfo objectForKey:NSFileModificationDate];//获取后一个文件修改时间
        return [firstData compare:secondData];//升序
    }];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSString* strFile in sortedPaths) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:10];
        [dict setObject:strFile forKey:@"filename"];
        NSString *firstUrl = [rootPath stringByAppendingPathComponent:strFile];//获取前一个文件完整路径
        NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstUrl error:nil];//获取前一个文件信息
        if ([firstFileInfo objectForKey:NSFileType] == NSFileTypeDirectory) {
            continue;
        }
        if([strFile hasPrefix:@"."])
            continue;
        if([strFile hasPrefix:@"com."])
            continue;
//        if([strFile hasSuffix:@".db"])
//            continue;
//        NSRange range = [strFile rangeOfString:@"/"];
//        if (!(range.location == NSNotFound))
//            continue;
        NSString* strData = [NSString stringWithFormat:@"%@",[firstFileInfo objectForKey:NSFileModificationDate]];
        [dict setObject: strData forKey:@"updatetime"];
        NSString* strSize = [NSString stringWithFormat:@"%@",[firstFileInfo objectForKey:NSFileSize]];
        if ([firstFileInfo objectForKey:NSFileSize]<=0) {
            continue;
        }
        [dict setObject: strSize forKey:@"fileSize"];
        [array addObject:dict];
    }
    return array;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!fileList) {
        return 0;
    }
    return [fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(fileList.count<=0)
    {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"cell1"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        }
        UILabel * bgLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
        bgLab.text = languageStringWithKey(@"暂无文件");
        bgLab.font = ThemeFontLarge;
        bgLab.textColor = [UIColor lightGrayColor];
        bgLab.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:bgLab];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellrefresscellid"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellrefresscellid"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
        cell.textLabel.numberOfLines = 0;
    }
    cell.textLabel.text = [[fileList objectAtIndex:indexPath.row] getStringForKey:@"filename"];
    if ([[[fileList objectAtIndex:indexPath.row] getStringForKey:@"updatetime"] length]>0) {
        cell.detailTextLabel.text = [[fileList objectAtIndex:indexPath.row] getStringForKey:@"updatetime"];
    }
    cell.imageView.image = ThemeImage(@"common_file.png");
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary* file = [fileList objectAtIndex:indexPath.row];
    NSDictionary* dict ;
    
    if(self.type == 1)
    {
        [self.chooseDelegate chooseFile:[[fileList objectAtIndex:indexPath.row] getStringForKey:@"filename"]];
        [self popViewController];
        return;
    }
    
    BOOL isModelView=NO;
    if([self.data isKindOfClass:[NSArray class]])
    {
        NSArray* members = (NSArray*)self.data;
        dict = [NSDictionary dictionaryWithObjectsAndKeys:file,@"file",members,@"members", nil];
    }
    else if([self.data isKindOfClass:[NSDictionary class]])
    {
        
    }
    
    if(isModelView)
    {
        [self pushViewController:@"RXFileCooperateViewController" withData:dict withNav:YES];
    }else
    {
        [self pushViewController:@"RXFileCooperateViewController" withData:dict withNav:NO];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}
-(void)popViewController:(id)sender
{
    //if(self.navigationController.topViewController isKindOfClass:[])
    
    if([self.data isKindOfClass:[NSDictionary class]])
    {
        if([[self.data objectForKey:kIsPresentModalView] isEqualToString:@"presentModalView"])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else
        {
            [super popViewController];
        }
    }else
    {
        [super popViewController];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
