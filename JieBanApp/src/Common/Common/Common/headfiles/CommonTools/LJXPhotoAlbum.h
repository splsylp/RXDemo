//
//  LJXPhotoAlbum.h
//  LJXPhotoAlbum
//
//  Created by jianxin.li on 16/4/14.
//  Copyright © 2016年 m6go.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^PhotoBlock)(UIImage *image);
// hanwei
typedef void (^PhotoResetBlock)(void);


@interface LJXPhotoAlbum : NSObject

- (void)getPhotoAlbumOrTakeAPhotoWithController:(UIViewController *)viewController
                                      andIsEdit:(BOOL)isEdit
                                   andWithBlock:(PhotoBlock)photoBlock withResetBlock:(PhotoResetBlock)resetBlock;

@end
