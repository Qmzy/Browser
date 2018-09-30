//
//  BrowserNavi.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>

@class UIViewController;
@interface BrowserNavi : NSObject

/**
  *  @brief   有导航栏时，设置导航栏左侧 items
  *
  *  @param   isNeedItems   是否需要创建左侧导航项
  *  @param   vc   视图控制器
  *  @param   isTapBack   是否点击过返回按钮
  *  @param   backSEL   返回方法
  *  @param   closeSEL   关闭方法
  */
@property (nonatomic, assign) void (^ naviBarLeftItemsBlock)(BOOL isNeedItems, UIViewController * vc, BOOL isTapBack, SEL backSEL, SEL closeSEL);

/**
  *  @brief   无导航栏时，设置左侧 items
  */
@property (nonatomic, assign) void (^ leftItemsBlock) (UIViewController * vc, SEL backSEL);

/**
  *  @brief   有导航栏时，设置导航栏右侧 items
  *
  *  @param   vc   视图控制器
  *  @param   title   标题。标题优先于图片
  *  @param   imageName   图片
  *  @param   tapSEL    点击方法
  */
@property (nonatomic, assign) void (^ naviBarRightItemsBlock)(UIViewController * vc, NSString * title, NSString * imageName, SEL tapSEL);

+ (instancetype)sharedInstance;

@end
