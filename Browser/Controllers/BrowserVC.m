//
//  BrowserVC.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserVC.h"
#import "BrowserJS.h"
#import "BrowserViewModel.h"
#import "BrowserNavi.h"

#define SCREEN_WIDTH         ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT        ([[UIScreen mainScreen] bounds].size.height)

@interface BrowserVC () <WKNavigationDelegate, WKUIDelegate>
{
    NSMutableArray * __cacheHomeRightItems;
    
    BOOL _isTapBack;   // 是否点击过返回按钮，如果触发过返回按钮，而又没退出浏览器或者回到商城首页，则显示关闭
    BOOL _isBacking;   // 是否正在返回。处理加载未完成时点击返回出现的问题
}
@property (weak, nonatomic) IBOutlet UIView * bgView;
@property (weak, nonatomic) IBOutlet UIView * errorBgView;
@property (weak, nonatomic) IBOutlet UILabel * errorLabel;
@property (weak, nonatomic) IBOutlet UIButton * errorBackBtn;

// 解决导航栏 title 不居中的问题。
@property (copy, nonatomic) NSString * cacheTitle;
@property (nonatomic, strong) BrowserViewModel * viewModel;

@end


static NSString * VC_NIB = @"BrowserVC";

@implementation BrowserVC
@dynamic viewModel;

- (void)dealloc
{
    self.viewModel.wkWebView.navigationDelegate = nil;
    [self.viewModel.requestTimer invalidate];
    self.viewModel.requestTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Initialize Method
/// 初始化方法。属性设置默认值代码移入 CYKJBaseBrowserConfig 类
- (instancetype)init
{
    if (self = [self initWithNibName:VC_NIB bundle:[NSBundle mainBundle]]) {
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _isTapBack = NO;
        _isBacking = NO;
    }
    return self;
}

- (instancetype)initWithRequestURL:(NSString *)requestURL
{
    if (self = [super initWithNibName:VC_NIB bundle:[NSBundle mainBundle]]) {
        
        self.viewModel.requestURL = requestURL;
    }
    return self;
}

- (instancetype)initWithViewModel:(BrowserViewModel *)viewModel
{
    if (self = [super initWithNibName:VC_NIB bundle:[NSBundle mainBundle]]) {
        
        self.viewModel = viewModel;
    }
    return self;
}


#pragma mark - Controller Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 将 wkWebView 从 self.view 移至 self.bgView 后内容向下偏移 64。移至 self.bgView 原因：loading 图标被遮住
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addWebView];
    [self setNaviBarLeftItems];
    [self addSwipeGesture];
    
    self.viewModel.wkWebView.navigationDelegate = self;
    self.viewModel.wkWebView.UIDelegate = self;
    
    [self.viewModel.loadExampleHTMLCommand execute:nil];
//    [self.viewModel.loadRequestCommand execute:nil];
}

- (void)bindViewModel
{
    [super bindViewModel];
    
    [[RACObserve(self.viewModel, errorText) distinctUntilChanged] subscribeNext:^(NSString * errorText) {
        
        if (errorText.length > 0) {
            self.errorLabel.text = errorText;
        }
    }];
    
    [[RACObserve(self.viewModel, errorBgViewHidden) distinctUntilChanged] subscribeNext:^(NSNumber * x) {
        self.errorBgView.hidden = x.boolValue;
    }];
    
    [self.viewModel.refreshTabbarSubject subscribeNext:^(id x) {
        [self refreshTabbar];
    }];
    
    [self.viewModel.loadFinishSubject subscribeNext:^(id x) {
        [self refreshNaviBarLeftItems];
        [self setNaviRightButton];
        [self refreshTabbar];
        [self refreshNaviBarTitle];
    }];
    
    [self.viewModel.refreshTitleViewSubject subscribeNext:^(id x) {
        [self refreshTitleView];
    }];
}

/// 对于非 push 情况进行处理
- (void)viewWillAppear:(BOOL)animated
{
    [self refreshTitleView];
    
    [super viewWillAppear:animated];
}

/// 处理底部 tabbar
- (void)viewDidAppear:(BOOL)animated
{
    if (self.viewModel.browserConfig.isForceRefreshTabbar) {
        
        self.viewModel.browserConfig.isForceRefreshTabbar = NO;
        [self performSelector:@selector(refreshTabbar) withObject:nil afterDelay:0.05];
    }
    
    [super viewDidAppear:animated];
}

/// 恢复现场
- (void)viewWillDisappear:(BOOL)animated
{
    _isBacking = YES;
    
    self.viewModel.browserConfig.isForceRefreshTabbar = YES;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationController.navigationItem.hidesBackButton = NO;
    [self.navigationController.navigationBar layoutIfNeeded];
    
    self.cacheTitle = self.navigationItem.title;
    self.navigationItem.title = @"";
    
    [super viewWillDisappear:animated];
}


#pragma mark - UI
/**
 *  @brief   更新导航栏标题。主要解决 CYKJBaseBrowserVC 处于一级页面时，切换 tabbar 会导致调用 viewWillDisappear 方法，将 title 置为 nil
 */
- (void)refreshTitleView
{
    [self.navigationController setNavigationBarHidden:self.viewModel.browserConfig.isHideTitleBar];
    
    if (!self.viewModel.browserConfig.isPush) {
        
        if (_cacheTitle.length > 0) {
            
            self.navigationItem.title = _cacheTitle;
            self.cacheTitle = @"";
        }
        
        [self.viewModel.browserService stringByEvaluatingJavaScriptFromString:refreshPageJS];
        [self refreshNaviBarLeftItems];
    }
    
    _isBacking = NO;
    
    self.viewModel.browserConfig.isPush = NO;
}

/**
 *  @brief   刷新导航栏标题
 */
- (void)refreshNaviBarTitle
{
    NSString * webTitle = self.viewModel.wkWebView.title;
    
    // 如果能取到页面元素，表明容器有数据，只提示请求失败，不屏蔽页面，如果容器无数据，则显示失败页
    if (webTitle.length > 0) {
        [self.errorBgView setHidden:YES];
    }
    else {
        webTitle = [self.viewModel.browserService stringByEvaluatingJavaScriptFromString:getTitleJS];
    }
    
    if (self.viewModel.browserConfig.isGetWebPageTitle) {
        self.navigationItem.title = webTitle;
    }
}

/**
 *  @brief   将 webView 添加到视图上
 */
- (void)addWebView
{
    [self.bgView addSubview:self.viewModel.wkWebView];
    [self.bgView sendSubviewToBack:self.viewModel.wkWebView];
    
    if (self.viewModel.browserSubView.subView) {
        
        [self.bgView addSubview:self.viewModel.browserSubView.subView];
        [self.bgView sendSubviewToBack:self.viewModel.browserSubView.subView];
        
        [self.viewModel.browserSubView setConstraint:self.viewModel.wkWebView];
    }
    else {
        [BrowserSub setConstraintWithNoSub:self.viewModel.wkWebView
                                 isHideBar:self.viewModel.browserConfig.isHideTitleBar];
    }
}

/**
 *  @brief   添加右滑返回手势
 */
- (void)addSwipeGesture
{
    if (self.viewModel.browserConfig.isSlideBack) {
        
        UISwipeGestureRecognizer * swpGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector( backPage)];
        [self.view addGestureRecognizer:swpGes];
    }
}

/**
 *  @brief   设置导航栏左侧 items
 */
- (void)setNaviBarLeftItems
{
    if (self.viewModel.browserConfig.isTopLevelVC && self.viewModel.browserConfig.isCYShop) {
        
    }
    else {
        // 是否需要创建左侧导航项
        BOOL isNeed = !self.viewModel.browserConfig.isHideTitleBar && !self.viewModel.browserConfig.isCustomTitleBar
        && !self.viewModel.browserConfig.isTopLevelVC;
        
        [BrowserNavi sharedInstance].naviBarLeftItemsBlock( isNeed,
                                                            self,
                                                            _isTapBack,
                                                            @selector( backPage ),
                                                            @selector( closeBrowser ));
    }
}

/**
 *  @brief   刷新导航栏左侧 items
 */
- (void)refreshNaviBarLeftItems
{
    if ([self.viewModel isTopVCAndShop]) {
        _isTapBack = NO;   // 如果是首页，恢复未点击返回状态
    }
    
    if ([self.viewModel isTopVCAndShop] && self.viewModel.browserConfig.isCYShop) {
        
    }
    else {
        // 是否需要创建左侧导航项
        BOOL isNeed = !self.viewModel.browserConfig.isHideTitleBar && !self.viewModel.browserConfig.isCustomTitleBar && ![self.viewModel isTopVCAndShop];
        
        [BrowserNavi sharedInstance].naviBarLeftItemsBlock( isNeed,
                                                            self,
                                                            _isTapBack,
                                                            @selector( backPage ),
                                                            @selector( closeBrowser ));
    }
}

/**
 *  @brief   设置导航栏右边按钮
 */
- (void)setNaviRightButton
{
    if (self.viewModel.browserConfig.isFixedHomeItem && !self.viewModel.wkWebView.canGoBack) {
        // 固定首页的自定义按钮
        if (__cacheHomeRightItems == nil) {
            __cacheHomeRightItems = [[NSMutableArray alloc] initWithCapacity:3];
            NSArray * items = self.navigationItem.rightBarButtonItems;
            if (items && items.count > 0) {
                [__cacheHomeRightItems addObjectsFromArray:items];
            }
        }
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = __cacheHomeRightItems;
    }
    else if (self.viewModel.browserConfig.isNeedShareBtn) {
        
        if (1 == [self.viewModel.browserService stringByEvaluatingJavaScriptFromString:@""].intValue) {
            
        }
        else if (0 != [self.viewModel.browserService stringByEvaluatingJavaScriptFromString:isNeedShareJS].intValue) {
            
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
            // 添加分享按钮...
        }
        // 设置了右侧按钮文本 && 最顶层的页面
        else if (self.viewModel.browserConfig.rightItemTitle.length > 0 && self.viewModel.wkWebView.canGoBack == NO) {
            [self setNavRightButton:self.viewModel.browserConfig.rightItemTitle imageName:nil];
        }
        else{
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
        }
    }
    else if (self.viewModel.browserConfig.isShareByFullAttribute) {
        
        // 添加分享按钮
    }
}

/**
 *  @brief   设置导航栏右侧 items
 */
- (void)setNavRightButton:(NSString *)title imageName:(NSString *)imageName
{
    [BrowserNavi sharedInstance].naviBarRightItemsBlock( self,
                                                         title,
                                                         imageName,
                                                         @selector( tapNavRightButton: ));
}

/**
 *  @brief   刷新 tabbar 隐藏状态
 */
- (void)refreshTabbar
{
    if (!self.viewModel.browserConfig.isTopLevelVC) {
        return;
    }
    
    BOOL isHide = ![self.viewModel isTopVCAndShop];
    
    [UIView animateWithDuration:0.15 animations:^{
        
        CGRect rect = self.tabBarController.tabBar.frame;
        
        self.tabBarController.tabBar.frame = CGRectMake(0, isHide ? SCREEN_HEIGHT : SCREEN_HEIGHT - CGRectGetHeight(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
        
        CGRect viewRect = self.view.frame;
        self.view.frame = CGRectMake(viewRect.origin.x, viewRect.origin.y, viewRect.size.width, isHide ? SCREEN_HEIGHT:SCREEN_HEIGHT- CGRectGetHeight(rect));
    }];
}


#pragma mark - ErrorPage Touch Action
/// 失败后点击刷新
- (IBAction)failRefresh:(id)sender
{
    BOOL isExistenceNetwork = NO;
    
    if (!isExistenceNetwork) {
        return;
    }
    
    [self.errorBgView setHidden:YES];
    [self.viewModel.loadRequestCommand execute:nil];
}

/// 失败页面返回按钮
- (IBAction)failBack:(UIButton *)sender
{
    [self.errorBgView setHidden:YES];
    
    [self backPage];
}


#pragma mark - SEL Method
/// 关闭网页
- (void)closeBrowser
{
    [self.viewModel.closeBrowserCommand execute:self];
}

/// 返回
- (void)backPage
{
    _isTapBack = YES;
    
    // 用户自定义拦截操作
    if ([self.viewModel.delegate respondsToSelector:@selector(beforeBackPage)]) {
        
        if (![self.viewModel.delegate performSelector:@selector(beforeBackPage)]) {
            return;
        }
    }
    
    [self.viewModel backPage:self isExitBrowser:self.viewModel.browserConfig.isDirectExit];
}

/// 导航栏右侧 items 被点击
- (void)tapNavRightButton:(id)object
{
    if ([self.viewModel.delegate respondsToSelector:@selector(tapNavRightButton:destVc:)]) {
        [self.viewModel.delegate tapNavRightButton:object destVc:self];
    }
    
    [self.viewModel.tapNaviRightCommand execute:self];
}

- (void)back
{
    [self backPage];
}


#pragma mark - WKNavigationDelegate
/// 准备加载页面
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    
}

/// 内容开始加载
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

/// 判断链接是否允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    __block BOOL retFlag = YES;
    
    NSString * urlString = [[navigationAction.request.URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([urlString hasPrefix:@"objc://"] && !_isBacking) {
        
        NSUInteger prefixLength = @"objc://".length;
        NSRange range = NSMakeRange(prefixLength, urlString.length - prefixLength);
        NSString * subString = [urlString substringWithRange:range];
        
        
        if (subString.length > 0) {
            
            NSString * functionString = subString;
            NSString * paramString = nil;
            NSRange range = [subString rangeOfString:@"/"];
            
            if (NSNotFound != range.location) {
                functionString = [subString substringWithRange:NSMakeRange(0, range.location)];
                paramString = [subString substringWithRange:NSMakeRange(range.location + 1, subString.length - range.location - 1)];
            }
            
            BrowserJS * data = [self.viewModel.browserService findJSData:functionString];
            if (nil != data) {
                if (nil != paramString) {
                    data.jsData.param = paramString;
                }
                else
                {
                    data.jsData.param = nil;
                }
            }
            
            decisionHandler(WKNavigationActionPolicyCancel);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                retFlag = [self.viewModel.browserService performJSCallBackByData:data
                                                                          target:self.viewModel.delegate];
                
                if (YES == retFlag) {
                    [self.viewModel.endRequestCommand execute:nil];
                }
            });
            
            return;
        }
    }
    else if ([urlString containsString:@"alipay://"]) {
        
        // urlString = alipay://alipayclient/?{"dataString":"h5_route_token=\"411434159e3c2791a9867f620a583c31\"&is_h5_route=\"true\"","requestType":"SafePay","fromAppUrlScheme":"alipays"}
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
        retFlag = NO;
    }
    else if ([navigationAction.request.URL.scheme isEqualToString:@"tel"]
             || [urlString containsString:@"ituns.apple.com"]) {
        
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            retFlag = NO;
        }
    }
    else
    {
        
    }
    
    if (self.viewModel.loadBlock) {
        retFlag = self.viewModel.loadBlock(self, urlString);
    }
    
    decisionHandler(retFlag ?  WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

/// 响应后决定是否允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    // 在收到响应后，决定是否跳转和发送请求之前那个允许配套使用
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/// 页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (_isBacking)
    {
        return;
    }
    
    [self.viewModel.endRequestCommand execute:nil];
    
    [self refreshNaviBarTitle];
    [self refreshNaviBarLeftItems];
    [self setNaviRightButton];
    
    if ([self.viewModel.delegate respondsToSelector:@selector(browser:didFinishRequest:)]) {
        [self.viewModel.delegate performSelector:@selector(browser:didFinishRequest:)
                                      withObject:self withObject:@"success"];
    }
    
    [self refreshTabbar];
    
    [self.viewModel.browserService insertBaseJsFun];
    [self.viewModel.browserService insertUserJsFun];
}

/// 加载错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"FAIL");
}

/// 请求失败
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // 如果load一个url还没结束就立即load另一个url，那么就会callback didFailLoadWithError method，error code is -999
    // V3.5 开发出现 errorCode = - 1004，且不在当前界面时，调用出错
    if ([error code] != NSURLErrorCancelled && !_isBacking) {
        
        [self.viewModel.endRequestCommand execute:nil];
        self.errorBgView.hidden = NO;
    }
}


#pragma mark - UIDelegate
/**
 *  @brief   Alert
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                      message:message?:@""
                                                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ensureAction = [UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              completionHandler();
                                                          }];
    
    [alertVC addAction:ensureAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/**
 *  @brief   comfirm   确认返回YES， 取消返回NO
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"提示"
                                                                      message:message?:@""
                                                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              completionHandler(NO);
                                                          }];
    UIAlertAction * ensureAction = [UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              completionHandler(YES);
                                                          }];
    
    [alertVC addAction:cancelAction];
    [alertVC addAction:ensureAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/**
 *  @brief   prompt   默认需要有一个输入框一个按钮，点击确认按钮回传输入值
 *  @param   completionHandler   只有一个参数，如果有多个输入框，需要将多个输入框中的值通过某种方式拼接成一个字符串回传
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:prompt
                                                                      message:@""
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    
    UIAlertAction * ensureAction = [UIAlertAction actionWithTitle:@"完成"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              completionHandler(alertVC.textFields[0].text?:@"");
                                                          }];
    
    [alertVC addAction:ensureAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
