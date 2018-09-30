//
//  BrowserConfig.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>

@interface BrowserConfig : NSObject

/****     界面显示配置    ****/
@property (assign, nonatomic) BOOL isPush;            // 默认为 yes
@property (assign, nonatomic) BOOL isTopLevelVC;      // 是否为顶层 vc（顶层 vc 是不能pop）。默认为 no
@property (assign, nonatomic) BOOL isCustomTitleBar;  // 是否自定义标题栏。默认为 no
@property (assign, nonatomic) BOOL isHideTitleBar;    // 是否隐藏标题栏。默认为 no
@property (assign, nonatomic) BOOL isGetWebPageTitle; // 是否获取 web 页面的标题。默认为 yes
@property (assign, nonatomic) BOOL isNeedShareBtn;    // 是否由 html 内容决定怎样显示右导航按钮。默认为 yes
@property (strong, nonatomic) NSString * rightItemTitle;   // 导航栏右侧标题。默认为 nil
@property (assign, nonatomic) BOOL isShareByFullAttribute; // 是否由 html 提供完整的分享属性。默认为 no
@property (assign, nonatomic) BOOL isForceRefreshTabbar;   // 解决商城底部tabbar隐藏相关问题。场景：商城跳IM,tabbar显示，回退后tabbar是显示的。
@property (assign, nonatomic) BOOL isCYShop;               // v4.0 慈云商城首页导航栏添加客服、订单按钮。默认为 no

/****     服务配置    ****/
@property (assign, nonatomic) BOOL isShop;            // 是否支持商城特殊的跳转处理。默认为 no
@property (assign, nonatomic) BOOL isSlideBack;       // 是否侧滑返回。默认为 yes
@property (assign, nonatomic) BOOL isDirectExit;      // yes-直接退出；no-默认按层级返回
@property (assign, nonatomic) BOOL isNeedPopSequenceBrowser;  // yes-是否需要移除栈顶连续的browser
@property (strong, nonatomic) NSString * backTips; // 用户判断退出评测时是否弹出返回提示
@property (assign, nonatomic) int hidSuvFlag;   // 评测中途退出时，给出不同提示：0 - 普通评测   1 -  中新惠尔评测
@property (assign, nonatomic) BOOL isReceivePE ;// 健康卡里面，激活体检套餐成功后标志。要求返回时，直接跳到健康卡
@property (assign, nonatomic) BOOL isFixedHomeItem; // 固定首页页面的标题栏按钮，其他页面根据页面信息自行设置


/****     界面操作     ****/
@property (nonatomic) SEL tempJumpSelector;     // 登录拦截

@end
