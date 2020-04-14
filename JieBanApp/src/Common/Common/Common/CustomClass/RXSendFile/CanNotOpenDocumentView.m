//
//  CanNotOpenDocumentView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "CanNotOpenDocumentView.h"
#import "BaseViewController.h"
#import "HXFileCacheManager.h"
#import "NSString+AES.h"

@implementation CanNotOpenDocumentView
{
    NSString *_filePath;
    UIDocumentInteractionController *_myDocumentInteractionController;
    ECMessage *_message;

}
- (instancetype)initWithFrame:(CGRect)frame fileMessage:(ECMessage *)message;
{
    self =[super initWithFrame:frame];
    
    if(self)
    {
        [self initUI:message];
        _message = message;
    }
    
    return self;
}

-(void)initUI:(ECMessage *)message
{
    ECFileMessageBody *fileBody =(ECFileMessageBody *)message.messageBody;
//路径修改
   // NSDictionary *fileDic =[[IMMsgDBAccess sharedInstance]getCacheFileData:[fileBody.localPath lastPathComponent]];
    NSDictionary *fileDic =[[SendFileData sharedInstance]getCacheFileData:fileBody.remotePath];
    if(fileDic.count==0)
    {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"本地文件不存在")];
        return;
    }
    
    _filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
   
    //打开本地缓存
    
    
    
   //  ECFileMessageBody *fileBody =(ECFileMessageBody *) _message.messageBody;
    CGFloat Height = 0;
    
    //图片
    Height = Height + 63;
    
    //间隙
    Height = Height + 15;
    CGSize size = [[Common sharedInstance] widthForContent:fileBody.displayName withSize:CGSizeMake(self.frame.size.width-30, CGFLOAT_MAX) withLableFont:13];
    //文件名
    Height = Height + size.height;
    
    //间隙
    Height = Height + 45;
    
    //按钮
    Height = Height + 40;
    
    //间隙
    Height = Height + 30;
    
    //文字
    Height = Height + 20;
    Height = Height + 20;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-50)/2.0, (self.frame.size.height-Height)/2.0, 50, 63)];
    imageView.image = [self iconImage:_filePath];
    [self addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(63, 63));
        make.centerY.mas_offset(0);
        make.centerX.mas_offset(0);
    }];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(imageView.frame)+15, self.frame.size.width-30, size.height)];
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    label.font = ThemeFontMiddle;
    
    
    NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:message.userData];
    if ([userData hasValueForKey:@"fileName"]) {
        label.text = [userData valueForKey:@"fileName"];
        
    } else {
        label.text = fileBody.displayName;
    }
    [self addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
        make.top.mas_equalTo(imageView.mas_bottom).mas_offset(15);
    }];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(label.frame)+45, kScreenWidth-30, 40)];
    button.layer.cornerRadius=5.0;
    button.layer.masksToBounds=YES;
    button.exclusiveTouch = YES;
    button.backgroundColor=[UIColor colorWithRed:0.49f green:0.50f blue:0.49f alpha:1.00f];
    [button addTarget:self action:@selector(openDocumentWithOtherApp) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:languageStringWithKey(@"用第三方应用打开") forState:UIControlStateNormal];
    button.titleLabel.font = ThemeFontMiddle;
    [self addSubview:button];
    
    button.hidden = HX_fileEncodedSwitch?YES:NO;

    
    UILabel *label01 = [[UILabel alloc] initWithFrame:CGRectMake(15,  CGRectGetMaxY(HX_fileEncodedSwitch?label.frame:button.frame)+30, kScreenWidth-30, 20)];
    label01.backgroundColor=[UIColor clearColor];
    label01.textAlignment = NSTextAlignmentCenter;
    label01.textColor = [UIColor colorWithRed:0.49f green:0.50f blue:0.49f alpha:1.00f];
    label01.font =ThemeFontSmall;
    label01.text = languageStringWithKey(@"暂不支持预览该格式的文件");
    [self addSubview:label01];
    
    [label01 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
        make.top.mas_equalTo(label.mas_bottom).mas_offset(30);
    }];
    
    UILabel *label02 = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(label01.frame), kScreenWidth-30, 20)];
    label02.backgroundColor=[UIColor clearColor];
    label02.textAlignment = NSTextAlignmentCenter;
    label02.textColor = [UIColor colorWithRed:0.49f green:0.50f blue:0.49f alpha:1.00f];
    label02.font =ThemeFontSmall;
    label02.text = languageStringWithKey(@"您可以用第三方应用打开");
    [self addSubview:label02];
    
    label02.hidden =  HX_fileEncodedSwitch?YES:NO;

}


- (UIImage*)iconImage:(NSString *)locationPath{
    NSString *fileExtention = [[locationPath lastPathComponent] pathExtension];
    if ([NSObject isFileType_Doc:fileExtention]) {
        return KKThemeImage(@"FileTypeS_DOC");
    }
    else if ([NSObject isFileType_PPT:fileExtention]) {
        return KKThemeImage(@"FileTypeS_PPT");
    }
    else if ([NSObject isFileType_XLS:fileExtention]) {
        return KKThemeImage(@"FileTypeS_XLS");
    }
    else if ([NSObject isFileType_IMG:fileExtention]) {
        return KKThemeImage(@"FileTypeS_IMG");
    }
//    else if ([NSObject isFileType_VIDEO:fileExtention]) {
//        return KKThemeImage(@"FileTypeS_VIDEO");
//    }
//    else if ([NSObject isFileType_AUDIO:fileExtention]) {
//        return KKThemeImage(@"FileTypeS_AUDIO");
//    }
    else if ([NSObject isFileType_PDF:fileExtention]) {
        return KKThemeImage(@"FileTypeS_PDF");
    }
    else if ([NSObject isFileType_TXT:fileExtention]) {
        return KKThemeImage(@"FileTypeS_TXT");
    }
    else if ([NSObject isFileType_ZIP:fileExtention]) {
        return KKThemeImage(@"FileTypeS_ZIP");
    }
    else{
        return KKThemeImage(@"FileTypeS_XXX");
    }
}

- (void)openDocumentWithOtherApp{
    
    if(KCNSSTRING_ISEMPTY(_filePath))
    {
        
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"本地文件不存在")];
        return;
    }
    
    @try {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        DDLogInfo(@"%@", pathArray);
        [pathArray firstObject];


        NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:_message.userData];
        if ([userData hasValueForKey:@"encryption"]) {
            if ([[userData valueForKey:@"encryption"] isEqual:@"EnTrue"]) {
                [SVProgressHUD showWithStatus:languageStringWithKey(@"文件解密中")];
                NSString *key = _message.to;
                NSRange rang = [_filePath rangeOfString:@"." options:NSBackwardsSearch];
                NSString *fileDirectory = [_filePath substringToIndex:rang.location];
                NSString *fileType = [_filePath substringFromIndex:rang.location];
                
                NSString *directryPath = [[pathArray firstObject] stringByAppendingPathComponent:@"tempDocuments"];
                
                NSRange rang1 = [_filePath rangeOfString:@"/" options:NSBackwardsSearch];
                NSString *fileDirectory1 = [_filePath substringFromIndex:rang1.location];
                NSString *copyToString = [directryPath stringByAppendingPathComponent:fileDirectory1];
                

                
                NSData *oldData = [NSData dataWithContentsOfFile:_filePath];
                
                NSString *dataString = [[NSString alloc] initWithData:oldData  encoding:NSUTF8StringEncoding];
                DDLogInfo(@"******************%@",dataString);
                //文件解密
                NSString *encodeData = [NSString decodeData:dataString withKey:key];
                NSData *data = [[NSData alloc]initWithBase64EncodedString:encodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                if ([fm createFileAtPath:copyToString contents:data attributes:nil]) {
                    DDLogInfo(@"******************%@",@"写入成功");
                }
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"解密完成")];

                _filePath = copyToString;
            }
        }
        
       _myDocumentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:_filePath]];
        _myDocumentInteractionController.delegate = self;
        
        BOOL ret = [_myDocumentInteractionController presentOptionsMenuFromRect:self.bounds inView:self animated:YES];//documentInteractionControllerDidDismissOpenInMenu
        if (!ret){
            [SVProgressHUD showErrorWithStatus:@"open failed"];
        }
    } @catch (NSException *exception) {
        DDLogInfo(@"exception:%@", exception);
    } @finally {
        
    }
    
    
}

@end
