//
//  BaseViewController.m
//  BaseComponent
//
//  Created by wangming on 16/7/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseViewController.h"
#import "UIColor+Ext.h"
#import "Common.h"
#import "YXPExtension.h"
#import "KCConstants_string.h"
#import "KCConstants_API.h"
#import "KCAPPAuth_string.h"
#import "KitDialingData.h"
#import "KitDialingInfoData.h"
#import "LanguageTools.h"
#import "UIButton+Utils.h"

#import "AppModel.h"
#import "RXBaseNavgationController.h"
#import "MSSBrowseActionSheet.h"
#import "UIBarButtonItem+RXAdd.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "WaterMarkView.h"

@interface BaseViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) WaterMarkView *waterMarkView;

@property (nonatomic, strong) MSSBrowseActionSheet *sheet;

@end

@implementation BaseViewController

////2017yup 支持屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
- (BOOL)prefersStatusBarHidden{
    return NO;
}
//add2017yxp8.29
- (BOOL)shouldOrientationLandscape{
    return NO;
}
- (void)setOrientationLandscape{
    if([self shouldOrientationLandscape]){
        objc_setAssociatedObject(@"settingOrientationStatus",&settingOrientationStatuss, @{@"orientationLandscape":[NSNumber numberWithBool:YES]}, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)]) {
            
            [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
        }
    }
}

- (void)setOrientationPortrait{
    if([self shouldOrientationLandscape]){
        objc_setAssociatedObject(@"settingOrientationStatus", &settingOrientationStatuss, @{@"orientationLandscape":[NSNumber numberWithBool:NO]}, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)]) {
            
            [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
        }
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (UIView *)watermarkView {
    return [self getDefaultWatermarkView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (iOS13) {
        if (@available(iOS 13.0, *)) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent animated:animated];
        } else {
            // Fallback on earlier versions
        }
    }else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    }
    [self setOrientationLandscape];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //这个不能再base设置 导致子类 想给提示 然后pop的时候 会一闪就没了 子类要移除转圈圈 还是要在子类实现
//    [SVProgressHUD dismiss];
    [self setOrientationPortrait];
}

- (void)viewDidLoad {
    //add2017yxp8.31
    if(![self shouldOrientationLandscape]){
        objc_setAssociatedObject(@"settingOrientationStatus", &settingOrientationStatuss, @{@"orientationLandscape":[NSNumber numberWithBool:NO]}, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)]) {
            
            [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
        }
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
    //end2017yxp8.31
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    if (@available(iOS 11, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; //iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
    }
    if (!self.navigationController.navigationBar.translucent) {
        self.navigationController.navigationBar.translucent = YES;
    }
}


- (BOOL)shouldRecognizeTapGesture {
    return YES;
}
//  防止导航控制器只有一个rootViewcontroller时触发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //判断不是返回手势直接返回yes
    if (![gestureRecognizer isEqual:_panGesture]) {
        return YES;
    }
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        //解决与左滑手势冲突
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view];
        if (translation.x <= 0) {
            return NO;
        }
        //add2017yxp8.29横屏时手势不做返回
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if(orientation != UIDeviceOrientationPortrait){
            return NO;
        }
        //end2017yxp8.29横屏时手势不做返回
        //停止录音
        [[NSNotificationCenter defaultCenter] postNotificationName:@"panGestureShouldBegin" object:nil];;
        if (self.class == [UINavigationController class] && self.childViewControllers) {
            if (self.childViewControllers.count == 1) {
                return NO;
            }else{
                /// eagle 收起键盘，仿QQ
                [[UIApplication sharedApplication].keyWindow endEditing:YES];
                return YES;
            }
        }else if (self.navigationController && self.navigationController.childViewControllers) {
            if (self.navigationController.childViewControllers.count == 1) {
                return NO;
            }else{
                /// eagle 收起键盘，仿QQ
                [[UIApplication sharedApplication].keyWindow endEditing:YES];
                return YES;
            }
        }
    }
    /// eagle 收起键盘，仿QQ
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    return YES;
}

- (void)onClickLeftBarButtonItem {
    [self popViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSDictionary *)getValue:(NSDictionary* )dict{
    NSAssert(YES,@"如果想用，则必须在子类覆盖该函数，否则我会报错的哦");
    return nil;
}
- (void)setValue:(NSDictionary *)dict{
    NSAssert(YES,@"如果想用，则必须在子类覆盖该函数，否则我会报错的哦");
}
- (NSDictionary *)getValue{
    NSAssert(YES,@"如果想用，则必须在子类覆盖该函数，否则我会报错的哦");
    return nil;
}

- (void)show{
    if (self.displayType == 1) {
        [(RXBaseNavgationController*)self.container pushViewController:self animated:YES];
    }else if (self.displayType == 2){
        [(UIViewController *)self.container presentViewController:self animated:YES completion:nil];
    }
}
- (void)pppppppp{
    
}
- (void)goBack{
    if (self.displayType == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.displayType == 2){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)reload{
    NSAssert(YES,@"如果想用，则必须在子类覆盖该函数，否则我会报错的哦");
}
- (void)refresh{
    NSAssert(YES,@"如果想用，则必须在子类覆盖该函数，否则我会报错的哦");
}

#pragma mark - 设置NavigationController的左右按钮
- (void)setBarButtonWithNormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg target:(id)target action:(SEL)action type:(NavigationBarItemType)type {
    if (type == NavigationBarItemTypeLeft) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:target action:action image:ThemeColorImage(normalImg, [UIColor blackColor])];
    }else{
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:target action:action image:ThemeColorImage(normalImg, [UIColor blackColor])];
    }
}



- (void)addRightTwoBarButtonsWithFirstImage:(UIImage *)firstImage highlightedImg:(UIImage *)firsthighlightedImg target:(id)target firstAction:(SEL)firstAction secondImage:(UIImage *)secondImage highlightedImg:(UIImage *)secondhighlightedImg secondAction:(SEL)secondAction {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,80,44)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(40, 0, 40, 44);
    [firstButton setImage:ThemeColorImage(firstImage, [UIColor blackColor]) forState:UIControlStateNormal];
    [firstButton setImage:ThemeColorImage(firsthighlightedImg, [UIColor blackColor]) forState:UIControlStateHighlighted];
    [firstButton addTarget:target action:firstAction forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:firstButton];

    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(0, 0, 40, 44);
    [secondButton setImage:ThemeColorImage(secondImage, [UIColor blackColor]) forState:UIControlStateNormal];
    [secondButton setImage:ThemeColorImage(secondhighlightedImg, [UIColor blackColor]) forState:UIControlStateHighlighted];
    [secondButton addTarget:target action:secondAction forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:secondButton];

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
//    [firstButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, -15)];
//    [secondButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, -15)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (UIButton *)setNavRightButtonTitle:(NSString *)title enable:(BOOL)enable selector:(SEL)selecter{
    CGSize size = [[Common sharedInstance] widthForContent:title withSize:CGSizeMake(kScreenWidth, CGFLOAT_MAX) withLableFont:14];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, MAX(size.width + 10, 42), 27);
    
    [rightButton setTitle:title forState:UIControlStateNormal];
    rightButton.titleLabel.font = SystemFontMiddle;;
    rightButton.exclusiveTouch = YES;//关闭多点
    if (selecter) {
        [rightButton addTarget:self action:selecter forControlEvents:UIControlEventTouchUpInside];
    }

    UIView *rightBarButtonItemContentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,rightButton.frame.size.width + 16,rightButton.frame.size.height)];
    rightBarButtonItemContentView.backgroundColor = [UIColor clearColor];
    [rightBarButtonItemContentView addSubview:rightButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItemContentView];;
    if (enable) {
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setBackgroundColor:[UIColor colorWithHexString:APPMainUIColorHexString] forState:UIControlStateNormal];
        [rightButton setCornerRadius:5.0];
        rightButton.layer.cornerRadius =5.0;
    }else{
        [rightButton setTitleColor:[UIColor colorWithRed:0.47f green:0.47f blue:0.47f alpha:1.00f] forState:UIControlStateNormal];
        [rightButton setBorderColor:[UIColor colorWithRed:0.47f green:0.47f blue:0.47f alpha:1.00f] width:0.5];
        [rightButton setCornerRadius:5.0];
    }
    return rightButton;
}

- (void)setBarItemTitle:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type {
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:SystemFontLarge}];
    CGRect btnFrame = CGRectMake(0, 0, size.width + 20, 30);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [[button titleLabel] setFont:SystemFontLarge];
    
    [button setTitleColor:color ? [UIColor colorWithHexString:color] : [UIColor colorWithHexString:APPMainUIColorHexString] forState:UIControlStateNormal];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    if (type == NavigationBarItemTypeLeft) {
        self.navigationItem.leftBarButtonItem = buttonItem;
    } else {
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)setBarItemTitle:(NSString *)title titleColor:(UIColor *)color target:(id)target action:(SEL)action{
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:SystemFontLarge}];
    CGRect btnFrame = CGRectMake(0, 0, size.width + 20, 30);

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [[button titleLabel] setFont:SystemFontLarge];

    [button setTitleColor:color forState:UIControlStateNormal];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = buttonItem;
}


- (void)setBackButtonItemWithNormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg titleText:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type{
    CGFloat font = SystemFontLarge.pointSize;   //文字字体
    CGFloat height = 40;   //背景高度
    CGFloat offsetx = -10; //文字和返回按钮的距离
    //背景button
    UIButton * frameViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,0,height)];
//    frameViewButton.backgroundColor = [UIColor redColor];
    [frameViewButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    //返回按钮的图片
    CGRect btnFrame = CGRectMake(0, 0, height, height);
    if (type == NavigationBarItemTypeLeft && [[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
//        btnFrame = CGRectMake(-20, 0, height, height);
        btnFrame = CGRectMake(0, 0, height, height);
    }

    UIButton *imageView = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageView setFrame:btnFrame];
    [imageView setUserInteractionEnabled:NO];
    [imageView setImage:normalImg forState:UIControlStateNormal];
    [imageView  setImage:highlightedImg forState:UIControlStateHighlighted];
    [imageView.titleLabel setFont:[UIFont systemFontOfSize:font]];
    [imageView setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateNormal];
    [imageView setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateHighlighted];
    [imageView.imageView setContentMode:UIViewContentModeCenter];
    frameViewButton.frame = CGRectMake(0, 0,btnFrame.size.width, height);
    [frameViewButton addSubview:imageView];
    
    //返回按钮的文字
    if(title.length){
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:font] maxSize:CGSizeMake(300, font) lineBreakMode:NSLineBreakByWordWrapping];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+offsetx, (height - font)/2, size.width, font)];
        [titleLabel setTextColor:[UIColor colorWithHexString:color]];
        titleLabel.text = title;
        titleLabel.font = SystemFontMiddle;
        frameViewButton.frame = CGRectMake(0, 0,btnFrame.size.width+size.width+offsetx, height);
        [frameViewButton addSubview:titleLabel];
    }
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameViewButton];
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (type == NavigationBarItemTypeLeft) {
        self.navigationItem.leftBarButtonItem = buttonItem;
//        negativeSeperator.width = -15;
//        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSeperator, buttonItem, nil];
    }else{
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)setBarButtonItemWithNormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg titleText:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type{
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName :SystemFontLarge}];
    CGRect btnFrame = CGRectMake(10, 0, titleSize.width + 10 * fitScreenWidth, 40);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setBackgroundImage:normalImg forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:SystemFontLarge];
    [button setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithHexString:color] forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIView *frameView = [[UIView alloc] initWithFrame:btnFrame];
    [frameView addSubview:button];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameView];
    if (type == NavigationBarItemTypeLeft) {
        self.navigationItem.leftBarButtonItem = buttonItem;
    }else{
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

#pragma mark -
- (void)titleColor:(NSString *)colorHex{
    UILabel *titleLabel = (UILabel *)[self.navigationController.view viewWithTag :1000];
    [titleLabel setTextColor:[UIColor colorWithHexString:colorHex]];
}

- (void)pushViewController:(UIViewController *)viewController{
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushViewController:(NSString *)className withData:(id)data{
    [self pushViewController:className withData:data withNav:NO];
}

- (void)pushViewController:(NSString *)className withData:(id)data withNav:(BOOL)nav{
    BaseViewController *controller = [BaseViewController getController:className withData:data];
    controller.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popRootViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

+ (id)getController:(NSString *)className withData:(id)data{
    BaseViewController *controller = nil;
    controller = [[NSClassFromString(className) alloc] init];
    controller.data = data;
    return controller;
}

- (void)showProgressWithMsg:(NSString *)msg{
    [SVProgressHUD showWithStatus:msg];
}
- (void)closeProgress{
    [SVProgressHUD dismiss];
}

- (void)showProgress:(NSString *)msg afterDelay:(NSTimeInterval)delay{
    [SVProgressHUD showWithStatus:msg];
    [SVProgressHUD dismissWithDelay:delay];
}

- (void)showCustomToast:(NSString *)msg{
    [SVProgressHUD showErrorWithStatus:msg];
}

- (NSArray *)getDepartmentArray:(NSString *)departmentId{
    NSArray *array = [departmentId componentsSeparatedByString:@","];
    return array;
}

- (void)showAlertWithMsg:(NSString *)msg delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:delegate cancelButtonTitle: [[LanguageTools sharedInstance]getStringForKey:@"确定"] otherButtonTitles:nil];
    [alertView show];
}

- (UIView *)getDefaultWatermarkView {
    NSString *mobile = [[Common sharedInstance] getStaffNo];
    NSString *name = [[Common sharedInstance] getUserName];
    UIView * waterView = [self getWatermarkViewWithFrame:[UIScreen mainScreen].bounds mobile:mobile name:name backColor:[UIColor whiteColor]];
    return waterView;
}

// ---- 水印代码
- (UIView *)getWatermarkViewWithFrame:(CGRect)frame mobile:(NSString *)mobile name:(NSString *)name backColor:(UIColor *)color{
    
    if (isHaveWaterView == 1) {
        if (!self.waterMarkView) {
            if (![mobile isEqualToString:[Common sharedInstance].getMobile]) {
                mobile = [Common sharedInstance].getMobile;
            }
            if (mobile.length > 4) { // 只需要取号码后4位
                mobile = [mobile substringFromIndex:mobile.length - 4];
            }
            _waterMarkView = [[WaterMarkView alloc] initWithFrame:frame mobile:mobile userName:name backColor:color];
        }
        return _waterMarkView;
    } else if (isHaveWaterView == 0) {
        UIView *backView = [[UIView alloc] initWithFrame:frame];
        return backView;
    }
}


- (void)showSheetWithItems:(NSArray *)items inView:(UIView *)view selectedIndex:(void (^)(NSInteger))selected {
    MSSBrowseActionSheet *sheet = [[MSSBrowseActionSheet alloc] initWithTitleArray:items cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:selected];
    self.sheet = sheet;
    if (view) {
        [sheet showInView:view];
    }
    else {
        [sheet showInView:self.view];
    }
}

- (void)showSheetWithItems:(NSArray *)items inView:(UIView *)view selectedIndex:(void (^)(NSInteger))selected dismissCompletion:(void (^)(void))dismissCompletion{
    MSSBrowseActionSheet *sheet = [[MSSBrowseActionSheet alloc] initWithTitleArray:items cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:selected dismissCompletion:dismissCompletion];
    self.sheet = sheet;
    if (view) {
        [sheet showInView:view];
    }
    else {
        [sheet showInView:self.view];
    }
}

- (void)showSheetWithTip:(NSString *)tip items:(NSArray *)items inView:(UIView *)view selectedIndex:(void (^)(NSInteger index))selected {
    MSSBrowseActionSheet *sheet = [[MSSBrowseActionSheet alloc] initWithTip:tip titleArray:items cancelButtonTitle:languageStringWithKey(@"取消") didSelectedBlock:selected];
    self.sheet = sheet;
    if (view) {
        [sheet showInView:view];
    }
    else {
        [sheet showInView:self.view];
    }
}

- (void)updateSheetStyle {
    if (self.sheet) {
        [self.sheet updateFrame];
    }
}

- (void)dismissSheet {
    if (self.sheet) {
        [self.sheet disMissActionSheet];
    }
    self.sheet = nil;
}

///覆写模态兼容iOS13
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (iOS13) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}


@end

//----------其他 NSObject

@implementation NSObject (NSObjectFileTypeExtention)

+ (BOOL)isFileType_Doc:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"doc"] ||
        [[fileExtention lowercaseString] isEqualToString:@"docx"]) {
        return YES;
    }
    else{
        return NO;
    }
}
+ (BOOL)isFileType_PPT:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"ppt"] ||
        [[fileExtention lowercaseString] isEqualToString:@"pptx"]) {
        return YES;
    }
    else{
        return NO;
    }
}

+ (BOOL)isFileType_XLS:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"xls"] ||
        [[fileExtention lowercaseString] isEqualToString:@"xlsx"] ||
        [[fileExtention lowercaseString] isEqualToString:@"csv"]) {
        return YES;
    }
    else{
        return NO;
    }
}

+ (BOOL)isFileType_IMG:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"png"] ||
        [[fileExtention lowercaseString] isEqualToString:@"jpg"] ||
        [[fileExtention lowercaseString] isEqualToString:@"bmp"] ||
        [[fileExtention lowercaseString] isEqualToString:@"gif"] ||
        [[fileExtention lowercaseString] isEqualToString:@"jpeg"]) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isFileType_VIDEO:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"mov"] ||
        [[fileExtention lowercaseString] isEqualToString:@"mp4"] ||
        [[fileExtention lowercaseString] isEqualToString:@"flv"] ||
        [[fileExtention lowercaseString] isEqualToString:@"avi"] ||
        [[fileExtention lowercaseString] isEqualToString:@"mkv"] ||
        [[fileExtention lowercaseString] isEqualToString:@"rm"] ||
        [[fileExtention lowercaseString] isEqualToString:@"rmvb"] ||
        [[fileExtention lowercaseString] isEqualToString:@"mpeg"]) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isFileType_AUDIO:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"mp3"] ||
        [[fileExtention lowercaseString] isEqualToString:@"wma"] ||
        [[fileExtention lowercaseString] isEqualToString:@"wav"]) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isFileType_PDF:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"pdf"]) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isFileType_TXT:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"txt"]) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isFileType_ZIP:(NSString *)fileExtention{
    if ([[fileExtention lowercaseString] isEqualToString:@"zip"] ||
        [[fileExtention lowercaseString] isEqualToString:@"rar"]) {
        return YES;
    }else{
        return NO;
    }
}

//add2017yxp9.5
+ (NSString *)getFileTypeImageViewWithFileExtension:(NSString*)fileExtention{
    if ([NSObject isFileType_Doc:fileExtention]) {
        return @"FileTypeS_DOC";
    }else if ([NSObject isFileType_PPT:fileExtention]) {
        return @"FileTypeS_PPT";
    }else if ([NSObject isFileType_XLS:fileExtention]) {
        return @"FileTypeS_XLS";
    }else if ([NSObject isFileType_IMG:fileExtention]) {
        return @"FileTypeS_IMG";
    }else if ([NSObject isFileType_PDF:fileExtention]) {
        return @"FileTypeS_PDF";
    }else if ([NSObject isFileType_TXT:fileExtention]) {
        return @"FileTypeS_TXT";
    }else if ([NSObject isFileType_ZIP:fileExtention]) {
        return @"FileTypeS_ZIP";
    }else{
        return @"FileTypeS_XXX";
    }
}

//---------其他公用方法
//字节大小转换成显示字符串
+ (NSString *)dataSizeFormat:(NSString*)dataSizeString{
    if (dataSizeString && [dataSizeString isKindOfClass:[NSString class]]) {
        NSString *sizeString = [dataSizeString uppercaseString];
        NSRange rangeByte = [sizeString rangeOfString:@"B"];
        NSRange rangeKB = [sizeString rangeOfString:@"K"];
        NSRange rangeMB = [sizeString rangeOfString:@"M"];
        NSRange rangeGB = [sizeString rangeOfString:@"G"];
        if (rangeByte.length > 0 ||
            rangeKB.length > 0 ||
            rangeMB.length > 0 ||
            rangeGB.length > 0) {
            return dataSizeString;
        }else{
            CGFloat dataSize = [dataSizeString floatValue];
            if (dataSize <= 0) {
                return  [[LanguageTools sharedInstance] getStringForKey:@"未知大小"];
            }else if (0 < dataSize && dataSize < (1024.0)) {
                return [NSString stringWithFormat:@"%.0fByte",dataSize];
            }else if ((1024.0) <= dataSize && dataSize < (1024*1024.0)){
                return [NSString stringWithFormat:@"%.0fKB",dataSize/(1024.0)];
            }else if ((1024*1024.0) <= dataSize && dataSize < (1024*1024*1024.0)){
                return [NSString stringWithFormat:@"%.1fMB",dataSize/(1024*1024.0)];
            }else{
                return [NSString stringWithFormat:@"%.1fGB",dataSize/(1024*1024*1024.0)];
            }
        }
    }else{
        return [[LanguageTools sharedInstance]getStringForKey:@"未知大小"];
    }
}

@end

@implementation NSObject (SystemEvent)
/**
 *  调用系统打电话功能
 *  @param phonenumber 电话号码
 *  isSaveRecord  是否保存记录
 *  recordDic  记录数据
 */
+ (void)callSystenPhoneNumber:(NSString *)phonenumber isSaveRecord:(BOOL)isSaveRecord recordDic:(NSDictionary *)recordDic{
    
    NSString *string = [NSString stringWithFormat:@"tel://%@", phonenumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
    
    if (isSaveRecord) {
        //保存数据库
        KitDialingData *dialing = [[KitDialingData alloc] init];
        dialing.nickname = [recordDic objectForKey:@"member_name"]?[recordDic objectForKey:@"member_name"] : phonenumber;
        dialing.account = [recordDic objectForKey:@"account"];
        dialing.mobile = phonenumber;
        dialing.call_status = @"0";
        dialing.call_number = 1;
        NSDate *date = [NSDate date];
        NSTimeInterval timeInterval = [date timeIntervalSince1970];
        dialing.call_date = timeInterval;
        //通话数据 入库
        [KitDialingData updateDialingDataDB:dialing];
        
        KitDialingInfoData *infoData = [[KitDialingInfoData alloc]init];
        infoData.dialNickName = [recordDic objectForKey:@"member_name"]?[recordDic objectForKey:@"member_name"]:phonenumber;
        infoData.dialType = [[LanguageTools sharedInstance]getStringForKey:@"普通电话"];
        infoData.dialAccount = [recordDic objectForKey:@"account"];
        infoData.dialMobile = phonenumber;
        infoData.dialState = @"0";
        infoData.dialBeginTime = timeInterval;
        infoData.dialTime = @"";
        [KitDialingInfoData insertdialData:infoData];
    }
}

/**
 *  调用系统发送短信功能
 *
 *  @param phonenumber 电话号码
 */
+ (void)smsSystemPhoneNumber:(NSString *)phonenumber{
    NSString *string = [NSString stringWithFormat:@"sms://%@", phonenumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

@end

