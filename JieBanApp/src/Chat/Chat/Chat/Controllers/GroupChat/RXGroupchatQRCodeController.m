//
//  RXGroupchatQRCodeController.m
//  Chat
//
//  Created by keven on 2019/1/3.
//  Copyright © 2019年 ronglian. All rights reserved.
//

#import "RXGroupchatQRCodeController.h"
#import "RXGrouchatQRcodeView.h"
#import "UIImage+deal.h"

@interface RXGroupchatQRCodeController ()<UIActionSheetDelegate>

@property(nonatomic,strong) UIButton * savePhotoButton;
@property(nonatomic,strong) UIButton * sharePhotoButton;
@property(nonatomic,strong) RXGrouchatQRcodeView *qRcodeView;

@end

@implementation RXGroupchatQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark -  setupUI

- (void)setupUI{
    self.navigationItem.title = languageStringWithKey(@"二维码");
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf3f4f8"];
    
    if (![self.data isKindOfClass:[ECGroup class]]) return;
    ECGroup * groupModel = (ECGroup *)self.data;
    
    [self.view addSubview:self.qRcodeView];
    [self.view addSubview:self.savePhotoButton];
    [self.view addSubview:self.sharePhotoButton];
    
    [self.savePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(12);
        make.bottom.equalTo(self.view).offset(-20-IphoneXBottomHeight);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
    }];
    [self.sharePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-12);
        make.bottom.equalTo(self.view).offset(-20-IphoneXBottomHeight);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
    }];
    [self.qRcodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(60 * iPhone6FitScreenHeight + kTotalBarHeight);
        make.leading.equalTo(self.view).offset(30 * iPhone6FitScreenWidth);
        make.trailing.equalTo(self.view).offset(-30 * iPhone6FitScreenWidth);
        make.bottom.equalTo(self.sharePhotoButton.mas_top).offset(-60 * iPhone6FitScreenHeight);
    }];
    
    self.qRcodeView.groupModel = groupModel;
}

#pragma mark -  action

- (void)savePhotoButtonClick:(id)sender{
    UIImage * image = [self.qRcodeView convertViewToImage];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"保存成功")];
                    } else {
                        [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"保存失败")];
                    }
                });
            }];
        }
        else if(status == 2 || status == 3) {
            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"保存失败,请打开相册权限")];
        }
    }];
}
- (void)sharePhotoButtonclick:(id)sender{
    UIActionSheet * sheet =[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"同事圈"),languageStringWithKey(@"选择联系人"), nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImage * image = [self.qRcodeView convertViewToImage];
    
    switch (buttonIndex) {
        case 1: {   //分享
            NSString *imagePath = [image saveToDocument];
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
            mediaBody.remotePath = imagePath;
            ECMessage *message = [[ECMessage alloc] initWithReceiver:@"" body:mediaBody];
            
            if ([[Common sharedInstance].componentDelegate respondsToSelector:@selector(getChooseMembersVCWithExceptData:WithType:)]) {
                UIViewController *groupVC = [[Common sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{@"msg":message,@"from":@"friendcicle"} WithType:SelectObjectType_TransmitSelectMember];
                RXBaseNavgationController * nav = [[RXBaseNavgationController alloc] initWithRootViewController:groupVC];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }   break;
        case 0: {   //朋友圈
            if ([[AppModel sharedInstance].appModelDelegate respondsToSelector:@selector(sendFriendCircleWityDic:)]) {
                  NSString *imagePath = [image saveToDocument];
                NSDictionary * dic = @{
                                        @"imgThumbPath":imagePath,
                                        @"currentType":@"transmitQrCode"
                                        };
                UIViewController *sendFriendCircleVC = [[AppModel sharedInstance].appModelDelegate sendFriendCircleWityDic:dic];
                if (sendFriendCircleVC) {
                    RXBaseNavgationController * nav = [[RXBaseNavgationController alloc] initWithRootViewController:sendFriendCircleVC];
                    [self presentViewController:nav animated:YES completion:nil];
                }
            }
        }   break;
    }
}

#pragma mark -  lazy

- (RXGrouchatQRcodeView*)qRcodeView{
    if (!_qRcodeView) {
        _qRcodeView = [[RXGrouchatQRcodeView alloc]init];
        _qRcodeView.layer.cornerRadius = 4;
        _qRcodeView.layer.masksToBounds = YES;
    }
    return _qRcodeView;
}
- (UIButton*)savePhotoButton{
    if (!_savePhotoButton) {
        _savePhotoButton = [[UIButton alloc]init];
        _savePhotoButton.backgroundColor = [UIColor whiteColor];
        [_savePhotoButton setTitle:languageStringWithKey(@"保存到手机") forState:UIControlStateNormal];
        [_savePhotoButton addTarget:self action:@selector(savePhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_savePhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _savePhotoButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _savePhotoButton.layer.cornerRadius = 4;
        _savePhotoButton.layer.masksToBounds = YES;
    }
    return _savePhotoButton;
}
- (UIButton*)sharePhotoButton{
    if (!_sharePhotoButton) {
        _sharePhotoButton = [[UIButton alloc]init];
        _sharePhotoButton.backgroundColor = ThemeColor;
        [_sharePhotoButton setTitle:languageStringWithKey(@"分享二维码") forState:UIControlStateNormal];
        [_sharePhotoButton addTarget:self action:@selector(sharePhotoButtonclick:) forControlEvents:UIControlEventTouchUpInside];
        [_sharePhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sharePhotoButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _sharePhotoButton.layer.cornerRadius = 4;
        _sharePhotoButton.layer.masksToBounds = YES;
    }
    return _sharePhotoButton;
}
@end
