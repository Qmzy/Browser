//
//  BrowserSub.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserSub.h"
#import "Masonry.h"
#import <WebKit/WebKit.h>


#define NAVIGATIONBAR_HEIGHT  ([BrowserSub naviBarHeight])

@implementation BrowserSub

- (instancetype)init
{
    if (self = [super init]) {
        self.subHeight = NAVIGATIONBAR_HEIGHT;
        self.position  = BrowserSubViewOnTop;
    }
    return self;
}

+ (CGFloat)naviBarHeight
{
    BOOL isIPoneX = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO);
   
    if (isIPoneX) {
        return 88.0;
    }
    return 64.0;
}


#pragma mark - With SubView
/**
  *  @brief   设置约束
  */
- (void)setConstraint:(WKWebView *)webView
{
    [self setConstraintForSub:webView];
    [self setConstraintForWeb:webView];
}

/**
  *  @brief   设置自定义视图约束
  */
- (void)setConstraintForSub:(WKWebView *)webView
{
    __block UIView * superView = webView.superview;
    
    __weak __typeof(self)weakSelf = self;
    [weakSelf.subView mas_makeConstraints:^(MASConstraintMaker * make) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        switch (strongSelf.position) {
            case BrowserSubViewOnTop:
            {
                make.top.equalTo(superView);
            }
                break;
                
            case BrowserSubViewOnBottom:
            {
                make.bottom.equalTo(superView);
            }
                break;
                
            default:
                break;
        }
        make.leading.equalTo(superView);
        make.trailing.equalTo(superView);
        make.height.equalTo(@(strongSelf.subHeight));
    }];
}

/**
  *  @brief   设置网页视图的约束
  */
- (void)setConstraintForWeb:(WKWebView *)webView
{
    __block UIView * superView = webView.superview;
    
    __weak __typeof(self)weakSelf = self;
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        switch (strongSelf.position) {
            case BrowserSubViewOnTop:
            {
                make.top.equalTo(strongSelf.subView).offset(strongSelf.subHeight);
                make.bottom.equalTo(superView);
            }
                break;
                
            case BrowserSubViewOnBottom:
            {
                make.top.equalTo(superView);
                make.bottom.equalTo(strongSelf.subView).offset(strongSelf.subHeight);
            }
                break;
                
            default:
                break;
        }
        make.leading.equalTo(superView);
        make.trailing.equalTo(superView);
    }];
}


#pragma mark - NO SubView
/**
  *  @brief   无自定义视图时的约束
  */
+ (void)setConstraintWithNoSub:(WKWebView *)webView isHideBar:(BOOL)isHideBar
{
    UIView * superView = webView.superview;
    
    if (isHideBar) {
        
        [webView mas_makeConstraints:^(MASConstraintMaker * make) {
            
            make.edges.equalTo(superView);
        }];
    }
    else {
        [webView mas_makeConstraints:^(MASConstraintMaker * make) {
            
            make.top.equalTo(@(NAVIGATIONBAR_HEIGHT));
            make.leading.equalTo(superView);
            make.trailing.equalTo(superView);
            make.bottom.equalTo(superView);
        }];
    }
}

@end
