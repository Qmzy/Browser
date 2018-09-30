//
//  BrowserViewModel.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserViewModel.h"
#import "BrowserHTML.h"


@interface BrowserViewModel ()

@property (nonatomic, readwrite, strong) RACSubject * refreshTabbarSubject;
@property (nonatomic, readwrite, strong) RACSubject * loadFinishSubject;
@property (nonatomic, readwrite, strong) RACSubject * refreshTitleViewSubject;
@property (nonatomic, readwrite, strong) RACCommand * loadRequestCommand;
@property (nonatomic, readwrite, strong) RACCommand * loadExampleHTMLCommand;
@property (nonatomic, readwrite, strong) RACCommand * refreshRequestCommand;
@property (nonatomic, readwrite, strong) RACCommand * endRequestCommand;
@property (nonatomic, readwrite, strong) RACCommand * closeBrowserCommand;
@property (nonatomic, readwrite, strong) RACCommand * tapNaviRightCommand;

@end


@implementation BrowserViewModel

- (void)initialize
{
    [super initialize];
    
    self.errorBgViewHidden = YES;
    
    self.refreshTabbarSubject    = [RACSubject subject];
    self.loadFinishSubject       = [RACSubject subject];
    self.refreshTitleViewSubject = [RACSubject subject];
}

/**
  *  @brief   关闭浏览器
  */
- (RACCommand *)closeBrowserCommand
{
    if (_closeBrowserCommand == nil) {
        
        _closeBrowserCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIViewController * vc) {
            
            if ( vc.navigationController &&
                     [vc.navigationController.viewControllers.firstObject isEqual:vc]) {
                
                [self.loadRequestCommand execute:nil];
            }
            else{
                [vc.navigationController popViewControllerAnimated:YES];
            }
            
            return [RACSignal empty];
        }];
    }
    return _closeBrowserCommand;
}

/**
  *  @brief   导航栏右侧按钮被点击
  */
- (RACCommand *)tapNaviRightCommand
{
    if (_tapNaviRightCommand == nil) {
        
        _tapNaviRightCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIViewController * vc) {
            
            if (self.browserConfig.rightItemTitle.length > 0) {
                // 根据导航栏右侧按钮文本做处理
            }
            
            return [RACSignal empty];
        }];
    }
    return _tapNaviRightCommand;
}


#pragma mark - Request Command
/**
  *  @brief   加载网页请求
  */
- (RACCommand *)loadRequestCommand
{
    if (_loadRequestCommand == nil) {
        
        _loadRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            // 远程网址
            if([self.requestURL hasPrefix:@"http"]) {
                
                [self.wkWebView loadRequest:[BrowserHTML webUrlRequest:self.requestURL]];
            }
            // 本地地址
            else {
                if (![self.requestURL hasPrefix:@"file"]) {
                    // 拼接
                }
                
                if (@available(iOS 9.0, *)) {
                    [self.wkWebView loadFileURL:[NSURL URLWithString:self.requestURL]
                        allowingReadAccessToURL:[BrowserHTML fileURLForAllowingReadAccess:self.requestURL]];
                }
                else {
                    [self.wkWebView loadRequest:[BrowserHTML webUrlRequest:self.requestURL]];
                }
            }
            
            // 启动定时器，监听请求时间，45秒超时
            if(_requestTimer == nil){
                _requestTimer = [NSTimer scheduledTimerWithTimeInterval:45.0 target:self selector:@selector(requestTimeOut) userInfo:nil repeats:YES];
            }
            _isInRequest = YES;
            
            return [RACSignal empty];
        }];
    }
    return _loadRequestCommand;
}

/**
  *  @brief   加载本地静态样例 html
  */
- (RACCommand *)loadExampleHTMLCommand
{
    if (_loadExampleHTMLCommand == nil) {
        
        _loadExampleHTMLCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
            NSString * appHtml = [NSString stringWithContentsOfFile:htmlPath
                                                           encoding:NSUTF8StringEncoding error:nil];
            [self.wkWebView loadHTMLString:appHtml baseURL:[NSURL fileURLWithPath:htmlPath]];
            
            return [RACSignal empty];
        }];
    }
    return _loadExampleHTMLCommand;
}

/**
  *  @brief   停止加载
  */
- (RACCommand *)endRequestCommand
{
    if (_endRequestCommand == nil) {
        
        _endRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            _isInRequest = NO;
            
            if (_requestTimer != nil) {
                [_requestTimer invalidate];
            }
            _requestTimer = nil;
            
            return [RACSignal empty];
        }];
    }
    return _endRequestCommand;
}

/**
  *  @brief   重新请求
  */
- (RACCommand *)refreshRequestCommand
{
    if (_refreshRequestCommand == nil) {
        
        _refreshRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            if ([self.wkWebView isLoading]) {
                [self.wkWebView stopLoading];
            }
            
            [self.endRequestCommand execute:nil];
            self.errorBgViewHidden = YES;
            [self.loadRequestCommand execute:nil];
            
            return [RACSignal empty];
        }];
    }
    return _refreshRequestCommand;
}

/**
  *  @brief   请求超时
  */
- (void)requestTimeOut
{
    [self.endRequestCommand execute:nil];
    self.errorBgViewHidden = NO;
}


#pragma mark - Funcs
/**
  *  @brief   判断当前内容是否是网页的首页
  */
- (BOOL)isTopVCAndShop
{
    if (self.browserConfig.isTopLevelVC) {
        // 填入自己 app 的判断首页 js 语句
        return (1 == [self.browserService stringByEvaluatingJavaScriptFromString:@""].intValue);
    }
    return NO;
}

/**
 *  @brief   是否直接退出/返回上一页
 */
- (void)backPage:(UIViewController *)vc isExitBrowser:(BOOL)isExit;
{
    if (self.browserConfig.isReceivePE) {
        return;
    }
    
    int backTo = [self.browserService stringByEvaluatingJavaScriptFromString:backToJS].intValue;
    
    switch (backTo) {
            
        case 3:  // 返回上一界面
        {
            [vc.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        case 4:  // 提示确认返回上一界面
        case 5:  // 提示确认返回上个 H5
        {
            NSString * str = [self.browserService stringByEvaluatingJavaScriptFromString:backTipsJS];
            
            if (str.length == 0) {
                str = @"是否结束健康测试?";
            }
            
            [self showAlertVCWithMessage:str inController:vc];
        }
            break;
            
        case 0:   // 正常返回
        default:
        {
            if ([self.wkWebView canGoBack]) {
                [self.wkWebView goBack];
            }
            else{
                [vc.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
    }
}

/**
 *  @brief   显示提示视图
 */
- (void)showAlertVCWithMessage:(NSString *)message inController:(UIViewController *)vc
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"提示"
                                                                      message:message
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              // 取消时的操作
                                                              [vc dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          // 确认时的操作
                                                          [vc dismissViewControllerAnimated:NO completion:nil];
                                                          
                                                          [self.endRequestCommand execute:nil];
                                                          
                                                          int backTo = [self.browserService stringByEvaluatingJavaScriptFromString:backToJS].intValue;
                                                          
                                                          if (4 == backTo) {
                                                              [vc.navigationController popViewControllerAnimated:YES];
                                                          }
                                                          else if (5 == backTo) {
                                                              
                                                              if ([self.wkWebView canGoBack]) {
                                                                  [self.wkWebView goBack];
                                                              }
                                                              else{
                                                                  [vc.navigationController popViewControllerAnimated:YES];
                                                              }
                                                          }
                                                      }];
    
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    
    [vc presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - GET Method
/// 初始化并返回对象
- (BrowserConfig *)browserConfig
{
    return _browserConfig ? : (_browserConfig = [[BrowserConfig alloc] init]);
}

- (BrowserService *)browserService
{
    return _browserService ? : (_browserService = [[BrowserService alloc] initWithViewModel:self]);
}

- (BrowserSub *)browserSubView
{
    return _browserSubView ? : (_browserSubView = [[BrowserSub alloc] init]);
}

- (WKWebView *)wkWebView
{
    if (_wkWebView == nil) {
        
        WKUserContentController * ucc = [[WKUserContentController alloc] init];
        WKWebViewConfiguration * wkConfig = [[WKWebViewConfiguration alloc] init];
        wkConfig.userContentController = ucc;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkConfig];
        _wkWebView.opaque = NO;
        _wkWebView.backgroundColor = [UIColor clearColor];
        _wkWebView.scrollView.backgroundColor = [UIColor clearColor];
        
        // 先创建 wkWebView 对象，使得它不为 nil
        [self.browserService insertBaseJsFun];
        [self.browserService insertUserJsFun];
    }
    return _wkWebView;
}

@end
