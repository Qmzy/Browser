//
//  BrowserJS.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserJS.h"

@implementation BrowserJSData

- (instancetype)init
{
    if (self = [super init]) {
        self.hasParam = NO;
        self.isDirectRetureJS = NO;
        self.isStringRTValue  = NO;
    }
    return self;
}

@end




@implementation BrowserJS

+ (instancetype)browserJSWithFunc:(NSString *)jsFuncName ocFunc:(NSString *)ocFuncName hasParam:(BOOL)hasParam
{
    BrowserJS * js = [BrowserJS new];
    js.jsData.isDirectRetureJS = NO;
    js.jsData.jsFunctionName = jsFuncName;
    js.jsData.ocFunctionName = ocFuncName;
    js.jsData.hasParam = hasParam;
    
    return js;
}

+ (instancetype)browserJSWithFunc:(NSString *)jsFuncName retValue:(NSString *)value isStringRTValue:(BOOL)isStringRTValue
{
    BrowserJS * js = [BrowserJS new];
    js.jsData.isDirectRetureJS = YES;
    js.jsData.jsFunctionName   = jsFuncName;
    js.jsData.isStringRTValue  = isStringRTValue;
    js.jsData.retValue = value;
    
    return js;
}

/**
 * @brief   创建注入的 js 字符串
 */
- (NSString *)createJSString
{
    if (self.jsData.jsFunctionName == nil || self.jsData.jsFunctionName.length == 0) {
        NSLog(@"injectJSWithjsFunction error !!!  jsFunctionName == nil");
        return nil;
    }
    
    if (nil == self.jsData.ocFunctionName) {
        self.jsData.ocFunctionName = self.jsData.jsFunctionName;
    }
    
    if (self.jsData.isDirectRetureJS) {
        return [self createDirectRetureJSString];
    }
    
    return [self createNoRetureJSString];
}

/**
  *  @brief   有返回值 js 方法字符串
  */
- (NSString *)createDirectRetureJSString
{
    if (self.jsData.isStringRTValue) {
        
        return [NSString stringWithFormat:@"var script = document.createElement('script');"
                "script.type = 'text/javascript';"
                "script.text = \"function %@() { "
                " return '%@';"
                "}\";"
                "document.getElementsByTagName('html')[0].appendChild(script);", self.jsData.jsFunctionName, self.jsData.retValue];
    }
    else{
        return [NSString stringWithFormat:@"var script = document.createElement('script');"
                "script.type = 'text/javascript';"
                "script.text = \"function %@() { "
                " return %@;"
                "}\";"
                "document.getElementsByTagName('html')[0].appendChild(script);", self.jsData.jsFunctionName, self.jsData.retValue];
    }
}

/**
  *  @brief   无返回值 js 方法字符串
  */
- (NSString *)createNoRetureJSString
{
    if (self.jsData.hasParam) {
        
        return [NSString stringWithFormat:@"var script = document.createElement('script');"
                "script.type = 'text/javascript';"
                "script.text = \"function %@(param) { "
                "window.location.href='objc://%@/'+param;"
                "}\";"
                "document.getElementsByTagName('head')[0].appendChild(script);", self.jsData.jsFunctionName, self.jsData.ocFunctionName];
    }
    else {
        return [NSString stringWithFormat:@"var script = document.createElement('script');"
                "script.type = 'text/javascript';"
                "script.text = \"function %@() { "
                "window.location.href='objc://%@';"
                "}\";"
                "document.getElementsByTagName('head')[0].appendChild(script);", self.jsData.jsFunctionName, self.jsData.ocFunctionName];
    }
}

/// 根据 oc 方法名判断是否是当前对象
- (BOOL)isEqualToJS:(NSString *)ocFunctionName
{
    return ([self.jsData.ocFunctionName isEqualToString:ocFunctionName]
            || [self.jsData.jsFunctionName isEqualToString:ocFunctionName]);
}


#pragma mark - GET

- (BrowserJSData *)jsData
{
    if (_jsData == nil) {
        _jsData = [BrowserJSData new];
    }
    return _jsData;
}

@end
