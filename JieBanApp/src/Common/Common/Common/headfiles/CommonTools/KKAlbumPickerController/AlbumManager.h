//
//  AlbumManager.h
//  Artup
//
//  Created by beartech on 13-10-23.
//  Copyright (c) 2013年 Artup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

//extern NSString *const AlbumManager_ALAssetsLibraryChangedNotification;

#define AlbumManagerKey_name                 @"name"
#define AlbumManagerKey_date                 @"date"
#define AlbumManagerKey_url                  @"url"
#define AlbumManagerKey_size                 @"size"

/*读取相册目录完成的Block*/
typedef void (^AlbumManagerLoadAlbumFinishedBlock)(NSArray *Albums);
typedef void (^AlbumManagerLoadAlbumAssetsFinishedBlock)(NSArray *Assets);

/*读取相册照片完成的Block*/
typedef void (^AlbumManagerLoadAlbumImageFinishedBlock)(UIImage *image);
typedef void (^AlbumManagerLoadAlbumImageFailureBlock)(NSError *error);


@interface AlbumManager : NSObject

+ (AlbumManager *)defaultManager;


#pragma mark ==================================================
#pragma mark == 遍历所有目录
#pragma mark ==================================================
- (void)loadAlbumDirectoryWithFinishedBlock:(AlbumManagerLoadAlbumFinishedBlock)finishedBlock;

#pragma mark ==================================================
#pragma mark == 遍历某个目录的所有照片
#pragma mark ==================================================
- (void)loadAlbumPhotosWithALAssetsGroupGroup:(ALAssetsGroup*)group finishedBlock:(AlbumManagerLoadAlbumAssetsFinishedBlock)finishedBlock;


#pragma mark ==================================================
#pragma mark == 根据地址读取图片
#pragma mark ==================================================
/*
 根据相册路径的URL 获取图片缩略图
 */
+ (void)loadAlbumThumbnailImageWithURL:(NSURL*)url resultBlock:(AlbumManagerLoadAlbumImageFinishedBlock)finishedBlock failureBlock:(AlbumManagerLoadAlbumImageFailureBlock)failureBlock;

/*
 根据相册路径的URL 获取图片全屏图片（缩放旋转处理好了的）
 */
+ (void)loadAlbumFullScreenImageWithURL:(NSURL*)url resultBlock:(AlbumManagerLoadAlbumImageFinishedBlock)finishedBlock failureBlock:(AlbumManagerLoadAlbumImageFailureBlock)failureBlock;

/*
 根据相册路径的URL 获取图片原始图片（没进行缩放旋转处理）
 */
+ (void)loadAlbumFullResolutionImageWithURL:(NSURL*)url resultBlock:(AlbumManagerLoadAlbumImageFinishedBlock)finishedBlock failureBlock:(AlbumManagerLoadAlbumImageFailureBlock)failureBlock;

@end

