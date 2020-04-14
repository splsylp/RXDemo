//
//  UISearchBar+JCSearchBarPlaceholder.m
//  AddressBook
//
//  Created by 王文龙 on 2017/5/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "UISearchBar+JCSearchBarPlaceholder.h"

@implementation UISearchBar (JCSearchBarPlaceholder)
-(void)changeLeftPlaceholder:(NSString *)placeholder {
    self.placeholder = placeholder;
    SEL centerSelector = NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"setCenter", @"Placeholder:"]);
    if ([self respondsToSelector:centerSelector]) {
        BOOL centeredPlaceholder = NO;
        NSMethodSignature *signature = [[UISearchBar class] instanceMethodSignatureForSelector:centerSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:centerSelector];
        [invocation setArgument:&centeredPlaceholder atIndex:2];
        [invocation invoke];
    }
}
@end
