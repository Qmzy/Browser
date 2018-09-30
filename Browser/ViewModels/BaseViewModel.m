//
//  BaseViewModel.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BaseViewModel.h"


@interface BaseViewModel ()

@property (nonatomic, readwrite, strong) NSDictionary * params;
@property (nonatomic, readwrite, strong) RACSubject * errors;
@property (nonatomic, readwrite, strong) RACSubject * willDisappearSignal;

@end


@implementation BaseViewModel

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    BaseViewModel * viewModel = [super allocWithZone:zone];
    @weakify(viewModel)
    [[viewModel rac_signalForSelector:@selector(initWithParams:)] subscribeNext:^(id x) {
        @strongify(viewModel)
        [viewModel initialize];
    }];
    return viewModel;
}

- (instancetype)initWithParams:(NSDictionary *)params
{
    if (self = [super init]) {
        self.params = params;
    }
    return self;
}

- (void)initialize
{
    // 子类实现
}


#pragma mark - GET

- (RACSubject *)errors
{
    if (_errors == nil)
        _errors = [RACSubject subject];
    return _errors;
}

- (RACSubject *)willDisappearSignal
{
    if (_willDisappearSignal == nil)
        _willDisappearSignal = [RACSubject subject];
    return _willDisappearSignal;
}

@end
