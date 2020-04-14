//
//  ResolutionAndViewModeController.m
//  Chat
//
//  Created by 王灿辉 on 2018/9/12.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "ResolutionAndViewModeController.h"

@interface ResolutionAndViewModeController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
@property(nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CameraCapabilityInfo *capabilityInfo;
@end

@implementation ResolutionAndViewModeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self prepareData];
}

- (void)prepareUI{
    self.title = languageStringWithKey(@"设置");
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    self.tableView = [[UITableView alloc] init];
    self.tableView.rowHeight = 50;
    self.tableView.frame = CGRectMake(0.0f, kTotalBarHeight+20, kScreenWidth,100);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ResolutionAndViewModeControllerCell"];
    [self.view addSubview:self.tableView];
}

- (void)prepareData{
    _dataSource = [NSMutableArray array];
    [_dataSource addObject:[NSString stringWithFormat:@"%@%ldx%ld",languageStringWithKey(@"当前分辨率:"),(long)self.capabilityInfo.width,(long)self.capabilityInfo.height]];
    [_dataSource addObject:[NSString stringWithFormat:@"%@%@",languageStringWithKey(@"视频显示模式:"),self.videoDisplayMode]];
}

#pragma mark - private method
/// 视频分辨率
- (CameraCapabilityInfo *)capabilityInfo{
    NSArray *cameraInfoArr = [[AppModel sharedInstance] getCameraInfo];
    CameraDeviceInfo *cameraInfo = cameraInfoArr.lastObject; // 前置摄像头
    NSNumber *reslolution = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_CurResolution];
    if (reslolution) {
        _capabilityInfo = cameraInfo.capabilityArray[reslolution.intValue];
    }else{ // 默认
        NSInteger index = cameraInfo.capabilityArray.count - 2; // 第二高分辨率480x640
        index = index >= 0 ? index : 0; // 防止意外，不过sdk写死的四种分辨率，不会有意外
        _capabilityInfo = cameraInfo.capabilityArray[index];
        [[NSUserDefaults standardUserDefaults] setValue:@(index) forKey:UserDefault_CurResolution];
    }
    return _capabilityInfo;
}
/// 视频显示模式
- (NSString *)videoDisplayMode{
    NSString *modeStr;
    NSNumber *mode = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_VideoViewContentMode];
    if (mode) {
        switch (mode.intValue) {
            case 0:
                modeStr = @"ScaleToFill";
                break;
            case 1:
                modeStr = @"ScaleAspectFit";
                break;
            case 2:
                modeStr = @"ScaleAspectFill";
                break;
        }
    }else{ // 默认
        modeStr = @"ScaleToFill"; // 一般都使用这一种模式，所以作为默认值
        [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:UserDefault_VideoViewContentMode];
    }
    return modeStr;
}
#pragma mark - Action
const NSInteger videoViewModeSheetTag = 101;
const char  KButtonLabelSheet;
- (void)videoDisplayModeClicked {
    NSString *title = languageStringWithKey(@"视频显示模式:");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[title substringToIndex:title.length-1] delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:@"ScaleToFill",@"ScaleAspectFit",@"ScaleAspectFill",nil];
    sheet.tag = videoViewModeSheetTag;
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}

const NSInteger videoResolutionSheetTag = 100;
- (void)videoResolutionClicked {
    CameraDeviceInfo *camera = [[AppModel sharedInstance] getCameraInfo].lastObject;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:languageStringWithKey(@"设置分辨率") delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:nil];
    sheet.tag = videoResolutionSheetTag;
    for (CameraCapabilityInfo *capability in camera.capabilityArray) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%ldx%ld",capability.width,capability.height]];
    }
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        switch (actionSheet.tag) {
            case videoResolutionSheetTag:
            {
                [[NSUserDefaults standardUserDefaults] setObject:@(buttonIndex-1) forKey:UserDefault_CurResolution];
                [_dataSource replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@%@",languageStringWithKey(@"当前分辨率:"),[actionSheet buttonTitleAtIndex:buttonIndex]]];
                [self.tableView reloadData];
            }
                break;
                
            case videoViewModeSheetTag:
            {
                [[NSUserDefaults standardUserDefaults] setObject:@(buttonIndex) forKey:UserDefault_VideoViewContentMode];
                [_dataSource replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%@%@",languageStringWithKey(@"视频显示模式:"),[actionSheet buttonTitleAtIndex:buttonIndex]]];
                [self.tableView reloadData];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ResolutionAndViewModeControllerCell"];
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self videoResolutionClicked];
    }else if (indexPath.row == 1){
        [self videoDisplayModeClicked];
    }
}

@end
