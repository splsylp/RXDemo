//
//  YXPAlertView.m
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/12/7.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "YXPAlertView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RXGroupHeadImageView.h"
#import "NSAttributedString+Color.h"


#define STR_DLALERTVIEW_CONFIRM     languageStringWithKey(@"发送")       //confirm text
#define STR_DLALERTVIEW_CANCEL      languageStringWithKey(@"取消")       //cancel text
#define PictureSizePorprotion 3/5
#define PIctureSize 160

#define TEXTCOLOR_DLALERTVIEW_CONFIRM  [UIColor colorWithRed:(float)74/255.0f green:(float)192/255.0f blue:(float)86/255.0f alpha:1.0]

@implementation YXPAlertView
{
    
    UIView *_coverView;//遮盖层
    UIView *_alertView;
    
    UIButton *_cancelBtn;//取消按钮
    
    YXPAlertViewCompletionHandler _alertHandler;
    YXPAlertType _alertType;
    NSString *_currentTitle;//主标题
    NSString *_groupCount;//群组成员个数
    NSString *_subContent;//副标题
    UIImage *_currentImage;//图片
    NSArray *_currentImageArray;//图片
    
    RelayMessageType _relayType;//转发消息的类型
    NSString *_localPath;//本地路径
    NSString *_remoteUrl;//远程下载
    NSString *_name; // 发送到对方的名字
}
- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithBlock:andType:title:image:content:` instead.", NSStringFromClass([self class])] userInfo:nil];
}


-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType title:(NSString *)title groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent  sessiongArray:(NSArray *)sessiongArray relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl
{
    self =[super init];
    if(self)
    {
        _alertHandler =completionHandler;
        _alertType = alertType;
        _groupCount =count;
        _currentTitle =title;
        _subContent = [NSString stringWithFormat:@"%@ %@",(relayType==RelayMessage_text)?@"":(relayType==RelayMessage_link)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"链接")]:(relayType==RelayMessage_file)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")]:(relayType==RelayMessage_voice)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音")]:(relayType==RelayMessage_card)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"服务号名片")]:[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"其他")],KCNSSTRING_ISEMPTY(content)?@"":content];
        if(relayType == RelayMessage_mergeMessage){
            _subContent = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"合并转发")],content];
        }
        if(relayType == RelayMessage_eachMessage){
            _subContent = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"逐条转发")],content];
        }
        _currentImageArray =sessiongArray;
        _relayType =relayType;
        _localPath =localPath;
        _remoteUrl =remoteUrl;
        
        [self initUI];
        
    }
    return self;
}


-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType title:(NSString *)title groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent  image:(UIImage *)image relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl
{
    self =[super init];
    if(self)
    {
        _alertHandler =completionHandler;
        _alertType = alertType;
        _groupCount =count;
        _currentTitle =title;
        
        _subContent = [NSString stringWithFormat:@"%@ %@",(relayType==RelayMessage_text)?@"":(relayType==RelayMessage_link)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"链接")]:(relayType==RelayMessage_file)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")]:(relayType==RelayMessage_voice)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音")]:(relayType==RelayMessage_card)?[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"服务号名片")]:[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"其他")],KCNSSTRING_ISEMPTY(content)?@"":content];
        if(relayType == RelayMessage_mergeMessage){
            _subContent = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"合并转发")],content];
        }
        _currentImage =image;
        _relayType =relayType;
        _localPath =localPath;
        _remoteUrl =remoteUrl;
        
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
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(35*fitScreenWidth, 0, self.width-70*fitScreenWidth, 0)];
    
    [self addSubview:_alertView];
    
    CGFloat kAlertViewHeight = 0;
    __block CGFloat kNewViewHeight = 0;
    
    
    switch (_alertType) {
        case YXP_relay:
        {
            UILabel *relayLabel =[[UILabel alloc]initWithFrame:CGRectMake(25, 20, _alertView.width-50, 25)];
            relayLabel.text =languageStringWithKey(@"发送给:");
            [relayLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
            relayLabel.backgroundColor=[UIColor clearColor];
            [_alertView addSubview:relayLabel];
            //图像
            UIImageView *imageHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(15,relayLabel.bottom+5, 45, 45)];
            imageHeadView.contentMode = UIViewContentModeScaleAspectFill;
            imageHeadView.clipsToBounds = YES;
            //            imageHeadView.layer.cornerRadius =imageHeadView.width/2;
            //            imageHeadView.layer.masksToBounds=YES;
            [_alertView addSubview:imageHeadView];
            if(_currentImage)
            {
                imageHeadView.image=_currentImage;
            }
            
            if(_currentImageArray.count!=0){
                imageHeadView.hidden = YES;
                UIScrollView *sv = [self createHeders];
                sv.top = imageHeadView.top;
                sv.left = imageHeadView.left;
                [_alertView addSubview: sv];
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, relayLabel.bottom+5, _alertView.width-85, 45)];
            titleLabel.numberOfLines = 0;
            titleLabel.font = ThemeFontLarge;
            titleLabel.backgroundColor = [UIColor clearColor];
            //            titleLabel.layer.borderWidth = 2;
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.text = _name;
            [_alertView addSubview:titleLabel];
            if (titleLabel.text.length <1) {
                
                titleLabel.attributedText =[NSAttributedString attributeStringWithContent:[NSString stringWithFormat:@"%@ %@",_currentTitle,KCNSSTRING_ISEMPTY(_groupCount)?@"":_groupCount] keyWords:_groupCount colors:[UIColor lightGrayColor]];
            }
            
            UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(15, imageHeadView.bottom+15, _alertView.width-30, 1)];
            lineView.backgroundColor=[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
            [_alertView addSubview:lineView];
            
            kAlertViewHeight =lineView.bottom;
            
            
            switch (_relayType) {
                case RelayMessage_text:
                case RelayMessage_link:
                case RelayMessage_file:
                case RelayMessage_voice:
                case RelayMessage_card:
                case RelayMessage_mergeMessage:
                case RelayMessage_eachMessage:
                {
                    
                    UILabel *contentLabel =[[UILabel alloc] initWithFrame:CGRectMake(15, lineView.bottom+15, _alertView.width-30, 0)];
                    contentLabel.font = ThemeFontMiddle;
                    contentLabel.textColor =[UIColor colorWithRed:0.57f green:0.57f blue:0.57f alpha:1.00f];
                    contentLabel.numberOfLines=0;
                    [_alertView addSubview:contentLabel];
                    
                    CGSize contentSize = [[Common sharedInstance] widthForContent:_subContent withSize:CGSizeMake(_alertView.width - 30, CGFLOAT_MAX) withLableFont:14];
                    if(contentSize.height > 35){
                        contentSize.height = 35;
                    }
                    contentLabel.height = contentSize.height+5;
                    contentLabel.text = _subContent;
                    
                    kAlertViewHeight =contentLabel.bottom+15;
                }
                    break;
                case RelayMessage_image:
                {
                    
                    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake((_alertView.width-80)/2, lineView.bottom+15, 80, 110)];
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    imageView.backgroundColor=[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
                    
                    [_alertView addSubview:imageView];
                    
                    kAlertViewHeight =imageView.bottom+15;
                    
                    
                    if(!KCNSSTRING_ISEMPTY(_localPath))
                    {
                        UIImage * image = [UIImage imageWithContentsOfFile:_localPath];
                        CGFloat width = image.size.width;
                        CGFloat hight = image.size.height;
                        
                        CGFloat newWidth = ((_alertView.width*PictureSizePorprotion > _alertView.width*PictureSizePorprotion)&&(width/hight >= 2))||(width/hight >= 2)?_alertView.width*PictureSizePorprotion:PIctureSize*width/hight;
                        CGFloat newHeight = ((width*PictureSizePorprotion > _alertView.width*PictureSizePorprotion)&&(width/hight >= 2))||(width/hight >= 2)?hight*((_alertView.width/width)*PictureSizePorprotion):PIctureSize;
                        
                        if ((newWidth<70)||newWidth > _alertView.width*2/3) {
                            newWidth = (newWidth<70)?70:newWidth;
                            newWidth = (newWidth > _alertView.width*2/3)?_alertView.width*2/3:newWidth;
                            
                        }
                        
                        imageView.frame=CGRectMake((_alertView.width-newWidth)/2, lineView.bottom+15, newWidth, newHeight);
                        
                        imageView.image =image;
                        
                        kAlertViewHeight =imageView.bottom+15;
                        
                    }else if (!KCNSSTRING_ISEMPTY(_remoteUrl))
                    {
                        __weak typeof(imageView)weak_image =imageView;
                        [imageView sd_setImageWithURL:[NSURL URLWithString:_remoteUrl] placeholderImage:nil options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            if(image)
                            {
                                CGSize imgSize = [self imageSize:image];
                                weak_image.frame=CGRectMake((_alertView.width-imgSize.width)/2, lineView.bottom+15, imgSize.width, imgSize.height);
                                _cancelBtn.originY =weak_image.bottom+15;
                                _confirmBtn.originY =weak_image.bottom+15;
                                _alertView.originY =(self.height-weak_image.bottom-15-48)/2;
                                _alertView.height =weak_image.bottom+15+48;
                                kNewViewHeight =weak_image.bottom+15;
                                
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
                        [thumImageView sd_setImageWithURL:[NSURL URLWithString:_remoteUrl] completed:nil];
                    }
                    
                    //标签图片
                    UIImageView *tagImageView =[[UIImageView alloc]initWithFrame:CGRectMake(8, thumImageView.height-15, 16, 9)];
                    tagImageView.image=ThemeImage(@"videoTag_03");
                    [thumImageView addSubview:tagImageView];
                    
                    kAlertViewHeight =thumImageView.bottom+15;
                    
                    
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
    [_confirmBtn setTitle:STR_DLALERTVIEW_CONFIRM forState:UIControlStateNormal];
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

- (void)confirm:(id)sender
{
    if (_alertHandler) {
        if (_alertType == YXP_relay)
        {
            _alertHandler(YES, nil);
            
            [self removeFromSuperview];
            return;
        }
        _alertHandler(YES, nil);
    }
    _alertHandler = nil;
    
    [self removeFromSuperview];
}

-(void)cancel:(id)sender
{
    if (_alertHandler) {
        _alertHandler(NO, nil);
    }
    _alertHandler = nil;
    
    [self removeFromSuperview];
}


- (void)showSuperView:(UIView *)view
{
    [self setOriginY:-kTotalBarHeight];
    [view addSubview:self];
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

-(CGSize )imageSize:(UIImage *)image
{
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

-(UIScrollView *)createHeders{
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _alertView.width-20, 45+16)];
    sv.showsVerticalScrollIndicator = NO;
    sv.showsHorizontalScrollIndicator = NO;
    [_alertView addSubview:sv];
    CGFloat svConentWidth = 0;
    CGFloat imageViewHight = sv.height- 16;
    CGFloat imageViewWidht = imageViewHight;
    
    
    CGFloat gap = 3.f;
    for(int j = 0 ;j < _currentImageArray.count;j++){
        UILabel *namelabel  = [[UILabel alloc] initWithFrame:CGRectMake(0,0,imageViewWidht, 16)];
        namelabel.font =ThemeFontSmall;
        namelabel.textColor = [UIColor blackColor];
        namelabel.textAlignment = NSTextAlignmentCenter;
        id data = _currentImageArray[j];
        
        NSString *sessionId = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary * book = (NSDictionary *)data;
            sessionId = book[Table_User_account];
        }else if ([data isKindOfClass:[ECSession class]]) {
            ECSession * session = (ECSession *)data;
            sessionId = session.sessionId;
        }else if ([data isKindOfClass:[ECGroup class]]) {
            ECGroup * group = (ECGroup *)data;
            sessionId = group.groupId;
        }
        
        
        if ([sessionId hasPrefix:@"g"])
        {//群组
            RXGroupHeadImageView *imageView = [[RXGroupHeadImageView alloc] initWithFrame:CGRectMake(j*imageViewWidht+j*gap, 0, imageViewWidht, imageViewHight)];
            [sv addSubview:imageView];
            //                imageView.layer.cornerRadius = sv.height/2;
            //                imageView.clipsToBounds = YES;
            NSArray *members =[KitGroupMemberInfoData getSequenceMembersforGroupId:sessionId memberCount:9];
            if(members.count > 1){
                //显示头像
                //                    dispatch_async(dispatch_get_main_queue(), ^{
                [imageView createHeaderViewH:imageView.width withImageWH:imageView.width groupId:sessionId withMemberArray:members];
                
                //                    });
            }
            if (_currentImageArray.count <=1) {
                namelabel.left = imageView.left;
                namelabel.top = imageView.bottom;
                svConentWidth = imageView.right;
                NSString *groName =sessionId;
                //                KitGroupInfoData * groupInfo = [KitGroupInfoData getGroupInfoWithGroupId:sessionId];
                //                if(groupInfo){
                //                    groName =groupInfo.groupName;
                //                }
                NSMutableArray *groupArray =[[KitMsgData sharedInstance] getGroupInformation:sessionId];
                if(groupArray.count>0)
                {
                    NSDictionary *groupInfoDic =groupArray[0];
                    groName =[groupInfoDic objectForKey:@"groupname"];
                }
                //                namelabel.text = groName;
                _name = groName;
                [sv addSubview:namelabel];
            }
        }else if ([sessionId isEqualToString:FileTransferAssistant]){
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(j*imageViewWidht+j*gap, 0, imageViewWidht, imageViewHight)];
            imageView.layer.cornerRadius = 4;//imageView.height/2;
            imageView.clipsToBounds = YES;
            imageView.image =ThemeImage(@"icon_filetransferassistant");
            svConentWidth = imageView.right;
            if (_currentImageArray.count <= 1) {
                namelabel.left = imageView.left;
                namelabel.top = imageView.bottom;
                //                namelabel.text = languageStringWithKey(@"文件传输助手");
                _name = languageStringWithKey(@"文件传输助手");
                [sv addSubview:namelabel];
            }
            [sv addSubview:imageView];
            
        }
        else
        {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(j*imageViewWidht+j*gap, 0, imageViewWidht, imageViewHight)];
            imageView.layer.cornerRadius = 4;//imageView.height/2;
            imageView.clipsToBounds = YES;
            
            NSDictionary *address =[[Common sharedInstance].componentDelegate getDicWithId:sessionId withType:0];
            
            if(address) {
                NSString * photourl = address[Table_User_avatar];
                NSString * urlmd5 = address[Table_User_urlmd5];
                NSString *userStatus = address[Table_User_status];
                if([userStatus isEqualToString:@"3"])
                {
                    imageView.image = ThemeDefaultHead(imageView.size, RXleaveJobImageHeadShowContent,address[Table_User_account]);
                }else
                {
                    if(!KCNSSTRING_ISEMPTY(photourl) && !KCNSSTRING_ISEMPTY(urlmd5)){
                        [imageView sd_setImageWithURL:[NSURL URLWithString:photourl] placeholderImage:ThemeDefaultHead(imageView.size, address[Table_User_member_name],address[Table_User_account]) options:0];
                    }else{
                        [imageView sd_cancelCurrentImageLoad];
                        imageView.image =ThemeDefaultHead(imageView.size, address[Table_User_member_name],address[Table_User_account]);
                    }
                }
            }else
            {
                imageView.image =ThemeDefaultHead(imageView.size, sessionId,sessionId);
                
            }
            svConentWidth = imageView.right;
            if (_currentImageArray.count <= 1) {
                namelabel.left = imageView.left;
                namelabel.top = imageView.bottom;
                //                namelabel.text = address[Table_User_member_name]?address[Table_User_member_name]:@"";
                _name = address[Table_User_member_name]?address[Table_User_member_name]:@"";
                [sv addSubview:namelabel];
            }
            [sv addSubview:imageView];
        }
    }
    svConentWidth = _currentImageArray.count*imageViewWidht+(_currentImageArray.count-1)*gap;
    sv.contentSize = CGSizeMake(svConentWidth, sv.height);
    //    sv.backgroundColor = [UIColor greenColor];
    return sv;
}

@end
