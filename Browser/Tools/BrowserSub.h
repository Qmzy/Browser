//
//  BrowserSub.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 设置子视图相对于 webView 的位置
typedef NS_ENUM(NSInteger, BrowserSubViewPosition) {
    
    BrowserSubViewOnTop = 1,  // 顶部
    BrowserSubViewOnLeft,     // 左侧
    BrowserSubViewOnRight,    // 右侧
    BrowserSubViewOnBottom,   // 底部
};


/**
  *  @brief   添加自定义子视图
  */
@class WKWebView;
@interface BrowserSub : NSObject

@property (nonatomic, strong) UIView * subView;
@property (nonatomic, assign) NSInteger subHeight;   // 自定义视图高度。默认 64
@property (nonatomic, assign) BrowserSubViewPosition position;  // 默认 Top

- (void)setConstraint:(WKWebView *)webView;

// isHideBar   需要根据是否有导航栏来设置约束，yes - 无导航栏  no - 有导航栏
+ (void)setConstraintWithNoSub:(WKWebView *)webView isHideBar:(BOOL)isHideBar;

@end
