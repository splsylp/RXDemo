//
//  AlertSheet.m
//  Common
//
//  Created by 韩微 on 2017/8/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "AlertSheet.h"

static AlertSheet* s_sharedInstance = nil;

@interface AlertSheet ()

@property(nonatomic,copy)AlertsheetChickBlock attenceBlock;


@end

@implementation AlertSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (AlertSheet *)sharedInstance {
    @synchronized(self) {
        if (s_sharedInstance == nil) {
            s_sharedInstance = [[AlertSheet alloc] init];
        }
    }
    return s_sharedInstance;
}

#pragma mark - View Init Methods -
- (id)init {
    self = [super init];
    if (self) {
        [self internalInit];
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
    }
    return self;
}

- (void)internalInit {
    
}

#pragma alertsheetView delegate -
- (id)initWithNerVersion:(NSString *)version withDexcription:(NSString *)descriptio withCancel:(NSString *)cancel withFromPage:(fromPage)frompage withChickBolck:(AlertsheetChickBlock)alertSheetBlock {
    self = [super init];
    if (self) {

        _attenceBlock = alertSheetBlock;
        
        if (frompage == VERSION_UPDATE) {
            AlertView *nameView = [[AlertView alloc] initWithFrame:CGRectMake(40*fitScreenWidth, (kScreenHeight-285*fitScreenHeight)/2 - 5*fitScreenHeight, kScreenWidth-80*fitScreenWidth, 285*fitScreenHeight)];
            nameView.removeAlertViewDelegate = self;
            nameView.descriptionStr = descriptio;
            nameView.dataVersion = version;
            [nameView loadViewIfNeed:cancel];
            nameView.layer.masksToBounds = YES;
            nameView.layer.cornerRadius = 8;
            [self addSubview:nameView];
        } else if (frompage == UPDATE_VATAR) {
            UpdataVatarView *avatarView = [[UpdataVatarView alloc] initWithFrame:CGRectMake(60*fitScreenWidth, kScreenHeight/2-80*fitScreenHeight, kScreenWidth-120*fitScreenWidth, 160*fitScreenHeight)];
            [self addSubview:avatarView];
            avatarView.alertViewAvatarDelegate = self;
            avatarView.layer.masksToBounds = YES;
            avatarView.layer.cornerRadius = 8;
            
        }
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        
//        [self animeData];
        
    }
    return self;
}

-(void)animeData{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isKindOfClass:[self class]]){
        return YES;
    }
    return NO;
}
-(void)tappedCancel{
//        [self removeFromSuperview];
}

- (void)showInView:(UIViewController *)Sview
{
    
    if(Sview==nil){
            [[UIApplication sharedApplication].delegate.window addSubview:self];

//            [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];

    }else{
        
        [Sview.view addSubview:self];
    }
    
}

#pragma delegate methods -
- (void)removeAlertView {
    
    
    if(_attenceBlock != nil)
    {
        [self removeFromSuperview];
        
        _attenceBlock();
    }
}

- (void)cancelView {
    [self removeFromSuperview];
}

- (void)removeAvatarView {
    [self removeFromSuperview];

}
- (void)confimAlertView {
    if(_attenceBlock != nil)
    {
        [self removeFromSuperview];
        
        
        _attenceBlock();
    }
    
}

@end
