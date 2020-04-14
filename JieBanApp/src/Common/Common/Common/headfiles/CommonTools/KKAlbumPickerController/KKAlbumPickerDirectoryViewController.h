//
//  KKAlbumPickerDirectoryViewController.h
//  Demo
//
//  Created by beartech on 14-9-10.
//  Copyright (c) 2014年 liubo. All rights reserved.
//

#import "BaseViewController.h"

@interface KKAlbumPickerDirectoryViewController : BaseViewController

/**
 * 1、aNumberNeedSelected 需要选择的照片数量
 * 2、aEditEnable 是否需要编辑功能（仅在aNumberNeedSelected为1的时候有效）
 * 3、aCropSize 编辑的尺寸（仅在aEditEnable为YES的时候有效）
 * 4、aPushToDefaultDirectory 是否需要默认进入“相机胶卷”
 */
- (id)initWithNumberNeedSelected:(NSInteger)aNumberNeedSelected
                      editEnable:(BOOL)aEditEnable
                        cropSize:(CGSize)aCropSize
          pushToDefaultDirectory:(BOOL)aPushToDefaultDirectory;


@end
