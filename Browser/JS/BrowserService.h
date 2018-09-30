//
//  BrowserService.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class BrowserJS;
@class BrowserViewModel;
@interface BrowserService : NSObject

@property (nonatomic, assign) BOOL isWebPay;  // 是否向 web 注入网上支付 js 函数。默认 yes - 注入

- (instancetype)initWithViewModel:(BrowserViewModel *)viewModel;

/**
  *  @brief   插入用户交互 js 语句
  */
- (void)insertUserJsFun;

/**
 *  @brief    插入基础交互能力 js 语句
 */
- (void)insertBaseJsFun;

/**
  *  @brief   将指定 js 信息添加到 user 数组中
  */
- (void)addUserJSWithjsFunction:(NSString *)jsFuncName
                     ocFunction:(NSString *)ocFuncName
                       hasParam:(BOOL)hasParam;

/**
  *  @brief   由 oc 方法名获取 js 交互信息对象
  */
- (BrowserJS *)findJSData:(NSString *)ocFuncName;

/**
 *  @brief   根据方法名查找方法
 *  @param    selectorName 方法名，如果有参数带冒号的哈
 *  @return    yes - 有该方法；no - 无该方法
 */
- (BOOL)findMethod:(NSString *)selectorName;

/**
  *  @brief   执行本地方法
  *  @param   selectorName   方法名，结构例如：@"play" 、@"play:"
  */
- (BOOL)performSelectorWithName:(NSString *)selectorName param:(id)param;

/**
  *  @brief   执行 js 回调方法
  *  @param   target   执行 js 回调方法的对象
  */
- (BOOL)performJSCallBackByData:(BrowserJS *)data target:(id)target;

/**
  *  @brief    执行 js 方法，并返回结果
  */
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)jsString;

@end
