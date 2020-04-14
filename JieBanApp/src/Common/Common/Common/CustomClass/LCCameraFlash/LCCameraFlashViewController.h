//
//  CameraFlashViewController1.h
//  Photo
//
//  Created by 刘畅 on 2017/10/11.
//  Copyright © 2017年 刘畅. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CameraFinishImagesBlock)(NSArray<UIImage *> *);
typedef void (^CameraFinishImageDatasBlock)(NSArray<NSData *> *);
typedef void (^CameraErrorBlock)(NSError *);

@interface LCCameraFlashViewController : UIViewController
// 连拍张数
@property(nonatomic, assign) int sheet;

@property(nonatomic, copy) CameraFinishImagesBlock imagesBlock;

@property(nonatomic, copy) CameraFinishImageDatasBlock imageDatasBlock;

@property(nonatomic, copy) CameraErrorBlock errorBlock;

@end
