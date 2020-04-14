//
//  ShowDocumentOfficeView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <QuickLook/QuickLook.h>

@interface ShowDocumentOfficeView : UIView<UIDocumentInteractionControllerDelegate,WKUIDelegate,WKNavigationDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>

//使用webView查看文件
@property (nonatomic,strong) WKWebView *wkWebView;


@property (nonatomic,strong)ECMessage *message;
@property(nonatomic,strong)UIView *otherView;


/**
 *
 * 、fileMessageBody 文档的信息
 */
- (instancetype)initWithFrame:(CGRect)frame fileMessage:(ECMessage *)message;
@end
