//
//  CustomEmojiView.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/18.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "CustomEmojiView.h"
#import "ChatEmojiManager.h"

#define EXPRESSION_SCROLL_VIEW_TAG 100

@interface CustomEmojiView()<UIScrollViewDelegate>

@end

@implementation CustomEmojiView
{
    UIPageControl *_pageCtrl;
    UIScrollView  *_pageScroll;
}

+(CustomEmojiView*)shardInstance{
    static dispatch_once_t emojiviewOnce;
    static CustomEmojiView *cutomemojiview;
    dispatch_once(&emojiviewOnce, ^{
        cutomemojiview = [[CustomEmojiView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 216*fitScreenWidth)];
    });
    return cutomemojiview;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreenWidth, 216*fitScreenWidth);
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        NSInteger pageCount = 6;
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        scrollView.tag = EXPRESSION_SCROLL_VIEW_TAG;
        _pageScroll = scrollView;
        _pageScroll.scrollsToTop = NO;
        scrollView.delegate = self;
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*pageCount, scrollView.frame.size.height);
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor whiteColor];
        
        int row = 4;
        int column = 8;
        int number = 0;
        for (int p=0; p<pageCount; p++)
        {
            NSInteger page_X = p*scrollView.frame.size.width;
            for (int j=0; j<row; j++)
            {
                NSInteger row_y = 15*fitScreenWidth+40*fitScreenWidth*j;
                for (int i=0; i<column; i++)
                {
                    //20*fitScreenWidth+40*i;
                    NSInteger column_x =20*fitScreenWidth+ i*((kScreenWidth-40*fitScreenWidth - column*40*fitScreenWidth))/(column-1)+40*fitScreenWidth*i;
                    
                    if (number > 170)
                    {
                        break;
                    }
                    
                    if (j!=row-1 || i!=column-1){
                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+column_x, row_y, 40.0f*fitScreenWidth, 30.0f*fitScreenWidth)];
                        btn.tag = number;
                        btn.backgroundColor = [UIColor clearColor];
                        btn.titleLabel.font = [UIFont systemFontOfSize:23.0f*fitScreenWidth];
                        [btn setTitle:[ChatEmojiManager getExpressionStrByIdCommon:number] forState:UIControlStateNormal];
                        [btn addTarget:self action:@selector(putExpress:) forControlEvents:UIControlEventTouchUpInside];
                        [scrollView addSubview:btn];
                        number++;
                    }
                }
            }
            
            UIButton* delBtn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+kScreenWidth-60*fitScreenWidth, 137.0f*fitScreenWidth, 40.0f*fitScreenWidth, 30.0f*fitScreenWidth)];
            delBtn.backgroundColor = [UIColor clearColor];
            [delBtn setImage:ThemeImage(@"emoji_delete_on") forState:UIControlStateHighlighted];
            [delBtn setImage:ThemeImage(@"emoji_delete") forState:UIControlStateNormal];
            [delBtn addTarget:self action:@selector(backspaceText:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:delBtn];
        }
        
        [self addSubview:scrollView];
        
        UIPageControl *pageView = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth-120*fitScreenWidth)/2, self.frame.size.height-40.0f*fitScreenWidth, 120.0f*fitScreenWidth, 20.0f*fitScreenWidth)];
        pageView.currentPageIndicatorTintColor = [UIColor blackColor];
        pageView.pageIndicatorTintColor = [UIColor grayColor];
        pageView.numberOfPages = pageCount;
        pageView.currentPage = 0;
        [pageView addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
        _pageCtrl = pageView;
        [self addSubview:pageView];
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(self.frame.size.width-80.0f*fitScreenWidth, self.frame.size.height-40.0f*fitScreenWidth, 60.0f*fitScreenWidth, 30.0f*fitScreenWidth);
        [sendBtn setBackgroundImage:[ThemeImage(@"common_resizable_blue_N") stretchableImageWithLeftCapWidth:6 topCapHeight:15] forState:UIControlStateNormal];
        [sendBtn setBackgroundImage:[ThemeImage(@"common_resizable_blue_H") stretchableImageWithLeftCapWidth:6 topCapHeight:15] forState:UIControlStateHighlighted];
        [sendBtn setTitle:languageStringWithKey(@"发送") forState:UIControlStateNormal];
        sendBtn.titleLabel.font = SystemFontMiddle;
        [self addSubview:sendBtn];
        [sendBtn addTarget:self action:@selector(emojiSendBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)putExpress:(id)sender{
    
    UIButton *button_tag = (UIButton *)sender;
    if (self.delegate) {
        [self.delegate emojiBtnInput:button_tag.tag];
    }
}


- (void)backspaceText:(id)sender{
    if (self.delegate) {
        [self.delegate backspaceText];
    }
}

-(void)emojiSendBtn:(id)sender{
    if (self.delegate) {
        [self.delegate emojiSendBtn:sender];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == EXPRESSION_SCROLL_VIEW_TAG)
    {
        //更新UIPageControl的当前页
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.frame;
        [_pageCtrl setCurrentPage:offset.x / bounds.size.width];
    }
}

- (void)pageTurn:(UIPageControl*)sender
{
    //令UIScrollView做出相应的滑动显示
    CGSize viewSize = _pageScroll.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [_pageScroll scrollRectToVisible:rect animated:YES];
}

@end
