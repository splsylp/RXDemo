//
//  PhotoCollectionViewCell.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/10/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self createView];
}

- (void)createView
{
    _scrolView = [[PhotoScrollView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:_scrolView];
}
-(void)setImagePath:(NSString *)imagePath
{
    if (_imagePath!=imagePath) {
        _imagePath=imagePath;
    }
    
    _scrolView.imagePath=_imagePath;
}

-(void)setRemotePath:(NSString *)remotePath{
    if (_remotePath != remotePath) {
        _remotePath = remotePath;
    }
    _scrolView.remotePath = _remotePath;
}
@end
