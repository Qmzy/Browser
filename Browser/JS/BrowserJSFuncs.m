//
//  BrowserJSFuncs.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserJSFuncs.h"
#import "BrowserViewModel.h"
#import <WebKit/WebKit.h>
#import "UIView+Tool.h"


@interface BrowserJSFuncs ()
{
    BrowserViewModel * _viewModel;
}
@end


@implementation BrowserJSFuncs

- (instancetype)initWithBrowserViewModel:(BrowserViewModel *)viewModel
{
    if (self = [super init]) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)back
{
    [_viewModel backPage:[_viewModel.wkWebView firstVC] isExitBrowser:YES];
}

- (void)isInApp
{
    [_viewModel.browserService stringByEvaluatingJavaScriptFromString:jsStringWithBaseValue(isInAppJS, 1)];
    [_viewModel.browserService stringByEvaluatingJavaScriptFromString:jsStringWithBaseValue(isInAppJSNew, 1)];
}

/// 通知 H5 登录状态
-(void)isLogin
{
    [_viewModel.browserService stringByEvaluatingJavaScriptFromString:jsStringWithOCString(isLoginJS, @"true")];
    [_viewModel.browserService stringByEvaluatingJavaScriptFromString:jsStringWithOCString(isLoginJSNew, @"true")];
}


#pragma mark - Pay JS Call OC Funcs
/// 调用微信接口支付。param 支付相关信息
- (void)appWXPay:(id)param
{
    
}

/// 调用支付宝接口支付。productModel 产品相关信息
-(void)appAliPay:(id)param
{
    
}

@end
