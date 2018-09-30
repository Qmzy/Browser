//
//  BrowserJSString.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserJSString.h"

NSString * jsStringWithOCString(NSString * js, NSString * param)
{
    return [NSString stringWithFormat:js, param];
}

NSString * jsStringWithBaseValue(NSString * js, NSInteger param)
{
    return [NSString stringWithFormat:js, param];
}
