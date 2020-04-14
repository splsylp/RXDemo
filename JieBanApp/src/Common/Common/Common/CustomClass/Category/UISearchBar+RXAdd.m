//
//  UISearchBar+RXAdd.m
//  Common
//
//  Created by y g on 2019/9/23.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "UISearchBar+RXAdd.h"

@implementation UISearchBar (RXAdd)

- (UITextField *)rx_getSearchTextFiled{
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 13.0) {
        return self.searchTextField;
    }else{
        UITextField *searchTextField =  [self valueForKey:@"_searchField"];
        return searchTextField;
    }
}


@end
