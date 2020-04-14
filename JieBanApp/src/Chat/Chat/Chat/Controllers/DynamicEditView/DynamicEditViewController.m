//
//  DynamicEditViewController.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/3/24.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "DynamicEditViewController.h"
#import "RX_MLSelectPhotoPickerViewController.h"
#import "MLSelectPhotoAssets.h"
#import "CommonUserTools.h"
#import "UIImage+deal.h"

#define KHight 100

@interface DynamicEditViewController ()<UITextViewDelegate,RX_TZImagePickerControllerDelegate>

@property (nonatomic ,strong) UITextView * editTextView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic ,strong) UIButton *addImageViewBtn;
@property (nonatomic ,strong) UIButton *delButton;

@property (nonatomic, strong) NSMutableArray * imageData;

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) UILabel *limitNumberLabel; //字数限制
@end

@implementation DynamicEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = languageStringWithKey(@"图文编辑");
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageData = [NSMutableArray array];
    
    if([self.data isKindOfClass:[NSString class]]){
        
        self.sessionId = self.data;
    }
    
    [self setBarItemTitle:languageStringWithKey(@"发送") titleColor:APPMainUIColorHexString target:self action:@selector(barRightButtonClick) type:NavigationBarItemTypeRight];
    [self setBarItemTitle:languageStringWithKey(@"取消") titleColor:APPMainUIColorHexString target:self action:@selector(barLeftButtonClick) type:NavigationBarItemTypeLeft];
    
    self.editTextView = [[UITextView alloc] initWithFrame:CGRectMake(25, kTotalBarHeight + 10, kScreenWidth - 40, 160)];
    [self.editTextView becomeFirstResponder];
    self.editTextView.font = ThemeFontLarge;
    self.editTextView.delegate = self;
    [self.view addSubview:self.editTextView];
    
//    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(5, self.editTextView.bottom + 9, kScreenWidth - 10, 1)];
//    line.backgroundColor = [UIColor grayColor];
//    [self.view addSubview:line];
    
    UILabel *limitNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 80, self.editTextView.bottom +10, 80, 20)];
    limitNumberLabel.right = kScreenWidth-20;
    limitNumberLabel.backgroundColor = [UIColor clearColor];
    limitNumberLabel.text = @"0/150";
    limitNumberLabel.textColor = [UIColor colorWithHexString:@"999999"];
    limitNumberLabel.textAlignment = NSTextAlignmentRight;
    limitNumberLabel.font = ThemeFontMiddle;
    _limitNumberLabel = limitNumberLabel;
    [self.view addSubview:limitNumberLabel];
    
    self.addImageViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addImageViewBtn.frame = CGRectMake(30, self.editTextView.bottom + 25, KHight, KHight);
    [self.addImageViewBtn setImage:ThemeImage(@"message_btn_plus") forState:UIControlStateNormal];
    [self.addImageViewBtn addTarget:self action:@selector(addImageViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addImageViewBtn];
    
    UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
    delButton.frame = CGRectMake(0, 0, 15, 15);
    delButton.top = self.addImageViewBtn.top;
    delButton.right = self.addImageViewBtn.right;
    [delButton setImage:ThemeImage(@"message_btn_delete") forState:UIControlStateNormal];
    [delButton addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delButton];
    delButton.hidden = YES;
    self.delButton = delButton;
    
//    [_editTextView.rac_textSignal subscribeNext:^(NSString *x) {
//        if(x.length >= 150) {
//            self->_editTextView.text = [self->_editTextView.text substringToIndex:150];
//        }
//        self->_countLabel.text = [NSString stringWithFormat:@"%@/150", @(self->_editTextView.text.length)];
//    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.editTextView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView.text.length > 150) {
        NSString * aString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        _editTextView.text = [aString substringToIndex:150];
        if (isEnLocalization) {
            [SVProgressHUD showErrorWithStatus:@"Limit 150"];
        } else{
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"最多可输入150个字")];
        }
       
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 150) {
        _editTextView.text = [textView.text substringToIndex:150];
        if (isEnLocalization) {
            [SVProgressHUD showErrorWithStatus:@"Limit 150"];
        } else{
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"最多可输入150个字")];
        }
      _limitNumberLabel.text = [NSString stringWithFormat:@"150/150"];
    }else{
        NSInteger lastTextLength = textView.text.length;
        
        _limitNumberLabel.text = [NSString stringWithFormat:@"%ld/150",(long)lastTextLength];
    }
}

- (void)barLeftButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)barRightButtonClick{
    if (self.imageData.count<1) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"请选择一张图片")];
        return;
    }else if (self.editTextView.text.length<1){
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"请输入文字内容")];
        return;
    }
    for (UIImage *image in self.imageData) {
        NSString *imagePath = [self saveToDocment:image];
        ECImageMessageBody *imageBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
        [self sendMediaMessage:imageBody];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *@brief 发送图文类型消息
 */
- (void)sendMediaMessage:(ECFileMessageBody *)mediaBody{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = self.sessionId;
    mDic[@"type"] = @(ChatMessageTypeImageText);
    mDic[@"text"] = self.editTextView.text;
    [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:mediaBody dic:mDic];
}


- (void)createImage{
    UIImage * image = [self.imageData lastObject];
    [self.addImageViewBtn setImage:image forState:UIControlStateNormal];
    self.delButton.hidden = NO;
}

- (void)deleteImage {
    self.delButton.hidden = YES;
    [self.imageData removeAllObjects];
    [self.addImageViewBtn setImage:ThemeImage(@"message_btn_plus") forState:UIControlStateNormal];
}

-(void)addImageViewBtnClick{
#pragma mark - 选择图片 RX_TZImagePickerController
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
    imagePickerVc.allowPickingOriginalPhoto = NO;
    //        imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = kScreenWidth - 2 * left;
    NSInteger top = (kScreenHeight - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    
    // 设置首选语言 / Set preferred language
    // imagePickerVc.preferredLanguage = @"zh-Hans";
    
    // 设置languageBundle以使用其它语言 / Set languageBundle to use other language
    //         imagePickerVc.languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"tz-ru" ofType:@"lproj"]];
    
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        if (photos.count <= 0) {
            return;
        }
        [self.imageData removeAllObjects];
        for (UIImage *image in photos) {
            
            [self.imageData addObject:image];
            [self createImage];
        }
    }];
    [self presentViewController:imagePickerVc animated:NO completion:nil];
    
}
// eagle 下面方法不用了
- (void)addImageViewBtnClick2{
    // fixbug by liyijun 2017/08/08
    // 访问相册受限时添加提示语
    if (!IsHengFengTarget) { // 容信添加相册权限判断
        if (![CommonUserTools userPhotosAuthorizationForAlert]) { // 用户未受权
            DDLogInfo(@"用户未受权相册访问权限");
            return;
        }
    }

    RX_MLSelectPhotoPickerViewController *imagePicker = [[RX_MLSelectPhotoPickerViewController alloc] init];
    imagePicker.status = PickerViewShowStatusGroup;
    imagePicker.doneString = languageStringWithKey(@"确定");
    imagePicker.minCount = 1;
    [self presentViewController:imagePicker animated:NO completion:nil];

    [imagePicker show];
    imagePicker.callBack = ^(NSArray *imageSelects){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.imageData removeAllObjects];
                for (MLSelectPhotoAssets *asset in imageSelects) {
                    
                    UIImage *image = [RX_MLSelectPhotoPickerViewController getImageWithImageObj:asset];
                    [self.imageData addObject:image];

                }
                
                [self createImage];
            });
        });
        
        
    };
}

- (NSString *)saveToDocment:(UIImage *)image {
    return [image saveToDocumentAndThum];
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    return [aImage fixOrientation];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
