//
//  KIImageCropperViewController.m
//  ChineseTastes
//
//  Created by 刘 波 on 13-7-8.
//  Copyright (c) 2013年 beartech. All rights reserved.
//

#import "KIImageCropperViewController.h"

@interface KIImageCropperViewController ()

@end

@implementation KIImageCropperViewController

- (id)initWithImage:(UIImage *)image cropSize:(CGSize)cropSize {
    if (self = [super init]) {
        _image = [image retain];
        _cropSize = cropSize;
    }
    return self;
}

- (void)dealloc {
    [_imageCropperView release];
    _imageCropperView = nil;
    [_image release];
    _image = nil;
    [_croppedImage release];
    _croppedImage = nil;
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    _imageCropperView = [[KIImageCropperView alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            CGRectGetWidth(self.view.bounds),
                                                                            CGRectGetHeight(self.view.bounds))];
    [_imageCropperView setCropSize:_cropSize];
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [self.view addSubview:_imageCropperView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:languageStringWithKey(@"编辑")];
//    [self showNavigationDefaultBackButton_ForNavPopBack];
//    
//    [self setNavRightButtonTitle:@"确定" selector:@selector(croppedImage)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_imageCropperView setImage:_image];
    [_imageCropperView setFrame:CGRectMake(0,
                                        0,
                                        CGRectGetWidth(self.view.bounds),
                                        CGRectGetHeight(self.view.bounds))];
}

- (void)setCroppedImage:(void(^)(UIImage *image))block {
    if (_croppedImage != block) {
        [_croppedImage release];
        _croppedImage = [block copy];
    }
}

- (void)croppedImage {
    if (_croppedImage != nil) {
        _croppedImage(_imageCropperView.croppedImage);
    }    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
