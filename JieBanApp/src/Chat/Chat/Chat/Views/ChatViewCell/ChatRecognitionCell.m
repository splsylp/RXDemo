//
//  ChatRecognitionCell.m
//  Chat
//
//  Created by 胡伟 on 2019/8/5.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "ChatRecognitionCell.h"
#import "RX_TFHpple.h"
#import "UIImage+deal.h"
#import <WebKit/WebKit.h>

#define CellH 80.0f
#define CellW 180.0f * fitScreenWidth
#define BubbleMaxSize CGSizeMake(180.0f*fitScreenWidth, 200.0f)

@interface RXRecognizeWebUrlTool : NSObject<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) void (^responseBlock)(NSDictionary *dic);

+ (instancetype)sharedInstance;
- (void)getWebViewHtmlData:(NSURL *)url  response:(void (^)(NSDictionary *dic))response;

@end
static RXRecognizeWebUrlTool *_sharedInstance = nil;
@implementation RXRecognizeWebUrlTool

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });
    return _sharedInstance;
}

- (void)getWebViewHtmlData:(NSURL *)url  response:(void (^)(NSDictionary *dic))response  {
    WS(weakSelf)
    self.responseBlock = response;
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:5.0];
    [request didChangeValueForKey:@"timeoutInterval"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.webView) {
            weakSelf.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
            weakSelf.webView.navigationDelegate = self;
            weakSelf.webView.UIDelegate = self;
        }
        [weakSelf.webView loadRequest:request];
    });
}


- (NSDictionary *)getParsedInfoWithUrl:(NSURL *)url {

    NSMutableDictionary *mDic = @{}.mutableCopy;
    NSData *data = [NSData dataWithContentsOfURL:url];
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *retStr = [[NSString alloc] initWithData:data encoding:encode];
    if (retStr) {
        data = [retStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    RX_TFHpple *thfpple = [[RX_TFHpple alloc] initWithHTMLData:data];
    NSArray *titleArray = [thfpple searchWithXPathQuery:@"//title"];
    if (titleArray.count > 0) {
        RX_TFHppleElement *element = (RX_TFHppleElement *)titleArray.firstObject;
        if (element.text) {
            [mDic setObject:[self trimedString:element.text] forKey:@"title"];
        }
    }
    
    NSArray *divArray = [thfpple searchWithXPathQuery:@"//div"];
    NSMutableString *mStr = @"".mutableCopy;
    [self recursion:divArray param:mStr];
    if (mStr.length > 0) {
        [mDic setObject:mStr forKey:@"divDesc"];
    }
    
    NSArray *descArray = [thfpple searchWithXPathQuery:@"//meta"];
    for (RX_TFHppleElement *element in descArray) {
        if ([[element objectForKey:@"name"] isEqualToString:@"description"]) {
            NSString *desc = element.attributes[@"content"];
            if (desc.length > 0) {
                [mDic setObject:desc forKey:@"metaDesc"];
            }
        }
    }
    
    NSArray *imgArray = [thfpple searchWithXPathQuery:@"//img"];
    [imgArray enumerateObjectsUsingBlock:^(RX_TFHppleElement *element, NSUInteger idx, BOOL *stop) {
        NSString *dataSrc = element.attributes[@"data-src"];
        NSString *src = element.attributes[@"src"];
        if (dataSrc.length > 0) {
            if (![dataSrc hasPrefix:url.scheme]) {
                dataSrc = [NSString stringWithFormat:@"%@:%@", url.scheme, dataSrc];
            }
            [mDic setObject:dataSrc forKey:@"img"];
            *stop = true;
        }
        else {
            if (src) {
                if (![src hasPrefix:url.scheme]) {
                    if ([src containsString:url.host]) {
                        src = [NSString stringWithFormat:@"%@:%@", url.scheme, src];
                    }
                    else {
                        src = [NSString stringWithFormat:@"%@%@", url.absoluteString, src];
                    }
                }
                [mDic setObject:src forKey:@"img"];
                *stop = true;
            }
        }
    }];
    
    return mDic.copy;
}

- (NSString *)trimedString:(NSString *)str {
    return [[[[[str stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)recursion:(NSArray *)array param:(NSMutableString *)mStr {
    NSMutableString *tempStr = mStr;
    if (tempStr.length > 50) {
        return tempStr;
    }
    for (int i = 0 ; i < array.count; i ++) {
        RX_TFHppleElement *element = array[i];
        if (![element.tagName isEqualToString:@"script"]) {
            if (element.children.count > 0) {
                [self recursion:element.children param:tempStr];
            }
            else {
                if ([element isTextNode] && element.content) {
                    NSString *content = [self trimedString:element.content];
                    if(content.length > 0) {
                        [tempStr appendString:[NSString stringWithFormat:@"%@ ", [self trimedString:element.content]]];
                    }
                }
            }
        }
    }
    return tempStr;
}

- (NSString *)localPathWithRemoteUrl:(NSURL *)imageUrl {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",dateStr]];
    if (!imageUrl) {
        return path;
    }
    dispatch_semaphore_t signal;
    signal = dispatch_semaphore_create(0);
    [[SDWebImageManager sharedManager] loadImageWithURL:imageUrl options:SDWebImageFromCacheOnly progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!image){
            image = ThemeImage(@"icon_linkfailure");
        }
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [imageData writeToFile:path atomically:YES];
        
        CGSize thumsize = CGSizeMake((90.0f/image.size.height) * image.size.width, 90.0f);
        UIImage * thumImage = [image compressImageWithSize:thumsize];
        NSData *photo = UIImageJPEGRepresentation(thumImage, 0.5);
        [photo writeToFile:path atomically:YES];
        dispatch_semaphore_signal(signal);
    }];
    dispatch_semaphore_wait(signal,DISPATCH_TIME_FOREVER);
    return path;
}

#pragma mark - WKWebViewDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSDictionary *dic = [self getParsedInfoWithUrl:webView.URL];
    if (dic.count>0) {
        !self.responseBlock?:self.responseBlock(dic);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    !self.responseBlock?:self.responseBlock(@{});
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    //这里有失败的情况 所以打开了这个注释
    !self.responseBlock?:self.responseBlock(@{});
}


@end












@interface ChatRecognitionCell ()

@property (nonatomic, weak) UILabel *urlLabel;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UILabel *descLabel;

@end

@implementation ChatRecognitionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getHightOfCellViewWith:(ECTextMessageBody *)messageBody{
    CGFloat height = 0.0f;
    ECTextMessageBody *body = (ECTextMessageBody *)messageBody;
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
    height = bubbleSize.height + 44.0f + 20.0f;
    return height;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
 
        self.bubbleView.frame = CGRectMake(CGRectGetMinX(self.portraitImg.frame)-CellW - 10, self.portraitImg.frame.origin.y, CellW, CellH);
        self.bubleimg.image = [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
        
        UILabel *urlLabel = [UILabel new];
        urlLabel.font = ThemeFontLarge;
        urlLabel.textColor = [UIColor colorWithHexString:@"1B7BD3"];
        urlLabel.numberOfLines = 2;
        [self.bubbleView addSubview:urlLabel];
        self.urlLabel = urlLabel;
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.lineView = lineView;
        [self.bubbleView addSubview:lineView];

        UILabel *descLabel = [UILabel new];
        descLabel.textColor = [UIColor lightGrayColor];
        descLabel.font = [UIFont systemFontOfSize:12];
        self.descLabel = descLabel;
        [self.bubbleView addSubview:descLabel];

    }
    return self;
}

- (void)setUIFrame:(CGSize)bubbleSize {
    
    if (self.isSender) {
        self.portraitImg.originX = kScreenWidth - 10.0f - self.portraitImg.width;
        self.bubbleView.left = self.portraitImg.left - bubbleSize.width - 20 - 10;
    }
    else {
        self.portraitImg.originX = 10.0f;
        self.bubbleView.left = self.portraitImg.right + 10;
    }
    self.bubbleView.width = bubbleSize.width + 20.0f;
    self.bubbleView.height = bubbleSize.height + 44;
    
    self.urlLabel.frame = CGRectMake(10, 10, bubbleSize.width + 5, bubbleSize.height);
    self.lineView.frame = CGRectMake(10, _urlLabel.bottom + 10, _urlLabel.width, 0.5);
    self.descLabel.frame = CGRectMake(10, _lineView.bottom + 5, _urlLabel.width, 14);
}

- (void)bubbleViewWithData:(ECMessage *)message{
    [super bubbleViewWithData:message];
    
    self.isSender = (message.messageState == ECMessageState_Receive && ![message.from isEqualToString:FileTransferAssistant]) ? NO : YES;
    
    self.displayMessage = message;
    ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
    self.urlLabel.text = body.text;
    
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
    
    [self setUIFrame:bubbleSize];

    self.retryBtn.hidden = YES;
    self.receipteBtn.hidden = YES;
    self.descLabel.text = @"链接识别中";
    [self showActivityView];
    
    if (body.text && message.messageId) {
        //识别过程 完成后刷新tableView
        NSString *url;
        NSRange httpRange = [body.text rangeOfString:@"http://"];
        NSRange httpsRange = [body.text rangeOfString:@"https://"];
        if (httpRange.location == NSNotFound && httpsRange.location == NSNotFound){
            url = [@"http://" stringByAppendingString:body.text];
        }
        else {
            url = body.text;
        }
        [self dissmissActivityView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [RXRecognizeWebUrlTool.sharedInstance getWebViewHtmlData:[NSURL URLWithString:url] response:^(NSDictionary *dic) {
    //                NSDictionary *dic = [self getParsedInfoWithUrl:[NSURL URLWithString:url]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
                        userData[SMSGTYPE] = @"27";
                        
                        if (dic.allKeys.count > 0) {
                            userData[@"sendState"] = @(1);
                            userData[@"title"] = dic[@"title"] ? : @"网页";
                            userData[@"desc"] = dic[@"metaDesc"] ? : dic[@"divDesc"];
                            userData[@"img"] = dic[@"img"];
                            userData[@"url"] = body.text;
                            if (self.isSender) {
                                NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
                                mDic[@"sessionId"] = message.sessionId;
                                mDic[@"type"] = @(ChatMessageTypeSendUrl);
                                mDic[@"isBurn"] = @(NO);
                                mDic[@"sendState"] = @(1);
                                mDic[@"title"] = dic[@"title"] ? : @"网页";
                                mDic[@"desc"] = dic[@"metaDesc"] ? : dic[@"divDesc"];
                                mDic[@"img"] = dic[@"img"];
                                mDic[@"url"] = body.text;
                                if ([message.messageId isEqualToString:body.text]) {
                                    BOOL delete = [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:message.sessionId];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewDeleteCell" object:message];
                                    if (delete) {
                                        [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:body dic:mDic];
                                    }
                                }else if (message.messageId){
                                    [[KitMsgData sharedInstance] updateMsgType:body UserData:userData.jsonEncodedKeyValueString ofMessageId:message.messageId];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewShouldReloadData" object:message];
                                }
                            }
                            else {
                                [[KitMsgData sharedInstance] updateMsgType:body UserData:userData.jsonEncodedKeyValueString ofMessageId:message.messageId];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewShouldReloadData" object:message];
                            }
                        }
                        else {
                            self.descLabel.text = @"未获取到链接内容";
                            userData[@"sendState"] = @(0);
                            if (self.isSender) {
                                NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
                                mDic[@"sessionId"] = message.sessionId;
                                mDic[@"type"] = @(ChatMessageTypeSendUrl);
                                mDic[@"isBurn"] = @(NO);
                                mDic[@"sendState"] = @(0);
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    BOOL delete = [[KitMsgData sharedInstance] deleteMessage:message.messageId andSession:message.sessionId];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewDeleteCell" object:message];
                                    if (delete) {
                                        [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:body dic:mDic];
                                    }
                                });
                            }
                            else {
                                [[KitMsgData sharedInstance] updateMsgType:body UserData:userData.jsonEncodedKeyValueString ofMessageId:message.messageId];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewShouldReloadData" object:message];
                            }
                        }
                        
                    });
            }];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.descLabel.text = @"未获取到链接内容";
        });
    }
}

- (void)showActivityView {
    if (self.isSender) {
        self.sendStatusView.originX = self.bubbleView.originX - 30.0f;
    }
    else {
        self.sendStatusView.originX = self.bubbleView.right + 30.0f;
    }
    self.sendStatusView.centerY = self.bubbleView.centerY;
    self.sendStatusView.hidden = NO;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}

- (void)dissmissActivityView {
    self.sendStatusView.hidden = YES;
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}


@end
