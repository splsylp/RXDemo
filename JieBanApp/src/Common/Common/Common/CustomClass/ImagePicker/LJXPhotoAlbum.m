//
//  LJXPhotoAlbum.m
//  LJXPhotoAlbum
//  GitHub:https://github.com/Li-JianXin/LJXPhotoAlbum
//  博客:http://www.jianshu.com/p/be40c92dd10f
//  Created by jianxin.li on 16/4/14.
//  Copyright © 2016年 m6go.com. All rights reserved.
//

#import "LJXPhotoAlbum.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "YYImageClipViewController.h"
#import "MSSBrowseActionSheet.h"

#define ScreenF [UIScreen mainScreen].bounds
#define ScreenW ScreenF.size.width
#define ScreenH ScreenF.size.height
#define IOS8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

// hanwei
#import "AlertSheet.h"

@interface LJXPhotoAlbum ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate,YYImageClipDelegate,RX_TZImagePickerControllerDelegate>

@property (nonatomic, copy) PhotoBlock photoBlock;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIViewController        *viewController;
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation LJXPhotoAlbum

- (instancetype)init {
    self = [super init];
    if (self) {
        _picker = [[UIImagePickerController alloc]init];
    }
    return self;
}

- (void)getPhotoAlbumOrTakeAPhotoWithController:(UIViewController *)viewController andIsEdit:(BOOL)isEdit andWithBlock:(PhotoBlock)photoBlock withResetBlock:(PhotoResetBlock)resetBlock {
    
    // hanwei fix
    
    self.photoBlock = photoBlock;
    self.viewController = viewController;
    self.isEdit = isEdit;
    if (K_RestoreAvatar && !KCNSSTRING_ISEMPTY([Common sharedInstance].getAvatar)) {
        if (IOS8) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *photoAlbumAction = [UIAlertAction actionWithTitle:languageStringWithKey(@"修改头像") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self loadImageWithController:viewController andIsEdit:isEdit andWithBlock:photoBlock];
                
            }];
            UIAlertAction *cemeraAction = [UIAlertAction actionWithTitle:languageStringWithKey(@"恢复默认头像") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // hanwei 2017.8.18
                AlertSheet *alertView = [[AlertSheet alloc] initWithNerVersion:nil withDexcription:nil withCancel:nil withFromPage:1 withChickBolck:^{
                    //请求服务器 重置头像
                    
                    if (resetBlock != nil) {
                        resetBlock();
                    }
                    
                }];
                [alertView showInView:nil];
                
            }];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:languageStringWithKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self getAlertActionType:0];
            }];
            [alertController addAction:photoAlbumAction];
            [alertController addAction:cemeraAction];
            [alertController addAction:cancleAction];
            [self.viewController presentViewController:alertController animated:YES completion:nil];
            

        } else {
            UIActionSheet *actionSheet;
            
            actionSheet  = [[UIActionSheet alloc] initWithTitle:languageStringWithKey(@"选择图像") delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles: languageStringWithKey(@"修改头像"), languageStringWithKey(@"恢复默认头像"), nil];
            
            actionSheet.tag = 9999;
            [actionSheet showInView:self.viewController.view];

        }
        
    } else {
        
        [self loadImageWithController:viewController andIsEdit:isEdit andWithBlock:photoBlock];
        
    }
    
//    [self loadImageWithController:viewController andIsEdit:isEdit andWithBlock:photoBlock];
    
}

- (void)loadImageWithController:(UIViewController *)viewController andIsEdit:(BOOL)isEdit andWithBlock:(PhotoBlock)photoBlock {
    
    self.photoBlock = photoBlock;
    self.viewController = viewController;
    self.isEdit = isEdit;

    MSSBrowseActionSheet *sheet = [[MSSBrowseActionSheet alloc] initWithTitleArray:@[languageStringWithKey(@"从相册中选择"),languageStringWithKey(@"拍照")] cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:^(NSInteger index) {
        if (index == MSSBrowseTypePhotos) {
            [self getAlertActionType:1];
        } else if (index == MSSBrowseTypePhotoAlbum) {
            [self getAlertActionType:2];
        }
    }];
    [sheet showInView:self.viewController.view];
}

- (void)loadAvatar {
   
}

- (void)getAlertActionType:(NSInteger)type {
    NSInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    switch (type) {
        case 1:
        {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
            break;
        case 2:
        {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
            break;
        case 0:
        {
            return;
        }
            break;
            
        default:
            break;
    }
    [self creatUIImagePickerControllerWithAlertActionType:sourceType];
    
}


#pragma mark - ActionSheet Delegte
- (void)actionSheet:(UIActionSheet *)actionSheetn didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheetn.tag == 9999) {
        UIActionSheet *actionSheet;
        if([self imagePickerControlerIsAvailabelToCamera]){
              actionSheet  = [[UIActionSheet alloc] initWithTitle:languageStringWithKey(@"选择图像") delegate:self cancelButtonTitle: languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"拍照"), languageStringWithKey(@"从相册选择"), nil];
        }else{
             actionSheet = [[UIActionSheet alloc] initWithTitle:languageStringWithKey(@"选择图像") delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"从相册选择"), nil];
        }
        [actionSheet showInView:self.viewController.view];
        
        return;
    }
    
    NSInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([self imagePickerControlerIsAvailabelToCamera]){
        switch (buttonIndex){
            case 0:
            {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
                break;
            case 1:
            {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
            }
                break;
            case 2:
                return;
        }
    } else {
        switch (buttonIndex) {
            case 0:
            {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
                break;
                
            default:
                break;
        }
    }
    [self creatUIImagePickerControllerWithAlertActionType:sourceType];
}


#pragma mark -  创建ImagePickerController
- (void)creatUIImagePickerControllerWithAlertActionType:(NSInteger)type {
    NSInteger sourceType = type;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (![self AVAuthorizationStatusIsGranted]) {
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if (IOS8 && authStatus == AVAuthorizationStatusDenied) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:languageStringWithKey(@"相机未授权") message:languageStringWithKey(@"请到设置-隐私-相机中修改") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:languageStringWithKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    return;
                }];
                [alertController addAction:comfirmAction];
                [self.viewController presentViewController:alertController animated:YES completion:nil];
            } else {
                if (authStatus == AVAuthorizationStatusDenied) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:languageStringWithKey(@"相机未授权") message:languageStringWithKey(@"请到设置-隐私-相机中修改") delegate:nil cancelButtonTitle:languageStringWithKey(@"确定") otherButtonTitles:nil, nil];
                    
                    [alert show];
                }
                return;
            }
        }else{
            [self showCamera];
            return;
        }
    }else {
        [self gotoSelectPhoto];
    }
}

- (void)showCamera {
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = NO;
    self.picker.navigationBar.translucent = NO;
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.viewController presentViewController:self.picker animated:YES completion:nil];
}

#pragma mark - 选择图片 RX_TZImagePickerController
- (void)gotoSelectPhoto{
    // 最多选取的图片个数
    NSInteger MaxImageCount = 1;
    // 每行显示的图片个数
    NSInteger columnNumber = 4;
    
    RX_TZImagePickerController *imagePickerVc = [[RX_TZImagePickerController alloc] initWithMaxImagesCount:MaxImageCount columnNumber:columnNumber delegate:self pushPhotoPickerVc:YES];
    //    pragma mark - 个性化设置，这些参数都可以不传，此时会走默认设置
    
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = 10; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    
    
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    //        imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = kScreenWidth - 2 * left;
    NSInteger top = (kScreenHeight - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.allowCrop = self.isEdit;
#pragma mark - 到这里为止
    // 你可以通过block或者代理，来得到用户选择的照片.
    __weak typeof(self)weak_self=self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage *image = photos.firstObject;
        if (self.photoBlock) {
            weak_self.photoBlock(image);
        }
    }];
    [imagePickerVc setDidFinishPickingGifImageHandle:^(UIImage *animatedImage, id sourceAssets) {
        UIImage *image = animatedImage;
        if (self.photoBlock) {
            weak_self.photoBlock(image);
        }
    }];
    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
    
}


// 判断硬件是否支持拍照
- (BOOL)imagePickerControlerIsAvailabelToCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 照机授权判断
- (BOOL)AVAuthorizationStatusIsGranted  {
    __block BOOL isGranted = NO;
    //判断是否授权相机
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (authStatus) {
        case 0: { //第一次使用，则会弹出是否打开权限
            [AVCaptureDevice requestAccessForMediaType : AVMediaTypeVideo completionHandler:^(BOOL granted) {
                //授权成功
                if (granted) {
                    isGranted = YES;
                    [self showCamera];
                }
                else{
                    isGranted = NO;
                }
            }];
        }
            break;
        case 1:{
            //还未授权
            isGranted = NO;
        }
            break;
        case 2:{
            //主动拒绝授权
            isGranted = NO;
        }
            break;
        case 3: {
            //已授权
            isGranted = YES;
        }
            break;
            
        default:
            break;
    }
    return isGranted;
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if (_isEdit) {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        YYImageClipViewController *imgCropperVC = [[YYImageClipViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f + kTotalBarHeight, kMainScreenWidth, kMainScreenWidth) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [picker pushViewController:imgCropperVC animated:NO];
    } else {
        UIImage *image = nil;
        if (_isEdit) {//获取编辑后的图片
            image = info[@"UIImagePickerControllerEditedImage"];
            if (!image) {
                image = info[UIImagePickerControllerEditedImage];
            }
        }else {
            image = info[@"UIImagePickerControllerOriginalImage"];
            if (!image) {
                image = info[UIImagePickerControllerOriginalImage];
            }
        }
        
        DDLogInfo(@"DELEGATE %@",image);
        if (self.photoBlock) {
            self.photoBlock(image);
        }
        [_picker dismissViewControllerAnimated:YES completion:nil];
    }
}

// 取消选择照片:
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DDLogInfo(@"取消图片选择");
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - YYImageCropperDelegate
- (void)imageCropper:(YYImageClipViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    DDLogInfo(@"DELEGATE %@",editedImage);
    if (self.photoBlock) {
        self.photoBlock(editedImage);
    }
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(YYImageClipViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
