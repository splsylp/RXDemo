//
//  AppDelegate.m
//  RX-Plugin
//
//  Created by 刘某某 on 2020/3/26.
//  Copyright © 2020 刘某某. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "RXBaseNavgationController.h"
#import "AppModel.h"
#import "QMapServices.h"
#import "QMSSearchServices.h"
#import "Chat.h"
#import "AFNetworking.h"
#import "IMConst.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self setRootViewController];
    [self.window makeKeyAndVisible];
    [self setKHOST];
    
    [AppModel sharedInstance].owner = [UIApplication sharedApplication].keyWindow;
    
    //腾讯地图
    [QMapServices sharedServices].apiKey = QmapKey;
    [[QMSSearchServices sharedServices] setApiKey:QmapKey];
    
    //iOS8 注册APNS
    [self registerForRemoteNotifica:application];
    
    //被踢下线
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beKickedOff) name:@"notificationKickedOff" object:nil];
    
    application.applicationIconBadgeNumber =0;
    
    //消息数量通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUpdateIMMesNum:) name:@"notification_update_session_im_message_num" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationUpdateIMMesNum:) name:@"KNotification_DeleteLocalSessionMessage" object:nil];
    
      [[NSNotificationCenter defaultCenter] postNotificationName:@"ecdevice.detail.sdk.log" object:@13];//底层日志
    //开启网络状态监听
    [self setAFListenNetWork];

    return YES;
}

- (void) setRootViewController {
     LoginViewController *loginVC = [[LoginViewController alloc] init];
     RXBaseNavgationController *nav = [[RXBaseNavgationController alloc] initWithRootViewController:loginVC];
     self.window.rootViewController = nav;
}

-(UIViewController *)getRootViewController{
    return [LoginViewController new];
}

- (void)setKHOST{
    // 配置环境 118.89.218.99 47.105.129.198
    [[NSUserDefaults standardUserDefaults] setObject:@"47.105.129.198" forKey:@"kHOST"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//更新通讯录部门相关信息
- (void)updateDepartInfo {
    [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getAllDepartInfo" :nil];
}

#pragma registerForRemoteNotifica
- (void)registerForRemoteNotifica:(UIApplication *)application {
    if([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
        //如果iOS版本低于7.0，这里可以干一些事情
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
#endif
    }
}

#pragma 应用程序处在打开状态,且服务器有推送消息过来时,以及通过推送打开应用程序,走的是这个方法
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"推送的内容：%@",notificationSettings);
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString* callid=nil;
    NSString *userdata = [userInfo objectForKey:@"c"];
    NSLog(@"远程推送userdata:%@",userdata);
    if (userdata) {
        NSDictionary*callidobj = [NSJSONSerialization JSONObjectWithData:[userdata dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"远程推送callidobj:%@",callidobj);
        if ([callidobj isKindOfClass:[NSDictionary class]]) {
            callid = [callidobj objectForKey:@"callid"];
        }
    }
    NSLog(@"远程推送 callid=%@",callid);
}

#pragma 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 将获取到的token传送消给SDK，用于苹果推送使用
    [[AppModel sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%@..............error",error);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  YES;
}

//被踢下线
- (void)beKickedOff {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"下线提示" message:@"您的账号在其他设备上登录" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self setRootViewController];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 退出应用
- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSLog(@"applicationIconBadgeNumber start---- %ld",(long)application.applicationIconBadgeNumber);
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if(isLogin) {
        NSInteger count = [[AppModel sharedInstance] getAppleBadgeNumberCount];
        application.applicationIconBadgeNumber = count;
        
        //设置角标数
//        [[AppModel sharedInstance] setAppleBadgeNumber:count];
        usleep(10);
    } else {
        application.applicationIconBadgeNumber =0;
        //设置角标数
//        [[AppModel sharedInstance] setAppleBadgeNumber:0];
        usleep(10);
    }
}

- (void)notificationUpdateIMMesNum:(NSNotification *)notification {
    // 消息数
    NSInteger num = [[Chat sharedInstance] unreadMessageCount];
    NSLog(@"%ld", (long)num);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self updateDepartInfo];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark 开启监听网络状态
- (void)setAFListenNetWork {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
