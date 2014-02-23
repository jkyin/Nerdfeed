//
//  WebViewController.m
//  Nerdfeed
//
//  Created by Yin on 14-2-23.
//  Copyright (c) 2014年 Jack Yin. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (void)loadView
{
    // 创建 UIWebView 对象并将其大小设置为屏幕的尺寸
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *wv = [[UIWebView alloc] initWithFrame:screenFrame];
    // 设置 UIWebView 对象，允许其缩放显示的 Web 内容，以适应 bounds 的大小
    [wv setScalesPageToFit:YES];
    
    [self setView:wv];
}

- (UIWebView *)webView
{
    return (UIWebView *)[self view];
}

@end
