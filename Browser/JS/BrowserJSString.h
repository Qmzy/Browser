//  可执行的 js 语句
//
//  BrowserJSString.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>

/// 简单 js 语句
static NSString * iOSLoadJS     = @"iosLoadjs();";     // iOS 登录
static NSString * getTitleJS    = @"document.title";   // 获取标题
static NSString * refreshPageJS = @"refreshPage();";   // 刷新 web 界面
static NSString * backToJS   = @"document.getElementById('backTo').value";   // 区分返回的操作
static NSString * backTipsJS = @"document.getElementById('backTips').value";  // 返回时的提示语句
static NSString * isNeedShareJS = @"document.getElementById('share').value";  // 是否需要分享

// 拼接 js 语句
static NSString * isLoginJS = @"isLoginCallback('%@');";
static NSString * isInAppJS = @"getIsInAppCallback('%d');";
static NSString * aliPayJS  = @"appAliPayCallback('%@');";
static NSString * wxPayJS   = @"appWXPayCallback('%d');";

// h5 采用新框架下的 js 语句
static NSString * isLoginJSNew = @"window.Login.isLoginCallback('%@');";
static NSString * isInAppJSNew = @"window.APP.getIsInAppCallback('%d');";
static NSString * aliPayJSNew  = @"window.Pay.appAliPayCallback('%@');";
static NSString * wxPayJSNew   = @"window.Pay.appWXPayCallback('%d');";


/*********************  创建 js 语句的方法   *********************/
/// 原语句 + oc 字符串
NSString * jsStringWithOCString(NSString * js, NSString * param);

///  原语句 + 基础类型
NSString * jsStringWithBaseValue(NSString * js, NSInteger param);

