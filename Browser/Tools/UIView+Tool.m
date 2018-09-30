//
//  UIView+Tool.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.
//

#import "UIView+Tool.h"

@implementation UIView (Tool)

- (UIViewController *)firstVC
{
    for (UIView * next = self; next; next = next.superview) {
        UIResponder * nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
