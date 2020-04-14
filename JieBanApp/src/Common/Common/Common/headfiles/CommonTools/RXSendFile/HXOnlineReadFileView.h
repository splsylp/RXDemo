//
//  HXOnlineReadFileView.h
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 2017/4/24.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface HXOnlineReadFileView : UIView<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic,strong) WKWebView *wkWebView;
@property (nonatomic,strong)NSString *fileUuid;
@property (nonatomic,strong)NSString *fileLoadUrl;
- (instancetype)initWithFrame:(CGRect)frame fileUuid:(NSString *)fileUuid fileKey:(NSString *)fileKey fileRemoteUrl:(NSString *)fileLoadUrl messageId:(NSString *)sessionId fileSize:(NSString *)fileSize filePathName:(NSString *)fileName;
- (instancetype)initWithFrame:(CGRect)frame withDic:(NSDictionary *)dic;

-(void)loadWebView:(NSString *)fileUrl;
@end
