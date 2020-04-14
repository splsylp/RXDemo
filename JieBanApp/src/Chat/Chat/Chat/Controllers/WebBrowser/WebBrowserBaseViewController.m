//
//  WebBrowserViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/17.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "WebBrowserBaseViewController.h"
#import <WebKit/WebKit.h>
#import "RX_TFHpple.h"
#import "RXThirdPart.h"
#import "NSString+containsString.h"
#import "UIImage+deal.h"

#define IPHONE8 [UIDevice currentDevice].systemVersion.integerValue<8.0

@interface WebBrowserBaseViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic,strong) WKWebView *wkWebView;
@property (nonatomic, strong) RX_TFHpple *doc;
@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) NSString *articleTitle;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imgLocalPath;
@property (nonatomic, copy) NSString *imgThumbPath;
@end

@implementation WebBrowserBaseViewController

- (instancetype)initWithBody:(ECPreviewMessageBody *)body andDelegate:(id)delegate {
    self=[super init];
    if (self) {
        _urlStr = body.url;
        self.delegate = delegate;
        _imageStr = body.remotePath;
        _articleTitle = body.title;
        _imgLocalPath = body.localPath;
        _imgThumbPath = body.thumbnailLocalPath;
        _content = body.desc;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = languageStringWithKey(@"网页");
    
//    UIBarButtonItem *leftItem;
    
    if ([UIDevice currentDevice].systemVersion.integerValue>7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
//        leftItem = [[UIBarButtonItem alloc] initWithImage:[ThemeImage(@"title_bar_back") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    }
//    else {
//        leftItem = [[UIBarButtonItem alloc] initWithImage:ThemeImage(@"title_bar_back") style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
//    }
//    self.navigationItem.leftBarButtonItem = leftItem;
    
//    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_back")
//                     highlightedImg:ThemeImage(@"title_bar_back")
//                             target:self
//                             action:@selector(returnClick)
//                               type:NavigationBarItemTypeLeft];
    
    [self setLeftBaritem];
    
    NSURL *url = [NSURL URLWithString:_urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_wkWebView];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    [_wkWebView loadRequest:request];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shoatSuccess:) name:@"shoatSuccess" object:nil];

    
}
- (void)shoatSuccess:(NSNotification *)noti {
    [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"已分享")];
//    [ATMHud showMessage:@"已分享"];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _wkWebView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight);
}

- (void) setRighBarItem {
    return;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:languageStringWithKey(@"分享") style:UIBarButtonItemStyleDone target:self action:@selector(shareAppToWeixin)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;

}
- (void)setLeftBaritem {
    CGRect btnFrame = CGRectMake(0, 0, 40, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setImage:ThemeImage(@"title_bar_back") forState:UIControlStateNormal];
    [button setImage:ThemeImage(@"title_bar_back") forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:self action:@selector(returnClick) forControlEvents:UIControlEventTouchUpInside];
    UIView* frameView = [[UIView alloc] initWithFrame:btnFrame];
    [frameView addSubview:button];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameView];
    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (void)returnClick {
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//    }];
}

- (void)shareAppToWeixin {
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(onSendPreviewMsgWithUrl:title:imgRemotePath:imgLocalPath:imgThumbPath:description:)]) {
//        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self.delegate onSendPreviewMsgWithUrl:_urlStr?_urlStr:nil title:_articleTitle?_articleTitle:nil imgRemotePath:_imageStr?_imageStr:nil imgLocalPath:_imgLocalPath?_imgLocalPath:nil imgThumbPath:_imgThumbPath?_imgThumbPath:nil description:_content?_content:_urlStr];
//        }];
    }
}



#pragma mark - UIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    
}
#pragma mark - navigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [SVProgressHUD showWithStatus:languageStringWithKey(@"正在加载...")];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    if ((!KCNSSTRING_ISEMPTY(_articleTitle)) || (!KCNSSTRING_ISEMPTY(_imgThumbPath)) || (!KCNSSTRING_ISEMPTY(_imgLocalPath)) || (!KCNSSTRING_ISEMPTY(_imageStr))) {
        [self setRighBarItem];
    } else {
        [self parseHtml:webView.URL];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self closeProgress];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@%ld",languageStringWithKey(@"网页加载失败"),(long)error.code]];
}

- (void)parseHtml:(NSURL*)url {
    self.doc = [[RX_TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:url]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *titleArray = [self.doc searchWithXPathQuery:@"//title"]?:@[];
        for (RX_TFHppleElement *element in titleArray) {
            _articleTitle = element.text?:languageStringWithKey(@"网页");
            _articleTitle = [[[_articleTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
            _articleTitle = [_articleTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = _articleTitle;
            });
        }
        if (![_urlStr myContainsString:@"taobao.com"]) {
            NSArray *descArray = [self.doc searchWithXPathQuery:@"//meta"];
            for (RX_TFHppleElement *element in descArray) {
                if ([[element objectForKey:@"name"] isEqualToString:@"description"]) {
                    _content = [element.attributes objectForKey:@"content"]?:@"";
                }
            }
        }
        if (_content.length<=0) {
            NSRange range1;
            if ([_urlStr hasPrefix:@"http://"]) {
                range1 = [_urlStr rangeOfString:@"http://"];
            } else if ([_urlStr hasPrefix:@"https://"]) {
                range1 = [_urlStr rangeOfString:@"https://"];
            }else{
                range1 = NSMakeRange(0, 0);
            }
            NSRange range2 = [_urlStr rangeOfString:@".com"];
            if (range1.length>0) {
                NSRange range3 = [[_urlStr substringFromIndex:range1.length-1] rangeOfString:@":"];
                range3.location+=range1.length-2;
                NSRange range4 = [[_urlStr substringFromIndex:range1.length-1] rangeOfString:@"/"];
                range4.location+=range1.length-2;
                range3 = range3.length==0?range4:range3;
                NSRange range = range2.length==0?range3:range2;
                if (range.length>0) {
                    _content = [_urlStr substringWithRange:NSMakeRange(range1.location+range1.length, range.location+range.length-range1.length)]?:@"";
                }
            }
        }

        
        NSArray *imgArray = [self.doc searchWithXPathQuery:@"//img"];
        [imgArray enumerateObjectsUsingBlock:^(RX_TFHppleElement *element, NSUInteger idx, BOOL *stop) {
            if ([[element objectForKey:@"class"] isEqualToString:@"firstPreload"]) {
                DDLogInfo(@"img:%@",element.attributes);
                _imageStr = [element.attributes objectForKey:@"src"]?:@"";
//                DDLogInfo(@"src:%@",_imageStr);
            }
        }];
        if (_imageStr.length<=0&&imgArray.count>0) {
            RX_TFHppleElement *element0 = (RX_TFHppleElement *)imgArray[0];
//            RX_TFHppleElement *element = [[RX_TFHppleElement alloc] init];
//            if (imgArray.count>1) {
//                RX_TFHppleElement *element1 = (RX_TFHppleElement *)imgArray[1];
//                element = (element1==nil)?element0:element1;
//            }else{
//                element = element0;
//            }
            _imageStr = [element0 objectForKey:@"src"];
        }
        if ((![_imageStr hasPrefix:@"http://"])&&![_imageStr hasPrefix:@"https://"]) {
            NSArray *arr = [_imageStr componentsSeparatedByString:@"/"];
            int a = 0;
            for (int i=0; i<arr.count; i++) {
                NSString *str = arr[i];
                if (!KCNSSTRING_ISEMPTY(str)) {
                    a = i;
                    break;
                }
            }
           NSString *tmpstr = [_imageStr substringFromIndex:a];
            if (tmpstr.length>0) {
                _imageStr = [NSString stringWithFormat:@"http://%@",tmpstr];
            } else {
                _imageStr = nil;
            }
            
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmssSSS";
        NSString *dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",dateStr]];
        _imgLocalPath = path;
        
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:_imageStr?:@""] options:SDWebImageFromCacheOnly progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            if (image) {
                
            } else {
                image = ThemeImage(@"ios_rx_logo");
            }
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [imageData writeToFile:path atomically:YES];
            
            CGSize thumsize = CGSizeMake((90.0f/image.size.height) * image.size.width, 90.0f);
            UIImage * thumImage = [image compressImageWithSize:thumsize];
            NSData *photo = UIImageJPEGRepresentation(thumImage, 0.5);
            NSString * thumfilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg_thum",dateStr]];
            _imgThumbPath = thumfilePath;
            [photo writeToFile:_imgThumbPath atomically:YES];
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setRighBarItem];
        });
    });
    
}

#pragma mark - 设置NavigationController的左右按钮
-(void)setBarButtonWithNormalImg:(UIImage *)normalImg
                  highlightedImg:(UIImage *)highlightedImg
                          target:(id)target
                          action:(SEL)action
                            type:(NavigationBarItemType)type
{
    
    CGRect btnFrame = CGRectMake(15, 0, 40, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:highlightedImg forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIView* frameView = [[UIView alloc] initWithFrame:btnFrame];
    [frameView addSubview:button];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameView];
    if (type == NavigationBarItemTypeLeft) {
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
    else{
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
}

@end
