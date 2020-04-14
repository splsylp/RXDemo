//
//  RXGuideView.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/6/17.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXGuideView.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"
#import "KCConstants_API.h"

#define IMAGE(name)     [[RXThemeManager sharedInstance] imageWithImageName:(name)]
#define IMAGESYSTEM(name)  ThemeImage((name))

//默认图片
#define IMG_DEFINE    IMAGESYSTEM(@"default.png")

//启动页图片
#define IMG_GUIDE_PAGE_01      @"product_wizard_page_01"
#define IMG_GUIDE_PAGE_02      @"product_wizard_page_02"
#define IMG_GUIDE_PAGE_03      @"product_wizard_page_03"
#define IMG_GUIDE_PAGE_04      @"product_wizard_page_04"
#define IMG_GUIDE_PAGETXT_01   @"product_wizard_page_txt_01"
#define IMG_GUIDE_PAGETXT_02   @"product_wizard_page_txt_02"
#define IMG_GUIDE_PAGETXT_03   @"product_wizard_page_txt_03"
#define IMG_GUIDE_PAGETXT_04   @"product_wizard_page_txt_04"
#define IMG_GUIDE_PAGEPOINT_01 @"product_wizard_page_point_01"
#define IMG_GUIDE_PAGEPOINT_02 @"product_wizard_page_point_02"
#define IMG_GUIDE_PAGEPOINT_03 @"product_wizard_page_point_03"
#define IMG_GUIDE_PAGEPOINT_04 @"product_wizard_page_point_04"
#define IMG_START_BUTTON       IMAGESYSTEM(@"start_page_button.png")
#define IMG_START_BUTTON_ON    IMAGESYSTEM(@"start_page_button_on.png")

#define YXP_GUIDEVIEW_STARTTILTE    languageStringWithKey(@"立即开启")
#define YXP_LoginView_Login         languageStringWithKey(@"登录")

@interface RXGuideView()<UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *maskView;
@property (strong, nonatomic) UIImageView *lastImgView;
@property (nonatomic, retain)UIPageControl *myPageControl;
- (void)showAppGuideView;
- (void)hideAppGuideView;
@end
@implementation RXGuideView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
   if(self)
   {
       if (IsHengFengTarget) {
           [self creatHFShowScrollView];
       }else{
           [self creatRXShowScrollView];
       }
   }
    return self;

}

- (void)creatHFShowScrollView{
    UIScrollView *scrollView =[[UIScrollView alloc]initWithFrame:self.bounds];
    scrollView.backgroundColor =[UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    scrollView.delegate = self;
    [scrollView setBounces:NO];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self addSubview:scrollView];
    
    //默认图
    self.maskView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.maskView setImage:IMG_DEFINE];
    [self.maskView setUserInteractionEnabled:YES];
    [self addSubview:self.maskView];
    
    //应用引导图
    NSArray *intrImgsArray =@[IMG_GUIDE_PAGE_01,IMG_GUIDE_PAGE_02,IMG_GUIDE_PAGE_03,IMG_GUIDE_PAGE_04];
   
    NSArray *titlesArray =@[ languageStringWithKey(@"即时消息"), languageStringWithKey(@"音视频会议"), languageStringWithKey(@"应用商店"), languageStringWithKey(@"改版")];
    
    NSArray *textsArray =@[languageStringWithKey(@"消息中心，随时沟通"),languageStringWithKey(@"实时通信，高效安全"),languageStringWithKey(@"多种功能，任您选择"),languageStringWithKey(@"更新改版，全新上线")];
    for(int i=0;i<intrImgsArray.count;i++)
    {
        UIImageView *imgView =[[UIImageView alloc] initWithFrame:CGRectMake(i*scrollView.frameWidth, 0, scrollView.frameWidth, scrollView.frameHight)];
        [imgView setUserInteractionEnabled:YES];
        
        UIImageView *pageImg = [[UIImageView alloc] initWithImage:ThemeImage(intrImgsArray[i])];
        pageImg.center = CGPointMake(self.width/2, self.height/3);
        pageImg.contentMode = UIViewContentModeScaleAspectFill;
        pageImg.image = ThemeImage(intrImgsArray[i]);
        [imgView addSubview:pageImg];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 40 * fitScreenWidth)];
        label1.center = CGPointMake(self.width/2, pageImg.center.y * 2 + 20 * fitScreenWidth);
        label1.font = ThemeFontLarge;
        label1.text = titlesArray[i];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.textColor = [UIColor blackColor];
        [imgView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 20*fitScreenWidth)];
        label2.center = CGPointMake(self.width/2, label1.center.y + 30 * fitScreenWidth);
        label2.font = ThemeFontMiddle;
        label2.text = textsArray[i];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.textColor = [UIColor grayColor];
        [imgView addSubview:label2];
        
        if(i == intrImgsArray.count - 1){
            UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [startBtn setFrame:CGRectMake((kScreenWidth - 150)/2, label2.bottom + 40 * fitScreenWidth, 150, 38)];
            [startBtn setBackgroundColor:[UIColor whiteColor]];
            startBtn.layer.borderWidth = 1;
            startBtn.layer.borderColor = ThemeColor.CGColor;
            startBtn.titleLabel.font = ThemeFontLarge;
            startBtn.layer.cornerRadius = 11;
            if (isEnLocalization) {
                [startBtn.titleLabel setFont:ThemeFontSmall];
            }
            [startBtn setTitle:languageStringWithKey(@"立即开启") forState:UIControlStateNormal];
            [startBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
            
            [startBtn addTarget:self action:@selector(hideAppGuideView) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:startBtn];
            self.lastImgView = imgView;
        }else
        {
            UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [startBtn setFrame:CGRectMake(self.width-85, 30, 60, 34)];
            [startBtn setBackgroundColor:[UIColor whiteColor]];
            startBtn.layer.borderWidth = 1;
            startBtn.layer.borderColor = ThemeColor.CGColor;
            startBtn.layer.cornerRadius = 17;
            [startBtn setTitle:languageStringWithKey(@"跳过") forState:UIControlStateNormal];
            [startBtn.titleLabel setFont:ThemeFontLarge];
            [startBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
            
            [startBtn addTarget:self action:@selector(hideAppGuideView) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:startBtn];
        }
        
        [scrollView addSubview:imgView];
        
    }
     [scrollView setContentSize:CGSizeMake(scrollView.frameWidth*intrImgsArray.count, scrollView.frameHight)];
    
    self.myPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.height * 2 / 3 + 140 *fitScreenWidth, kScreenWidth, 30)];
    self.myPageControl.numberOfPages = intrImgsArray.count;
    self.myPageControl.currentPage = 0;
    self.myPageControl.hidden = intrImgsArray.count==0?YES:NO;
    [self addSubview:self.myPageControl];
    self.myPageControl.pageIndicatorTintColor = RGBA(192, 219, 251, 1);
    self.myPageControl.currentPageIndicatorTintColor = ThemeColor;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _myPageControl.currentPage = scrollView.contentOffset.x/self.frame.size.width;
}

- (void)creatRXShowScrollView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];
    [scrollView setBounces:NO];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self addSubview:scrollView];
    
    //默认图
    self.maskView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.maskView setImage:IMG_DEFINE];
    [self.maskView setUserInteractionEnabled:YES];
    [self addSubview:self.maskView];
    
    //应用引导图
    //1-3-4-2
    NSMutableArray *intrImgsArray = [[NSMutableArray alloc] init];
    for (int i = 1; i < 5; i++) {
        NSString *str = [NSString stringWithFormat:@"product_wizard_page%@_0%d",isIPhoneX ? @"_X":@"",i];
        [intrImgsArray addObject:str];
    }

    NSArray *intrImgsTwoAarry =@[IMG_GUIDE_PAGETXT_01,IMG_GUIDE_PAGETXT_03,IMG_GUIDE_PAGETXT_04,IMG_GUIDE_PAGETXT_02];
    
    NSArray *intrImgsThreeArray =@[IMG_GUIDE_PAGEPOINT_01,IMG_GUIDE_PAGEPOINT_02,IMG_GUIDE_PAGEPOINT_03];
    
    for(int i = 0; i < intrImgsArray.count ; i++){
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * scrollView.frameWidth, 0, scrollView.frameWidth, scrollView.frameHight)];
         [imgView setUserInteractionEnabled:YES];
        if(i == intrImgsArray.count - 1){
            [imgView setUserInteractionEnabled:YES];
            UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [startBtn setFrame:CGRectMake((kScreenWidth - 130)/2, self.frameHight - 42 * fitScreenWidth  - 40 * fitScreenWidth, 130, 42)];
            [startBtn setBackgroundImage:IMG_START_BUTTON forState:UIControlStateNormal];
            [startBtn setTitle:YXP_GUIDEVIEW_STARTTILTE forState:UIControlStateNormal];
            [startBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
            [startBtn setBackgroundImage:IMG_START_BUTTON_ON
                                forState:UIControlStateHighlighted];
            [startBtn setTitle:YXP_GUIDEVIEW_STARTTILTE forState:UIControlStateHighlighted];
            [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            if (isEnLocalization) {
                [startBtn.titleLabel setFont:ThemeFontSmall];
            }
            [startBtn addTarget:self action:@selector(hideAppGuideView) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:startBtn];
            self.lastImgView = imgView;
        }else{
//            UIImageView *pagePoint = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-61)/2, self.frameHight-9*fitScreenWidth-60*fitScreenWidth, 61*fitScreenWidth, 9*fitScreenWidth)];
//            pagePoint.image = ThemeImage(intrImgsThreeArray[i]);
//            [imgView addSubview:pagePoint];
//            [imgView setUserInteractionEnabled:YES];

            UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [startBtn setFrame:CGRectMake(self.width - 25 - 60 * FitThemeFont, kMainStatusBarHeight + 10, 60 * FitThemeFont, 34)];
            [startBtn setBackgroundColor:[UIColor whiteColor]];
            startBtn.layer.borderWidth = 1;
            startBtn.layer.borderColor = ThemeColor.CGColor;
            startBtn.layer.cornerRadius = 17;
            [startBtn setTitle:languageStringWithKey(@"跳过") forState:UIControlStateNormal];
            [startBtn.titleLabel setFont:ThemeFontLarge];
            [startBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
            
            [startBtn addTarget:self action:@selector(hideAppGuideView) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:startBtn];
        }
//        UIImageView *pageImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-225*fitScreenWidth)/2, 50*fitScreenWidth, 225*fitScreenWidth, 225*fitScreenWidth)];
//        pageImg.image = ThemeImage(intrImgsArray[i]);
//        [imgView addSubview:pageImg];

//        UIImageView *pagetxt = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-173*fitScreenWidth)/2, pageImg.bottom+40*fitScreenWidth, 173*fitScreenWidth, 61*fitScreenWidth)];
//        pagetxt.image = ThemeImage(intrImgsTwoAarry[i]);
//        [imgView addSubview:pagetxt];
        imgView.image = ThemeImage(intrImgsArray[i]);
        [scrollView addSubview:imgView];
    }
    [scrollView setContentSize:CGSizeMake(scrollView.frameWidth * intrImgsArray.count, scrollView.frameHight)];
}

+ (id)show{
    NSString *oldVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kNotFirstRunAppKey];
    
    if (oldVersion) {
        NSString *newVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([newVersion compare:oldVersion options:NSNumericSearch] == NSOrderedSame) {
            return nil;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_show_key object:nil];
    // 显示第一次启动简介
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [[[UIApplication sharedApplication] windows] lastObject];
    }
    RXGuideView *guideView =[[RXGuideView alloc] initWithFrame:window.bounds];
    [window addSubview:guideView];
    [guideView showAppGuideView];
    return guideView;
}
- (void)showAppGuideView{
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
}
- (void)hideAppGuideView{
    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:kNotFirstRunAppKey];
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.5];
    self.lastImgView.alpha = 0;
    self.lastImgView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self removeFromSuperview];
}





@end
