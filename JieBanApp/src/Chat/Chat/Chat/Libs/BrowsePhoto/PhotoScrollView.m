//
//  PhotoScrollView.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/10/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "PhotoScrollView.h"
#import "RXThirdPart.h"
#import "RXCollectData.h"
#import "ChatViewController.h"

@implementation PhotoScrollView
{
    UIImageView *_imgView;//图片显示
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imgView];
        
        //设置缩放的最大、最小倍数
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;
        
        //隐藏滚动条
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        //设置代理
        self.delegate = self;
        
        //创建双击手势用于放大缩小图片
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        //设置点击数量
        tap.numberOfTapsRequired = 2;
        //设置触摸手指的数量
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        
        //创建返回上一层的手势
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackAction:)];
        [self addGestureRecognizer:tap1];
        
        //当tap手势触发时，让tap1手势失效
        [tap1 requireGestureRecognizerToFail:tap];
        
        //创建长按保存图片操作
        UILongPressGestureRecognizer *longRecognizer =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(tapSaveImageToIphone:)];
        [self addGestureRecognizer:longRecognizer];
    }
    return self;
}

-(void)tapSaveImageToIphone:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state==UIGestureRecognizerStateBegan)
    {
        UIActionSheet *sheet;
        //判断图片中是否有二维码
        NSNumber * number1 = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"isHaveQrCodeWithImage:" :@[_imgView.image]];
        UIImage *image2 = [[AppModel sharedInstance]runModuleFunc:@"PublicService" :@"screenView:" :@[_imgView]];
        NSNumber * number2 = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"isHaveQrCodeWithImage:" :@[image2]];
        if ([number1 boolValue] || [number2 boolValue]) {//二维码
//            [[AppModel sharedInstance]runModuleFunc:@"PublicService" :@"checkImageQrCodeWithImage:rootVC:" :@[_imgView.image,self]];
            sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"分享"),languageStringWithKey(@"收藏"),languageStringWithKey(@"保存图片"), languageStringWithKey(@"识别图中二维码"), nil];
        }else{
            sheet =[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:languageStringWithKey(@"取消") destructiveButtonTitle:nil otherButtonTitles:languageStringWithKey(@"分享"),languageStringWithKey(@"收藏"),languageStringWithKey(@"保存图片"), nil];
            
        }
        [sheet showInView:self];
    }
    
}
#pragma UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *actionTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([actionTitle isEqualToString:languageStringWithKey(@"分享")]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@",_imagePath];
        if ([imageUrl hasSuffix:@"_thum"]) {
            imageUrl = [imageUrl substringToIndex:(imageUrl.length - 5)];
        }
        if ([[NSFileManager defaultManager]fileExistsAtPath:_imagePath]) {
            BOOL isTransmit = YES;
            NSNumber *isTransmitNum = [NSNumber numberWithBool:isTransmit];
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:_imagePath displayName:_imagePath.lastPathComponent];
            mediaBody.remotePath = _remotePath;
            ECMessage *message = [[ECMessage alloc] initWithReceiver:@"" body:mediaBody];

            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:message,@"msg", isTransmitNum,@"isTransmitNum",nil];
            UIViewController *groupVC = [[Chat sharedInstance].componentDelegate getChooseMembersVCWithExceptData:dict WithType:SelectObjectType_TransmitSelectMember];
            RXBaseNavgationController *viewC = [UIApplication sharedApplication].windows[0].rootViewController.childViewControllers[0];
            for (id vc  in viewC.childViewControllers) {
                if ([vc isKindOfClass:[ChatViewController class]]) {
                    ChatViewController *chatVC = (ChatViewController *)vc;
                    [chatVC pushViewController:groupVC];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"photoBrowseBackView" object:nil];
                }
            }
        }else{
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"图片未下载")];
            return;
        }
    }else if ([actionTitle isEqualToString:languageStringWithKey(@"收藏")]){
        NSString * imageUrl = [NSString stringWithFormat:@"%@",_imagePath];
        if([imageUrl hasSuffix:@"_thum"]){
            imageUrl =[imageUrl substringToIndex:(imageUrl.length - 5)];
        }
        NSDictionary * dic = @{@"url":imageUrl};
        NSString * content = [dic convertToString];
        
        RXCollectData *tempCollectData = [[RXCollectData alloc] init];
        tempCollectData.txtContent = content;
        tempCollectData.type = @"2";
        tempCollectData.sessionId = [Common sharedInstance].getAccount;
        tempCollectData.url = @"";
        tempCollectData.favoriteMsgId = [imageUrl MD5EncodingString].lowercaseString;
        
        [RestApi addMultiCollectDataWithAccount:[Common sharedInstance].getAccount collectContents:@[tempCollectData] didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSDictionary *headDic = [dict objectForKey:@"head"];
            NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
            if (statusCode == 000000) {
                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"收藏成功")];
                NSDictionary *body = [dict objectForKey:@"body"];
                RXCollectData *collectData = [[RXCollectData alloc] init];
                collectData.collectId = [body objectForKey:@"collectId"];
                if ([[body objectForKey:@"collectIds"] count] > 0) {
                    collectData.collectId = [[body objectForKey:@"collectIds"] firstObject];
                }
                
                collectData.time = [body objectForKey:@"createTime"];
                collectData.txtContent = content;
                collectData.type = @"2";
                collectData.sessionId = [Common sharedInstance].getAccount;
                collectData.url = @"";
                
                [RXCollectData insertCollectionInfoData:collectData];
                
            } else {
                
                [SVProgressHUD showErrorWithStatus:statusCode == 901551 ? languageStringWithKey(@"请不要重复收藏"): languageStringWithKey(@"收藏失败")];
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
        }];
        
//        [RestApi addCollectDataWithAccount:[[Common sharedInstance] getAccount] fromAccount:[[Common sharedInstance] getAccount] TxtContent:content Url:nil DataType:@"2" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
//            NSDictionary *headDic = [dict objectForKey:@"head"];
//            NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
//            if (statusCode == 000000) {
//                [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"收藏成功")];
//                NSDictionary *bodyDic = [dict objectForKey:@"body"];
//                RXCollectData * collectData = [[RXCollectData alloc] init];
//                collectData.collectId = bodyDic[@"collectId"];
//                collectData.time = [bodyDic objectForKey:@"createTime"];
//                collectData.type = @"2";
//                collectData.txtContent = content;
//                collectData.sessionId = [[Common sharedInstance] getAccount];
//                [RXCollectData insertCollectionInfoData:collectData];
//            } else {
//                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
//            }
//        } didFailLoaded:^(NSError *error, NSString *path) {
//             [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
//        }];
    }else if ([actionTitle isEqualToString:languageStringWithKey(@"保存图片")]){
        if(_imagePath){
            UIImageWriteToSavedPhotosAlbum(_imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }else if ([actionTitle isEqualToString:languageStringWithKey(@"识别图中二维码")]){
        
        RXBaseNavgationController *viewC = [UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject;
        UIViewController *viewController = [viewC visibleViewController];
        NSNumber * number1 = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"isHaveQrCodeWithImage:" :@[_imgView.image]];
        UIImage *image2 = [[AppModel sharedInstance]runModuleFunc:@"PublicService" :@"screenView:" :@[_imgView]];
        NSNumber * number2 = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"isHaveQrCodeWithImage:" :@[image2]];
        if ([number1 boolValue] || [number2 boolValue]) {
            [[AppModel sharedInstance]runModuleFunc:@"PublicService" :@"checkImageQrCodeWithImage:rootVC:" :@[_imgView.image,viewController]];
        }
    }
}
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
   if(!error)
   {
       [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"已存入手机相册")];
   }else
   {
       [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"存入手机相册失败")];
   }
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (self.zoomScale > 1) {//大于1，说明已经放大了
        [self setZoomScale:1 animated:YES];
    }else
    {
        [self setZoomScale:3 animated:YES];
    }
    
}
- (void)tapBackAction:(UITapGestureRecognizer *)tap
{
    //[[self navigationController] setNavigationBarHidden:![[self navigationController] isNavigationBarHidden] animated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"photoBrowseBackView" object:nil];
}
-(void)setImagePath:(NSString *)imagePath
{
    // zmf add
//   if(_imagePath!=imagePath)
//   {
//       _imagePath=imagePath;
//       if ([@"gif" isEqualToString:imagePath.pathExtension.lowercaseString]) {
//           
//           NSData *data = [NSData dataWithContentsOfFile:ISSTRING_ISSTRING(_imagePath) ];
////           _imgView.image = [UIImage sd_animatedGIFWithData:data] ;//sd_animatedGIFWithData
//           [_imgView showImageData:data inFrame:_imgView.frame];
//       } else {
//           _imgView.image = [UIImage imageWithContentsOfFile:ISSTRING_ISSTRING(_imagePath)];
//       }
//       
//   }
    if(_imagePath!=imagePath)
    {
        _imagePath=imagePath;
        if ([@"gif" isEqualToString:imagePath.pathExtension.lowercaseString]) {
            
            NSData *data = [NSData dataWithContentsOfFile:ISSTRING_ISSTRING(_imagePath) ];
            _imgView.image = [UIImage sd_animatedGIFWithData:data] ;//sd_animatedGIFWithData
        } else {
            _imgView.image = [UIImage imageWithContentsOfFile:ISSTRING_ISSTRING(_imagePath)];
        }
      
        
    }
    // 长图的时候，按照宽高比例拉伸 eagle
    if ((_imgView.image.size.width < kScreenWidth || _imgView.image.size.height > kScreenHeight)&& _imgView.image.size.height>3*_imgView.image.size.width) {
        
        _imgView.frame = CGRectMake(_imgView.originX, _imgView.originY, kScreenWidth, _imgView.image.size.height*kScreenWidth/_imgView.image.size.width);
        
        [self setZoomScale:_imgView.size.width / kScreenWidth  animated:YES];
    }
    //zmf end
}
#pragma mark -UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgView;
}
@end
