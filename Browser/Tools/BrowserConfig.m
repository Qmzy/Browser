//
//  BrowserConfig.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserConfig.h"

@implementation BrowserConfig

- (instancetype)init
{
    if (self = [super init]) {
        
        self.isSlideBack = YES;
        self.isNeedShareBtn = YES;
        self.isShareByFullAttribute = NO;
        self.isPush = YES;
        self.isTopLevelVC = NO;
        self.isGetWebPageTitle = YES;
        self.isHideTitleBar = NO;
        self.isCYShop = NO;
        self.isFixedHomeItem = NO;
    }
    return self;
}

@end
