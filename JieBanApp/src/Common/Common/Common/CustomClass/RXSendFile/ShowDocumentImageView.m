//
//  ShowDocumentImageView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ShowDocumentImageView.h"
#import "HXFileCacheManager.h"
#import "YXPExtension.h"
#import "NSString+AES.h"
#import "HXWaterStainLayer.h"
#import "HYTApiClient+Ext.h"
#import "RXThirdPart.h"

@implementation ShowDocumentImageView{
    NSString *_cachePathString;
}

- (instancetype)initWithFrame:(CGRect)frame
                  fileMessage:(ECMessage *)message
{
    self =[super initWithFrame:frame];
    
    if(self)
    {
        _message=message;
        [self initUI];
    }
    
    return self;

}
-(void)initUI
{
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    DDLogInfo(@"%@", pathArray);
    [pathArray firstObject];
    NSString *directryPath = [[pathArray firstObject] stringByAppendingPathComponent:@"tempDocuments"];
    _cachePathString = directryPath;
    
    
    ECFileMessageBody *fileBody =(ECFileMessageBody *)_message.messageBody;
//路径修改
    //NSDictionary *fileDic =[[IMMsgDBAccess sharedInstance]getCacheFileData:[fileBody.localPath lastPathComponent]];
    NSDictionary *fileDic =[[SendFileData sharedInstance]getCacheFileData:fileBody.remotePath];
    if(fileDic.count==0)
    {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"本地文件不存在")];
        return;
    }
    
    NSString *filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
    if(KCNSSTRING_ISEMPTY(filePath))
    {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"本地文件不存在")];
        return;
    }
    
    //解压
    NSData *data = [NSData dataWithContentsOfFile:filePath options:(NSDataReadingMappedIfSafe) error:nil];
    NSString *ifZip = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogInfo(@"eagle.ifzip111");
    if (!ifZip) {
        DDLogInfo(@"eagle.ifzip222");
        data = [data gzipInflate];
        [data writeToFile:filePath atomically:YES];
    }
    
    
    self.backgroundColor = [UIColor clearColor];
    
    _myScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _myScrollView.backgroundColor = [UIColor clearColor];
    _myScrollView.bounces = YES;
    _myScrollView.minimumZoomScale = 1.0;
    _myScrollView.maximumZoomScale = 5.0;
    _myScrollView.delegate = self;
    _myScrollView.contentMode = UIViewContentModeScaleAspectFit;
    _myScrollView.clipsToBounds = YES;
    _myScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    ;
    
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.clipsToBounds = YES;
    
    _myImageView = [[FLAnimatedImageView alloc]initWithFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    _myImageView.contentMode = UIViewContentModeScaleAspectFit;
    _myImageView.clipsToBounds = YES;
    _myImageView.backgroundColor = [UIColor clearColor];
    _myImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    [_myScrollView addSubview:_myImageView];
    [self addSubview:_myScrollView];
    
    //    [myImageView setBorderColor:[UIColor redColor] width:5.0];
    
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
//    tapGestureRecognizer.delegate = self;
//    [_myScrollView addGestureRecognizer:tapGestureRecognizer];
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressGesture.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    [longPressGesture setDelegate:self];
    [_myScrollView addGestureRecognizer:longPressGesture];
    
#pragma warning

    NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:_message.userData];
    if ([userData hasValueForKey:@"encryption"]) {
        if ([[userData valueForKey:@"encryption"] isEqual:@"EnTrue"]) {
            [SVProgressHUD showWithStatus:languageStringWithKey(@"文件解密中")];

            NSFileManager *fm = [NSFileManager defaultManager];
            
            NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            DDLogInfo(@"%@", pathArray);
            [pathArray firstObject];

            NSString *key = _message.to;
            NSRange rang = [filePath rangeOfString:@"." options:NSBackwardsSearch];
            NSString *fileDirectory = [filePath substringToIndex:rang.location];
            NSString *fileType = [filePath substringFromIndex:rang.location];

            NSRange rang1 = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
            NSString *fileDirectory1 = [filePath substringFromIndex:rang1.location];
            NSString *copyToString = [_cachePathString stringByAppendingPathComponent:fileDirectory1];

            NSData *imageData = [NSData dataWithContentsOfFile:filePath];

            //文件解密
            NSString *imageString = [[NSString alloc] initWithData:imageData  encoding:NSUTF8StringEncoding];
            NSString *encodeData = [NSString decodeData:imageString withKey:key];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:encodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            if ([fm createFileAtPath:copyToString contents:data attributes:nil]) {
                DDLogInfo(@"******************%@%@",@"写入成功",copyToString);
            }
            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"解密完成")];
            
            filePath = copyToString;
        }
    }
    
    //恒丰新增wjy
    NSString *fileUUid = [fileDic objectForKey:cachefileUuid];
    NSString *fileKey  = [fileDic objectForKey:cachefileKey];
    NSString *fileName =  [fileDic objectForKey:cachefileDisparhName];
    //判断有没有UUid
    if(!KCNSSTRING_ISEMPTY(fileUUid) && KCNSSTRING_ISEMPTY(fileKey))
    {
        [self getFileKey:fileUUid encodeFilePath:filePath dispathName:fileName];
        
    }else if (!KCNSSTRING_ISEMPTY(fileKey))
    {
        //先解密
        [self decodeFile:fileKey withencodedPath:filePath dispathName:fileName];
    }else
    {
//        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        _myImageView.image = [UIImage imageWithContentsOfFile:filePath];
        if (!KCNSSTRING_ISEMPTY(filePath)) {
            
            [_myImageView sd_setImageWithURL:[NSURL fileURLWithPath:filePath] placeholderImage:[UIImage imageWithContentsOfFile:filePath]];
        }
//        [_myImageView showImageData:imageData inFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    }

    //恒信所有 wjy
//    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
//    
//    [_myImageView showImageData:imageData inFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
//    
}


////单击
//-(void) singleTap:(UITapGestureRecognizer*) tap {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(ShowDocumentImageViewSingleTap:)]) {
//        [self.delegate ShowDocumentImageViewSingleTap:self];
//    }
//}

//长按
-(void)longPressed:(UILongPressGestureRecognizer*) tap {
    if (!IsHengFengTarget) {
        if (tap.state == UIGestureRecognizerStateBegan) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(ShowDocumentImageViewLongPressed:)]) {
                [self.delegate ShowDocumentImageViewLongPressed:self];
            }
        }
    }
}
//恒丰新增wjy
#pragma mark 获取文件Key

- (void)getFileKey:(NSString *)fileUUid encodeFilePath:(NSString *)encodePath dispathName:(NSString *)fileName
{
    
    __weak typeof(self)weak_self = self;
    [SVProgressHUD showWithStatus:languageStringWithKey(@"文件处理中")];
    [HYTApiClient getKeyByFileNodeIdWithAccount:[Common sharedInstance].getAccount withNodeId:fileUUid didFinishLoaded:^(NSDictionary *json, NSString *path) {
        
        __strong typeof(weak_self)strong_self = weak_self;
        
        NSDictionary* head = [json objectForKey:@"head"];
        
        NSString *statuscode = [head objectForKey:@"statusCode"];
        
        if([statuscode isEqualToString:@"000000"]){
            [SVProgressHUD dismiss];
            NSDictionary *bodyJson =[json objectForKey:@"body"];
            
            NSString *fileKey = [bodyJson objectForKey:@"fileKey"];
            
            [[SendFileData sharedInstance]updateFileKey:fileKey withFileUUid:fileUUid];
            
            
            [strong_self decodeFile:fileKey withencodedPath:encodePath dispathName:fileName];
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"文件处理失败")];
        }
        
    } didFailLoaded:^(NSError *error, NSString *path) {
        [HYTApiClient showErrorDomain:error];
    }];
}

#pragma mark 对文件进行解密

- (void)decodeFile:(NSString *)fileKey withencodedPath:(NSString *)encodePath dispathName:(NSString *)fileName
{
    NSData *fileData  = [NSData dataWithContentsOfFile:encodePath];
    
    NSData *decodeData = [NSString decoded_aseData :fileData withKey:fileKey];
    
    // NSData *imageData = [NSData dataWithContentsOfFile:tmpPath];
    [_myImageView showImageData:decodeData inFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    
    HXWaterStainLayer *overLayer = [HXWaterStainLayer initLayer];
    [self.layer insertSublayer:overLayer above:_myImageView.layer];
}

#pragma mark ==================================================
#pragma mark == 缩放
#pragma mark ==================================================
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _myImageView;//返回ScrollView上添加的需要缩放的视图
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
}

@end
