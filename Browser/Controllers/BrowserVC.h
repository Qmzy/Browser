//  浏览器
//
//  BrowserVC.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BaseViewController.h"

@class BrowserViewModel;
@interface BrowserVC : BaseViewController

/// 以 viewModel 对象来初始化
- (instancetype)initWithViewModel:(BrowserViewModel *)viewModel;

@end



/*********************   代理    *********************/
@protocol CYKJBaseBrowserDelegatePTC <NSObject>
@optional
/**
  *  @brief   点击返回按钮时，让外界处理业务逻辑
  */
- (void)beforeBackPage;

- (void)tapNavRightButton:(id)object destVc:(UIViewController *)vc;

/**
  *  @brief   请求完成的回调方法
  *  @param   result    "success" - 请求成功    "fail" - 请求失败   "timeout" - 请求超时
  */
- (void)browser:(BrowserVC *)browser didFinishRequest:(NSString *)result;

@end
