//
//  CYLTabBarController.m
//  CYLTabBarController
//
//  v1.21.x Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 10/20/15.
//  Copyright © 2018 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLTabBarController.h"
#import "CYLTabBar.h"
#import <objc/runtime.h>
#import "UIViewController+CYLTabBarControllerExtention.h"
#import "UIControl+CYLTabBarControllerExtention.h"
#import "UIImage+CYLTabBarControllerExtention.h"
#if __has_include(<Lottie/Lottie.h>)
#import <Lottie/Lottie.h>
#else
#endif

#import "RXBaseNavgationController.h"
#import "KCConstants_string.h"
#import "HXInviteCountData.h"
#import "AppModel.h"

NSString *const CYLTabBarItemTitle = @"CYLTabBarItemTitle";
NSString *const CYLTabBarItemImage = @"CYLTabBarItemImage";
NSString *const CYLTabBarItemSelectedImage = @"CYLTabBarItemSelectedImage";
NSString *const CYLTabBarItemImageInsets = @"CYLTabBarItemImageInsets";
NSString *const CYLTabBarItemTitlePositionAdjustment = @"CYLTabBarItemTitlePositionAdjustment";
NSString *const CYLTabBarLottieURL = @"CYLTabBarLottieURL";
NSString *const CYLTabBarLottieSize = @"CYLTabBarLottieSize";

NSUInteger CYLTabbarItemsCount = 0;
NSUInteger CYLPlusButtonIndex = 0;
CGFloat CYLTabBarItemWidth = 0.0f;
CGFloat CYLTabBarHeight = 0.0f;

NSString *const CYLTabBarItemWidthDidChangeNotification = @"CYLTabBarItemWidthDidChangeNotification";
static void * const CYLTabImageViewDefaultOffsetContext = (void*)&CYLTabImageViewDefaultOffsetContext;

@interface CYLTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, assign, getter=isObservingTabImageViewDefaultOffset) BOOL observingTabImageViewDefaultOffset;
@property (nonatomic, assign, getter=shouldInvokeOnceViewDidLayoutSubViewsBlock) BOOL invokeOnceViewDidLayoutSubViewsBlock;
@property (nonatomic, strong) NSMutableArray<NSURL *> *lottieURLs;
@property (nonatomic, strong) NSMutableArray *lottieSizes;
@property (nonatomic, assign, getter=isLottieViewAdded) BOOL lottieViewAdded;

@end

@implementation CYLTabBarController

@synthesize viewControllers = _viewControllers;

#pragma mark -
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (CYL_IS_IPHONE_X) {
        self.tabBarHeight = 83;
    } 
    // 处理tabBar，使用自定义 tabBar 添加 发布按钮
    [self setUpTabBar];
    // KVO注册监听
    if (!self.isObservingTabImageViewDefaultOffset) {
        [self.tabBar addObserver:self forKeyPath:@"tabImageViewDefaultOffset" options:NSKeyValueObservingOptionNew context:CYLTabImageViewDefaultOffsetContext];
        self.observingTabImageViewDefaultOffset = YES;
    }
    [self createTip];
}



///add by 李晓杰
#pragma mark - 底部红点
- (void)createTip{
    ///总数量
    NSInteger count = self.viewControllers.count;
    NSInteger width = [UIScreen mainScreen].bounds.size.width / count;
    //消息数量显示
    _sessionUnread = [UIButton buttonWithType:UIButtonTypeCustom];
    _sessionUnread.frame = CGRectMake(width / 2 + 5, 3, 20 * FitThemeTabBarFont, 20 * FitThemeTabBarFont);
    _sessionUnread.backgroundColor = [UIColor colorWithRed:1.00f green:0.29f blue:0.25f alpha:1.00f];
    _sessionUnread.titleLabel.font = ThemeFontSmall;
    _sessionUnread.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [_sessionUnread setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sessionUnread setTitle:@"" forState:UIControlStateNormal];
    [_sessionUnread setTitle:@"" forState:UIControlStateHighlighted];
    [_sessionUnread setTitle:@"" forState:UIControlStateSelected];
    _sessionUnread.layer.cornerRadius = self.sessionUnread.frame.size.width / 2;
    _sessionUnread.layer.masksToBounds = YES;
    _sessionUnread.userInteractionEnabled = NO;
    [self.tabBar addSubview:_sessionUnread];

    _unreadImage = [[UIImageView alloc] initWithFrame:CGRectMake(width + width / 2 + 5,6, 9, 9)];
    _unreadImage.backgroundColor = [UIColor redColor];
    _unreadImage.layer.cornerRadius = 4.5;
    _unreadImage.layer.masksToBounds = YES;
    [self.tabBar addSubview:_unreadImage];


    _myAppStoreUnreadView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 + 11,6, 9, 9)];
    _myAppStoreUnreadView.backgroundColor = [UIColor redColor];
    _myAppStoreUnreadView.image = ThemeImage(@"myAppPoint");
    _myAppStoreUnreadView.layer.cornerRadius = 4.5;
    _myAppStoreUnreadView.layer.masksToBounds = YES;
    [self.tabBar addSubview:_myAppStoreUnreadView];


    _unreadFriendCount = [UIButton buttonWithType:UIButtonTypeCustom];
    _unreadFriendCount.frame = CGRectMake(width * 3 + width / 2 + 5, 3, 20 * FitThemeTabBarFont, 20 * FitThemeTabBarFont);
    _unreadFriendCount.backgroundColor =[UIColor colorWithRed:1.00f green:0.29f blue:0.25f alpha:1.00f];
    _unreadFriendCount.layer.cornerRadius = self.unreadFriendCount.frame.size.width/2;
    _unreadFriendCount.layer.masksToBounds = YES;
    _unreadFriendCount.userInteractionEnabled = NO;
    _unreadFriendCount.titleLabel.font = ThemeFontSmall;
    _unreadFriendCount.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [_unreadFriendCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_unreadFriendCount setTitle:@"" forState:UIControlStateNormal];
    [_unreadFriendCount setTitle:@"" forState:UIControlStateHighlighted];
    [_unreadFriendCount setTitle:@"" forState:UIControlStateSelected];
    [self.tabBar addSubview:self.unreadFriendCount];

    //一开始隐藏
    _sessionUnread.hidden = YES;
    _unreadImage.hidden = YES;
    _myAppStoreUnreadView.hidden = YES;
    _unreadFriendCount.hidden = YES;
    ///设置消息未读数
    [self sessionUnreadCount];
    [self getSportUnreadCount];
    [self updateMyAppStoreUnreadCount];
    [self inviteFriendNumberCount];
}
///红点移到前方
- (void)bringTipToFront{
    ///总数量
    NSInteger count = self.viewControllers.count;
    NSInteger width = [UIScreen mainScreen].bounds.size.width / count;
    _sessionUnread.frame = CGRectMake(width / 2 + 5, 3, 20 * FitThemeTabBarFont, 20 * FitThemeTabBarFont);
    _unreadImage.frame = CGRectMake(width + width / 2 + 5, 6, 9, 9);
    _myAppStoreUnreadView.frame = CGRectMake(kScreenWidth / 2 + 11,6, 9, 9);
    _unreadFriendCount.frame = CGRectMake(width * 3 + width / 2 + 5, 3, 20 * FitThemeTabBarFont, 20 * FitThemeTabBarFont);
    //移到前方
    [self.tabBar bringSubviewToFront:self.sessionUnread];
    [self.tabBar bringSubviewToFront:self.unreadImage];
    [self.tabBar bringSubviewToFront:self.myAppStoreUnreadView];
    [self.tabBar bringSubviewToFront:self.unreadFriendCount];
}

#pragma mark - 消息未读提示
- (void)sessionUnreadCount{
    NSInteger numConut = [[KitMsgData sharedInstance] getUnreadMessageCountFromSession];
    NSString *strCount = [NSString stringWithFormat:@"%ld",(long)numConut];
    if(numConut > 0) {
        if(numConut > 99) {
            strCount = @"...";
        }
        self.sessionUnread.hidden = NO;
    }else{
        strCount = @"";
        self.sessionUnread.hidden = YES;
    }
    [self.sessionUnread setTitle:strCount forState:UIControlStateNormal];
    [self.sessionUnread setTitle:strCount forState:UIControlStateHighlighted];
    [self.sessionUnread setTitle:strCount forState:UIControlStateSelected];
}
#pragma mark - 获取朋友圈未读个数
- (void)getSportUnreadCount{
    NSMutableDictionary *dict = [[AppModel sharedInstance] runModuleFunc:@"RXUser" :@"userForAccount:" :[NSArray arrayWithObject:@"currentUser"]];
    NSString *account = [dict objectForKey:@"RX_account_key"];

    UIViewController *friendVc = nil;
    for (RXBaseNavgationController *childVC in self.viewControllers) {
        UIViewController *vc = childVC.childViewControllers.firstObject;
        if ([vc.title isEqualToString:languageStringWithKey(@"同事圈")]) {
            friendVc = vc;
        }
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",KCreateSportMeetMessageFriendClass,account]] isEqualToString:KCreateSportMeetMessageFriendClass] ) {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            //创建未读提示框
            [friendVc.tabBarItem setBadgeValue:@""];
        } else{
            _unreadImage.hidden = NO;
        }
    } else {
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            //创建未读提示框
            [friendVc.tabBarItem setBadgeValue:nil];
        }else{
            _unreadImage.hidden = YES;
        }
    }
}
#pragma mark - 获取应用商店的未读数或者刷新
- (void)updateMyAppStoreUnreadCount {
    NSNumber *numConut = [[AppModel sharedInstance] runModuleFunc:@"Common" :@"getMyAppStoreUnreadCountStatus:" :@[[NSNumber numberWithInt:-1]]];
    BOOL result = [numConut boolValue];
    if(result) {
        _myAppStoreUnreadView.hidden = NO;
    } else {
        _myAppStoreUnreadView.hidden = YES;
    }
}
#pragma mark - 好友邀请未读提示
- (void)inviteFriendNumberCount{
    NSInteger numConut = [HXInviteCountData getCurrentInviteCount];
    NSString *strCount = [NSString stringWithFormat:@"%ld",(long)numConut];
    if(numConut > 0){
        if(numConut > 99){
            strCount = @"99+";
        }
        self.unreadFriendCount.hidden = NO;
    }else{
        strCount = @"";
        self.unreadFriendCount.hidden = YES;
    }
    [self.unreadFriendCount setTitle:strCount forState:UIControlStateNormal];
    [self.unreadFriendCount setTitle:strCount forState:UIControlStateHighlighted];
    [self.unreadFriendCount setTitle:strCount forState:UIControlStateSelected];
}
- (void)reload{
    self.tabBarHeight = TAB_BAR_HEIGHT;
    CGSize size = CGSizeMake(30 * FitThemeTabBarFont, 30 * FitThemeTabBarFont);
    for (int i = 0 ; i < self.viewControllers.count; i++) {
        UINavigationController *nvc = (UINavigationController *)self.viewControllers[i];
        NSDictionary *dic = self.tabBarItemsAttributes[i];

        UIImage *normalImage = [self getImageFromImageInfo:dic[CYLTabBarItemImage]];
        UIImage *selectedImage = [self getImageFromImageInfo:dic[CYLTabBarItemSelectedImage]];

        nvc.tabBarItem.image = [[self scaleToSize:normalImage size:size] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nvc.tabBarItem.selectedImage = [[self scaleToSize:selectedImage size:size] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:128/255. green:128/255. blue:128/255. alpha:1];
    normalAttrs[NSFontAttributeName] = ThemeFontMiddle;
    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = ThemeColor;
    selectedAttrs[NSFontAttributeName] = ThemeFontMiddle;
    // 设置文字属性
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];

    ///总数量
    NSInteger count = self.viewControllers.count;
    NSInteger width = [UIScreen mainScreen].bounds.size.width / count;
    self.sessionUnread.frame = CGRectMake(width / 2 + 5, 3, 20 * FitThemeTabBarFont, 20 * FitThemeTabBarFont);
    self.sessionUnread.layer.cornerRadius = self.sessionUnread.frame.size.width/2;
    self.sessionUnread.layer.masksToBounds = YES;
    self.sessionUnread.userInteractionEnabled = NO;
    self.sessionUnread.titleLabel.font = ThemeFontSmall;


    self.unreadFriendCount.frame = CGRectMake(width * 4 + width / 2 + 5, 3, 20 * FitThemeTabBarFont, 20 * FitThemeTabBarFont);
    self.unreadFriendCount.layer.cornerRadius = self.unreadFriendCount.frame.size.width/2;
    self.unreadFriendCount.layer.masksToBounds = YES;
    self.unreadFriendCount.userInteractionEnabled = NO;
    self.unreadFriendCount.titleLabel.font = ThemeFontSmall;

    [self bringTipToFront];
}

/**
 *  改变图片的大小
 *
 *  @param img     需要改变的图片
 *  @param newsize 新图片的大小
 *
 *  @return 返回修改后的新图片
 */
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(newsize, NO, [UIScreen mainScreen].scale);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
///end by 李晓杰





- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    [self updateSelectionStatusIfNeededForTabBarController:nil shouldSelectViewController:nil];
    UIControl *selectedControl = [self.tabBar cyl_tabBarButtonWithTabIndex:selectedIndex];
    if (selectedControl) {
        [self didSelectControl:selectedControl];
    }
}

- (void)setViewDidLayoutSubViewsBlockInvokeOnce:(BOOL)invokeOnce block:(CYLViewDidLayoutSubViewsBlock)viewDidLayoutSubviewsBlock  {
    self.viewDidLayoutSubviewsBlock = viewDidLayoutSubviewsBlock;
    self.invokeOnceViewDidLayoutSubViewsBlock = YES;
}

- (void)setViewDidLayoutSubViewsBlock:(CYLViewDidLayoutSubViewsBlock)viewDidLayoutSubviewsBlock {
    _viewDidLayoutSubviewsBlock = viewDidLayoutSubviewsBlock;
}

- (void)viewDidLayoutSubviews {
    [self.tabBar layoutSubviews];//Fix issue #93 #392
    CYLTabBar *tabBar =  (CYLTabBar *)self.tabBar;
    // add callback for visiable control, included all plusButton.
    [tabBar.cyl_visibleControls enumerateObjectsUsingBlock:^(UIControl * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
        //to avoid invoking didSelectControl twice, because plusChildViewControllerButtonClicked will invoke setSelectedIndex
        if ([control cyl_isChildViewControllerPlusButton]) {
            return;
        }
        SEL actin = @selector(didSelectControl:);
        [control addTarget:self action:actin forControlEvents:UIControlEventTouchUpInside];
        if (idx == self.selectedIndex) {
            control.selected = YES;
        }
    }];

    do {
        if (self.isLottieViewAdded) {
            break;
        }
        //FIXME:
        NSArray *subTabBarButtonsWithoutPlusButton = tabBar.cyl_subTabBarButtonsWithoutPlusButton;
        BOOL isLottieEnabled = [self isLottieEnabled];
        if(!isLottieEnabled || (subTabBarButtonsWithoutPlusButton.count != self.lottieURLs.count)) {
            self.lottieViewAdded = YES;
            break;
        }
        dispatch_async(dispatch_get_main_queue(),^{
            [subTabBarButtonsWithoutPlusButton enumerateObjectsUsingBlock:^(UIControl * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
                UIControl *tabButton = control;
                BOOL defaultSelected = NO;
                if (idx == self.selectedIndex) {
                    defaultSelected = YES;
                }
                [self addLottieImageWithControl:tabButton animation:defaultSelected defaultSelected:defaultSelected];
            }];
            self.lottieViewAdded = YES;
        });
        break;
    } while (NO);
    
    
    if (self.shouldInvokeOnceViewDidLayoutSubViewsBlock) {
        //在对象生命周期内，不添加 flag 属性的情况下，防止多次调进这个方法
        if (objc_getAssociatedObject(self, _cmd)) {
            return;
        } else {
            !self.viewDidLayoutSubviewsBlock ?: self.viewDidLayoutSubviewsBlock(self);
            objc_setAssociatedObject(self, _cmd, @"shouldInvokeOnceViewDidLayoutSubViewsBlock", OBJC_ASSOCIATION_RETAIN);
        }
        return;
    }
    !self.viewDidLayoutSubviewsBlock ?: self.viewDidLayoutSubviewsBlock(self);
}

- (void)viewWillLayoutSubviews {
    if (!(self.tabBarHeight > 0)) {
        return;
    }
    self.tabBar.frame = ({
        CGRect frame = self.tabBar.frame;
        CGFloat tabBarHeight = self.tabBarHeight;
        frame.size.height = tabBarHeight;
        frame.origin.y = self.view.frame.size.height - tabBarHeight;
        frame;
    });
}

- (void)setTabBarHeight:(CGFloat)tabBarHeight {
    _tabBarHeight = tabBarHeight;
    CYLTabBarHeight = tabBarHeight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *controller = self.selectedViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)controller;
        return navigationController.topViewController.supportedInterfaceOrientations;
    } else {
        return controller.supportedInterfaceOrientations;
    }
}

- (void)dealloc {
    UIButton<CYLPlusButtonSubclassing> *plusButton = CYLExternPlusButton;
    if (plusButton.superview && (plusButton.superview == self.tabBar)) {
        plusButton.selected = NO;
        [plusButton removeFromSuperview];
    }
    BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
    BOOL hasPlusChildViewController = [self hasPlusChildViewController] && isAdded;
    if (isAdded && hasPlusChildViewController && CYLPlusChildViewController.cyl_plusViewControllerEverAdded == YES) {
        [CYLPlusChildViewController cyl_setPlusViewControllerEverAdded:NO];
    }
    // KVO反注册
    if (self.isObservingTabImageViewDefaultOffset) {
        [self.tabBar removeObserver:self forKeyPath:@"tabImageViewDefaultOffset"];
    }
}

#pragma mark -
#pragma mark - public Methods

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {
    return [self initWithViewControllers:viewControllers
                   tabBarItemsAttributes:tabBarItemsAttributes
                             imageInsets:UIEdgeInsetsZero
                 titlePositionAdjustment:UIOffsetZero
                                 context:nil];
}

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    
    return [self initWithViewControllers:viewControllers
                   tabBarItemsAttributes:tabBarItemsAttributes
                             imageInsets:imageInsets
                 titlePositionAdjustment:titlePositionAdjustment
                                 context:nil];
}

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                context:(NSString *)context {
    if (self = [super init]) {
        
        _imageInsets = imageInsets;
        _titlePositionAdjustment = titlePositionAdjustment;
        _tabBarItemsAttributes = tabBarItemsAttributes;
        self.context = context;
        self.viewControllers = viewControllers;
    }
    return self;
}

- (void)setContext:(NSString *)context {
    if (context && context.length > 0) {
        _context = [context copy];
    } else {
        _context = NSStringFromClass([CYLTabBarController class]);
    }
    [self.tabBar setValue:_context forKey:@"context"];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                            context:(NSString *)context {
    return [[self alloc] initWithViewControllers:viewControllers
                           tabBarItemsAttributes:tabBarItemsAttributes
                                     imageInsets:imageInsets
                         titlePositionAdjustment:titlePositionAdjustment
            context:context];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    return [[self alloc] initWithViewControllers:viewControllers
                           tabBarItemsAttributes:tabBarItemsAttributes
                                     imageInsets:imageInsets
                         titlePositionAdjustment:titlePositionAdjustment
                                         context:nil];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {
    return [self tabBarControllerWithViewControllers:viewControllers
                               tabBarItemsAttributes:tabBarItemsAttributes
                                         imageInsets:UIEdgeInsetsZero
                             titlePositionAdjustment:UIOffsetZero];
}

- (void)hideTabBadgeBackgroundSeparator {
    [self hideTabBarShadowImageView];
}

- (void)hideTabBarShadowImageView {
    [self.tabBar layoutIfNeeded];
    UIImageView *imageView = self.tabBar.cyl_tabShadowImageView;
    imageView.hidden = YES;//iOS13+
    imageView.alpha = 0;
}

+ (BOOL)havePlusButton {
    if (CYLExternPlusButton) {
        return YES;
    }
    return NO;
}

+ (NSUInteger)allItemsInTabBarCount {
    NSUInteger allItemsInTabBar = CYLTabbarItemsCount;
    if ([CYLTabBarController havePlusButton]) {
        allItemsInTabBar += 1;
    }
    return allItemsInTabBar;
}

- (id<UIApplicationDelegate>)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (UIWindow *)rootWindow {
    UIWindow *result = nil;
    do {
        if ([self.appDelegate respondsToSelector:@selector(window)]) {
            result = [self.appDelegate window];
        }
        
        if (result) {
            break;
        }
    } while (NO);
    return result;
}

#pragma mark -
#pragma mark - Private Methods

/**
 *  利用 KVC 把系统的 tabBar 类型改为自定义类型。
 */
- (void)setUpTabBar {
    CYLTabBar *tabBar = [[CYLTabBar alloc] init];
    [self setValue:tabBar forKey:@"tabBar"];
    [tabBar cyl_setTabBarController:self];
}

- (BOOL)hasPlusChildViewController {
    NSString *context = CYLPlusChildViewController.cyl_context;
    BOOL isSameContext = [context isEqualToString:self.context] && (context && self.context); // || (!context && !self.context);
    BOOL hasPlusChildViewController = CYLPlusChildViewController && isSameContext;//&& !isAdded;
    return hasPlusChildViewController;
}

- (BOOL)isPlusViewControllerAdded:(NSArray *)viewControllers {
    if ([_viewControllers containsObject:CYLPlusChildViewController]) {
        return YES;
    }
    __block BOOL isAdded = NO;
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isEqualViewController:obj compairedViewController:CYLPlusChildViewController]) {
            isAdded = YES;
            *stop = YES;
            return;
        }
    }];
    return isAdded;;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers && _viewControllers.count) {
        for (UIViewController *viewController in _viewControllers) {
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
        BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
        BOOL hasPlusChildViewController = [self hasPlusChildViewController] && !isAdded;
        if (hasPlusChildViewController) {
            [CYLPlusChildViewController willMoveToParentViewController:nil];
            [CYLPlusChildViewController.view removeFromSuperview];
            [CYLPlusChildViewController removeFromParentViewController];
        }
    }
    
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        if ((!_tabBarItemsAttributes) || (_tabBarItemsAttributes.count != viewControllers.count)) {
            [NSException raise:NSStringFromClass([CYLTabBarController class]) format:@"The count of CYLTabBarControllers is not equal to the count of tabBarItemsAttributes.【Chinese】设置_tabBarItemsAttributes属性时，请确保元素个数与控制器的个数相同，并在方法`-setViewControllers:`之前设置"];
        }
        BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
        BOOL addedFlag = [CYLPlusChildViewController cyl_plusViewControllerEverAdded];
        BOOL hasPlusChildViewController = [self hasPlusChildViewController] && !isAdded && !addedFlag;
        if (hasPlusChildViewController) {
            NSMutableArray *viewControllersWithPlusButton = [NSMutableArray arrayWithArray:viewControllers];
            [viewControllersWithPlusButton insertObject:CYLPlusChildViewController atIndex:CYLPlusButtonIndex];
            _viewControllers = [viewControllersWithPlusButton copy];
            [CYLPlusChildViewController cyl_setPlusViewControllerEverAdded:YES];
            [CYLExternPlusButton cyl_setTabBarChildViewControllerIndex:CYLPlusButtonIndex];
        } else {
            _viewControllers = [viewControllers copy];
            [CYLExternPlusButton cyl_setTabBarChildViewControllerIndex:NSNotFound];
        }
        CYLTabbarItemsCount = [viewControllers count];
        CYLTabBarItemWidth = ([UIScreen mainScreen].bounds.size.width - CYLPlusButtonWidth) / (CYLTabbarItemsCount);
        NSUInteger idx = 0;
        for (UIViewController *viewController in _viewControllers) {
            NSString *title = nil;
            id normalImageInfo = nil;
            id selectedImageInfo = nil;
            UIOffset titlePositionAdjustment = UIOffsetZero;
            UIEdgeInsets imageInsets = UIEdgeInsetsZero;
            NSURL *lottieURL = nil;
            NSValue *lottieSizeValue = nil;
            if (viewController != CYLPlusChildViewController) {
                title = _tabBarItemsAttributes[idx][CYLTabBarItemTitle];
                normalImageInfo = _tabBarItemsAttributes[idx][CYLTabBarItemImage];
                selectedImageInfo = _tabBarItemsAttributes[idx][CYLTabBarItemSelectedImage];
                lottieURL = _tabBarItemsAttributes[idx][CYLTabBarLottieURL];
                lottieSizeValue = _tabBarItemsAttributes[idx][CYLTabBarLottieSize];

                NSValue *offsetValue = _tabBarItemsAttributes[idx][CYLTabBarItemTitlePositionAdjustment];
                UIOffset offset = [offsetValue UIOffsetValue];
                titlePositionAdjustment = offset;
                
                NSValue *insetsValue = _tabBarItemsAttributes[idx][CYLTabBarItemImageInsets];
                UIEdgeInsets insets = [insetsValue UIEdgeInsetsValue];
                imageInsets = insets;
            } else {
                idx--;
            }
            
            [self addOneChildViewController:viewController
                                  WithTitle:title
                            normalImageInfo:normalImageInfo
                          selectedImageInfo:selectedImageInfo
                    titlePositionAdjustment:titlePositionAdjustment
                                imageInsets:imageInsets
                                  lottieURL:lottieURL
                            lottieSizeValue:lottieSizeValue
             
             ];
            [[viewController cyl_getViewControllerInsteadOfNavigationController] cyl_setTabBarController:self];
            idx++;
        }
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [[viewController cyl_getViewControllerInsteadOfNavigationController] cyl_setTabBarController:nil];
        }
        _viewControllers = nil;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.f) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.tabBar setSelectedImageTintColor:tintColor];
#pragma clang diagnostic pop
    }
    self.tabBar.tintColor = tintColor;
}

/**
 *  添加一个子控制器
 *
 *  @param viewController    控制器
 *  @param title             标题
 *  @param normalImageInfo   图片
 *  @param selectedImageInfo 选中图片
 */
- (void)addOneChildViewController:(UIViewController *)viewController
                        WithTitle:(NSString *)title
                  normalImageInfo:(id)normalImageInfo
                selectedImageInfo:(id)selectedImageInfo
          titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                      imageInsets:(UIEdgeInsets)imageInsets
                        lottieURL:(NSURL *)lottieURL
                  lottieSizeValue:(NSValue *)lottieSizeValue {
    viewController.tabBarItem.title = title;
    CGSize placeholderSize = CGSizeMake(22, 22);
    UIImage *placeholderImage = [UIImage cyl_imageWithColor:[UIColor whiteColor] size:placeholderSize];
    UIImage *normalImage = nil;
    if (normalImageInfo) {
        normalImage = [self getImageFromImageInfo:normalImageInfo];
    } else {
        normalImage = placeholderImage;
    }
    viewController.tabBarItem.image = normalImage;

    UIImage *selectedImage = nil;
    if (selectedImageInfo) {
        selectedImage = [self getImageFromImageInfo:selectedImageInfo];
    } else {
        selectedImage = placeholderImage;
    }
    viewController.tabBarItem.selectedImage = selectedImage;

    if (self.shouldCustomizeImageInsets || ([self isNOTEmptyForImageInsets:imageInsets])) {
        UIEdgeInsets insets = (([self isNOTEmptyForImageInsets:imageInsets]) ? imageInsets : self.imageInsets);
        viewController.tabBarItem.imageInsets = insets;
    }
    if (self.shouldCustomizeTitlePositionAdjustment || [self isNOTEmptyForTitlePositionAdjustment:titlePositionAdjustment]) {
        UIOffset offset = (([self isNOTEmptyForTitlePositionAdjustment:titlePositionAdjustment]) ? titlePositionAdjustment : self.titlePositionAdjustment);
        viewController.tabBarItem.titlePositionAdjustment = offset;
    }
    if (lottieURL) {
        [self.lottieURLs addObject:lottieURL];
        NSValue *tureLottieSizeValue = nil;
        do {
            if (!CGSizeEqualToSize(CGSizeZero, [lottieSizeValue CGSizeValue])) {
                tureLottieSizeValue = lottieSizeValue;
                break;
            }
            if (normalImage && !CGSizeEqualToSize(CGSizeZero, normalImage.size)) {
                tureLottieSizeValue = [NSValue valueWithCGSize:normalImage.size];
                break;
            }
            tureLottieSizeValue = [NSValue valueWithCGSize:placeholderSize];
            break;
        } while (NO);
        [self.lottieSizes addObject:tureLottieSizeValue];
    }
    [self addChildViewController:viewController];
}

- (UIImage *)getImageFromImageInfo:(id)imageInfo {
    UIImage *image = nil;
    if ([imageInfo isKindOfClass:[NSString class]]) {
        image = ThemeImage(imageInfo);
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([imageInfo isKindOfClass:[UIImage class]]) {
        image = (UIImage *)imageInfo;
    }
    return image;
}

- (BOOL)shouldCustomizeImageInsets {
    BOOL shouldCustomizeImageInsets = [self isNOTEmptyForImageInsets:self.imageInsets];
    return shouldCustomizeImageInsets;
}

- (BOOL)shouldCustomizeTitlePositionAdjustment {
    BOOL shouldCustomizeTitlePositionAdjustment = [self isNOTEmptyForTitlePositionAdjustment:self.titlePositionAdjustment];
    return shouldCustomizeTitlePositionAdjustment;
}

- (BOOL)isNOTEmptyForImageInsets:(UIEdgeInsets)imageInsets {
    if (imageInsets.top != 0 || imageInsets.left != 0 || imageInsets.bottom != 0 || imageInsets.right != 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isNOTEmptyForTitlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    if (titlePositionAdjustment.horizontal != 0 || titlePositionAdjustment.vertical != 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isNOTEmptyForSize:(UIOffset)titlePositionAdjustment {
    if (titlePositionAdjustment.horizontal != 0 || titlePositionAdjustment.vertical != 0) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - KVO Method

// KVO监听执行
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context != CYLTabImageViewDefaultOffsetContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if(context == CYLTabImageViewDefaultOffsetContext) {
        CGFloat tabImageViewDefaultOffset = [change[NSKeyValueChangeNewKey] floatValue];
        [self offsetTabBarTabImageViewToFit:tabImageViewDefaultOffset];
    }
}

- (void)offsetTabBarTabImageViewToFit:(CGFloat)tabImageViewDefaultOffset {
    if (self.shouldCustomizeImageInsets) {
        return;
    }
    NSArray<UITabBarItem *> *tabBarItems = self.tabBar.items;
    [tabBarItems enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIEdgeInsets imageInset = UIEdgeInsetsMake(tabImageViewDefaultOffset, 0, -tabImageViewDefaultOffset, 0);
        obj.imageInsets = imageInset;
        if (!self.shouldCustomizeTitlePositionAdjustment) {
            obj.titlePositionAdjustment = UIOffsetMake(0, MAXFLOAT);
        }
    }];
}

#pragma mark - delegate
- (void)updateSelectionStatusIfNeededForTabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [self updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController shouldSelect:YES];
}

- (void)updateSelectionStatusIfNeededForTabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController shouldSelect:(BOOL)shouldSelect {
    [[viewController.tabBarItem cyl_tabButton] cyl_setShouldNotSelect:!shouldSelect];
    if (!shouldSelect) {
        return;
    }
    UIButton *plusButton = CYLExternPlusButton;
    if (!viewController) {
        viewController = self.selectedViewController;
    }
    BOOL isCurrentViewController = [self isEqualViewController:viewController compairedViewController:CYLPlusChildViewController];
    BOOL shouldConfigureSelectionStatus = (!isCurrentViewController);
    plusButton.selected = !shouldConfigureSelectionStatus;
    if (!shouldConfigureSelectionStatus) {
        [self.tabBar cyl_stopAnimationOfAllLottieView];
    }
}

- (BOOL)isEqualViewController:(UIViewController *)viewController compairedViewController:(UIViewController *)compairedViewController {
    if ([viewController isEqual:compairedViewController]) {
        return YES;
    }
    if ([[viewController cyl_getViewControllerInsteadOfNavigationController] isEqual:[compairedViewController cyl_getViewControllerInsteadOfNavigationController]]) {
        return YES;
    }
    return NO;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [self updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController];
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control {
}

- (BOOL)isLottieEnabled {
    NSInteger lottieURLCount = self.lottieURLs.count;
    BOOL isLottieEnabled = lottieURLCount > 0 ;
    return isLottieEnabled;
}

- (void)didSelectControl:(UIControl *)control {
    SEL actin = @selector(tabBarController:didSelectControl:);

    BOOL shouldSelectViewController =  YES;
    @try {
       shouldSelectViewController = (!control.cyl_shouldNotSelect) && (!control.hidden) ;
    } @catch (NSException *exception) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
    }
    
    BOOL isSelected = control.cyl_isSelected;
    if (shouldSelectViewController) {
        [self.tabBar.cyl_visibleControls enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = NO;
        }];
        control.selected = YES;
        UIControl *tabButton = control;
        BOOL isChildViewControllerPlusButton = [control cyl_isChildViewControllerPlusButton];
        BOOL isLottieEnabled = [self isLottieEnabled];
        if (!isSelected && isLottieEnabled && !isChildViewControllerPlusButton) {
            [self addLottieImageWithControl:tabButton animation:YES];
        }
    }
    
    if ([self.delegate respondsToSelector:actin] && shouldSelectViewController) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:actin withObject:self withObject:control ?: self.selectedViewController.tabBarItem.cyl_tabButton];
#pragma clang diagnostic pop
    }
}

- (void)addLottieImageWithControl:(UIControl *)control animation:(BOOL)animation {
    [self addLottieImageWithControl:control animation:animation defaultSelected:NO];
}

- (void)addLottieImageWithControl:(UIControl *)control animation:(BOOL)animation defaultSelected:(BOOL)defaultSelected {
     NSUInteger index = [self.tabBar.cyl_subTabBarButtonsWithoutPlusButton indexOfObject:control];
    if (NSNotFound == index) {
        return;
    }
    if (control.cyl_isPlusButton) {
        return;
    }
    NSURL *lottieURL = self.lottieURLs[index];
    NSValue *lottieSizeValue = self.lottieSizes[index];
    CGSize lottieSize = [lottieSizeValue CGSizeValue];
    [control cyl_addLottieImageWithLottieURL:lottieURL size:lottieSize];
    if (animation) {
        [self.tabBar cyl_animationLottieImageWithSelectedControl:control lottieURL:lottieURL size:lottieSize defaultSelected:defaultSelected];
    }
}

- (id)rootViewController {
    CYLTabBarController *tabBarController = nil;
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    UIViewController *rootViewController = [window.rootViewController cyl_getViewControllerInsteadOfNavigationController];;
    if ([rootViewController isKindOfClass:[CYLTabBarController class]]) {
        tabBarController = (CYLTabBarController *)rootViewController;
    }
    return tabBarController;
}

/**
 *  lazy load lottieURLs
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)lottieURLs {
    if (_lottieURLs == nil) {
        NSMutableArray *lottieURLs = [[NSMutableArray alloc] init];
        _lottieURLs = lottieURLs;
    }
    return _lottieURLs;
}

/**
 *  lazy load lottieSizes
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)lottieSizes {
    if (_lottieSizes == nil) {
        NSMutableArray *lottieSizes = [[NSMutableArray alloc] init];
        _lottieSizes = lottieSizes;
    }
    return _lottieSizes;
}

@end

@implementation NSObject (CYLTabBarControllerReferenceExtension)

- (void)cyl_setTabBarController:(CYLTabBarController *)tabBarController {
    //OBJC_ASSOCIATION_ASSIGN instead of OBJC_ASSOCIATION_RETAIN_NONATOMIC to avoid retain circle
    id __weak weakObject = tabBarController;
    id (^block)(void) = ^{ return weakObject; };
    objc_setAssociatedObject(self, @selector(cyl_tabBarController),
                             block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//TODO: 更新实现，多实例场景下进行栈操作，弹出最新一个。
- (CYLTabBarController *)cyl_tabBarController {
    CYLTabBarController *tabBarController;
    id (^block)(void) = objc_getAssociatedObject(self, @selector(cyl_tabBarController));
    tabBarController = (block ? block() : nil);
    if (tabBarController && [tabBarController isKindOfClass:[CYLTabBarController class]]) {
        return tabBarController;
    }
    if ([self isKindOfClass:[UIViewController class]] && [(UIViewController *)self parentViewController]) {
        tabBarController = [[(UIViewController *)self parentViewController] cyl_tabBarController];
        if ([tabBarController isKindOfClass:[CYLTabBarController class]]) {
            return tabBarController;
        }
    }
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    UIViewController *rootViewController = [window.rootViewController cyl_getViewControllerInsteadOfNavigationController];;
    if ([rootViewController isKindOfClass:[CYLTabBarController class]]) {
        tabBarController = (CYLTabBarController *)rootViewController;
    }
    return tabBarController;
}

@end
