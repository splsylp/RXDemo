//
//  KKAlbumPickerPhotoViewController.h
//  Demo
//
//  Created by beartech on 14-9-10.
//  Copyright (c) 2014年 liubo. All rights reserved.
//

#import "BaseViewController.h"
#import "AlbumManager.h"

@interface KKAlbumPickerPhotoViewController : BaseViewController{
    UITableView *_table;
    NSMutableArray *_dataSource;
    UIImageView *_toolBarView;
    UIImageView *_infoBoxView;
    UILabel  *_infoLabel;
    UIButton *_okButton;


    NSMutableDictionary *_selectedInformation;
    NSMutableDictionary *_selectedImages;
    NSMutableArray *_selectImageArray;
}

@property(nonatomic,retain)UITableView *table;
@property(nonatomic,retain)NSMutableArray *dataSource;
@property(nonatomic,retain)UIImageView *toolBarView;
@property(nonatomic,retain)UIImageView *infoBoxView;
@property(nonatomic,retain)UILabel *infoLabel;
@property(nonatomic,retain)UIButton *okButton;

@property(nonatomic,retain)NSMutableDictionary *selectedInformation;
@property(nonatomic,retain)NSMutableDictionary *selectedImages;
@property(nonatomic,retain)NSMutableArray *selectImageArray;


/**
 * 1、group 相册目录
 * 2、aNumberNeedSelected 需要选择的照片数量
 * 3、aEditEnable 是否需要编辑功能（仅在aNumberNeedSelected为1的时候有效）
 * 4、aCropSize 编辑的尺寸（仅在aEditEnable为YES的时候有效）
 * 5、aPushToDefaultDirectory 是否需要默认进入“相机胶卷”
 */
- (id)initWithAssetsGroup:(id)aGroup
       numberNeedSelected:(NSInteger)aNumberNeedSelected
               editEnable:(BOOL)aEditEnable
                 cropSize:(CGSize)aCropSize
   pushToDefaultDirectory:(BOOL)aPushToDefaultDirectory;


@end
