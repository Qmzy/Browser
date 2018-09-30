//
//  BrowserHTML.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserHTML.h"

@implementation BrowserHTML

/**
  *  @brief   iOS 9.0 以下本地或远端
  */
+ (NSURLRequest *)webUrlRequest:(NSString *)webUrl;
{
    NSString * str = webUrl;
    
    // NEEDFIX #号不编码，只对|等符号编码，编码后再替换回#
    str = [str stringByReplacingOccurrencesOfString:@"#" withString:@","];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@"#"];
    
    str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:str];
    
    // 默认要对%等各种特殊字符进行编码，但是|在replace后会被还原，然后会导致url为空，所以重新添加编码
    if (url == nil) {
        str = [str stringByReplacingOccurrencesOfString:@"#" withString:@","];
        str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        str = [str stringByReplacingOccurrencesOfString:@"," withString:@"#"];
        url = [NSURL URLWithString:str];
    }
    
    return [NSURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                        timeoutInterval:60.0];
}


#pragma mark - Local
/**
  *  @brief   WKWebView 加载时的 allowingReadAccessToURL 参数需要是 html 所在的文件夹路径。 The second argument would be the directory the html lies in.
  */
+ (NSURL *)fileURLForAllowingReadAccess:(NSString *)fileUrl
{
    NSString * temp = fileUrl.stringByDeletingLastPathComponent;
    
    return [NSURL fileURLWithPath:temp isDirectory:YES];
}

@end
