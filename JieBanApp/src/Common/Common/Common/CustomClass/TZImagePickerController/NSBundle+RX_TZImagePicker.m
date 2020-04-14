//
//  NSBundle+TZImagePicker.m
//  RX_TZImagePickerController
//
//  Created by 谭真 on 16/08/18.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "NSBundle+RX_TZImagePicker.h"
#import "RX_TZImagePickerController.h"

@implementation NSBundle (RX_TZImagePicker)

+ (NSBundle *)tz_imagePickerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[RX_TZImagePickerController class]];
    NSURL *url = [bundle URLForResource:@"RX_TZImagePickerController" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)tz_localizedStringForKey:(NSString *)key {
    return [self tz_localizedStringForKey:key value:@""];
}

+ (NSString *)tz_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = [RX_TZImagePickerConfig sharedInstance].languageBundle;
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    return value1;
}

@end
