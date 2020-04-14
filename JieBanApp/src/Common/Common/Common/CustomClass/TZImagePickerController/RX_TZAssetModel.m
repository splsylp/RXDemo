//
//  RX_TZAssetModel.m
//  RX_TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "RX_TZAssetModel.h"
#import "RX_TZImageManager.h"

@implementation RX_TZAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type{
    RX_TZAssetModel *model = [[RX_TZAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type timeLength:(NSString *)timeLength {
    RX_TZAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end



@implementation RX_TZAlbumModel

- (void)rxsetResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _rxresult = result;
    if (needFetchAssets) {
        [[RX_TZImageManager manager] getAssetsFromFetchResult:result completion:^(NSArray<RX_TZAssetModel *> *models) {
            self->_rxmodels = models;
            if (self->_rxselectedModels) {
                [self checkSelectedModels];
            }
        }];
    }
}

- (void)setRxselectedModels:(NSArray *)rxselectedModels {
    _rxselectedModels = rxselectedModels;
    if (_rxmodels) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.rxselectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (RX_TZAssetModel *model in _rxselectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (RX_TZAssetModel *model in _rxmodels) {
        if ([selectedAssets containsObject:model.asset]) {
            self.rxselectedCount ++;
        }
    }
}

- (NSString *)rxname {
    if (_rxname) {
        return _rxname;
    }
    return @"";
}

@end
