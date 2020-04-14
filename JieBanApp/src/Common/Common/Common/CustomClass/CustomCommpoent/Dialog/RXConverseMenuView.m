//
//  RXConverseMenuView.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/8/15.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXConverseMenuView.h"
#import "NSAttributedString+Color.h"
#import "UIView+Ext.h"
#import "UIButton+Ext.h"
#import "KCConstants_API.h"

@interface RXConverseMenuView()
@property(nonatomic,retain)UIView *mainView;
@property(nonatomic,retain)UIView *introduceView;
@property(nonatomic,retain)UIView *dailingView;
@property(nonatomic,retain)NSArray *titleArray;
@property (strong,nonatomic)UILabel *teleLabel;


@end
@implementation RXConverseMenuView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor colorWithIntRed:36 green:40 blue:42 alpha:255];
        
    }
    return self;
}

-(void)setFetchTitleArray:(NSArray *(^)(void))fetchTitleArray
{
    _titleArray=fetchTitleArray();
    [self createViewUI];
    
}
-(void)updateSubViewLayout:(CGRect)rect
{
    self.frame=rect;
    self.backgroundColor=[UIColor clearColor];
    self.backgroundColor=[UIColor clearColor];
    self.mainView =[[UIView alloc]init];
    self.mainView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
    self.mainView.backgroundColor=[UIColor whiteColor];
    self.mainView.userInteractionEnabled=YES;
    //[self addSubview:self.mainView];
    [self insertSubview:self.mainView aboveSubview:self];
    
}

- (void)createViewUI {
    
    self.teleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10*fitScreenWidth, self.mainView.frame.size.width, 21*fitScreenWidth)];
    self.teleLabel.text = languageStringWithKey(@"通话");
    self.teleLabel.textAlignment = NSTextAlignmentCenter;
    self.teleLabel.font = ThemeFontLarge;
    [self.mainView addSubview:self.teleLabel];
    
    UIButton *selectTypeBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    selectTypeBtn.frame =CGRectMake(self.teleLabel.right-80*fitScreenWidth, 14*fitScreenWidth, 70*fitScreenWidth, 17*fitScreenWidth);
    if (isEnLocalization) {
        selectTypeBtn.titleLabel.font =ThemeFontSmall;
    }else{
        selectTypeBtn.titleLabel.font = ThemeFontLarge;
    }
    [selectTypeBtn setTitleColor:[UIColor colorWithHexString:APPMainUIColorHexString] forState:UIControlStateNormal];
    [selectTypeBtn setTitle:languageStringWithKey(@"我选用?") forState:UIControlStateNormal];
    [selectTypeBtn addTarget:self action:@selector(showViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:selectTypeBtn];
    
    _introduceView =[[UIView alloc]init];
    [self.mainView addSubview:_introduceView];
    
    
    NSString *rongxinStr =languageStringWithKey(@"网络电话: 需双方均安装该APP并在线，通过网络进行免费通话，通话质量受双方网络质量影响.");
    NSString *zhiboStr =languageStringWithKey(@"直拨电话: 您将采用网络呼叫至对方手机进行免费通话，通话质量与您的网络有关，通话质量较好。");
    NSString *putongStr =languageStringWithKey(@"普通电话: 您将采用传统呼叫方式直接与对方进行通话，通话质量优秀，但需要向运营商支付话费。");
    NSString *huiboStr =languageStringWithKey(@"回拨电话: 您先通过网络发起通话请求，服务器会依次呼叫双方，待双方都接听后即可进行免费通话，通话质量不受网络影响。");
    

    //网络电话介绍
    UILabel *workTeleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5*fitScreenWidth, 0, self.mainView.frame.size.width-10*fitScreenWidth, 30*fitScreenWidth)];
    workTeleLabel.textColor = [UIColor colorWithRed:0.77f green:0.77f blue:0.77f alpha:1.00f];
    workTeleLabel.attributedText = [NSAttributedString attributeStringWithContent:rongxinStr keyWords:languageStringWithKey(@"网络电话:") colors:[UIColor colorWithHexString:APPMainUIColorHexString]];
    workTeleLabel.numberOfLines = 0;
    workTeleLabel.font =ThemeFontSmall;
    [workTeleLabel sizeToFit];
    [_introduceView addSubview:workTeleLabel];
    
    //直拨
    UILabel *directTeleLabel =[[UILabel alloc]initWithFrame:CGRectMake(5*fitScreenWidth, workTeleLabel.bottom+5*fitScreenWidth, self.mainView.frame.size.width-10*fitScreenWidth, 30*fitScreenWidth)];
    directTeleLabel.textColor=[UIColor colorWithRed:0.77f green:0.77f blue:0.77f alpha:1.00f];
    directTeleLabel.attributedText=[NSAttributedString attributeStringWithContent:zhiboStr keyWords:languageStringWithKey(@"直拨电话:") colors:[UIColor colorWithHexString:APPMainUIColorHexString]];
    directTeleLabel.numberOfLines = 0;
    directTeleLabel.font =ThemeFontSmall;
    [directTeleLabel sizeToFit];
    [_introduceView addSubview:directTeleLabel];
    
    //普通电话
    UILabel *ordinaryTeleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5*fitScreenWidth, directTeleLabel.bottom+5*fitScreenWidth, self.mainView.frame.size.width-10*fitScreenWidth, 30*fitScreenWidth)];
    ordinaryTeleLabel.textColor = [UIColor colorWithRed:0.77f green:0.77f blue:0.77f alpha:1.00f];
    ordinaryTeleLabel.attributedText = [NSAttributedString attributeStringWithContent:putongStr keyWords:languageStringWithKey(@"普通电话:") colors:[UIColor colorWithHexString:APPMainUIColorHexString]];
    ordinaryTeleLabel.numberOfLines = 0;
    ordinaryTeleLabel.font =ThemeFontSmall;
    [ordinaryTeleLabel sizeToFit];
    [_introduceView addSubview:ordinaryTeleLabel];
    
    //回拨电话
    
    UILabel *voiceTeleLabel =[[UILabel alloc]initWithFrame:CGRectMake(5*fitScreenWidth, ordinaryTeleLabel.bottom+5*fitScreenWidth, self.mainView.frame.size.width-10*fitScreenWidth, 5*fitScreenWidth)];
    voiceTeleLabel.textColor=[UIColor colorWithRed:0.77f green:0.77f blue:0.77f alpha:1.00f];
    voiceTeleLabel.attributedText=[NSAttributedString attributeStringWithContent:huiboStr keyWords:languageStringWithKey(@"回拨电话:") colors:[UIColor colorWithHexString:APPMainUIColorHexString]];
    voiceTeleLabel.numberOfLines = 0;
    voiceTeleLabel.font =ThemeFontSmall;
    [voiceTeleLabel sizeToFit];
    // eagle 屏蔽回拨电话
    voiceTeleLabel.hidden = YES;
    [_introduceView addSubview:voiceTeleLabel];
    
    //选择电话类型
    
    UILabel *seleLabel =[[UILabel alloc]initWithFrame:CGRectMake(5*fitScreenWidth, ordinaryTeleLabel.bottom+5*fitScreenWidth, self.mainView.frame.size.width-10, 15*fitScreenWidth)];
    seleLabel.text=languageStringWithKey(@"您可根据自身网络情况进行选择通话方式:");
    seleLabel.font =ThemeFontSmall;
    seleLabel.numberOfLines=0;
    [seleLabel sizeToFit];
    seleLabel.textColor=[UIColor colorWithHexString:APPMainUIColorHexString];
    // seleLabel.textColor=[UIColor colorWithRed:0.77f green:0.77f blue:0.77f alpha:1.00f];
    [_introduceView addSubview:seleLabel];
    _introduceView.hidden=YES;
    _dailingView =[[UIView alloc]init];
    _dailingView.frame =CGRectMake(0, 46*fitScreenWidth, self.mainView.size.width, self.mainView.size.height-46*fitScreenWidth);
    [self.mainView addSubview:_dailingView];
    UIImageView *imgView1 =[[UIImageView alloc]initWithFrame:CGRectMake(_dailingView.frame.size.width/2-0.5, 0, 1, _dailingView.frame.size.height)];
    imgView1.backgroundColor=[UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
    

    [_dailingView addSubview:imgView1];
    if(_titleArray.count>0)
    {
        for(int i=0;i<_titleArray.count ;i++)
        {
            UIButton *teleButton =[UIButton buttonWithType:UIButtonTypeCustom];
            teleButton.tag =100+i;
             UIImageView *imgView2 =[[UIImageView alloc]initWithFrame:CGRectMake(teleButton.originX, teleButton.originY, _dailingView.frame.size.width, 1)];
            imgView2.backgroundColor=[UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:1.00f];
            [teleButton addSubview:imgView2];
            [teleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if((!_isCanVoice && i==0) || (!_isDirectDial && i == 1) || (!_isBackDial && i == 3))
            {
                [teleButton setTitleColor:[UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.00f] forState:UIControlStateNormal];
            }
            
            CGFloat height = _dailingView.frame.size.height/2;
            if (_titleArray.count == 2){
                height = _dailingView.frame.size.height;
            }
            if(i%2==0)
            {
                teleButton.frame=CGRectMake(0,_dailingView.frame.size.height/2 *(i/2), _dailingView.frame.size.width/2-0.5, height);
            }else
            {
                teleButton.frame=CGRectMake(_dailingView.frame.size.width/2+0.5, _dailingView.frame.size.height/2 *(i/2), _dailingView.frame.size.width/2-0.5, height);
            }
            NSString *imgName = _titleArray[i];
            [teleButton setTitle:imgName forState:UIControlStateNormal];
            teleButton.titleLabel.font = ThemeFontLarge;
            [teleButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_dailingView addSubview:teleButton];
            
        }
    }
    
//    self.centerY = kScreenHeight/2;
}

-(void)showViewAction:(UIButton *)btn
{
    CGFloat rxWidth = kScreenWidth - 40*fitScreenWidth;
    CGFloat top = kScreenHeight-376*fitScreenWidth;
    if(_introduceView.hidden==YES)
    {
        _introduceView.hidden=NO;
        [UIView animateWithDuration:0.3 animations:^{
            if (isEnLocalization) {
                _introduceView.frame =CGRectMake(0, self.teleLabel.bottom+10*fitScreenWidth, rxWidth, 190*fitScreenWidth);
                _dailingView.frame =CGRectMake(0, _introduceView.bottom, rxWidth, 120*fitScreenWidth);
                self.frame=CGRectMake(20*fitScreenWidth, kScreenHeight-(_introduceView.height +_introduceView.originY+ _dailingView.height)-80, rxWidth, (_introduceView.originY+_introduceView.height + _dailingView.height));
                self.mainView.frame=CGRectMake(0, 0, self.size.width, self.size.height);
                
//                self.top = top;
                
            }else{
                _introduceView.frame = CGRectMake(0, self.teleLabel.bottom+10*fitScreenWidth, rxWidth, 130*fitScreenWidth);
                _dailingView.frame =CGRectMake(0, _introduceView.bottom, rxWidth, 120*fitScreenWidth);
                self.frame=CGRectMake(20*fitScreenWidth, kScreenHeight-(_introduceView.height +_introduceView.originY+ _dailingView.height)-80, rxWidth, (_introduceView.height +_introduceView.originY+ _dailingView.height));
                self.mainView.frame=CGRectMake(0, 0, self.size.width, self.size.height);
//                self.top = top;
            }
        }];
    }else
    {
        _introduceView.hidden=YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame=CGRectMake(20*fitScreenWidth, kScreenHeight-376*fitScreenWidth, kScreenWidth-40*fitScreenWidth, 166*fitScreenWidth);
            self.mainView.frame=CGRectMake(0, 0, self.size.width, self.size.height);
            _dailingView.frame =CGRectMake(0, 46*fitScreenWidth, self.mainView.size.width, self.mainView.size.height-46*fitScreenWidth);
        }];
    }
}
-(void)buttonAction:(UIButton *)btn
{
    UIButton *button =btn;
    if((button.tag==100 && !_isCanVoice) || (button.tag == 101 && !_isDirectDial) || (button.tag == 103 && !_isBackDial))
    {
        return;
    }
    
    [self dismissModalDialogWithAnimation:YES];
    if(self.didclickBtn)
    {
        self.didclickBtn(self,button.tag);
    }
    
    
}
@end
