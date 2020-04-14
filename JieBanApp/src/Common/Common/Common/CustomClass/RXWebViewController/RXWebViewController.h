//
//  RXWebViewController.h
//  Common
//
//  Created by apple on 2019/12/20.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RXWebViewType) {
    RXWebViewTypeNormal,    //只显示网页内容
    RXWebViewTypeTransform, //解析网页内容 供发送链接使用
    RXWebViewTypeCustom,    //其他自定义格式
};

NS_ASSUME_NONNULL_BEGIN

@interface RXWebViewController : UIViewController

@property (nonatomic, assign) RXWebViewType type;

@end

NS_ASSUME_NONNULL_END
