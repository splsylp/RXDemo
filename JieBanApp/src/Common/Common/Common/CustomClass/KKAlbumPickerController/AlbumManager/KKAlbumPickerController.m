//
//  KKAlbumPickerController.m
//  Demo
//
//  Created by beartech on 14-9-10.
//  Copyright (c) 2014年 liubo. All rights reserved.
//

#import "KKAlbumPickerController.h"
#import "AlbumManager.h"
#import "KKAlbumPickerDirectoryViewController.h"
#import "YXPExtension.h"
@interface KKAlbumPickerController ()

@property (nonatomic,assign)NSInteger numberOfPhotosNeedSelected;
@property (nonatomic,assign)BOOL editEnable;//是否可以编辑 (当numberOfPhotosNeedSelected=1时 有效)
@property (nonatomic,assign)CGSize cropSize;//裁剪大小（当editEnable为YES的时候有效）
@property (nonatomic,assign)BOOL pushToGroupSavedPhotos;//是否默认进入相机胶卷;

@end

@implementation KKAlbumPickerController
@synthesize numberOfPhotosNeedSelected;
@synthesize editEnable;
@synthesize cropSize;
@synthesize pushToGroupSavedPhotos;
@synthesize delegate;

- (void)dealloc{
}

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
pushToDefaultDirectory:(BOOL)aPushToDefaultDirectory{
    
    self = [super init];
    if (self) {
        delegate = aDelegate;
        numberOfPhotosNeedSelected = MAX(aNumberNeedSelected, 1);
        editEnable = aEditEnable;
        if (CGSizeEqualToSize(aCropSize, CGSizeZero)) {
            cropSize = CGSizeMake(200, 200);
        }
        else{
            cropSize = aCropSize;
        }
        pushToGroupSavedPhotos = aPushToDefaultDirectory;
        
        KKAlbumPickerDirectoryViewController *directoryViewController = [[KKAlbumPickerDirectoryViewController alloc] initWithNumberNeedSelected:numberOfPhotosNeedSelected editEnable:editEnable cropSize:cropSize pushToDefaultDirectory:pushToGroupSavedPhotos];
        [self pushViewController:directoryViewController animated:NO];
    }
    else{
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [KKAuthorizedManager isAlbumAuthorized_ShowAlert:YES];
}


@end
