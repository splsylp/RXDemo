//
//  RX_TZGifPhotoPreviewController.m
//  RX_TZImagePickerController
//
//  Created by ttouch on 2016/12/13.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "RX_TZGifPhotoPreviewController.h"
#import "RX_TZImagePickerController.h"
#import "RX_TZAssetModel.h"
#import "UIView+RX_Layout.h"
#import "RX_TZPhotoPreviewCell.h"
#import "RX_TZImageManager.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface RX_TZGifPhotoPreviewController () {
    UIView *_toolBar;
    UIButton *_doneButton;
    UIProgressView *_progress;
    
    RX_TZPhotoPreviewView *_rxpreviewView;
    
    UIStatusBarStyle _originStatusBarStyle;
}
@end

@implementation RX_TZGifPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    RX_TZImagePickerController *tzImagePickerVc = (RX_TZImagePickerController *)self.navigationController;
    if (tzImagePickerVc) {
        self.navigationItem.title = [NSString stringWithFormat:@"GIF %@",tzImagePickerVc.previewBtnTitleStr];
    }
    [self configPreviewView];
    [self configBottomToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
}

- (void)configPreviewView {
    _rxpreviewView = [[RX_TZPhotoPreviewView alloc] initWithFrame:CGRectZero];
    _rxpreviewView.model = self.model;
    __weak typeof(self) weakSelf = self;
    [_rxpreviewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf signleTapAction];
    }];
    [self.view addSubview:_rxpreviewView];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = SystemFontLarge;
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    RX_TZImagePickerController *tzImagePickerVc = (RX_TZImagePickerController *)self.navigationController;
    if (tzImagePickerVc) {
        [_doneButton setTitle:tzImagePickerVc.doneBtnTitleStr forState:UIControlStateNormal];
        [_doneButton setTitleColor:tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:[NSBundle tz_localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    }
    [_toolBar addSubview:_doneButton];
    
    UILabel *byteLabel = [[UILabel alloc] init];
    byteLabel.textColor = [UIColor whiteColor];
    byteLabel.font = SystemFontMiddle;
    byteLabel.frame = CGRectMake(10, 0, 100, 44);
    [[RX_TZImageManager manager] getPhotosBytesWithArray:@[_model] completion:^(NSString *totalBytes) {
        byteLabel.text = totalBytes;
    }];
    [_toolBar addSubview:byteLabel];
    
    [self.view addSubview:_toolBar];
    
    if (tzImagePickerVc.gifPreviewPageUIConfigBlock) {
        tzImagePickerVc.gifPreviewPageUIConfigBlock(_toolBar, _doneButton);
    }
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _rxpreviewView.frame = self.view.bounds;
    _rxpreviewView.scrollView.frame = self.view.bounds;
    CGFloat toolBarHeight = [RX_TZCommonTools rxtz_isIPhoneX] ? 44 + (83 - 49) : 44;
    _toolBar.frame = CGRectMake(0, self.view.tz_height - toolBarHeight, self.view.tz_width, toolBarHeight);
    _doneButton.frame = CGRectMake(self.view.tz_width - 44 - 12, 0, 44, 44);
    
    RX_TZImagePickerController *tzImagePickerVc = (RX_TZImagePickerController *)self.navigationController;
    if (tzImagePickerVc.gifPreviewPageDidLayoutSubviewsBlock) {
        tzImagePickerVc.gifPreviewPageDidLayoutSubviewsBlock(_toolBar, _doneButton);
    }
}

#pragma mark - Click Event

- (void)signleTapAction {
    _toolBar.hidden = !_toolBar.isHidden;
    [self.navigationController setNavigationBarHidden:_toolBar.isHidden];
    RX_TZImagePickerController *tzImagePickerVc = (RX_TZImagePickerController *)self.navigationController;
    if (_toolBar.isHidden) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    } else if (tzImagePickerVc.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
}

- (void)doneButtonClick {
    if (self.navigationController) {
        RX_TZImagePickerController *imagePickerVc = (RX_TZImagePickerController *)self.navigationController;
        if (imagePickerVc.autoDismiss) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self callDelegateMethod];
            }];
        } else {
            [self callDelegateMethod];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    }
}

- (void)callDelegateMethod {
    RX_TZImagePickerController *imagePickerVc = (RX_TZImagePickerController *)self.navigationController;
    UIImage *animatedImage = _rxpreviewView.imageView.image;
    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingGifImage:sourceAssets:)]) {
        [imagePickerVc.pickerDelegate imagePickerController:imagePickerVc didFinishPickingGifImage:animatedImage sourceAssets:_model.asset];
    }
    if (imagePickerVc.didFinishPickingGifImageHandle) {
        imagePickerVc.didFinishPickingGifImageHandle(animatedImage,_model.asset);
    }
}

#pragma clang diagnostic pop

@end
