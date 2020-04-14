//
//  UIImage+deal.h
//  WBSSDemo
//
//  Created by 王明哲 on 16/8/16.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <UIKit/UIKit.h>
///add by李晓杰
//保存图片的时候用
#define DefaultThumImageWidth 120.0f
#define DefaultThumImageHeigth 90.0f
#define DefaultPressImageWidth 1280.0f
#define DefaultPressImageHeigth 960.0f

@interface UIImage (deal)

///返回压缩好的图片
- (UIImage *)fixImage;
//返回文档路径
- (NSString *)saveToDocument;
///保存到沙盒同时保存一份缩略图 返回文档路径
- (NSString *)saveToDocumentAndThum;
///保存到沙盒 有文件名称
- (NSString *)saveToDocumentWithFileName:(NSString *)fileName;
///保存到沙盒同时保存一份缩略图 有文件名称
- (NSString *)saveToDocumentAndThumWithFileName:(NSString *)fileName;

//调整方向
- (UIImage *)fixOrientation;
- (NSData *)fixCurrentImage;
//绘制图片
- (UIImage *)compressImageWithSize:(CGSize)viewsize;

//返回压缩后的图片数据
- (NSData *)compressAndSaveImageWithNewSize:(CGSize)size andFilePath:(NSString *)filePath;
/**
 * 生成对应的图片缩略图
 * size 大小
 * compressionQuality 压质量
 * filePath 存储路径
 **/
- (BOOL)compressAndSaveImageWithSize:(CGSize)size withCompressionQuality:(CGFloat)compressionQuality withFilePath:(NSString*)filePath;
- (CGSize)sizeWithFitMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;

- (UIImage *)scaletoSize:(CGSize)size;

//图片旋转
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

//图片水印
+ (UIImage *)addImage:(UIImage *)useImage addMsakImage:(UIImage *)maskImage;

-(UIImage*)imageWithCornerRadius:(CGFloat)radius;
@end
