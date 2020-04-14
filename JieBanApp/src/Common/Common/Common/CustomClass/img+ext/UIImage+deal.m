//
//  UIImage+deal.m
//  WBSSDemo
//
//  Created by 王明哲 on 16/8/16.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import "UIImage+deal.h"

@implementation UIImage (deal)
#pragma mark - 外部主要使用
///返回压缩好的图片
- (UIImage *)fixImage{
    UIImage *fixImage = [self fixOrientation];
    CGSize pressSize = [fixImage sizeWithFitMaxWidth:DefaultPressImageWidth maxHeight:DefaultThumImageWidth];
    UIImage *pressImage = [fixImage compressImageWithSize:pressSize];
    NSData *imageData = UIImageJPEGRepresentation(pressImage, 0.5);
    return [UIImage imageWithData:imageData];
}
///保存到沙盒
- (NSString *)saveToDocument{
   return [self saveToDocumentWithFileName:nil];
}
///保存到沙盒同时保存一份缩略图
- (NSString *)saveToDocumentAndThum{
    return [self saveToDocumentAndThumWithFileName:nil];
}
///保存到沙盒 有文件名称
- (NSString *)saveToDocumentWithFileName:(NSString *)fileName{
    UIImage *fixImage = [self fixOrientation];
    if (fileName == nil) {
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
        fileName = [NSString stringWithFormat:@"%@.jpg", [formater stringFromDate:[NSDate date]]];
    }
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:fileName];

    CGSize pressSize = [fixImage sizeWithFitMaxWidth:DefaultPressImageWidth maxHeight:DefaultPressImageHeigth];
//    CGSize pressSize = [fixImage sizeWithFitMaxWidth:self.size.width maxHeight:self.size.height];
    
    UIImage * pressImage = [self compressImageWithSize:pressSize];
    NSData *imageData = UIImageJPEGRepresentation(pressImage, 1);
    [imageData writeToFile:filePath atomically:YES];

    return filePath;
}
///保存到沙盒同时保存一份缩略图
- (NSString *)saveToDocumentAndThumWithFileName:(NSString *)fileName{
    UIImage *fixImage = [self fixOrientation];
    if (fileName == nil) {
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
        fileName = [NSString stringWithFormat:@"%@.jpg", [formater stringFromDate:[NSDate date]]];
    }
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:fileName];

    CGSize pressSize = [fixImage sizeWithFitMaxWidth:DefaultPressImageWidth maxHeight:DefaultPressImageHeigth];
    UIImage *pressImage = [self compressImageWithSize:pressSize];
    NSData *imageData = UIImageJPEGRepresentation(pressImage, 0.5);
    [imageData writeToFile:filePath atomically:YES];

    ///缩略图
    CGSize thumsize = [fixImage sizeWithFitMaxWidth:DefaultThumImageWidth maxHeight:DefaultThumImageHeigth];
    UIImage *thumImage = [fixImage compressImageWithSize:thumsize];
    NSData *photo = UIImageJPEGRepresentation(thumImage, 0.5);
    NSString *thumfilePath = [NSString stringWithFormat:@"%@.jpg_thum", filePath];
    [photo writeToFile:thumfilePath atomically:YES];
    return filePath;
}

#pragma mark - 一般内部使用
///横竖适配
- (UIImage *)fixOrientation {
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,CGImageGetBitsPerComponent(self.CGImage), 0,CGImageGetColorSpace(self.CGImage),CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
//根据最大宽度高度，返回对应比例的size
- (CGSize)sizeWithFitMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight{
    CGSize size;
    CGFloat imageW = self.size.width;
    CGFloat imageH = self.size.height;
    CGFloat fitW = imageW / maxWidth;
    CGFloat fitH = imageH / maxHeight;
    if (imageH > 4 * imageW) {
        size = CGSizeMake(imageW,imageH);
    }else if (fitW > 1 || fitH > 1) {//宽或高超过比例
        CGFloat fit = fitW > fitH ? fitW : fitH;
        size = CGSizeMake(imageW / fit , imageH / fit);
    }else{
        size = CGSizeMake(imageW,imageH);
    }
    return size;
}
///获取图像
- (UIImage *)compressImageWithSize:(CGSize)viewsize{
    CGFloat imgHWScale = self.size.height/self.size.width;
    CGFloat viewHWScale = viewsize.height/viewsize.width;
    CGRect rect = CGRectZero;
    if (imgHWScale > viewHWScale) {
        rect.size.height = viewsize.width * imgHWScale;
        rect.size.width = viewsize.width;
        rect.origin.x = 0.0f;
        rect.origin.y =  (viewsize.height - rect.size.height)*0.5f;
    } else {
        CGFloat imgWHScale = self.size.width /self.size.height;
        rect.size.width = viewsize.height * imgWHScale;
        rect.size.height = viewsize.height;
        rect.origin.y = 0.0f;
        rect.origin.x = (viewsize.width - rect.size.width) * 0.5f;
    }

    UIGraphicsBeginImageContext(viewsize);
    [self drawInRect:rect];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

- (UIImage *)compressNewImageWithSize:(CGSize)viewsize{
    UIGraphicsBeginImageContextWithOptions(viewsize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, viewsize.width, viewsize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (NSData *)compressAndSaveImageWithNewSize:(CGSize)size andFilePath:(NSString*)filePath{
    UIImage *fixImage = [self fixOrientation];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
    CGSize pressSize;
    pressSize = CGSizeMake((size.height/fixImage.size.height) * fixImage.size.width, size.height);

    UIImage *pressImage = [self compressImageWithSize:pressSize];
    NSData *imageData = UIImageJPEGRepresentation(pressImage, 0.5);
    [imageData writeToFile:filePath atomically:YES];
    return imageData;
}
- (BOOL)compressAndSaveImageWithSize:(CGSize)size withCompressionQuality:(CGFloat)compressionQuality withFilePath:(NSString *)filePath{
    if(self.size.height > size.height || self.size.width > size.width){
        //缓存目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        //文件完整目录
        NSString *fileDirectoryPath = [NSString stringWithFormat:@"%@/%@",cachesDirectory,@"CircleOfFriends"];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if(![fileManager contentsOfDirectoryAtPath:fileDirectoryPath error:&error]){
            BOOL result = [fileManager createDirectoryAtPath:fileDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (!result) {
                DDLogInfo(@"%@",[error localizedDescription]);

                return NO;
            }
        }

        UIImage *fixImage = [self fixOrientation];
        CGFloat scaleY  = fixImage.size.height/kScreenHeight;
        CGFloat scaleW  = fixImage.size.width/kScreenWidth;
        CGFloat curScale  = 1;//当前比例 暂时只支持到3倍之内 否则过分了
        CGFloat deviceScale = 414/kScreenWidth;
        if(scaleY > 3 && scaleY <= 6){
            curScale = (scaleY/7)*deviceScale + 1;
            compressionQuality=0.8;
        }else if (scaleW > 3 && scaleW <= 6){
            curScale = (scaleW/6)*deviceScale + 1;
            compressionQuality = 0.8;
        }else if (scaleY > 6 && scaleY <= 13){
            curScale = (scaleY / 8)*deviceScale + 1;
            compressionQuality = 0.7;
        }else if (scaleW > 6 && scaleW <= 13){
            curScale = (scaleW / 8) * deviceScale + 1;
            compressionQuality = 0.7;
        }else if (scaleY > 13 && scaleY < 18){
            curScale = (scaleY / 9) * deviceScale + 1;
            compressionQuality = 0.6;
        }else if (scaleW > 13 && scaleW < 18){
            curScale = (scaleW / 9) * deviceScale + 1;
            compressionQuality = 0.6;
        }else if (scaleW > 18){
            curScale = (scaleW / 10) * deviceScale + 1;
            compressionQuality = 0.6;
        }else if (scaleY > 18){
            curScale = (scaleY / 10) * deviceScale + 1;
            compressionQuality = 0.6;
        }
        CGSize  pressSize = CGSizeMake((size.height/fixImage.size.height) * fixImage.size.width * curScale, size.height * curScale);
        NSData *imageData;
        //长图
        if ((size.width < kScreenWidth ||
             size.height > kScreenHeight) &&
            size.height > 3 * size.width) {
            //图片按compressionQuality的质量压缩－》转换为NSData
            imageData = UIImageJPEGRepresentation(fixImage, 0.5);
        } else {
            //图片按compressionQuality的质量压缩－》转换为NSData
            UIImage * pressImage = [self compressNewImageWithSize:pressSize];
            imageData = UIImageJPEGRepresentation(pressImage, compressionQuality);
        }
        NSString *fileFullDirectoryPath = [NSString stringWithFormat:@"%@/%@",fileDirectoryPath,filePath];
        [fileManager createFileAtPath:fileFullDirectoryPath contents:imageData attributes:nil];
        return YES;
    }
    return NO;
}

- (NSData *)fixCurrentImage{
    UIImage *fixImage = [self fixOrientation];
    if(IsHengFengTarget){
        NSData *imageData = UIImageJPEGRepresentation(fixImage, 0.5);
        return imageData;
    }
    CGSize pressSize = [fixImage sizeWithFitMaxWidth:DefaultPressImageWidth maxHeight:DefaultPressImageHeigth];
    UIImage *pressImage = [fixImage compressImageWithSize:pressSize];
    NSData *imageData = UIImageJPEGRepresentation(pressImage, 1);
    return imageData;
}

#pragma mark -
- (UIImage *)scaletoSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}
+ (UIImage *)addImage:(UIImage *)useImage addMsakImage:(UIImage *)maskImage
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(useImage.size ,NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext(useImage.size);
    }
#endif
    [useImage drawInRect:CGRectMake(0, 0, useImage.size.width, useImage.size.height)];
    
    
    CGFloat scale =  (maskImage.size.height/maskImage.size.width);
    
    CGFloat msakW  = useImage.size.width;
    CGFloat msakH = msakW *scale;
    CGFloat msakY = (useImage.size.height-msakH)/2;
    
    //高度小于宽度*比例 如果宽度×比例比高度高 ,那么按照高度来计算宽度
    if((msakW > useImage.size.height*scale) || (msakW*scale>useImage.size.height))
    {
        //按照高度的比例来
        msakW  = useImage.size.height/scale;
        msakH  = useImage.size.height;
        msakY  = 0 ;
    }
    if(msakY<0)
    {
        msakY = 0;
    }
    
    //[maskImage drawInRect:CGRectMake(0, 0, useImage.size.width, useImage.size.height/2)];
    [maskImage drawInRect:CGRectMake((useImage.size.width-msakW)/2, msakY,msakW, msakH)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

-(UIImage*)imageWithCornerRadius:(CGFloat)radius{
    UIImage *image = self;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    CGFloat borderWidth = 0;
    CGFloat minSize = MIN(image.size.width, image.size.height);
    if (borderWidth < minSize / 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, borderWidth)];
        [path closePath];
        
        CGContextSaveGState(context);
        [path addClip];
        CGContextDrawImage(context, rect, image.CGImage);
        CGContextRestoreGState(context);
    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
