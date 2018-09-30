//
//  BrowserHTML.h
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import <Foundation/Foundation.h>

@interface BrowserHTML : NSObject

/// iOS 9.0 以下读取本地文件方法和远程网址请求
+ (NSURLRequest *)webUrlRequest:(NSString *)webUrl;

/// iOS 9.0 以上读取本地文件方法
+ (NSURL *)fileURLForAllowingReadAccess:(NSString *)fileUrl;

@end
