//
//  KitKeyBoard.m
//  ccp_ios_kit
//
//  Created by yuxuanpeng on 16/3/1.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "KitKeyBoard.h"
#import "SINGetSystemAudio.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"
@interface KitKeyBoard ()
@property (nonatomic, weak) id<KitKeyBoardDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *addAddressBtn;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *keyButtons;
@property (retain, nonatomic) IBOutlet UIButton *callButton;

- (IBAction)onClickStarButton:(id)sender;
- (IBAction)onClickJingButton:(id)sender;
- (IBAction)onClickCallButton:(id)sender;
- (IBAction)onClickDelButton:(id)sender;
- (IBAction)addAddressButtom:(id)sender;


@end

@implementation KitKeyBoard

- (void)awakeFromNib{
    [super awakeFromNib];
    _inputText = @"";
    for (int i = 0; i < self.keyButtons.count; i++) {
        if (i != 9 && i != 11) {
            UIButton *btn = self.keyButtons[i];
            [btn addTarget:self action:@selector(onClickNumberButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

+ (id)showInView:(UIView *)view withDelegate:(id<KitKeyBoardDelegate>)delegate{
    KitKeyBoard *keyboard = [KitKeyBoard classFromNib:@"KitKeyBoard"];
    keyboard.addAddressBtn.hidden = NO;
    // keyboard.backgroundColor=[UIColor redColor];
    double y =[[NSString stringWithFormat:@"%.2f",fitScreenWidth] doubleValue];
    keyboard.frame =CGRectMake(0, 0, kScreenWidth, 345*y);
    [keyboard setButtonImages];
    // DDLogInfo(@"keyboard------%@",NSStringFromCGRect(keyboard.frame));
    keyboard.delegate = delegate;
    [view addSubview:keyboard];
    keyboard.origin = CGPointMake(0, view.frameHight);
    [UIView animateWithDuration:0.3 animations:^{
        keyboard.origin = CGPointMake(0, view.frameHight-keyboard.frameHight);
    }];
    return keyboard;
}

+ (id)showInMeetDialView:(UIView *)view withDelegate:(id<KitKeyBoardDelegate>)delegate;{
    KitKeyBoard *keyboard = [KitKeyBoard classFromNib:@"KitKeyBoard"];
    keyboard.addAddressBtn.hidden = YES;
    // keyboard.backgroundColor=[UIColor redColor];
    double y = [[NSString stringWithFormat:@"%.2f",fitScreenWidth] doubleValue];
    keyboard.frame = CGRectMake(0, 0, kScreenWidth, 345*y);
    [keyboard setButtonImages];
    // DDLogInfo(@"keyboard------%@",NSStringFromCGRect(keyboard.frame));
    keyboard.delegate = delegate;
    [view addSubview:keyboard];
    keyboard.origin = CGPointMake(0, view.frameHight);
    [UIView animateWithDuration:0.3 animations:^{
        keyboard.origin = CGPointMake(0, view.frameHight-keyboard.frameHight);
    }];
    return keyboard;
}

- (void)setButtonImages{
    [self.callButton setImage:ThemeImage(@"call_icon") forState:UIControlStateNormal];
    for (int i = 1; i <= self.keyButtons.count; i++) {
        NSString *name = [NSString stringWithFormat:@"keyboard_%02d",i];
        UIButton *btn = self.keyButtons[i-1];
        [btn setImage:ThemeImage(name) forState:UIControlStateNormal];
    }
}

- (void)onClickNumberButton:(id)sender{
    NSInteger index = [self.keyButtons indexOfObject:sender]+1;
    if (index > 9) {
        index = 0;
    }
    //0-9键盘声音
    [[SINGetSystemAudio shareManager] KeyBoardNumberSound:index];
    _inputText=[NSString stringWithFormat:@"%@%ld", _inputText, (long)index];
    if(_inputText.length > 18){
        _inputText = [_inputText substringToIndex:18];
    }
    
    //[self.inputLabelView setText:[NSString stringWithFormat:@"%@%d", self.inputLabelView.text, index]];
    if (_delegate && [_delegate respondsToSelector:@selector(keyBoard:currentKey:)]) {
        [_delegate keyBoard:self currentKey:_inputText];
    }
}

- (IBAction)onClickStarButton:(id)sender{
    _inputText = [NSString stringWithFormat:@"%@%@", _inputText, @"*"];
    if(_inputText.length > 18){
        _inputText = [_inputText substringToIndex:18];
    }
    //[self.inputLabelView setText:[NSString stringWithFormat:@"%@%@", self.inputLabelView.text, @"*"]];
    [[SINGetSystemAudio shareManager] KeyBoardStarSound];
    if (_delegate && [_delegate respondsToSelector:@selector(keyBoard:currentKey:)]) {
        [_delegate keyBoard:self currentKey:_inputText];
    }
}

- (IBAction)onClickJingButton:(id)sender{
    _inputText = [NSString stringWithFormat:@"%@%@", _inputText, @"#"];
    if(_inputText.length > 18){
        _inputText = [_inputText substringToIndex:18];
    }
    //[self.inputLabelView setText:[NSString stringWithFormat:@"%@%@", self.inputLabelView.text, @"#"]];
    [[SINGetSystemAudio shareManager]KeyBoardPoundSound];
    if (_delegate && [_delegate respondsToSelector:@selector(keyBoard:currentKey:)]) {
        [_delegate keyBoard:self currentKey:_inputText];
    }
}

- (void)onClickKeyboardButton:(id)sender{
    // [[SINGetSystemAudio shareManager]KeyBoardPoundSound];
    [UIView animateWithDuration:0.3 animations:^{
        self.originY = self.originY + self.frameHight;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(keyBoardDidmiss:)]) {
            [self.delegate keyBoardDidmiss:self];
        }
        [self removeFromSuperview];
    }];
}

- (void)hiddenKeyBoard{
    [UIView animateWithDuration:0.3 animations:^{
        self.originY = self.originY + self.frameHight;
    } completion:^(BOOL finished) {
        //        _inputText = @"";
        if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenKeyBoard:)]) {
            [self.delegate hiddenKeyBoard:self];
        }
    }];
}
- (void)showkeyBoard:(UIView *)view{
    [UIView animateWithDuration:0.3 animations:^{
        self.origin = CGPointMake(0, view.frameHight-self.frameHight);
    }];
}
- (IBAction)onClickCallButton:(id)sender{
    if (KCNSSTRING_ISEMPTY(_inputText)) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(keyBoard:text:index:)]) {
        [_delegate keyBoard:self text:_inputText index:0];
    }
}

- (IBAction)onClickDelButton:(id)sender{
    if (KCNSSTRING_ISEMPTY(_inputText)) {
        _inputText = @"";
    }else{
        NSString *text = _inputText;
        [[SINGetSystemAudio shareManager] KeyBoardPoundSound];
        if (text.length <= 1) {
            _inputText=@"";
        }else{
            _inputText = [text substringToIndex:text.length - 1];
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(keyBoard:currentKey:)]) {
        [_delegate keyBoard:self currentKey:_inputText];
    }
}
//键盘回收按钮
- (IBAction)addAddressButtom:(id)sender {
    [[SINGetSystemAudio shareManager]KeyBoardPoundSound];
    if (_delegate && [_delegate respondsToSelector:@selector(keyBoardAddMobile:text:)]) {
        [_delegate keyBoardAddMobile:self text:_inputText];
    }
}

- (void)setInputText:(NSString *)inputText {
    if (!inputText) {
        _inputText = @"";
    } else {
        _inputText = inputText;
    }
}
@end
