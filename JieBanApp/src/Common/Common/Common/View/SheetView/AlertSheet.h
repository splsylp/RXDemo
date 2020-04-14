//
//  AlertSheet.h
//  Common
//
//  Created by 韩微 on 2017/8/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
//获取设备的物理高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//获取设备的物理宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#import "AlertView.h"
#import "UpdataVatarView.h"

typedef NS_ENUM(NSInteger, fromPage) {
    VERSION_UPDATE = 0,
    UPDATE_VATAR,
};

typedef void(^AlertsheetChickBlock)(void);

@interface AlertSheet : UIView<UIGestureRecognizerDelegate, RemoveAlertViewDelegate, AlertViewAvatarDelegate>


- (id)initWithNerVersion:(NSString *)version withDexcription:(NSString *)descriptio withCancel:(NSString *)cancel withFromPage:(fromPage)frompage withChickBolck:(AlertsheetChickBlock)alertSheetBlock;

- (void)showInView:(UIViewController *)Sview;

+ (AlertSheet *)sharedInstance;
- (void)remove;


@end
