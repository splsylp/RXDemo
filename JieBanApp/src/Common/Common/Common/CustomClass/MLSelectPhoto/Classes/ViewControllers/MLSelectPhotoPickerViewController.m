//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  PickerViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "RX_MLSelectPhotoPickerViewController.h"
#import "RX_MLSelectPhotoNavigationViewController.h"
#import "RX_MLSelectPhotoPickerGroupViewController.h"
#import "RX_MLSelectPhotoCommon.h"
#import "RX_MLSelectPhotoAssets.h"

@interface RX_MLSelectPhotoPickerViewController ()
@property (nonatomic , weak) RX_MLSelectPhotoPickerGroupViewController *groupVc;
@end

@implementation RX_MLSelectPhotoPickerViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotification];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
     DDLogInfo(@"....viewWillDisappear....走了一次......");
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init Action
- (void) createNavigationController{
    RX_MLSelectPhotoPickerGroupViewController *groupVc = [[RX_MLSelectPhotoPickerGroupViewController alloc] init];
    DDLogInfo(@"%@",self.doneString);

    RX_MLSelectPhotoNavigationViewController *nav = [[RX_MLSelectPhotoNavigationViewController alloc] initWithRootViewController:groupVc];
    nav.navigationBar.translucent = NO;
    nav.view.frame = self.view.bounds;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.groupVc = groupVc;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self createNavigationController];
    }
    return self;
}

- (void)setDoneString:(NSString *)doneString{
    if (_doneString != doneString) {
        _doneString = doneString;
    }
    self.groupVc.doneString = doneString;
}

- (void)setSelectPickers:(NSArray *)selectPickers{
    _selectPickers = selectPickers;
    self.groupVc.selectAsstes = selectPickers;
}

- (void)setStatus:(PickerViewShowStatus)status{
    _status = status;
    self.groupVc.status = status;
}

- (void)setMinCount:(NSInteger)minCount{
    if (minCount <= 0) return;
    _minCount = minCount;
    self.groupVc.minCount = minCount;
}

#pragma mark - 展示控制器
- (void)show{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) addNotification{
    // 监听异步done通知
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done:) name:PICKER_TAKE_DONE object:nil];
    });
}

- (void) done:(NSNotification *)note{
    NSArray *selectArray =  note.userInfo[@"selectAssets"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickerViewControllerDoneAsstes:)]) {
            [self.delegate pickerViewControllerDoneAsstes:selectArray];
        }else if (self.callBack){
            self.callBack(selectArray);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)setTopShowPhotoPicker:(BOOL)topShowPhotoPicker{
    _topShowPhotoPicker = topShowPhotoPicker;
    self.groupVc.topShowPhotoPicker = topShowPhotoPicker;
}

- (void)setDelegate:(id<ZLPhotoPickerViewControllerDelegate>)delegate{
    _delegate = delegate;
    self.groupVc.delegate = delegate;
}

#pragma mark - 通过传入一个图片对象（RX_MLSelectPhotoAssets/ALAsset）获取一张缩略图
+ (UIImage *)getImageWithImageObj:(id)imageObj{
    __block UIImage *image = nil;
    if ([imageObj isKindOfClass:[UIImage class]]) {
        return imageObj;
    }else if ([imageObj isKindOfClass:[ALAsset class]]){
        @autoreleasepool {
            ALAsset *asset = (ALAsset *)imageObj;
            //[asset thumbnail] 缩略图
            
            return [UIImage imageWithCGImage:[asset thumbnail]];
        }
    }else if ([imageObj isKindOfClass:[RX_MLSelectPhotoAssets class]]){
        return [imageObj originImage];
    }
    return image;
}

@end
