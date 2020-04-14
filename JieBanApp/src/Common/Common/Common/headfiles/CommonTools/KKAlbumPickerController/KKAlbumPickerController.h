//
//  KKAlbumPickerController.h
//  Demo
//
//  Created by beartech on 14-9-10.
//  Copyright (c) 2014年 liubo. All rights reserved.
//

//#import "UINavigationController.h"

@protocol KKAlbumPickerControllerDelegate <UINavigationControllerDelegate>

- (void)KKAlbumPickerController_DidFinishedPickImage:(NSArray*)aImageArray imageInformation:(NSArray*)aImageInformationAray;

@end



@interface KKAlbumPickerController : UINavigationController

@property (nonatomic,assign)id<KKAlbumPickerControllerDelegate> delegate;

/**
 * 1、aDelegate 代理
 * 2、aNumberNeedSelected 需要选择的照片数量
 * 3、aEditEnable 是否需要编辑功能（仅在aNumberNeedSelected为1的时候有效）
 * 4、aCropSize 编辑的尺寸（仅在aEditEnable为YES的时候有效）
 * 5、aPushToDefaultDirectory 是否需要默认进入“相机胶卷”
 */
- (id)initWithDelegate:(id<KKAlbumPickerControllerDelegate>)aDelegate
    numberNeedSelected:(NSInteger)aNumberNeedSelected
            editEnable:(BOOL)aEditEnable
              cropSize:(CGSize)aCropSize
pushToDefaultDirectory:(BOOL)aPushToDefaultDirectory;

@end
