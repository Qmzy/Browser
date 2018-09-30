//
//  BrowserViewModel.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BaseViewModel.h"
#import "BrowserConfig.h"
#import "BrowserService.h"
#import "BrowserSub.h"
#import "BrowserJSString.h"
#import <WebKit/WebKit.h>


typedef BOOL(^ CYEBrowserShouldLoadBlock)(UIViewController * browser, NSString * url);

@interface BrowserViewModel : BaseViewModel

@property (nonatomic, strong) WKWebView * wkWebView;
@property (nonatomic, weak) id delegate; // 保存外部代理对象
@property (nonatomic, weak) CYEBrowserShouldLoadBlock loadBlock;

@property (nonatomic, copy) NSString * requestURL;  // 加载的网址
@property (nonatomic, copy) NSString * errorText;   // 加载错误的提示文本
@property (nonatomic, assign) BOOL isInRequest;     // 是否在请求中
@property (nonatomic, strong) NSTimer * requestTimer;  // 请求计时器
@property (nonatomic, assign) BOOL errorBgViewHidden;  // 错误页隐藏

@property (nonatomic, strong) BrowserConfig * browserConfig;   // 配置项
@property (nonatomic, strong) BrowserService * browserService; // 与 js 交互信息对象
@property (nonatomic, strong) BrowserSub * browserSubView;     // 自定义的视图

/*   方法暴露   */
@property (nonatomic, readonly, strong) RACSubject * refreshTabbarSubject;
@property (nonatomic, readonly, strong) RACSubject * loadFinishSubject;  // H5 加载完成，web 业务执行完后调用
@property (nonatomic, readonly, strong) RACSubject * refreshTitleViewSubject; // 更新导航栏标题

/*   网页请求    */
@property (nonatomic, readonly, strong) RACCommand * loadRequestCommand;
@property (nonatomic, readonly, strong) RACCommand * loadExampleHTMLCommand;
@property (nonatomic, readonly, strong) RACCommand * refreshRequestCommand;
@property (nonatomic, readonly, strong) RACCommand * endRequestCommand;

/*    界面操作   */
@property (nonatomic, readonly, strong) RACCommand * closeBrowserCommand;  // 关闭浏览器
@property (nonatomic, readonly, strong) RACCommand * tapNaviRightCommand;  // 导航栏右侧被点击

- (BOOL)isTopVCAndShop;

/**
  *  @brief   isExitBrowser   yes - 直接退出 | no - 返回上一页
  */
- (void)backPage:(UIViewController *)vc isExitBrowser:(BOOL)isExit;

@end
