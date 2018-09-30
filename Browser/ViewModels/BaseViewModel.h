//  viewModel 基类
//
//  BaseViewModel.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface BaseViewModel : NSObject

- (instancetype)initWithParams:(NSDictionary *)params;

@property (nonatomic, readonly, strong) NSDictionary * params;

@property (nonatomic, readonly, strong) RACSubject * errors;  // 所有产生的 error
@property (nonatomic, readonly, strong) RACSubject * willDisappearSignal; // 页面即将隐藏

- (void)initialize;

@end
