//
//  BaseViewController
//  BaseComponent
//
//  Created by wangming on 16/7/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    
    NavigationBarItemTypeBack,
    
    NavigationBarItemTypeLeft,
    
    NavigationBarItemTypeRight,
    
    NavigationBarItemTypeBlueRight,
    
    NavigationBarItemTypeOrangeRight,
    
    NavigationBarItemTypeRightDisabled,
    
} NavigationBarItemType;

typedef void (^JSCallback)(id responseData);

@interface BaseViewController : UIViewController
@property(nonatomic,assign) int displayType;//1是push，2是modelView
@property(nonatomic,weak) id owner;//所有者
@property(nonatomic,weak) id delegate;//代理
@property(nonatomic,weak) id container;//容器
@property(nonatomic,strong) id data;//数据
@property(nonatomic,strong) NSDictionary* resources;//资源url
@property (nonatomic, strong) NSDictionary *dataSearchFrom;
@property (nonatomic, strong) JSCallback jsCallBack;//js选择联系人
@property(nonatomic,strong)UIPanGestureRecognizer *panGesture;

@property(nonatomic,strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIView *watermarkView;

-(NSDictionary*)getValue;
-(void)setValue:(NSDictionary*)dict;
-(void)show;
-(void)reload;
-(void)refresh;

- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewController:(NSString *)className withData:(id)data;
- (void)pushViewController:(NSString *)className withData:(id)data withNav:(BOOL)nav;
- (void)popViewController;
- (void)popRootViewController;

-(void)titleColor:(NSString *)colorHex;
-(void)setBarButtonWithNormalImg:(UIImage *)normalImg
                  highlightedImg:(UIImage *)highlightedImg
                          target:(id)target
                          action:(SEL)action
                            type:(NavigationBarItemType)type;

- (void)setBarButtonItemWithNormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg titleText:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type;

- (void)addRightTwoBarButtonsWithFirstImage:(UIImage *)firstImage
                             highlightedImg:(UIImage *)firsthighlightedImg
                                     target:(id)target
                                firstAction:(SEL)firstAction
                                secondImage:(UIImage *)secondImage
                             highlightedImg:(UIImage *)secondhighlightedImg
                               secondAction:(SEL)secondAction;

/**
 @brief 设置聊天页面的带消息数的返回按钮 如“<消息（1）”
 */
-(void)setBackButtonItemWithNormalImg2:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg titleText:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type;
-(void)setBackButtonItemWithNormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg titleText:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type;

- (void)setBarItemTitle:(NSString *)title titleColor:(NSString *)color target:(id)target action:(SEL)action type:(NavigationBarItemType)type;
- (void)setBarItemTitle:(NSString *)title titleColor:(UIColor *)color target:(id)target action:(SEL)action;


-(void)showProgressWithMsg:(NSString *)msg;
-(void)closeProgress;
- (void)showCustomToast:(NSString *)msg;
-(void)showProgress:(NSString *)msg afterDelay:(NSTimeInterval)delay;

-(NSArray *)getDepartmentArray:(NSString *)departmentId;

- (void)showAlertWithMsg:(NSString *)msg delegate:(id)delegate;

- (UIButton*)setNavRightButtonTitle:(NSString *)title enable:(BOOL)enable selector:(SEL)selecter;

- (UIView *)getWatermarkViewWithFrame:(CGRect)frame mobile:(NSString *)mobile name:(NSString *)name backColor:(UIColor *)color;

//通用的sheet样式
- (void)showSheetWithItems:(NSArray *)items inView:(UIView *)view selectedIndex:(void(^)(NSInteger index))selected;

//通用的sheet样式 带 sheet 消失的回调
- (void)showSheetWithItems:(NSArray *)items inView:(UIView *)view selectedIndex:(void (^)(NSInteger index))selected dismissCompletion:(void (^)(void))dismissCompletion;
//tip是说明
- (void)showSheetWithTip:(NSString *)tip items:(NSArray *)items inView:(UIView *)view selectedIndex:(void (^)(NSInteger index))selected;

- (void)updateSheetStyle;

- (void)dismissSheet;

@end

@interface NSObject (NSObjectFileTypeExtention)

+ (BOOL)isFileType_Doc:(NSString*)fileExtention;

+ (BOOL)isFileType_PPT:(NSString*)fileExtention;

+ (BOOL)isFileType_XLS:(NSString*)fileExtention;

+ (BOOL)isFileType_IMG:(NSString*)fileExtention;

+ (BOOL)isFileType_VIDEO:(NSString*)fileExtention;

+ (BOOL)isFileType_AUDIO:(NSString*)fileExtention;

+ (BOOL)isFileType_PDF:(NSString*)fileExtention;

+ (BOOL)isFileType_TXT:(NSString*)fileExtention;

+ (BOOL)isFileType_ZIP:(NSString*)fileExtention;

//add2017yxp9.5 获取文件对应的图片显示
+ (NSString *)getFileTypeImageViewWithFileExtension:(NSString*)fileExtention;

+ (NSString*)dataSizeFormat:(NSString*)dataSizeString;

@end

@interface NSObject (SystemEvent)

/**
 *  调用系统打电话功能
 *
 *  @param phonenumber 电话号码
 */
+ (void)callSystenPhoneNumber:(NSString *)phonenumber isSaveRecord:(BOOL)isSaveRecord recordDic:(NSDictionary *)recordDic;

/**
 *  调用系统发送短信功能
 *
 *  @param phonenumber 电话号码
 */
+ (void)smsSystemPhoneNumber:(NSString *)phonenumber;

/**
 *  是否需要侧滑返回手势
 **/
- (BOOL)shouldRecognizeTapGesture;

/**
 * 是否需要横屏
 **/
- (BOOL)shouldOrientationLandscape;
/**
 *强制横屏
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation;

@end

