//
//  KitRelayAlertView.m
//  AddressBook
//
//  Created by yuxuanpeng on 2017/5/16.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "KitRelayAlertView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <WebKit/WebKit.h>
#import "HXShowFileViewController.h"
#import "BaseViewController.h"
#import "HXFileCacheManager.h"
#import "HXMergeMessageModel.h"
#import "HXMergeMessageFatherCell.h"
#import "HXMergerMessageBubbleFatherView.h"
#import "ShowLocationViewController.h"

#define STR_DLALERTVIEW_CONFIRM     languageStringWithKey(@"发送")      //confirm text
#define STR_DLALERTVIEW_CANCEL      languageStringWithKey(@"取消")      //cancel text
#define PictureSizePorprotion 3/5
#define PIctureSize 160.0

#define MaxSHowImageCount  6
#define showImageW  30*fitScreenWidth

#define TEXTCOLOR_DLALERTVIEW_CONFIRM  [UIColor colorWithHexString:APPMainUIColorHexString]


@interface KitRelayAlertPopView : UIView<UITableViewDelegate,UITableViewDataSource>

/** type */
@property(nonatomic,assign)RelayMessageType type;

/** params */
@property(nonatomic,strong)NSDictionary *params;

/** relatedView */
@property(nonatomic,strong)UIView *relatedView;

/** tableView */
@property(nonatomic,strong)UITableView *tableView;

/** dataArray */
@property(nonatomic,strong)NSArray *dataArray;

- (void)showInView:(UIView *)superView;

@end

@implementation KitRelayAlertPopView

- (instancetype)initWithType:(RelayMessageType)type params:(NSDictionary *)params relatedView:(UIView *)relatedView {
    self = [super init];
    if (self) {
        self.params = params;
        self.type = type;
        self.relatedView = relatedView;
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
    [self.layer setCornerRadius:5.0];
    [self.layer setMasksToBounds:YES];
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backButton = [UIImageView new];
    backButton.image = ThemeColorImage(ThemeImage(@"title_bar_back"), [UIColor blackColor]);
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    backButton.userInteractionEnabled = YES;
    [self addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(5);
        make.top.mas_offset(8);
        make.height.mas_equalTo(backButton.mas_width).multipliedBy(1);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action: @selector(backAction)];
    [backButton addGestureRecognizer:tap];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(backButton.mas_centerY);
        make.left.mas_equalTo(backButton.mas_right);
        make.right.mas_offset(-27);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.layer.backgroundColor = [UIColor colorWithHexString:@"#DBDBDB"].CGColor;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.height.mas_equalTo(0.5);
        make.top.mas_equalTo(backButton.mas_bottom).mas_offset(8);
    }];
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.top.mas_equalTo(line.mas_bottom).mas_offset(5);
    }];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.text = self.params[@"content"];
    contentLabel.font = [UIFont systemFontOfSize:16.f];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.left.mas_offset(5);
        make.right.mas_offset(-5);
        make.width.mas_equalTo(scrollView.mas_width).mas_offset(-10);
    }];
    
    NSString *url = self.params[@"url"];
    NSString *localPath = self.params[@"localPath"];
    if (self.type == RelayMessage_text) {
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_offset(0);
        }];
    }else if (self.type == RelayMessage_image){
        FLAnimatedImageView *imgView = [FLAnimatedImageView new];
        [scrollView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLabel.mas_bottom);
            make.bottom.mas_offset(0);
            make.left.mas_offset(5);
            make.right.mas_offset(-5);
            make.width.mas_equalTo(scrollView.mas_width).mas_offset(-10);
        }];
        
        if (!KCNSSTRING_ISEMPTY(localPath)) {
            NSString *templocalPath = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),localPath.lastPathComponent];
            UIImage *image = [UIImage imageWithContentsOfFile:templocalPath];
            if (image) {
                CGFloat h = (image.size.height/image.size.width)*(self.relatedView.width-10);
                [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(h);
                    if (KCNSSTRING_ISEMPTY(contentLabel.text)) {
                        make.centerY.mas_offset(0);
                    }else {
                        make.bottom.mas_offset(0);
                    }
                }];
            }
            [imgView sd_setImageWithURL:[NSURL fileURLWithPath:templocalPath] placeholderImage:ThemeImage(@"chat_placeholder_image") options:SDWebImageRefreshCached|SDWebImageRetryFailed];
        }else if (!KCNSSTRING_ISEMPTY(url)){
            [imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:ThemeImage(@"chat_placeholder_image") options:SDWebImageRefreshCached|SDWebImageRetryFailed];
        }
    }else if (self.type == RelayMessage_link) {
        WKWebView *webView = [[WKWebView alloc]init];
        [self addSubview:webView];
        [webView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.top.mas_equalTo(line.mas_bottom).mas_offset(0);
        }];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [webView loadRequest:request];
        titleLabel.text = self.params[@"content"];
    }else if (self.type == RelayMessage_video) {
        UIView *videoView = [UIView new];
        videoView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:videoView];
        [videoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.top.mas_equalTo(line.mas_bottom).mas_offset(0);
        }];
        
        url = [url stringByReplacingOccurrencesOfString:@"_thum" withString:@""];
        NSURL *videoUrl = [NSURL URLWithString:url];
        if(localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:localPath]){
            videoUrl =[NSURL fileURLWithPath:localPath];
        }
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
//        UIImage *image = [KitRelayAlertView.new getVideoImage:localPath];
        
        CGFloat w = 230.f;
        CGFloat x = (self.relatedView.width-w)/2;
        CGFloat h = 361.f;//(image.size.height/image.size.width)*w;
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.frame = CGRectMake(x, 0, w, h);
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
        [videoView.layer addSublayer:playerLayer];
        [player play];
        
//        UIView *toolView = [UIView new];
//        toolView.backgroundColor = [UIColor redColor];
//        [videoView addSubview:toolView];
//        toolView.size = CGSizeMake(w, 40);
//        toolView.left = x;

    }else if (self.type == RelayMessage_file) {
        ECMessage *message = self.params[@"message"];
        HXShowFileViewController *vc = [HXShowFileViewController new];
        vc.data = message;
        [self addSubview:vc.view];
        [vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.top.mas_equalTo(line.mas_bottom).mas_offset(0);
        }];
        titleLabel.text = self.params[@"content"];
    }else if (self.type == RelayMessage_mergeMessage) {
        titleLabel.text = self.params[@"content"];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithHexString:XHMergeBackColor];
        [self addSubview:_tableView];
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.top.mas_equalTo(line.mas_bottom).mas_offset(0);
        }];
        [self getArrayData];
    }else if (self.type == RelayMessage_location){
        ECMessage *message = self.params[@"message"];
        ECLocationMessageBody *msgBody = (ECLocationMessageBody*)message.messageBody;
        ECLocationPoint *point = [[ECLocationPoint alloc] initWithCoordinate:msgBody.coordinate andTitle:msgBody.title];
        ShowLocationViewController *locationVC = [[ShowLocationViewController alloc] initWithLocationPoint:point];
        locationVC.data = @{@"from":@"alert"};
        [self addSubview:locationVC.view];
        [locationVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.top.mas_equalTo(line.mas_bottom).mas_offset(0);
        }];
        titleLabel.text = self.params[@"content"];
        contentLabel.hidden = YES;
    }
    [self layoutIfNeeded];
}

- (void)backAction {
    [UIView animateWithDuration:0.15 animations:^{
        self.frame = self.relatedView.frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.relatedView.hidden = NO;
    }];
}

- (void)showInView:(UIView *)superView {
    self.frame = self.relatedView.frame;
    [superView addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.height = 400;
        self.centerY = self.relatedView.centerY;
    } completion:^(BOOL finished) {
        self.relatedView.hidden = YES;
    }];
}


#pragma mark  - 合并消息相关
- (void)getArrayData{
    ECMessage *message = self.params[@"message"];
    ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
    
    NSString *filePaht = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePaht];
    NSString *base64 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!base64) {//Android 发的需要先解压，才能读取到里面的内容
        NSData *dataUncompressed = [data uncompressZippedData];
        base64 = [[NSString alloc] initWithData:dataUncompressed encoding:NSUTF8StringEncoding];
    }
    if (!base64) {
        return;
    }
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSArray *tempDataArray = [NSData toArrayOrNSDictionary:decodedData];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dict in tempDataArray) {
        HXMergeMessageModel *model = [[HXMergeMessageModel alloc]init];
        [model setValuesForKeysWithDictionary:dict];
        model.faterMessage = message;
        [arr addObject:model];
    }
    self.dataArray = arr;
    [self.tableView reloadData];
}


/**
 secton 组数
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
/**
 row 行数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

/**
 cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    __weak HXMergeMessageDetailController *blockSelf = self;
    NSString *cellID = [HXMergeMessageFatherCell cellIdentifierForMessageModel:nil];
    HXMergeMessageFatherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[HXMergeMessageFatherCell alloc] initWithEachMergeMessageModel:[self.dataArray objectAtIndex:indexPath.section] reuseIdentifier:cellID];
    }
    [cell.mTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-5);
        make.width.mas_lessThanOrEqualTo(120);
        make.centerY.mas_equalTo(cell.mNameLabel.mas_centerY);
    }];
    
    [cell.mBubbleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(0);
        make.right.mas_offset(-5);
        make.left.mas_equalTo(cell.mHeaderImageView.mas_right).mas_offset(10);
        make.top.mas_equalTo(cell.mNameLabel.mas_bottom).mas_offset(5);
    }];
    cell.model = [self.dataArray objectAtIndex:indexPath.section];
    return cell;
}
/**
 row height --行高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HXMergeMessageModel *model = [self.dataArray objectAtIndex:indexPath.section];
    model.bubbleW = self.relatedView.width - 60-5;
    return [HXMergeMessageFatherCell returnHeightWithModel:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return FooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [HXMergeMessageFatherCell returnSecontionFooterView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
}


@end
















@implementation KitRelayAlertView
{
    
    UIView *_coverView;//遮盖层
    UIView *_alertView;
    
    UIButton *_cancelBtn;//取消按钮
    
    YXPAlertType _alertType;
//    NSString *_currentTitle;//主标题
    NSString *_groupCount;//群组成员个数
    NSString *_subContent;//副标题
    NSArray *_currentImageArray;//图片
    NSString *_content; //图文内容
    RelayMessageType _relayType;//转发消息的类型
    NSString *_localPath;//本地路径
    NSString *_remoteUrl;//远程下载
    
    NSArray *_contentArray;
    BOOL canShowDetail;//是否需要展示详情
    ECMessage *_message;
}

- (void)dealloc
{
    NSLog(@"KitRelayAlertView  大声的告诉我,你走走走");
}

-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType showContents:(NSArray *)showArray groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl message:(ECMessage *)message {
    self =[super init];
    if(self)
    {
        _alertHandler =completionHandler;
        _alertType = alertType;
        _groupCount =count;
        NSString *linkStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"链接")];
        NSString *fileStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")];
        NSString *voiceStr =[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音")];
        NSString *cardStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"服务号名片")];
        NSString *personCardStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"个人名片")];
        NSString *otherStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"其他")];
        NSString *transferStr =[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"合并转发")];
        NSString *locationStr =[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"位置")];
        _subContent = [NSString stringWithFormat:@"%@ %@",(relayType==RelayMessage_text)?@"":(relayType==RelayMessage_link)?linkStr:(relayType==RelayMessage_file)?fileStr:(relayType==RelayMessage_voice)?voiceStr:(relayType==RelayMessage_card)?cardStr:(relayType==RelayMessage_personCard)?personCardStr:(relayType==RelayMessage_location)?locationStr:otherStr,KCNSSTRING_ISEMPTY(content)?@"":content];
        if(relayType == RelayMessage_mergeMessage){
            _subContent = [NSString stringWithFormat:@"%@ %@",transferStr,content];
        }
        _contentArray = showArray;
        _relayType =relayType;
        _localPath =localPath;
        _remoteUrl =remoteUrl;
        _content = content;
        _message = message;
        if ([_subContent rangeOfString:personCardStr].location != NSNotFound || _relayType == RelayMessage_personCard) {
            canShowDetail = NO;
        }else {
            canShowDetail = YES;
        }
        [self initUI];
        
    }
    return self;
}

-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType showContents:(NSArray *)showArray groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl
{
    self =[super init];
    if(self)
    {
        _alertHandler =completionHandler;
        _alertType = alertType;
        _groupCount =count;
        NSString *linkStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"链接")];
        NSString *fileStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")];
        NSString *voiceStr =[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音")];
        NSString *cardStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"服务号名片")];
        NSString *personCardStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"个人名片")];
        NSString *otherStr = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"其他")];
        NSString *transferStr =[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"合并转发")];
        
        _subContent = [NSString stringWithFormat:@"%@ %@",(relayType==RelayMessage_text)?@"":(relayType==RelayMessage_link)?linkStr:(relayType==RelayMessage_file)?fileStr:(relayType==RelayMessage_voice)?voiceStr:(relayType==RelayMessage_card)?cardStr:(relayType==RelayMessage_personCard)?personCardStr:otherStr,KCNSSTRING_ISEMPTY(content)?@"":content];
        if(relayType == RelayMessage_mergeMessage){
            _subContent = [NSString stringWithFormat:@"%@ %@",transferStr,content];
        }
        _contentArray = showArray;
        _relayType =relayType;
        _localPath =localPath;
        _remoteUrl =remoteUrl;
        _content = content;
        
        if ([_subContent rangeOfString:personCardStr].location != NSNotFound || _relayType == RelayMessage_personCard) {
            canShowDetail = NO;
        }else {
            canShowDetail = YES;
        }
        [self initUI];
        
    }
    return self;
}

-(void)initUI
{
    [self setFrame:[UIScreen mainScreen].bounds];
    
    _coverView = [[UIView alloc] initWithFrame:self.frame];
    [_coverView setBackgroundColor:[UIColor blackColor]];
    [_coverView setAlpha:0.5];
    [self addSubview:_coverView];
    
    _alertView =[[UIView alloc]init];
    _alertView.backgroundColor=[UIColor whiteColor];
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(30*fitScreenWidth, 0, self.width-60*fitScreenWidth, 0)];
    
    [self addSubview:_alertView];
    
    CGFloat kAlertViewHeight = 0;
    __block CGFloat kNewViewHeight = 0;
    
    switch (_alertType) {
        case YXP_relay:
        {
            UILabel *relayLabel =[[UILabel alloc]initWithFrame:CGRectMake(15, 20, _alertView.width-50, 25)];
            relayLabel.text =languageStringWithKey(@"发送给:");
            [relayLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
            relayLabel.backgroundColor=[UIColor clearColor];
            [_alertView addSubview:relayLabel];
            
            if(_contentArray.count == 1){
                NSDictionary *contentDic = _contentArray[0];
                //图像
                UIImageView *imageHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(15,relayLabel.bottom+5, 45, 45)];
                imageHeadView.contentMode = UIViewContentModeScaleAspectFill;
                imageHeadView.clipsToBounds = YES;
                [_alertView addSubview:imageHeadView];
                if([contentDic objectForKey:@"selectHeadImage"]){
                    imageHeadView.image = (UIImage *)[contentDic objectForKey:@"selectHeadImage"];
                }
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, relayLabel.bottom+5, _alertView.width-85, 45)];
                titleLabel.numberOfLines = 0;
                titleLabel.font = ThemeFontLarge;
                titleLabel.backgroundColor=[UIColor clearColor];
                [_alertView addSubview:titleLabel];

                NSString *forwardName;
//                if ([[contentDic objectForKey:@"symbol"] isEqualToString:@"~ytxfa"]) {
//                    forwardName = contentDic[@"selectName"];
//                } else {
//                    forwardName = [[Common sharedInstance] getOtherNameAndCountWithPhone:[contentDic objectForKey:@"symbol"]];
//                }
                if ([contentDic objectForKey:@"selectName"]) {
                    forwardName = contentDic[@"selectName"];
                }else {
                    forwardName = [[Common sharedInstance] getOtherNameAndCountWithPhone:[contentDic objectForKey:@"symbol"]];
                }
                
                titleLabel.text = forwardName;
//                titleLabel.attributedText = [NSAttributedString attributeStringWithContent:[NSString stringWithFormat:@"%@ %@",forwardName,[contentDic objectForKey:@"groupCountStr"]] keyWords:[contentDic objectForKey:@"groupCountStr"] colors:[UIColor lightGrayColor]];
                kAlertViewHeight  = imageHeadView.bottom+15;
               
            }else
            {
                //间隔
                CGFloat lineW =   ((_alertView.width - 30)-MaxSHowImageCount*showImageW)/5;
                CGFloat lineY = 5*fitScreenWidth;
                for(int i = 0;i<_contentArray.count; i++)
                {
                     NSDictionary *contentDic = _contentArray[i];
                    int row = i/MaxSHowImageCount;//行
                    int loc=i%MaxSHowImageCount;//列号
                    
                    CGFloat appviewx=lineW+(lineW+showImageW)*loc;
                    CGFloat appviewy=lineY+(lineY+showImageW)*row+relayLabel.bottom+5;
                    
                    //图像
                    UIImageView *imageHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(appviewx,appviewy, showImageW, showImageW)];
                    imageHeadView.contentMode = UIViewContentModeScaleAspectFill;
                    imageHeadView.clipsToBounds = YES;
                    imageHeadView.image=[contentDic objectForKey:@"selectHeadImage"];

                    [_alertView addSubview:imageHeadView];
                    
                    kAlertViewHeight = imageHeadView.bottom+15;
                }
               
            }
            
            UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(15, kAlertViewHeight, _alertView.width-30, 1)];
            lineView.backgroundColor=[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
            [_alertView addSubview:lineView];
            
            kAlertViewHeight =lineView.bottom;
            
            
            switch (_relayType) {
                case RelayMessage_text:
                case RelayMessage_link:
                case RelayMessage_file:
                case RelayMessage_voice:
                case RelayMessage_card:
                case RelayMessage_personCard:
                case RelayMessage_mergeMessage:
                case RelayMessage_location:
                {
                    
                    UILabel *contentLabel =[[UILabel alloc]initWithFrame:CGRectMake(15, lineView.bottom+15, _alertView.width-30-15, 0)];
                    contentLabel.font = ThemeFontMiddle;
                    contentLabel.textColor =[UIColor colorWithRed:0.57f green:0.57f blue:0.57f alpha:1.00f];
                    contentLabel.numberOfLines=0;
                    [_alertView addSubview:contentLabel];
                    
                    CGSize contentSize = [[Common sharedInstance] widthForContent:_subContent withSize:CGSizeMake(_alertView.width - 30-15, CGFLOAT_MAX) withLableFont:14];
                    if(contentSize.height > 35){
                        contentSize.height = 35;
                    }
                    contentLabel.height = contentSize.height+5;
                    contentLabel.text = _subContent;
                    kAlertViewHeight =contentLabel.bottom+15;
                    
                    if (_relayType != RelayMessage_card || _relayType != RelayMessage_personCard) {
                        contentLabel.userInteractionEnabled = YES;
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPopView)];
                        [contentLabel addGestureRecognizer:tap];
                    }
                    
                    if (_relayType == RelayMessage_text || _relayType == RelayMessage_link || _relayType == RelayMessage_file || _relayType == RelayMessage_mergeMessage || _relayType == RelayMessage_location) {
                        //enter_icon_02
                        UIImageView *arrowImgView = [UIImageView new];
                        arrowImgView.image = ThemeImage(@"enter_icon_02");
                        arrowImgView.contentMode = UIViewContentModeScaleAspectFit;
                        arrowImgView.size = CGSizeMake(15, 15);
                        [_alertView addSubview:arrowImgView];
//                        arrowImgView.backgroundColor = [UIColor greenColor];
//                        contentLabel.backgroundColor = [UIColor redColor];
                        arrowImgView.centerY = contentLabel.centerY;
                        arrowImgView.left = contentLabel.right;
                    }
                }
                    break;
                case RelayMessage_image:
                {
                    UIImageView *imageView;
                    UILabel *contentLabel;
                    if (_content.length>0) {

                        contentLabel =[[UILabel alloc]initWithFrame:CGRectMake(15, lineView.bottom+15, _alertView.width-30, 0)];
                        contentLabel.font = ThemeFontMiddle;
                        contentLabel.textColor =[UIColor colorWithRed:0.57f green:0.57f blue:0.57f alpha:1.00f];
                        contentLabel.numberOfLines=0;
                        [_alertView addSubview:contentLabel];

                        CGSize contentSize = [[Common sharedInstance] widthForContent:_content withSize:CGSizeMake(_alertView.width - 30, CGFLOAT_MAX) withLableFont:14];
                        if(contentSize.height > 35){
                            contentSize.height = 35;
                        }
                        contentLabel.height =contentSize.height+5;
                        contentLabel.text = _content;
                        //                        kAlertViewHeight =contentLabel.bottom+15;

                        imageView =[[UIImageView alloc]initWithFrame:CGRectMake((_alertView.width-80)/2, contentLabel.bottom+15, 80, 110)];

                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        imageView.clipsToBounds = YES;
                        imageView.backgroundColor=[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];

                        [_alertView addSubview:imageView];

                        kAlertViewHeight =  imageView.bottom+15;

                    }else{
                        imageView =[[UIImageView alloc]initWithFrame:CGRectMake((_alertView.width-80)/2, lineView.bottom+15, 80, 110)];
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        imageView.clipsToBounds = YES;
                        imageView.backgroundColor=[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];

                        [_alertView addSubview:imageView];

                        kAlertViewHeight =imageView.bottom+15;
                    }
                    
                    imageView.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPopView)];
                    [imageView addGestureRecognizer:tap];

                    if(!KCNSSTRING_ISEMPTY(_localPath)){
                        
                        NSString *templocalPath = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),_localPath.lastPathComponent];
                        UIImage *image = [UIImage imageWithContentsOfFile:templocalPath] ? : [UIImage imageWithContentsOfFile:_localPath];
                        
                        CGFloat width = image.size.width;
                        CGFloat hight = image.size.height;

                        CGFloat newWidth = ((_alertView.width * PictureSizePorprotion > _alertView.width * PictureSizePorprotion) && (width / hight >= 2))||(width / hight >= 2)?_alertView.width * PictureSizePorprotion:PIctureSize * width/hight;
                        CGFloat newHeight = ((width * PictureSizePorprotion > _alertView.width * PictureSizePorprotion) && (width / hight >= 2))||(width/hight >= 2) ?hight * ((_alertView.width/width) * PictureSizePorprotion):PIctureSize;

                        if ((newWidth<70)||newWidth > _alertView.width*2/3) {
                            newWidth = (newWidth<70)?70:newWidth;
                            newWidth = (newWidth > _alertView.width*2/3)?_alertView.width*2/3:newWidth;
                        }
                        if (contentLabel) {
                            imageView.frame = CGRectMake((_alertView.width-newWidth)/2, contentLabel.bottom+15, newWidth, newHeight);
                        }else{
                            imageView.frame = CGRectMake((_alertView.width -newWidth)/2, lineView.bottom + 15, newWidth, newHeight);
                        }
                        imageView.image = image;
                        kAlertViewHeight = imageView.bottom+15;
                    }else if (!KCNSSTRING_ISEMPTY(_remoteUrl)){
                        __weak typeof(imageView)weak_image =imageView;
                        [imageView sd_setImageWithURL:[NSURL URLWithString:_remoteUrl] placeholderImage:nil options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            if(image){
                                CGSize imgSize = [self imageSize:image];
                                //                                 weak_image.frame
                                if (contentLabel) {
                                    weak_image.frame = CGRectMake((_alertView.width-imgSize.width)/2, contentLabel.bottom+15, imgSize.width, imgSize.height);
                                }else{
                                    weak_image.frame = CGRectMake((_alertView.width-imgSize.width)/2, lineView.bottom+15, imgSize.width, imgSize.height);
                                }
                                _cancelBtn.originY = weak_image.bottom+15;
                                _confirmBtn.originY = weak_image.bottom+15;
                                _alertView.originY = (self.height-weak_image.bottom-15-48)/2;
                                _alertView.height = weak_image.bottom+15+48;
                                kNewViewHeight = weak_image.bottom+15;
                            }
                        }];
                    }
                }
                    break;
                    
                case RelayMessage_video:
                {
                    //大小固定 50x80
                    UIImageView *thumImageView =[[UIImageView alloc]initWithFrame:CGRectMake((_alertView.width-100)/2, lineView.bottom+15, 110, 130)];
                    thumImageView.contentMode = UIViewContentModeScaleAspectFill;
                    thumImageView.clipsToBounds = YES;
                    thumImageView.layer.cornerRadius=5;
                    thumImageView.layer.masksToBounds=YES;
                    thumImageView.backgroundColor=[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
                    
                    [_alertView addSubview:thumImageView];
                    
                    if(_localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:_localPath])
                    {
                        thumImageView.image =[self getVideoImage:_localPath];
                    }else
                    {
                        [thumImageView sd_setImageWithURL:[NSURL URLWithString:_remoteUrl]placeholderImage:nil options:0];
                    }
                    
                    //标签图片
                    UIImageView *tagImageView =[[UIImageView alloc]initWithFrame:CGRectMake(8, thumImageView.height-15, 16, 9)];
                    tagImageView.image= ThemeImage(@"videoTag_03");
                    [thumImageView addSubview:tagImageView];
                    
                    kAlertViewHeight =thumImageView.bottom+15;
                    
                    thumImageView.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPopView)];
                    [thumImageView addGestureRecognizer:tap];

                }
                    break;
                case RelayMessage_other:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
            
        default:
            break;
    }
    
    
    
    //[_alertView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [_alertView.layer setCornerRadius:5.0];
    [_alertView.layer setMasksToBounds:YES];
    [_alertView setBackgroundColor:[UIColor whiteColor]];
    
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(_alertView.width/2, (kNewViewHeight==0?kAlertViewHeight:kNewViewHeight), _alertView.width/2, 48)];
    [_confirmBtn setBackgroundColor:[UIColor whiteColor]];
    [_confirmBtn.layer setShadowColor:[[UIColor grayColor] CGColor]];
    [_confirmBtn.layer setShadowRadius:0.5];
    [_confirmBtn.layer setShadowOpacity:1.0];
    [_confirmBtn.layer setShadowOffset:CGSizeZero];
    [_confirmBtn.layer setMasksToBounds:NO];
    
    if(_contentArray.count>1)
    {
        [_confirmBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",STR_DLALERTVIEW_CONFIRM,(unsigned long)_contentArray.count] forState:UIControlStateNormal];
  
    }else
    {
        [_confirmBtn setTitle:STR_DLALERTVIEW_CONFIRM forState:UIControlStateNormal];
    }
    
    [_confirmBtn setTitleColor:TEXTCOLOR_DLALERTVIEW_CONFIRM forState:UIControlStateNormal];
    [_confirmBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:_confirmBtn.titleLabel.font.pointSize]];
    [_confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_confirmBtn];
    
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (kNewViewHeight==0?kAlertViewHeight:kNewViewHeight), _alertView.width/2, 48)];
    [_cancelBtn setBackgroundColor:[UIColor whiteColor]];
    [_cancelBtn.layer setShadowColor:[[UIColor grayColor] CGColor]];
    [_cancelBtn.layer setShadowRadius:0.5];
    [_cancelBtn.layer setShadowOpacity:1.0];
    [_cancelBtn.layer setShadowOffset:CGSizeZero];
    [_cancelBtn.layer setMasksToBounds:NO];
    [_cancelBtn setTitle:STR_DLALERTVIEW_CANCEL forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:_cancelBtn.titleLabel.font.pointSize]];
    [_cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_cancelBtn];
    _alertView.originY =(self.height-kAlertViewHeight-48)/2;
    _alertView.height =(kNewViewHeight==0?kAlertViewHeight:kNewViewHeight)+48;
    
}

- (void)showSuperView:(UIView *)view
{
    [self setOriginY:0];
    [view addSubview:self];
}

-(void)cancel:(id)sender
{
    if (_alertHandler) {
        _alertHandler(NO, nil);
    }
    _alertHandler = nil;
    
    [self removeFromSuperview];
}

- (void)confirm:(id)sender
{
    if (_alertHandler) {
        if (_alertType == YXP_relay)
        {
            _alertHandler(YES, nil);
//            _alertHandler = nil;
            [self removeFromSuperview];
            return;
        }
        _alertHandler(YES, nil);
    }
    _alertHandler = nil;
    
    [self removeFromSuperview];
}

- (CGSize)imageSize:(UIImage *)image{
    CGFloat width = image.size.width;
    CGFloat hight = image.size.height;
    
    CGFloat newWidth = ((_alertView.width*PictureSizePorprotion > _alertView.width*PictureSizePorprotion)&&(width/hight >= 2))||(width/hight >= 2)?_alertView.width*PictureSizePorprotion:PIctureSize*width/hight;
    CGFloat newHeight = ((width*PictureSizePorprotion > _alertView.width*PictureSizePorprotion)&&(width/hight >= 2))||(width/hight >= 2)?hight*((_alertView.width/width)*PictureSizePorprotion):PIctureSize;
    
    if ((newWidth<70)||newWidth > _alertView.width*2/3) {
        newWidth = (newWidth<70)?70:newWidth;
        newWidth = (newWidth > _alertView.width*2/3)?_alertView.width*2/3:newWidth;
        
    }
    
    return CGSizeMake(newWidth, newHeight);
}


#pragma mark getVideoImage
-(UIImage *)getVideoImage:(NSString *)videoURL
{
    NSString* fileNoExtStr = [videoURL stringByDeletingPathExtension];
    NSString* imagePath = [NSString stringWithFormat:@"%@.jpg", fileNoExtStr];
    UIImage * returnImage = [[UIImage alloc] initWithContentsOfFile:imagePath] ;
    if (returnImage){
        return returnImage;
    }
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:opts] ;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(360.0f, 480.0f);
    NSError *error = nil;
    CGImageRef image = [gen copyCGImageAtTime: CMTimeMake(1, 1) actualTime:NULL error:&error];
    returnImage = [[UIImage alloc] initWithCGImage:image] ;
    CGImageRelease(image);
    [UIImageJPEGRepresentation(returnImage, 0.6) writeToFile:imagePath atomically:YES];
    return returnImage;
}

- (void)showPopView {
    if (!canShowDetail) {
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    if (!KCNSSTRING_ISEMPTY(_content)) {
        [params setObject:_content forKey:@"content"];
    }
    if (_remoteUrl) {
        [params setObject:_remoteUrl forKey:@"url"];
    }
    if (_localPath) {    
        [params setObject:_localPath forKey:@"localPath"];
    }
    
    if (_message) {
        [params setObject:_message forKey:@"message"];
    }
    
    KitRelayAlertPopView *view = [[KitRelayAlertPopView alloc] initWithType:_relayType params:params relatedView:_alertView];
    [view showInView:self];
}


@end
