//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  PickerDatas.h
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RX_MLSelectPhotoPickerGroup;

// 回调
typedef void(^callBackBlock)(id obj);

@interface RX_MLSelectPhotoPickerDatas : NSObject

/**
 *  获取所有组
 */
+ (instancetype) defaultPicker;

/**
 * 获取所有组对应的图片
 */
- (void) getAllGroupWithPhotos : (callBackBlock ) callBack;

/**
 * 获取所有组对应的Videos
 */
- (void) getAllGroupWithVideos : (callBackBlock ) callBack;

/**
 *  传入一个组获取组里面的Asset
 */
- (void) getGroupPhotosWithGroup : (RX_MLSelectPhotoPickerGroup *) pickerGroup finished : (callBackBlock ) callBack;

/**
 *  传入一个AssetsURL来获取UIImage
 */
- (void) getAssetsPhotoWithURLs:(NSURL *) url callBack:(callBackBlock ) callBack;

@end
