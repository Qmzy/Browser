//  待插入的 OC 与 H5 交互的 js 语句
//
//  OC 与 H5 开发人员确定方法，例如：openXX()
//      H5 开发人员只需要调用 openXX，不需要实现
//      OC 开发人员将 openXX 的实现通过 webView 将 js 语句插入的文档中
//
//  BrowserJS.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>

/******************  创建 js 语句的必要字段  ******************/
@interface BrowserJSData : NSObject

@property (nonatomic, copy) NSString * jsFunctionName;  // 提供给 h5 的调用方法名

@property (nonatomic, copy) NSString * ocFunctionName;  // oc 本地回调方法名。为空时复用 jsFunctionName
@property (nonatomic, assign) BOOL hasParam;            // oc 本地回调方法是否有参数
@property (nonatomic, strong) id param;                 // oc 本地回调方法的参数值

@property (nonatomic, assign) BOOL isDirectRetureJS;    // js 方法是否有返回值
@property (nonatomic, assign) BOOL isStringRTValue;     // js 方法返回值的类型。yes - 字符串  no - 非字符串
@property (nonatomic, copy) NSString * retValue;        // js 方法的返回值

@end



/*************************   js 语句相关  *************************/
@interface BrowserJS : NSObject

@property (nonatomic, strong) BrowserJSData * jsData;

/// 无返回值 js
+ (instancetype)browserJSWithFunc:(NSString *)jsFuncName
                           ocFunc:(NSString *)ocFuncName
                         hasParam:(BOOL)hasParam;
/// 有返回值 js
+ (instancetype)browserJSWithFunc:(NSString *)jsFuncName
                         retValue:(NSString *)value
                  isStringRTValue:(BOOL)isStringRTValue;

/// 用 jsData 对象创建将要被注入的 js 方法字符串
- (NSString *)createJSString;

/// 根据 oc 方法名判断是否是当前对象
- (BOOL)isEqualToJS:(NSString *)ocFuncName;

@end
