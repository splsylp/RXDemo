//
//  RX_TZPhotoPickerController.h
//  RX_TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RX_TZAlbumModel;
@interface RX_TZPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) RX_TZAlbumModel *model;
@end


@interface RX_TZCollectionView : UICollectionView

@end
