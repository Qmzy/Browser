//
//  BrowserService.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserService.h"
#import "BrowserJS.h"
#import "BrowserJSFuncs.h"
#import "BrowserViewModel.h"


#define WXPAYRESULT    @"WXPAYRESULT"  // 微信支付结果
#define ALIPAYRESULT   @"ALIPAYRESULT"  // 支付宝支付结果

@interface BrowserService ()
{
    BrowserJSFuncs * _jsFuncs;
    BrowserViewModel * _viewModel;
}
@property (nonatomic, strong) NSMutableArray * userInjectJSData;
@property (nonatomic, strong) NSMutableArray * baseInjectJSData;

@end


@implementation BrowserService

- (instancetype)initWithViewModel:(BrowserViewModel *)viewModel
{
    if (self = [super init]) {
        
        self.isWebPay = YES;  // 所有浏览器可获取用户信息和支付
        
        _viewModel = viewModel;
        _jsFuncs = [[BrowserJSFuncs alloc] initWithBrowserViewModel:viewModel];
    }
    return self;
}


#pragma mark - Setter Method
/// 重写 isWebPay 的 set 方法，当 web 需要支付时，也必须可获取用户信息
- (void)setIsWebPay:(BOOL)isWebPay
{
    if ((_isWebPay = isWebPay)) {
        
        [self insertUserInfoFunData];
        [self insertPayFunData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getWXPayCallback:) name:WXPAYRESULT object:nil];
    }
}

/// 微信支付后回调 webview
-(void)getWXPayCallback:(NSNotification *)noti
{
    [self stringByEvaluatingJavaScriptFromString:jsStringWithBaseValue(wxPayJS, [noti.object intValue])];
    [self stringByEvaluatingJavaScriptFromString:jsStringWithBaseValue(wxPayJSNew, [noti.object intValue])];
}


#pragma mark - Inject JS To Web
/// 因为用户交互可能有特殊的场景（比如得预先读取页面属性进行某种业务操作后，再将返回值注入到页面），所以保持在页面加载完成后注入
- (void)insertUserJsFun
{
    [self injectUserJSCode];
    
    if (self.isWebPay) {
        [self stringByEvaluatingJavaScriptFromString:iOSLoadJS];
    }
    [self finishAppJsInsert];
}

/// 通知 web 插入 js 完成
- (void)finishAppJsInsert
{
    [self stringByEvaluatingJavaScriptFromString:@"finishAppJsInsert();"];
}

/// 因为基础交互能力不基于业务，所以修改为启动时直接注入
- (void)insertBaseJsFun
{
    [self.baseInjectJSData enumerateObjectsUsingBlock:^(BrowserJS * obj, NSUInteger idx, BOOL * stop) {
        
        NSString * jsString = [obj createJSString];
        
        if(jsString.length > 0) {
            
            // ①、采用 wkWebView 推荐的方式向 web 页插入 js 语句
            WKUserScript * us = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            
            [_viewModel.wkWebView.configuration.userContentController addUserScript:us];
            
            // ②、采用 wkWebView 执行 js 语句的方法插入 js 语句
            // [self stringByEvaluatingJavaScriptFromString:jsString];
        }
    }];
}

- (void)injectUserJSCode
{
    [self.userInjectJSData enumerateObjectsUsingBlock:^(BrowserJS * obj, NSUInteger idx, BOOL * stop) {
        
        NSString * jsString = [obj createJSString];
        
        if(jsString.length > 0) {
            
            // ①、采用 wkWebView 推荐的方式向 web 页插入 js 语句
            WKUserScript * us = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            
            [_viewModel.wkWebView.configuration.userContentController addUserScript:us];
            
            // ②、采用 wkWebView 执行 js 语句的方法插入 js 语句
            // [self stringByEvaluatingJavaScriptFromString:jsString];
        }
    }];
}


#pragma mark - Add JS To Array
/// 向 user 数组中添加 BrowserJS 对象
- (void)addUserJSWithjsFunction:(NSString *)jsFuncName ocFunction:(NSString *)ocFuncName hasParam:(BOOL)hasParam
{
    BrowserJS * injectJSData = [BrowserJS browserJSWithFunc:jsFuncName ocFunc:ocFuncName hasParam:hasParam];
    [self.userInjectJSData addObject:injectJSData];
}

/// 向 base 数组中添加 BrowserJS 对象
- (void)addBaseJSWithjsFunction:(NSString *)jsFuncName ocFunction:(NSString *)ocFuncName hasParam:(BOOL)hasParam
{
    BrowserJS * injectJSData = [BrowserJS browserJSWithFunc:jsFuncName ocFunc:ocFuncName hasParam:hasParam];
    [self.baseInjectJSData addObject:injectJSData];
}

- (void)addBaseJSWithjsFunction:(NSString *)jsFuncName retValue:(NSString *)retValue isStringRTValue:(BOOL)isStringRTValue
{
    BrowserJS * injectJSData = [BrowserJS browserJSWithFunc:jsFuncName
                                                   retValue:retValue
                                            isStringRTValue:isStringRTValue];
    [self.baseInjectJSData addObject:injectJSData];
}

/// 向 web 页注入用户信息交互的函数
- (void)insertUserInfoFunData
{
    [self addBaseJSWithjsFunction:@"back" ocFunction:nil hasParam:NO];
    [self addBaseJSWithjsFunction:@"isLogin" ocFunction:nil hasParam:NO];    // 是否登录
    [self addBaseJSWithjsFunction:@"isInApp" ocFunction:nil hasParam:NO];
    [self addBaseJSWithjsFunction:@"callPhone" ocFunction:nil hasParam:YES]; // 拨打电话
}

/// 向 web 页注入支付函数
- (void)insertPayFunData
{
    [self addBaseJSWithjsFunction:@"appWXPay" ocFunction:nil hasParam:YES];
    [self addBaseJSWithjsFunction:@"appAliPay" ocFunction:nil hasParam:YES];
}


#pragma mark - Find JS From Array
/// 查找 js 交互信息对象
- (BrowserJS *)findJSData:(NSString *)ocFuncName
{
    __block BrowserJS * retValue = nil;
    
    do {
        [self.userInjectJSData enumerateObjectsUsingBlock:^(BrowserJS * obj, NSUInteger idx, BOOL * stop) {
            
            if ([obj isEqualToJS:ocFuncName]) {
                retValue = obj;
            }
        }];
        
        if (retValue)
            break; // 已找到
        
        [self.baseInjectJSData enumerateObjectsUsingBlock:^(BrowserJS * obj, NSUInteger idx, BOOL * stop) {
            
            if ([obj isEqualToJS:ocFuncName]) {
                retValue = obj;
            }
        }];
        
    } while (0);
    
    return retValue;
}


#pragma mark - Perform OC Func
/// 查找方法
- (BOOL)findMethod:(NSString *)selectorName
{
    return [_jsFuncs respondsToSelector:NSSelectorFromString(selectorName)];
}

/// 执行本地方法
- (BOOL)performSelectorWithName:(NSString *)selectorName param:(id)param
{
    SEL selector = NSSelectorFromString(selectorName);
    
    // 转给 CYKJBaseBrowserJSFuncs 执行
    if ([_jsFuncs respondsToSelector:selector]) {
        
        /*
                         解决警告方式：
                                ①、#pragma clang diagnostic push
                                        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                                [target performSelector:sel withObject: nil];
                                        #pragma clang diagnostic pop
         
                                ②、IMP imp = [target methodForSelector:sel];
                                        void (*func)(id, SEL) = (void *)imp;
                                        func(target, sel);
         
                                        ((void (*)(id, SEL))[target methodForSelector:sel])(target, sel);
                     */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (param) {
            [_jsFuncs performSelector:selector withObject:param];
        }
        else {
            [_jsFuncs performSelector:selector];
        }
#pragma clang diagnostic pop
        
        return YES;
    }
    
    return NO;
}

/// 执行 js 回调方法
- (BOOL)performJSCallBackByData:(BrowserJS *)data target:(id)target
{
    BOOL result = YES;
    
    // do - while(0)   用于 break 控制代码执行
    do {
        
        NSString * sel = data.jsData.ocFunctionName.length > 0 ? data.jsData.ocFunctionName : data.jsData.jsFunctionName;
        
        if (sel.length == 0)
            break;
        
        if (data.jsData.hasParam) {
            sel = [NSString stringWithFormat:@"%@:", sel];
        }
        
        SEL selector = NSSelectorFromString(sel);
        
        // 如果传入参数为空 || 执行对象未实现方法
        if (target == nil || ![target respondsToSelector:selector]) {
            
            // 判断 self 是否实现了方法
            if (![_jsFuncs respondsToSelector:selector])
                break;
            
            target = _jsFuncs;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (data.jsData.hasParam) {
            [target performSelector:selector withObject:data.jsData.param];
        }
        else {
            [target performSelector:selector];
        }
#pragma clang diagnostic pop
        
        result = NO;
        
    } while (0);
    
    return result;
}

/// 返回 js 方法执行结果
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)jsString
{
    __block NSString * str = nil;
    
    [_viewModel.wkWebView evaluateJavaScript:jsString completionHandler:^(NSString * result, NSError * error){
        str = result;
        CFRunLoopStop(CFRunLoopGetCurrent());
    }];
    
    CFRunLoopRun();
    
    if (str == nil || [str isKindOfClass:[NSNull class]]) {
        str = @"";
    }
    
    return str;
}


#pragma mark - GET

- (NSMutableArray *)userInjectJSData
{
    return _userInjectJSData ? : (_userInjectJSData = [NSMutableArray array]);
}

- (NSMutableArray *)baseInjectJSData
{
    return _baseInjectJSData ? : (_baseInjectJSData = [NSMutableArray array]);
}

@end
