//
//  YXPExtension.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "YXPExtension.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>

#import "KILocalizationManager.h"

#import "KKAlertView.h"
#import "KCConstants_API.h"

@implementation YXPExtension

@end
#pragma mark ==================================================
#pragma mark ==UIView
#pragma mark ==================================================
#define activityViewTag 1010110
#import <objc/runtime.h>

@implementation KKAuthorizedManager

/*
 检查是否授权【通讯录】
 #import <AddressBook/AddressBook.h>
 */
+ (BOOL)isAddressBookAuthorized_ShowAlert:(BOOL)showAlert{
    
    BOOL Authorized = NO;
    
    ABAuthorizationStatus author = ABAddressBookGetAuthorizationStatus();
    
    //用户尚未做出授权选择
    if (author == kABAuthorizationStatusNotDetermined) {
        __block BOOL accessGranted = NO;
        // 初始化并创建通讯录对象，记得释放内存
        ABAddressBookRef addressBook = nil;
        if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //dispatch_release(sema);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
        Authorized = accessGranted;
    }
    //其他原因未被授权——可能是家长控制权限
    else if (author == kABAuthorizationStatusRestricted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showAlert) {
                //app名称
                NSString *app_Name = @"";
                app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                if (!app_Name) {
                    app_Name = APP_NAME;
                }
                
//                NSString *message = [NSString stringWithFormat:@"《%@》%@%@%@",app_Name,languageStringWithKey(@"没有权限访问您的通讯录，请在 设置--→隐私--→通讯录 里面为", nil),app_Name,languageStringWithKey(@"开启权限", nil))];
                
                NSString *message = [NSString stringWithFormat:@"《%@》%@%@%@",app_Name,languageStringWithKey(@"没有权限访问您的通讯录，请在 设置--→隐私--→通讯录 里面为"),app_Name,languageStringWithKey(@"开启权限")];
                
                KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                [alertView show];
                //[alertView release];
                UIButton *button = [alertView buttonAtIndex:0];
                [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
            }
        });
        
        Authorized = NO;
    }
    //用户已经明确拒绝——拒绝访问
    else if (author == kABAuthorizationStatusDenied){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showAlert) {
                // app名称
                NSString *app_Name = @"";
                app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                if (!app_Name) {
                    app_Name = APP_NAME;
                }
                NSString *message = [NSString stringWithFormat:@"《%@》%@%@%@",app_Name,languageStringWithKey(@"没有权限访问您的通讯录，请在 设置--→隐私--→通讯录 里面为"),app_Name,languageStringWithKey(@"开启权限")];
                
                KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                [alertView show];
                UIButton *button = [alertView buttonAtIndex:0];
                [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
            }
        });
        Authorized = NO;
    }
    //用户已经授权同意——同意访问
    else if (author == kABAuthorizationStatusAuthorized) {
        Authorized = YES;
    }
    else {
        Authorized = NO;
    }
    
    return Authorized;
}

/*
 检查是否授权【相册】
 #import <AssetsLibrary/AssetsLibrary.h>
 */
+ (BOOL)isAlbumAuthorized_ShowAlert:(BOOL)showAlert{
    
    BOOL Authorized = NO;
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    
    //用户尚未做出授权选择
    if (author == ALAuthorizationStatusNotDetermined) {
        Authorized = NO;
    }
    //其他原因未被授权——可能是家长控制权限
    else if (author == ALAuthorizationStatusRestricted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showAlert) {
                //app名称
                NSString *app_Name = @"";
                app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                if (!app_Name) {
                    app_Name = APP_NAME;
                }
                
                NSString *message = [NSString stringWithFormat:@"《%@》%@《%@》%@",app_Name,languageStringWithKey(@"没有权限访问您的手机相册，请在 设置--→隐私--→照片 里面为"),app_Name,languageStringWithKey(@"开启权限。")];
                
                KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                [alertView show];
                UIButton *button = [alertView buttonAtIndex:0];
                [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
            }
        });
        
        Authorized = NO;
    }
    //用户已经明确拒绝——拒绝访问
    else if (author == ALAuthorizationStatusDenied){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showAlert) {
                // app名称
                NSString *app_Name = @"";
                app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                if (!app_Name) {
                    app_Name = APP_NAME;
                }
               
                NSString *message = [NSString stringWithFormat:@"《%@》%@《%@》%@",app_Name, languageStringWithKey(@"没有权限访问您的手机相册，请在 设置--→隐私--→照片 里面为"),app_Name,languageStringWithKey(@"开启权限。")];
                
                KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                [alertView show];
                UIButton *button = [alertView buttonAtIndex:0];
                [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
            }
        });
        Authorized = NO;
    }
    //用户已经授权同意——同意访问
    else if (author == ALAuthorizationStatusAuthorized) {
        Authorized = YES;
    }
    else {
        Authorized = NO;
    }
    
    return Authorized;
}

/*
 检查是否授权【相机】
 #import <AVFoundation/AVFoundation.h>
 */
+ (BOOL)isCameraAuthorized_ShowAlert:(BOOL)showAlert{
    
    BOOL Authorized = NO;
    
    AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    //用户尚未做出授权选择
    if (author == AVAuthorizationStatusNotDetermined) {
        __block BOOL accessGranted = NO;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
        Authorized = accessGranted;
    }
    //其他原因未被授权——可能是家长控制权限
    else if (author == AVAuthorizationStatusRestricted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showAlert) {
                //app名称
                NSString *app_Name = @"";
                app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                if (!app_Name) {
                    app_Name = APP_NAME;
                }
              
                    NSString *message = [NSString stringWithFormat:@"《%@》%@《%@》%@",app_Name, languageStringWithKey(@"没有权限访问您的相机，请在 设置--→隐私--→相机 里面为"),app_Name, languageStringWithKey(@"开启权限。")];
                    
                    KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                    [alertView show];
                    UIButton *button = [alertView buttonAtIndex:0];
                    [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
            }
        });
        
        Authorized = NO;
    }
    //用户已经明确拒绝——拒绝访问
    else if (author == AVAuthorizationStatusDenied){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showAlert) {
                // app名称
                NSString *app_Name = @"";
                app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                if (!app_Name) {
                    app_Name = APP_NAME;
                }

                    NSString *message = [NSString stringWithFormat:@"《%@》%@《%@》%@",app_Name,languageStringWithKey(@"没有权限访问您的相机，请在 设置--→隐私--→相机 里面为"),app_Name,languageStringWithKey(@"开启权限。")];
                    
                    KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                    [alertView show];
                    UIButton *button = [alertView buttonAtIndex:0];
                    [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
                
            }
        });
        Authorized = NO;
    }
    //用户已经授权同意——同意访问
    else if (author == AVAuthorizationStatusAuthorized) {
        Authorized = YES;
    }
    else {
        Authorized = NO;
    }
    
    return Authorized;
}


/*
 检查是否授权【地理位置】
 #import <MapKit/MapKit.h>
 */
+ (BOOL)isLocationAuthorized_ShowAlert:(BOOL)showAlert{
    
    BOOL Authorized = NO;
    
    if (![CLLocationManager locationServicesEnabled]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showAlert) {
                NSString *message = languageStringWithKey(@"您好，请检查您的定位服务是否被关闭。如果被关闭，请在手机设置中打开定位服务");
                KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:languageStringWithKey(@"温馨提示") subTitle:nil message:message delegate:self buttonTitles: languageStringWithKey(@"确定"),nil];
               
                [alertView show];
                UIButton *button = [alertView buttonAtIndex:0];
                [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
            }
        });
        Authorized = NO;
    }
    else{
        CLAuthorizationStatus author = [CLLocationManager authorizationStatus];
        
        //用户尚未做出授权选择
        if (author == kCLAuthorizationStatusNotDetermined) {
            
            CLLocationManager *myLocationManager = [[CLLocationManager alloc] init];//创建位置管理器
#ifdef __IPHONE_8_0
            if ([myLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [myLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                // choose one request according to your business.
                if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                    [myLocationManager requestAlwaysAuthorization];
                } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                    [myLocationManager  requestWhenInUseAuthorization];
                } else {
#ifdef DEBUG
                    NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
#endif
                }
            }
#endif
            Authorized = YES;
        }
        //其他原因未被授权——可能是家长控制权限
        else if (author == kCLAuthorizationStatusRestricted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (showAlert) {
                    //app名称
                    NSString *app_Name = @"";
                    app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                    if (!app_Name) {
                        app_Name = APP_NAME;
                    }
                    NSString *message = [NSString stringWithFormat:languageStringWithKey(@"请在系统设置中开启定位服务（设置>隐私>定位服务>开启%@）"),app_Name];
                    KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:languageStringWithKey(@"定位服务未开启") subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                    
                    [alertView show];
                    UIButton *button = [alertView buttonAtIndex:0];
                    [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
                }
            });
            
            Authorized = NO;
        }
        //用户已经明确拒绝——拒绝访问
        else if (author == kCLAuthorizationStatusDenied){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (showAlert) {
                    // app名称
                    NSString *app_Name = @"";
                    app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                    if (!app_Name) {
                        app_Name = APP_NAME;
                    }
                    NSString *message = [NSString stringWithFormat:@"%@%@",languageStringWithKey(@"请在系统设置中开启定位服务 设置>隐私>定位服务>开启"),app_Name];
                    KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:languageStringWithKey(@"定位服务未开启") subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                    
                    [alertView show];
                    UIButton *button = [alertView buttonAtIndex:0];
                    [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
                }
            });
            Authorized = NO;
        }
        //用户已经授权同意——同意访问【始终】
        else if (author == kCLAuthorizationStatusAuthorizedAlways) {
            Authorized = YES;
        }
        //用户已经授权同意——同意访问【使用期间】
        else if (author == kCLAuthorizationStatusAuthorizedWhenInUse) {
            Authorized = YES;
        }
        else {
            Authorized = NO;
        }
    }
    
    return Authorized;
}

/*
 检查是否授权【麦克风】
 #import <AVFoundation/AVFoundation.h>
 */
+ (BOOL)isMicrophoneAuthorized_ShowAlert:(BOOL)showAlert{
    
    __block BOOL Authorized = NO;
    
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        __block BOOL accessGranted = NO;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [avSession requestRecordPermission:^(BOOL available) {
            accessGranted = available;
            if (!available) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (showAlert) {
                        //app名称
                        NSString *app_Name = @"";
                        app_Name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                        if (!app_Name) {
                            app_Name = APP_NAME;
                        }
     
                            NSString *message = [NSString stringWithFormat:@"《%@》%@《%@》%@",app_Name, languageStringWithKey(@"没有权限访问您的麦克风，请在 设置--→隐私--→麦克风 里面为"),app_Name, languageStringWithKey(@"开启权限。")];
                            KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:nil subTitle:nil message:message delegate:self buttonTitles:languageStringWithKey(@"确定"),nil];
                            [alertView show];
                            UIButton *button = [alertView buttonAtIndex:0];
                            [button setTitleColor:MainTheme_GreenColor forState:UIControlStateNormal];
                        
                    }
                });
            }
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
        Authorized = accessGranted;
    }
    return Authorized;
}

/*
 检查是否授权【通知中心】
 */
+ (BOOL)isNotificationAuthorized{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationType types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
        return (types & UIRemoteNotificationTypeAlert);
    }
    else
    {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return (types & UIRemoteNotificationTypeAlert);
    }
}



@end


@implementation UIView (YXPUIViewExtension)

- (void)setTagInfo:(id)tagInfo{
    objc_setAssociatedObject(self, @"tagInfo", tagInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)tagInfo {
    return objc_getAssociatedObject(self, @"tagInfo");
}

- (UIImage *)snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    //    if (UIGraphicsBeginImageContextWithOptions != NULL) {
    //        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    //    } else {
    //        UIGraphicsBeginImageContext(self.bounds.size);
    //    }
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)clearBackgroundColor {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setBackgroundImage:(UIImage *)image {
    UIColor *color = [UIColor colorWithPatternImage:image];
    [self setBackgroundColor:color];
}

- (void)setIndex:(NSInteger)index {
    if (self.superview != nil) {
        [self.superview insertSubview:self atIndex:index];
    }
}

- (void)bringToFront {
    if (self.superview != nil) {
        [self.superview bringSubviewToFront:self];
    }
}

- (void)sendToBack {
    if (self.superview != nil) {
        [self.superview sendSubviewToBack:self];
    }
}

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width {
    [self.layer setBorderWidth:width];
    [self.layer setBorderColor:color.CGColor];
}

- (void)setCornerRadius:(CGFloat)radius {
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:radius];
}

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset blurRadius:(CGFloat)blurRadius {
    [self.layer setShadowColor:color.CGColor];
    [self.layer setShadowOpacity:opacity];
    [self.layer setShadowOffset:offset];
    [self.layer setShadowRadius:blurRadius];
}

- (UIActivityIndicatorView *)activityIndicatorView {
    UIActivityIndicatorView *view = (UIActivityIndicatorView *)[self viewWithTag:activityViewTag];
    if (view == nil) {
        view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [view setTag:activityViewTag];
        CGFloat width = 100;
        CGFloat height = 100;
        CGFloat x = (CGRectGetWidth(self.frame) - width) / 2;
        CGFloat y = (CGRectGetHeight(self.frame) - height) / 2;
        [view setFrame:CGRectMake(x, y, width, height)];
        [self addSubview:view];
    }
    return view;
}

- (UIViewController *)viewController {
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

//- (id)initWithFrame:(CGRect)frame startHexColor:(NSString*)startHexColor endHexColor:(NSString*)endHexColor{
//    self = [self initWithFrame:frame];
//    if (self) {
//        if (startHexColor && endHexColor) {
//            CAGradientLayer *gLayer = [CAGradientLayer layer];
//            gLayer.frame = self.bounds;
//            gLayer.colors =     [NSArray arrayWithObjects:
//                                 (id)[UIColor hexColorToUIColor:startHexColor].CGColor,
//                                 (id)[UIColor hexColorToUIColor:endHexColor].CGColor, nil];
//            [self.layer insertSublayer:gLayer atIndex:0];
//        }
//        else{
//            self.backgroundColor = [UIColor darkGrayColor];
//        }
//    }
//    return self;
//}

- (void)setBackgroundColorFromColor:(UIColor*)startUIColor toColor:(UIColor*)endUIColor direction:(UIViewGradientColorDirection)direction{
    
    if (! (startUIColor && endUIColor)) {
        return;
    }
    
    if ([[self.layer sublayers] count]>0 &&  [[[self.layer sublayers] objectAtIndex:0] isKindOfClass:[CAGradientLayer class]]) {
        [[[self.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
    }
    
    
    CAGradientLayer *gLayer = [CAGradientLayer layer];
    gLayer.colors =     [NSArray arrayWithObjects:
                         (id)startUIColor.CGColor,
                         (id)endUIColor.CGColor, nil];
    
    if (direction==UIViewGradientColorDirection_TopBottom) {
        gLayer.frame = self.bounds;
    }
    else if (direction==UIViewGradientColorDirection_BottomTop){
        gLayer.frame = self.bounds;
        [gLayer setValue:[NSNumber numberWithDouble:M_PI] forKeyPath:@"transform.rotation.z"];
    }
    else if (direction==UIViewGradientColorDirection_LeftRight){
        gLayer.frame = CGRectMake(-(self.frame.size.height/2.0-self.frame.size.width/2.0), self.frame.size.height/2.0-self.frame.size.width/2.0, self.bounds.size.height, self.bounds.size.width);
        [gLayer setValue:[NSNumber numberWithDouble:-M_PI/2] forKeyPath:@"transform.rotation.z"];
    }
    else if (direction==UIViewGradientColorDirection_RightLeft){
        gLayer.frame = CGRectMake(-(self.frame.size.height/2.0-self.frame.size.width/2.0), self.frame.size.height/2.0-self.frame.size.width/2.0, self.bounds.size.height, self.bounds.size.width);
        [gLayer setValue:[NSNumber numberWithDouble:M_PI/2] forKeyPath:@"transform.rotation.z"];
    }
    else{
        gLayer.frame = self.bounds;
        [gLayer setValue:[NSNumber numberWithDouble:M_PI/2] forKeyPath:@"transform.rotation.z"];
    }
    
    [self.layer insertSublayer:gLayer atIndex:0];
    [gLayer setNeedsDisplay];
}

-(UIImage *)getImageFromSelf{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//=================设置遮罩相关=================

- (void)setBezierPath:(UIBezierPath *)bezierPath{
    objc_setAssociatedObject(self, @"bezierPath", bezierPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIBezierPath *)bezierPath {
    return objc_getAssociatedObject(self, @"bezierPath");
}

- (void)setMaskWithPath:(UIBezierPath*)path {
    [self setBezierPath:path];
    [self setMaskWithPath:path withBorderColor:nil borderWidth:0];
}

- (void)setMaskWithPath:(UIBezierPath*)path withBorderColor:(UIColor*)borderColor borderWidth:(float)borderWidth{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [path CGPath];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.frame = self.bounds;
    self.layer.mask = maskLayer;
    
    if (borderColor && borderWidth>0) {
        NSMutableArray *oldLayers = [NSMutableArray array];
        for (CALayer *layer in [self.layer sublayers]) {
            if ([layer isKindOfClass:[CAShapeLayer class]]) {
                [oldLayers addObject:layer];
            }
        }
        
        for (NSInteger i=0; i<[oldLayers count]; i++) {
            CALayer *layer = (CALayer*)[oldLayers objectAtIndex:i];
            [layer removeFromSuperlayer];
        }
        
        CAShapeLayer *maskBorderLayer = [[CAShapeLayer alloc] init];
        maskBorderLayer.path = [path CGPath];
        maskBorderLayer.fillColor = [[UIColor clearColor] CGColor];
        maskBorderLayer.strokeColor = [borderColor CGColor];
        maskBorderLayer.lineWidth = borderWidth;
        [self.layer addSublayer:maskBorderLayer];
    }
}

- (BOOL)containsPoint:(CGPoint)point{
    return [[self bezierPath] containsPoint:point];
}

@end
#pragma mark ==================================================
#pragma mark ==NSString
#pragma mark ==================================================
@implementation NSDictionary (YXPStringExtension)

//转成String类型
-(NSString*)getStringForKey:(NSString*)key
{
    id retObj = [NSString string];
    
    if (nil != key)
    {
        NSDictionary* dict = (NSDictionary*)self;
        retObj = [dict objectForKey:key];
        
        if ([retObj isKindOfClass:[NSNumber class]])
        {
            retObj = [retObj stringValue];
        }
        
        if (![retObj isKindOfClass:[NSString class]])
        {
            retObj = [NSString string];
        }
    }
    
    return retObj;
}

@end


#pragma mark ==================================================
#pragma mark == NSData
#pragma mark ==================================================

@implementation NSData (KKNSDataExtension)


//将图片压缩到指定大小 imageArray UIImage数组，imageDataSize 图片数据大小(单位KB)，比如100KB
+ (void)convertImage:(NSArray*)imageArray toDataSize:(CGFloat)imageDataSize
convertImageOneCompleted:(KKImageConvertImageOneCompletedBlock)completedOneBlock
KKImageConvertImageAllCompletedBlock:(KKImageConvertImageAllCompletedBlock)completedAllBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        for (NSInteger i=0; i<[imageArray count]; i++) {
            
            //原始图片==================================================
            UIImage *originalImage_in =[[imageArray objectAtIndex:i] copy];
            NSData *originalImageData_in = UIImageJPEGRepresentation(originalImage_in,1);
            CGFloat sizeKB = [originalImageData_in length]/1024.00;
            
            for (float i=1.0;sizeKB>imageDataSize;) {
                i=i-0.1;
                if (i<0 || originalImage_in.size.width*i<=kScreenWidth || originalImage_in.size.height<=kScreenHeight) {
                    break;
                }
                originalImage_in = [originalImage_in convertImageToScale:i];
                originalImageData_in = UIImageJPEGRepresentation(originalImage_in,1);
                sizeKB = [originalImageData_in length]/1024.00;
            }
            
            //主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                completedOneBlock(originalImageData_in,i);
            });
            
        }
        
        //主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            completedAllBlock();
        });
    });
    
}

@end

#pragma mark ==================================================
#pragma mark ==UIImageView
#pragma mark ==================================================
#import <ImageIO/ImageIO.h>

@implementation UIImageView (Extension)

- (void)showImageData:(NSData*)imageData{
    if ([[UIImage contentTypeExtensionForImageData:imageData] isEqualToString:UIImageExtensionType_GIF]) {
        NSMutableArray *frames = nil;
        CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        double total = 0;
        CGFloat width = 0;
        CGFloat height = 0;
        
        NSTimeInterval gifAnimationDuration;
        if (src) {
            size_t l = CGImageSourceGetCount(src);
            if (l >= 1){
                frames = [NSMutableArray arrayWithCapacity: l];
                for (size_t i = 0; i < l; i++) {
                    CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
                    NSDictionary *dict = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, 0, NULL));
                    if (dict){
                        width = [[dict objectForKey: (NSString*)kCGImagePropertyPixelWidth] floatValue];
                        height = [[dict objectForKey: (NSString*)kCGImagePropertyPixelHeight] floatValue];
                        NSDictionary *tmpdict = [dict objectForKey: (NSString*)kCGImagePropertyGIFDictionary];
                        total += [[tmpdict objectForKey: (NSString*)kCGImagePropertyGIFDelayTime] doubleValue] * 100;
                    }
                    if (img) {
                        [frames addObject: [UIImage imageWithCGImage: img]];
                        CGImageRelease(img);
                    }
                }
                gifAnimationDuration = total / 100;
                
                CGRect oldFrame = self.frame;
                self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, width, height);
                self.center = CGPointMake(oldFrame.origin.x+width/2.0, height/2.0);
                self.animationImages = frames;
                self.animationDuration = gifAnimationDuration;
                [self startAnimating];
            }
            
            CFRelease(src);
        }
    }
    else{
        self.image = [UIImage imageWithData:imageData];
        [self stopAnimating];
    }
}

- (void)showImageData:(NSData*)imageData inFrame:(CGRect)rect{
    if ([[UIImage contentTypeExtensionForImageData:imageData] isEqualToString:UIImageExtensionType_GIF]) {
        NSMutableArray *frames = nil;
        CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        
        double total = 0;
        
        NSTimeInterval gifAnimationDuration;
        if (src) {
            size_t l = CGImageSourceGetCount(src);
            if (l >= 1){
                frames = [NSMutableArray arrayWithCapacity: l];
                for (size_t i = 0; i < l; i++) {
                    CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
                    NSDictionary *dict = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, 0, NULL));
                    if (dict){
                       
                        NSDictionary *tmpdict = [dict objectForKey: (NSString*)kCGImagePropertyGIFDictionary];
                        total += [[tmpdict objectForKey: (NSString*)kCGImagePropertyGIFDelayTime] doubleValue] * 100;
                    }
                    if (img) {
                        [frames addObject: [UIImage imageWithCGImage: img]];
                        CGImageRelease(img);
                    }
                }
                gifAnimationDuration = total / 100;
                
                self.frame = rect;
                self.animationImages = frames;
                self.animationDuration = gifAnimationDuration;
                [self startAnimating];
            }
            CFRelease(src);
        }
    }
    else{
        self.frame = rect;
        self.image = [UIImage imageWithData:imageData];
    }
}

@end

#pragma mark ==================================================
#pragma mark ==UIImage
#pragma mark ==================================================
CGFloat KKDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat KKRadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation UIImage (KKUIImageExtension)

//取消searchbar背景色
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIView *view = [[UIView alloc]initWithFrame:rect];
    view.backgroundColor = color;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, view.layer.contentsScale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *) contentTypeForImageData:(NSData *)data{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x42:
            return @"image/bmp";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+ (NSString *) contentTypeExtensionForImageData:(NSData *)data{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return UIImageExtensionType_JPG;
        case 0x89:
            return UIImageExtensionType_PNG;
        case 0x42:
            return UIImageExtensionType_BMP;
        case 0x47:
            return UIImageExtensionType_GIF;
        case 0x49:
        case 0x4D:
            return UIImageExtensionType_TIFF;
    }
    return @"";
}

- (UIImage*)convertImageToScale:(double)scale{
    CGSize newImageSize = CGSizeMake(self.size.width * scale, self.size.height * scale);
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(newImageSize, 1.0, 1.0);
    //    UIGraphicsBeginImageContext(newImageSize);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0,0, newImageSize.width, newImageSize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)watermarkImage:(NSString *)text{
    
    
    
    //1.获取上下文
    
    UIGraphicsBeginImageContext(self.size);
    
    
    
    //2.绘制图片
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    
    CGFloat width = 120*fitScreenWidth/kScreenWidth*self.size.width;
    CGFloat height = 100/kScreenHeight*self.size.height;
    UIFont *font = ThemeFontLarge;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    
    //文字的属性
    
    NSDictionary *dic = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:[UIColor colorWithWhite:0.667 alpha:.3]};
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(c, -M_PI/6);
    
    for (int x = 0; x*width<self.size.width; x++) {
        for (int y = 0; y*height<self.size.height; y++) {
            //3.绘制水印文字
            
            CGRect rect = CGRectMake(x*width+(y+1)%2*(width/2), y*height, width, height);

            rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(M_PI/6));
            //将文字绘制上去
            
            [text drawInRect:rect withAttributes:dic];
            
        }
    }
    
    
    //4.获取绘制到得图片
    
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    //5.结束图片的绘制
    
    UIGraphicsEndImageContext();
    
    
    
    return watermarkImage;
    
}

@end

#pragma mark ==================================================
#pragma mark ==NSBundle
#pragma mark ==================================================
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation NSBundle (KKNSBundleExtension)

/*Bundle相关*/
+ (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)bundleName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSString *)bundleBuildVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)bundleVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (float)bundleMiniumOSVersion {
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"MinimumOSVersion"] floatValue];
}

+ (NSString *)bundlePath {
    return [[NSBundle mainBundle] bundlePath];
}

/*编译信息相关*/
+ (int)buildXcodeVersion {
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"DTXcode"] intValue];
}

+ (BOOL)isOpenPushNotification{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    return (types);
#else
    return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
#endif
}


/*路径相关*/
+ (NSString *)homeDirectory {
    return NSHomeDirectory();
}

+ (NSString *)documentDirectory {
    return [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
}

+ (NSString *)libaryDirectory {
    return [NSString stringWithFormat:@"%@/Library", NSHomeDirectory()];
}

+ (NSString *)tmpDirectory {
    return [NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()];
}

+ (NSString *)temporaryDirectory {
    return NSTemporaryDirectory();
}

+ (NSString *)cachesDirectory {
    return [NSString stringWithFormat:@"%@/Library/Caches", NSHomeDirectory()];
}
@end

#pragma mark ==================================================
#pragma mark ==KKNSNullExtension
#pragma mark ==================================================
#import <QuartzCore/QuartzCore.h>

@implementation UIButton (Extension)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)controlState{
    
    UIImage *image = [UIImage imageWithColor:backgroundColor size:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
    [self setBackgroundImage:image forState:controlState];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state contentMode:(UIViewContentMode)contentMode{
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    imageView.contentMode = contentMode;
    imageView.image = image;
    
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, imageView.layer.contentsScale);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setBackgroundImage:newImage forState:state];
    UIGraphicsEndImageContext();
    
    
}


- (void)setButtonContentAlignment:(ButtonContentAlignment)contentAlignment
         ButtonContentLayoutModal:(ButtonContentLayoutModal)contentLayoutModal
       ButtonContentTitlePosition:(ButtonContentTitlePosition)contentTitlePosition
        SapceBetweenImageAndTitle:(CGFloat)aSpace
                       EdgeInsets:(UIEdgeInsets)aEdgeInsets{
    self.titleEdgeInsets = UIEdgeInsetsZero;
    self.imageEdgeInsets = UIEdgeInsetsZero;
    
    NSString *aTitle = self.titleLabel.text;
    
    CGSize titleSize = [[Common sharedInstance] widthForContent:aTitle withSize:CGSizeMake(self.width, CGFLOAT_MAX) withLableFont:self.titleLabel.font.pointSize];

    CGSize aImageSize = self.imageView.frame.size;
    if (!self.imageView.image) {
        aImageSize = CGSizeZero;
    }
    
    
    // 取得imageView最初的center
    CGPoint startImageViewCenter = self.imageView.center;
    // 取得titleLabel最初的center
    CGPoint startTitleLabelCenter = self.titleLabel.center;
    
    // 找出titleLabel最终的center
    CGPoint endTitleLabelCenter = CGPointZero;
    // 找出imageView最终的center
    CGPoint endImageViewCenter = CGPointZero;
    
    
    //垂直对齐
    if (contentLayoutModal==ButtonContentLayoutModalVertical) {
        if (contentAlignment==ButtonContentAlignmentLeft) {
            if (contentTitlePosition==ButtonContentTitlePositionBefore) {
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(aEdgeInsets.left+MAX(titleSize.width, aImageSize.width)/2.0, (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+titleSize.height/2.0);
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(aEdgeInsets.left+MAX(titleSize.width, aImageSize.width)/2.0,  (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+titleSize.height+aSpace+aImageSize.height);
            }
            else if (contentTitlePosition==ButtonContentTitlePositionAfter){
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(aEdgeInsets.left+MAX(titleSize.width, aImageSize.width)/2.0,  (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+aImageSize.height/2.0);
                
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(aEdgeInsets.left+MAX(titleSize.width, aImageSize.width)/2.0, (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+aImageSize.height+aSpace+titleSize.height/2.0);
            }
            else{
                
            }
        }
        else if (contentAlignment==ButtonContentAlignmentCenter){
            if (contentTitlePosition==ButtonContentTitlePositionBefore) {
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake((self.frame.size.width-MAX(titleSize.width, aImageSize.width))/2.0+MAX(titleSize.width, aImageSize.width)/2.0, (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+titleSize.height/2.0);
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake((self.frame.size.width-MAX(titleSize.width, aImageSize.width))/2.0+MAX(titleSize.width, aImageSize.width)/2.0,  (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+titleSize.height+aSpace+aImageSize.height);
            }
            else if (contentTitlePosition==ButtonContentTitlePositionAfter){
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake((self.frame.size.width-MAX(titleSize.width, aImageSize.width))/2.0+MAX(titleSize.width, aImageSize.width)/2.0,  (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+aImageSize.height/2.0);
                
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake((self.frame.size.width-MAX(titleSize.width, aImageSize.width))/2.0+MAX(titleSize.width, aImageSize.width)/2.0, (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+aImageSize.height+aSpace+titleSize.height/2.0);
            }
            else{
                
            }
        }
        else if (contentAlignment==ButtonContentAlignmentRight){
            
            if (contentTitlePosition==ButtonContentTitlePositionBefore) {
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(self.frame.size.width-aEdgeInsets.right-MAX(titleSize.width, aImageSize.width)/2.0, (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+titleSize.height/2.0);
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(self.frame.size.width-aEdgeInsets.right-MAX(titleSize.width, aImageSize.width)/2.0,  (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+titleSize.height+aSpace+aImageSize.height);
            }
            else if (contentTitlePosition==ButtonContentTitlePositionAfter){
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(self.frame.size.width-aEdgeInsets.right-MAX(titleSize.width, aImageSize.width)/2.0,  (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+aImageSize.height/2.0);
                
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(self.frame.size.width-aEdgeInsets.right-MAX(titleSize.width, aImageSize.width)/2.0, (self.frame.size.height-titleSize.height-aImageSize.height-aSpace)/2.0+aImageSize.height+aSpace+titleSize.height/2.0);
            }
            else{
                
            }
        }
        else{
            
        }
    }
    //水平对齐
    else if (contentLayoutModal==ButtonContentLayoutModalHorizontal){
        if (contentAlignment==ButtonContentAlignmentLeft) {
            if (contentTitlePosition==ButtonContentTitlePositionBefore) {
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(aEdgeInsets.left+titleSize.width/2.0, self.frame.size.height/2.0);
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(aEdgeInsets.left+titleSize.width+aImageSize.width/2.0+aSpace, self.frame.size.height/2.0);
            }
            else if (contentTitlePosition==ButtonContentTitlePositionAfter){
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(aEdgeInsets.left+titleSize.width/2.0+aImageSize.width+aSpace, self.frame.size.height/2.0);
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(aEdgeInsets.left+aImageSize.width/2.0, self.frame.size.height/2.0);
            }
            else{
                
            }
        }
        else if (contentAlignment==ButtonContentAlignmentCenter){
            if (contentTitlePosition==ButtonContentTitlePositionBefore) {
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake((self.frame.size.width-titleSize.width-aImageSize.width-aSpace)/2.0+titleSize.width/2.0, self.frame.size.height/2.0);
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake((self.frame.size.width-titleSize.width-aImageSize.width-aSpace)/2.0+titleSize.width+aSpace+aImageSize.width/2.0, self.frame.size.height/2.0);
            }
            else if (contentTitlePosition==ButtonContentTitlePositionAfter){
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake((self.frame.size.width-titleSize.width-aImageSize.width-aSpace)/2.0+aImageSize.width/2.0, self.frame.size.height/2.0);
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(endImageViewCenter.x+(aImageSize.width)/2.0+aSpace+titleSize.width/2.0, self.frame.size.height/2.0);
            }
            else{
                
            }
        }
        else if (contentAlignment==ButtonContentAlignmentRight){
            
            if (contentTitlePosition==ButtonContentTitlePositionBefore) {
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(self.frame.size.width-titleSize.width/2.0-aImageSize.width-aEdgeInsets.right-aSpace, self.frame.size.height/2.0);
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(self.frame.size.width-aEdgeInsets.right-aImageSize.width/2.0, self.frame.size.height/2.0);
            }
            else if (contentTitlePosition==ButtonContentTitlePositionAfter){
                // 找出imageView最终的center
                endImageViewCenter = CGPointMake(self.frame.size.width-aImageSize.width/2.0-titleSize.width-aEdgeInsets.right-aSpace, self.frame.size.height/2.0);
                // 找出titleLabel最终的center
                endTitleLabelCenter = CGPointMake(self.frame.size.width-aEdgeInsets.right-titleSize.width/2.0, self.frame.size.height/2.0);
            }
            else{
                
            }
        }
        else{
            
        }
    }
    else{
        
    }
    
    // 设置titleEdgeInsets
    CGFloat titleEdgeInsetsTop = endTitleLabelCenter.y-startTitleLabelCenter.y+self.titleEdgeInsets.top;
    CGFloat titleEdgeInsetsLeft = endTitleLabelCenter.x - startTitleLabelCenter.x+self.titleEdgeInsets.left;
    CGFloat titleEdgeInsetsBottom = -titleEdgeInsetsTop;
    CGFloat titleEdgeInsetsRight = -titleEdgeInsetsLeft;
    self.titleEdgeInsets = UIEdgeInsetsMake(titleEdgeInsetsTop, titleEdgeInsetsLeft, titleEdgeInsetsBottom, titleEdgeInsetsRight);
    
    
    // 设置imageEdgeInsets
    CGFloat imageEdgeInsetsTop = endImageViewCenter.y - startImageViewCenter.y+self.imageEdgeInsets.top;
    CGFloat imageEdgeInsetsLeft = endImageViewCenter.x - startImageViewCenter.x+self.imageEdgeInsets.left;
    CGFloat imageEdgeInsetsBottom = -imageEdgeInsetsTop;
    CGFloat imageEdgeInsetsRight = -imageEdgeInsetsLeft;
    self.imageEdgeInsets = UIEdgeInsetsMake(imageEdgeInsetsTop, imageEdgeInsetsLeft, imageEdgeInsetsBottom, imageEdgeInsetsRight);
}
@end

#pragma mark ==================================================
#pragma mark ==UITableViewCell
#pragma mark ==================================================
@implementation UITableViewCell (Extesion)

- (void)setBackgroundViewColor:(UIColor *)color {
    [self clearBackgroundColor];
    [self.contentView clearBackgroundColor];
    
    if (color == nil) {
        color = [UIColor whiteColor];
    }
    
    if (self.backgroundView == nil) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [backgroundView setOpaque:YES];
        [self setBackgroundView:backgroundView];
        backgroundView = nil;
    }
    [self.backgroundView setBackgroundColor:color];
}

- (void)setBackgroundViewImage:(UIImage *)image  {
    [self clearBackgroundColor];
    [self.contentView clearBackgroundColor];
    
    if (image == nil) {
        [self setBackgroundViewColor:nil];
        return ;
    }
    
    if (![self.backgroundView isMemberOfClass:[UIImageView class]]) {
        [self.backgroundView removeFromSuperview];
    }
    
    UIImageView *imageView = (UIImageView *)[self backgroundView];
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self setBackgroundView:imageView];
    }
    
    [imageView setImage:image];
}

- (void)setSelectedBackgroundViewColor:(UIColor *)color {
    [self clearBackgroundColor];
    [self.contentView clearBackgroundColor];
    
    if (color == nil) {
        color = [UIColor whiteColor];
    }
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    [selectedBackgroundView setOpaque:YES];
    [self setSelectedBackgroundView:selectedBackgroundView];
    selectedBackgroundView = nil;
    [self.selectedBackgroundView setBackgroundColor:color];
}

- (void)setSelectedBackgroundViewImage:(UIImage *)image {
    [self clearBackgroundColor];
    [self.contentView clearBackgroundColor];
    
    if (image == nil) {
        [self setSelectedBackgroundViewColor:nil];
        return ;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [imageView setImage:image];
    [self setSelectedBackgroundView:imageView];
    imageView = nil;
}

@end
#pragma mark ==================================================
#pragma mark ==NSDictionary
#pragma mark ==================================================
@implementation NSDictionary (KKNSDictionaryExtension)

+ (BOOL)isDictionaryNotEmpty:(id)dictionary{
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]] && [(NSDictionary *)dictionary count]>0) {
        return YES;
    }
    else{
        return NO;
    }
}

+ (BOOL)isDictionaryEmpty:(id)dictionary{
    return ![NSDictionary isDictionaryNotEmpty:dictionary];
}


- (BOOL)boolValueForKey:(id)aKey {
    return [[self objectForKey:aKey] boolValue];
}

- (int)intValueForKey:(id)aKey {
    return [[self objectForKey:aKey] intValue];
}

- (NSInteger)integerValueForKey:(id)aKey {
    return [[self objectForKey:aKey] integerValue];
}

- (float)floatValueForKey:(id)aKey {
    return [[self objectForKey:aKey] floatValue];
}

- (double)doubleValueForKey:(id)aKey {
    return [[self objectForKey:aKey] doubleValue];
}

/* 获取NSString对象
 * 返回：可能是NSString对象 或者 nil
 */
- (NSString *)stringValueForKey:(id)aKey {
    id value = [self objectForKey:aKey];
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString*)value;
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)value stringValue];
    }
    else{
        return nil;
    }
}

/* 获取NSString对象，不可能返回nil
 * 返回：一定是一个NSString对象(NSString可能有值，可能为@“”)
 */
- (NSString*)validStringForKey:(id)aKey{
    
    if (aKey && ![aKey isKindOfClass:[NSNull class]]) {
        NSObject *object = [self objectForKey:aKey];
        if (object && ![object isKindOfClass:[NSNull class]]) {
            if ([object isKindOfClass:[NSNumber class]]) {
                return [(NSNumber*)object stringValue];
            }
            else if ([object isKindOfClass:[NSString class]]){
                return (NSString*)object;
            }
            else if ([object isKindOfClass:[NSDictionary class]]){
                return (NSString*)[(NSDictionary*)object translateToJSONString];
            }
            else if ([object isKindOfClass:[NSArray class]]){
                
                return (NSString *)[(NSArray *)object description];
                
            }
            else if ([object isKindOfClass:[NSURL class]]){
                return [(NSURL*)object absoluteString];
            }
            else{
                return [[NSString alloc] initWithFormat:@"%@", object];
            }
        }
        else{
            return @"";
        }
    }
    else{
        return @"";
    }
}

/* 获取NSDictionary对象
 * 返回：可能是NSDictionary对象 或者 nil
 */
- (NSDictionary *)dictionaryValueForKey:(id)aKey {
    id value = [self objectForKey:aKey];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary*)value;
    }
    else{
        return nil;
    }
}

/* 获取NSDictionary对象
 * 返回：一定是一个NSDictionary对象(NSDictionary里面可能有值，可能为空)
 */
- (NSDictionary *)validDictionaryForKey:(id)aKey{
    id value = [self objectForKey:aKey];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary*)value;
    }else{
        return [NSDictionary dictionary];
    }
}

/* 获取NSArray对象
 * 返回：可能是NSArray对象 或者nil
 */
- (NSArray *)arrayValueForKey:(id)aKey {
    id value = [self objectForKey:aKey];
    if ([value isKindOfClass:[NSArray class]]) {
        return (NSArray*)value;
    }
    else{
        return nil;
    }
}

/* 获取NSArray对象
 * 返回：一定是一个NSArray对象(NSArray里面可能有值，可能为空)
 */
- (NSArray*)validArrayForKey:(id)aKey{
    id value = [self objectForKey:aKey];
    if ([value isKindOfClass:[NSArray class]]) {
        return (NSArray*)value;
    }
    else{
        return [NSArray array];
    }
}


//- (id)valuableObjectForKey:(id)aKey{
//    if (!self || !aKey) {
//        return nil;
//    }
//
//    if ([[self objectForKey:aKey] isKindOfClass:[NSNumber class]]) {
//        return [[self objectForKey:aKey] stringValue];
//    }
//    else if ([[self objectForKey:aKey] isKindOfClass:[NSNull class]] || ![self objectForKey:aKey]){
//        return @"";
//    }
//    return [self objectForKey:aKey];
//}

/**
 @brief 转换成json字符串
 @discussion
 */
- (NSString *)translateToJSONString{
    NSString *jsonKitString = nil;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *returnString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([returnString isEqualToString:jsonKitString]) {
        NSLog(@"YES");
    }
    return returnString;
}

/**
 @brief json字符串转换成对象
 @discussion
 */
+ (NSDictionary*)dictionaryFromJSONData:(NSData*)aJsonData{
    if (aJsonData && [aJsonData isKindOfClass:[NSData class]]) {
        NSError *error = nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:aJsonData options:NSJSONReadingMutableContainers error:&error];
        if (jsonObject != nil && error == nil && [jsonObject isKindOfClass:[NSDictionary class]]){
            return jsonObject;
        }else{
            // 解析错误
            return nil;
        }
    }else{
        // 解析错误
        return nil;
    }
}

@end

#pragma mark ==================================================
#pragma mark ==UIFont
#pragma mark ==================================================
@implementation UIFont (KKUIFontExtension)

+ (CGSize)sizeOfFont:(UIFont*)aFont{
    NSString *string = languageStringWithKey(@"我");
    return [string sizeWithFont:aFont maxWidth:1000];
}

@end

#pragma mark ==================================================
#pragma mark ==NSString
#pragma mark ==================================================
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (KKNSStringExtension)

+ (BOOL)isStringNotEmpty:(id)string{
    if (string && [string isKindOfClass:[NSString class]] && [[string trimLeftAndRightSpace] length]>0) {
        return YES;
    }
    else{
        return NO;
    }
}

+ (BOOL)isStringEmpty:(id)string{
    return ![NSString isStringNotEmpty:string];
}

- (NSString *)trimWhitespace {
    NSString *string = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isWebUrl {
    if(self == nil) {
        return NO;
    }
    NSString *url;
    if (self.length>4 && [[self substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",self];
    } else{
        url = self;
    }
    NSString *urlRegex = @"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    BOOL result = [urlTest evaluateWithObject:url];
    return result;
}

- (BOOL)isEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
- (NSString *)trimHTMLTag {
    
    NSString *html = [self stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"  "];
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];
        
        NSString *replaceString = [NSString stringWithFormat:@"%@>", text];
        if ([replaceString hasPrefix:@"<KK{"]) {
            continue;
        }
        else{
            html = [html stringByReplacingOccurrencesOfString:replaceString
                                                   withString:@""];
        }
    }
    return [html trimLeftAndRightSpace];
}

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode{
    return [self sizeWithFont:font maxSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:lineBreakMode];
}

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width {
    return [self sizeWithFont:font maxSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
}


- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size {
    return [self sizeWithFont:font maxSize:size inset:UIEdgeInsetsMake(0, 0, 0, 0) lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode{
    return [self sizeWithFont:font maxSize:size inset:UIEdgeInsetsMake(0, 0, 0, 0) lineBreakMode:lineBreakMode];
}
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size inset:(UIEdgeInsets)inset lineBreakMode:(NSLineBreakMode)lineBreakMode{
    if (font == nil) {
        font = ThemeFontMiddle;
    }
    CGFloat width = size.width - inset.left - inset.right;
    CGFloat height = size.height - inset.top - inset.bottom;

    CGSize sizeReturn;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<=7.1) {
        sizeReturn = [[Common sharedInstance] widthForContent:self withSize:CGSizeMake(ceilf(width), ceilf(height)) withLableFont:font.pointSize];
    }else{
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;

        /// Make a copy of the default paragraph style
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        /// Set line break mode
        paragraphStyle.lineBreakMode = lineBreakMode;
        /// Set text alignment
        paragraphStyle.alignment = NSTextAlignmentLeft;

        NSDictionary *Attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName, nil];

        CGRect rect0 = [self boundingRectWithSize:CGSizeMake(width, height) options:options attributes:Attributes2 context:nil];
        sizeReturn = CGSizeMake(ceilf(rect0.size.width), ceilf(rect0.size.height));
    }
    return sizeReturn;
}


- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width inset:(UIEdgeInsets)inset {
    return [self sizeWithFont:font maxSize:CGSizeMake(width, CGFLOAT_MAX) inset:inset lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width inset:(UIEdgeInsets)inset lineBreakMode:(NSLineBreakMode)lineBreakMode{
    return [self sizeWithFont:font maxSize:CGSizeMake(width, CGFLOAT_MAX) inset:inset lineBreakMode:lineBreakMode];
}

- (CGFloat)heightWithFont:(UIFont *)font {
    CGSize size = [self sizeWithFont:font maxSize:CGSizeMake(300, 300)];
    return size.height;
}

//去掉字符串首尾的空格
-(NSString*)trimLeftAndRightSpace{
    if (self) {
        NSString* trimed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return trimed;
    }
    else {
        return nil;
    }
}

//去掉字符串中的所有空格
-(NSString*)trimAllSpace{
    if (self) {
        NSString *trimed1 = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *trimed = [trimed1 trimWhitespace];
        
        return trimed;
    }
    else {
        return nil;
    }
    
}

//去掉数字
- (NSString*)trimNumber{
    if (self) {
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:NULL];
        NSString* resultString = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
        return resultString;
    }
    else {
        return nil;
    }
}

+ (NSString*)stringWithData:(NSData *)data{
    NSString* s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return s;
}


/*是否是整数*/
- (BOOL)isInteger{
    if (self) {
        NSScanner* scan = [NSScanner scannerWithString:self];
        NSInteger val;
        return [scan scanInteger:&val] && [scan isAtEnd];
    }
    else {
        return NO;
    }
}

/*是否是整数*/
- (BOOL)isValuableInteger{
    
    if ([self isInteger]) {
        
        NSString *AA = [NSString stringWithFormat:@"%ld",(long)[self integerValue]];
        //        NSString *BB = [NSString stringWithFormat:@"%ld",NSIntegerMax];
        
        if ([AA isEqualToString:self]) {
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}

/*是否是浮点数*/
- (BOOL)isFloat{
    
    NSString *clearString = [self stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (![clearString isInteger]) {
        return NO;
    }
    else{
        NSRange stringRange = NSMakeRange(0, [self length]);
        NSRegularExpression* pointRegular = [NSRegularExpression regularExpressionWithPattern:@"[.]"
                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                        error:nil];
        NSArray *matches = [pointRegular matchesInString:self  options:NSMatchingReportCompletion range:stringRange];
        
        if ([matches count]==1) {
            return YES;
        }
        else{
            return NO;
        }
        //        for (NSTextCheckingResult *match in matches) {
        //            NSRange numberRange = [match range];
        //            [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
        //                                     value:(id)specialTextColor.CGColor
        //                                     range:numberRange];
        //        }
    }
}


+ (NSInteger)sizeOfStringForNSUTF8StringEncoding:(NSString*)aString{
    NSInteger result = 0;
    const char *tchar=[aString UTF8String];
    if (NULL == tchar) {
        return result;
    }
    result = strlen(tchar);
    return result;
}

+ (NSString*)subStringForNSUTF8StringEncodingWithSize:(NSInteger)size string:(NSString*)string{
    
    NSString *tempString = [NSString stringWithString:string];
    
    NSInteger tempStringSize = [NSString sizeOfStringForNSUTF8StringEncoding:tempString];
    if (tempStringSize <= size) {
        return tempString;
    }
    
    if (size>tempStringSize/2) {
        NSInteger index = [tempString length];
        while (1) {
            if ([NSString sizeOfStringForNSUTF8StringEncoding:tempString]<=size) {
                break;
            }
            else{
                index = index -1;
                tempString = [string substringWithRange:NSMakeRange(0, index)];
            }
        }
    }
    else{
        NSInteger index = 1;
        while (1) {
            tempString = [string substringWithRange:NSMakeRange(0, index)];
            if ([NSString sizeOfStringForNSUTF8StringEncoding:tempString]<size) {
                index = index + 1;
            }
            else{
                break;
            }
        }
    }
    
    return tempString;
}

+ (NSInteger)sizeOfStringForNSUnicodeStringEncoding:(NSString*)aString{
    int strlength = 0;
    char* p = (char*)[aString cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[aString lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

+ (NSString*)subStringForNSUnicodeStringEncodingWithSize:(NSInteger)size string:(NSString*)string{
    
    NSString *tempString = [NSString stringWithString:string];
    
    NSInteger tempStringSize = [NSString sizeOfStringForNSUnicodeStringEncoding:tempString];
    if (tempStringSize <= size) {
        return tempString;
    }
    
    if (size>tempStringSize/2) {
        NSInteger index = [tempString length];
        while (1) {
            if ([NSString sizeOfStringForNSUnicodeStringEncoding:tempString]<=size) {
                break;
            }
            else{
                index = index -1;
                tempString = [string substringWithRange:NSMakeRange(0, index)];
            }
        }
    }
    else{
        NSInteger index = 1;
        while (1) {
            tempString = [string substringWithRange:NSMakeRange(0, index)];
            if ([NSString sizeOfStringForNSUnicodeStringEncoding:tempString]<size) {
                index = index + 1;
            }
            else{
                break;
            }
        }
    }
    
    return tempString;
}

+ (NSString*)stringWithInteger:(NSInteger)intValue{
    return [NSString stringWithFormat:@"%ld",(long)intValue];
}

+ (NSString*)stringWithFloat:(CGFloat)floatValue{
    return [NSString stringWithFormat:@"%f",floatValue];
}


+ (NSString*)stringWithDouble:(double)doubleValue{
    return [NSString stringWithFormat:@"%lf",doubleValue];
}

@end
#pragma mark ==================================================
#pragma mark == NSDate
#pragma mark ==================================================

@implementation NSDate (KKNSDateExtension)

- (NSUInteger)day {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    return [[dateFormatter day:self] intValue];
}

- (NSUInteger)weekday {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    return [[dateFormatter weekday:self] intValue];
}

- (NSUInteger)month {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    return [[dateFormatter month:self] intValue];
}

- (NSUInteger)year {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    return [[dateFormatter year:self] intValue];
}

- (NSUInteger)numberOfDaysInMonth {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    return [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                              inUnit:NSMonthCalendarUnit
                                             forDate:self].length;
#else
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay
                                              inUnit:NSCalendarUnitMonth
                                             forDate:self].length;
#endif
    
}

- (NSUInteger)weeksOfMonth {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    return [[NSCalendar currentCalendar] rangeOfUnit:NSWeekCalendarUnit
                                              inUnit:NSMonthCalendarUnit
                                             forDate:self].length;
#else
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitWeekOfMonth
                                              inUnit:NSCalendarUnitMonth
                                             forDate:self].length;
#endif
    
}

- (NSDate *)previousDate {
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setDay:-1];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                         toDate:self
                                                        options:0];
}

- (NSDate *)nextDate {
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setDay:1];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                         toDate:self
                                                        options:0];
}

- (NSDate *)firstDayOfWeek {
    NSDate *date = nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSWeekCalendarUnit
                                              startDate:&date
                                               interval:NULL
                                                forDate:self];
#else
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitWeekOfMonth
                                              startDate:&date
                                               interval:NULL
                                                forDate:self];
#endif
    
    
    if (ok) {
        return date;
    }
    return nil;
}

- (NSDate *)lastDayOfWeek {
    return [[self firstDayOfNextWeek] previousDate];
}

- (NSDate *)firstDayOfNextWeek {
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    [dateComp setWeek:1];
#else
    [dateComp setWeekOfMonth:1];
#endif
    
    return [[[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                          toDate:self
                                                         options:0] firstDayOfWeek];
}

- (NSDate *)lastDayOfNextWeek {
    return [[self firstDayOfNextWeek] lastDayOfWeek];
}

- (NSDate *)firstDayOfMonth {
    NSDate *date = nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSMonthCalendarUnit
                                              startDate:&date
                                               interval:NULL
                                                forDate:self];
#else
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth
                                              startDate:&date
                                               interval:NULL
                                                forDate:self];
#endif
    
    if (ok) {
        return date;
    }
    return nil;
}

- (NSDate *)lastDayOfMonth {
    NSDate *date = nil;
    date = [[self firstDayOfNextMonth] previousDate];
    return date;
}

- (NSUInteger)weekdayOfFirstDayInMonth {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    return [[dateFormatter weekday:[self firstDayOfMonth]] intValue];
}

- (NSDate *)firstDayOfPreviousMonth {
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setMonth:-1];
    return [[[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                          toDate:self
                                                         options:0] firstDayOfMonth];
}

- (NSDate *)firstDayOfNextMonth {
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setMonth:1];
    return [[[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                          toDate:self
                                                         options:0] firstDayOfMonth];
}

- (NSDate *)firstDayOfQuarter {
    NSDate *date = nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSQuarterCalendarUnit
                                              startDate:&date
                                               interval:NULL
                                                forDate:self];
#else
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitQuarter
                                              startDate:&date
                                               interval:NULL
                                                forDate:self];
#endif
    
    if (ok) {
        return date;
    }
    return nil;
}

- (NSDate *)lastDayOfQuarter {
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setQuarter:1];
    return [[[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                          toDate:self
                                                         options:0] lastDayOfMonth];
}

- (NSDate *)theDayOfNextMonth{
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setMonth:1];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                         toDate:self
                                                        options:0];
}

- (NSDate *)theDayOfNextWeek{
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setWeekday:7];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                         toDate:self
                                                        options:0];
}


#pragma mark == NSDate 字符串方法
+ (NSString*)getStringWithFormatter:(NSString*)formatterString{
    if ((formatterString==nil) || ![formatterString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:formatterString];
    NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return nowDateString;
}


+ (NSString*)getStringFromOldDateString:(NSString*)oldDateString
                       withOldFormatter:(NSString*)oldFormatterString
                           newFormatter:(NSString*)newFormatterString {
    
    if (oldDateString==nil || (![oldDateString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    if (oldFormatterString==nil || (![oldFormatterString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    if (newFormatterString==nil || (![newFormatterString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    NSDate *oldDate = [NSDate getDateFromString:oldDateString dateFormatter:oldFormatterString];
    
    NSString *returnString = [NSDate getStringFromDate:oldDate dateFormatter:newFormatterString];
    
    return returnString;
}

+ (NSString*)getStringFromDate:(NSDate*)date dateFormatter:(NSString*)formatterString{
    
    if (formatterString==nil || (![formatterString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    if (date==nil || (![date isKindOfClass:[NSDate class]])) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:formatterString];
    NSString *returnString = [dateFormatter stringFromDate:date];
    
    return returnString;
}

+ (NSDate*)getDateFromString:(NSString*)string dateFormatter:(NSString*)formatterString{
    
    if (formatterString==nil || (![formatterString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    if (string==nil || (![string isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:formatterString];
    NSDate *oldDate = [dateFormatter dateFromString:string];
    
    return oldDate;
}

+ (NSString*)timeAwayFromNowWithOldDateString:(NSString*)oldDateString oldFormatterString:(NSString*)oldFormatterString defaultFormatterString:(NSString*)defaultFormatterString{
    
    if (oldDateString==nil || (![oldDateString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    if (oldFormatterString==nil || (![oldFormatterString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    if (defaultFormatterString==nil || (![defaultFormatterString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    //******************************************************************************************
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:oldFormatterString];
    NSDate *firstDate = [dateFormatter dateFromString:oldDateString];
    
    NSTimeInterval before = [firstDate timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval after = [[NSDate date] timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval cha = after - before;
    
    if (cha <=0 ) {
        return languageStringWithKey(@"刚刚");
    }
    else if ((0<cha) && (cha<60)) {
        return [NSString stringWithFormat:@"%d%@",(int)roundf(cha),languageStringWithKey(@"秒前")];
    }
    else if ((60<=cha) && (cha<3600)) {
        return [NSString stringWithFormat:@"%d%@",(int)roundf(cha/60),languageStringWithKey(@"分钟前")];
    }
    else if ((3600<=cha) && (cha<86400)) {
        return [NSString stringWithFormat:@"%d%@",(int)roundf(cha/3600),languageStringWithKey(@"小时前")];
    }
    else{
        return [self getStringWithFormatter:defaultFormatterString];
    }
}

+ (NSString*)timeAwayFromNowWithOldDate:(NSDate*)oldDate defaultFormatterString:(NSString*)defaultFormatterString{
    
    if (oldDate==nil || (![oldDate isKindOfClass:[NSDate class]])) {
        return nil;
    }
    
    if (defaultFormatterString==nil || (![defaultFormatterString isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    NSTimeInterval before = [oldDate timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval after = [[NSDate date] timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval cha = after - before;
    
    if (cha <=0 ) {
        return languageStringWithKey(@"刚刚");
    }
    else if ((0<cha) && (cha<60)) {
        return [NSString stringWithFormat:@"%d%@",(int)roundf(cha),languageStringWithKey(@"秒前")];
    }
    else if ((60<=cha) && (cha<3600)) {
        return [NSString stringWithFormat:@"%d%@",(int)roundf(cha/60),languageStringWithKey(@"分钟前")];
    }
    else if ((3600<=cha) && (cha<86400)) {
        return [NSString stringWithFormat:@"%d%@",(int)roundf(cha/3600),languageStringWithKey(@"小时前")];
    }
    else{
        return [self getStringWithFormatter:defaultFormatterString];
    }
}

+ (BOOL)isString:(NSString*)date1String01 earlierThanString:(NSString*)date1String02 formatter01:(NSString*)formatter01 formatter02:(NSString*)formatter02{
    
    if (date1String01==nil || (![date1String01 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    if (date1String02==nil || (![date1String02 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    if (formatter01==nil || (![formatter01 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    if (formatter02==nil || (![formatter02 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter1 setDateFormat:formatter01];
    NSDate *date1 = [formatter1 dateFromString:date1String01];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter2 setDateFormat:formatter02];
    NSDate *date2 = [formatter2 dateFromString:date1String02];
    
    NSTimeInterval before = [date1 timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval after = [date2 timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval cha = after - before;
    
    
    if (cha>0) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)isString:(NSString*)date1String01 earlierThanDate:(NSDate*)date02 formatter01:(NSString*)formatter01 {
    
    if (date1String01==nil || (![date1String01 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    if (formatter01==nil || (![formatter01 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    if (date02==nil || (![date02 isKindOfClass:[NSDate class]])) {
        return NO;
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:formatter01];
    NSDate *date1 = [dateFormatter dateFromString:date1String01];
    
    NSTimeInterval before = [date1 timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval after = [date02 timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval cha = after - before;
    
    
    if (cha>0) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)isDate:(NSDate*)date01 earlierThanString:(NSString*)dateString02 formatter02:(NSString*)formatter02{
    
    if (dateString02==nil || (![dateString02 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    if (formatter02==nil || (![formatter02 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    if (date01==nil || (![date01 isKindOfClass:[NSString class]])) {
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:formatter02];
    NSDate *date2 = [dateFormatter dateFromString:dateString02];
    
    NSTimeInterval before = [date01 timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval after = [date2 timeIntervalSince1970]*1;
    
    //******************************************************************************************
    
    NSTimeInterval cha = after - before;
    
    
    if (cha>0) {
        return YES;
    }
    else {
        return NO;
    }
}


+ (BOOL)isDate:(NSDate*)date01 earlierThanDate:(NSDate*)date02{
    
    if (date01==nil || (![date01 isKindOfClass:[NSDate class]])) {
        return NO;
    }
    
    if (date02==nil || (![date02 isKindOfClass:[NSDate class]])) {
        return NO;
    }
    
    NSTimeInterval before = [date01 timeIntervalSince1970]*1;
    
    NSTimeInterval after = [date02 timeIntervalSince1970]*1;
    
    
    NSTimeInterval cha = after - before;
    
    
    if (cha>0) {
        return YES;
    }
    else {
        return NO;
    }
}

/**
 判断时间是否超过一天了
 date01：需要判断的日期
 */
+ (BOOL)isDate:(NSDate*)date01 beforeNDays:(NSUInteger)days{
    double cha = [[NSDate date] timeIntervalSince1970]-[date01 timeIntervalSince1970];
    if (cha>=24*60*60*days) {
        return YES;
    }
    else{
        return NO;
    }
}


/**
 判断时间是否超过N天了
 date01：需要判断的日期
 formatterString：date01的格式
 days：超过N天了
 */
+ (BOOL)isDateString:(NSString*)dateString formatter:(NSString*)formatterString afterNDay:(NSUInteger)days{
    NSString *dateStringNow = [self getStringWithFormatter:@"yyyyMMdd"];
    NSString *dateStringOld = [self getStringFromOldDateString:dateString withOldFormatter:formatterString newFormatter:@"yyyyMMdd"];
    NSInteger cha = [dateStringNow integerValue]-[dateStringOld integerValue];
    if (cha>=days) {
        return YES;
    }
    else{
        return NO;
    }
}


@end
#pragma mark ==================================================
#pragma mark ==NSDateFormatter
#pragma mark ==================================================

@implementation NSDateFormatter (KKNSDateFormatterExtension)

- (NSString *)weekday:(NSDate *)date {
    [self setDateFormat:@"c"];
    return [self stringFromDate:date];
}

- (NSString *)day:(NSDate *)date {
    [self setDateFormat:@"d"];
    return [self stringFromDate:date];
}

- (NSString *)month:(NSDate *)date {
    [self setDateFormat:@"M"];
    return [self stringFromDate:date];
}

- (NSString *)year:(NSDate *)date {
    [self setDateFormat:@"y"];
    return [self stringFromDate:date];
}


@end
