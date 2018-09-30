//
//  BaseViewController.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <UIKit/UIKit.h>
#import "BaseViewModel.h"

@interface BaseViewController : UIViewController

@property (nonatomic, readonly, strong) BaseViewModel * viewModel;

/// 初始化方法
- (instancetype)initWithViewModel:(BaseViewModel *)viewModel;
- (instancetype)initWithViewModel:(BaseViewModel *)viewModel clsName:(NSString *)name;

/// 绑定数据模型
- (void)bindViewModel;

@end
