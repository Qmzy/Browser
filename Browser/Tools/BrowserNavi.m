//
//  BrowserNavi.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BrowserNavi.h"
#import <UIKit/UIKit.h>

#define H     44.0
#define B1W   40.0
#define B2W   40.0

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation BrowserNavi

static BrowserNavi * instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


#pragma mark - Left

- (void (^)(BOOL, UIViewController *, BOOL, SEL, SEL))naviBarLeftItemsBlock
{
    if (_naviBarLeftItemsBlock == nil) {
        
        _naviBarLeftItemsBlock = ^ (BOOL isNeedItems, UIViewController * vc, BOOL isTapBack, SEL backSEL, SEL closeSEL) {
            
            if (isNeedItems) {
                
                UIView * bgView = [[UIView alloc] init];
                
                UIButton * btn1 = [BrowserNavi getCommonButton:CGRectMake(0, 0, B1W, H)
                                                         title:nil
                                                     imageName:@"back"
                                                        target:vc
                                                      selector:backSEL];
                //btn1.titleEdgeInsets = UIEdgeInsetsMake(0.0, 2.0, 0.0, 0.0);
                btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [bgView addSubview:btn1];
                
                if (isTapBack) {
                    
                    [btn1 setTitle:@"返回" forState:UIControlStateNormal];
                    CGFloat w = [BrowserNavi calculateTextWidth:@"返回"
                                                         height:20
                                                           font:[UIFont systemFontOfSize:15]];
                    w = MAX(40, w + 22);
                    btn1.frame = CGRectMake(0, 0, w, H);
                    
                    UIButton * btn2 = [BrowserNavi getCommonButton:CGRectMake(w + 10, 0, B2W, H)
                                                             title:@"关闭"
                                                         imageName:nil
                                                            target:vc
                                                          selector:closeSEL];
                    btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [bgView addSubview:btn2];
                    
                    bgView.frame = CGRectMake(0, 0, w + 10 + B2W, H);
                }
                else{
                    bgView.frame = CGRectMake(0, 0, B1W, H);
                }
                
                UIBarButtonItem * btn_right = [[UIBarButtonItem alloc] initWithCustomView:bgView];
                
                [vc.navigationController.navigationItem setHidesBackButton:YES]; // 隐藏自带的返回按钮
                vc.navigationItem.hidesBackButton = YES;
                vc.navigationItem.leftBarButtonItems = @[btn_right];
            }
            else {
                vc.navigationItem.leftBarButtonItems = nil;
            }
            
            [vc.navigationController.navigationBar setNeedsLayout];
        };
    }
    
    return _naviBarLeftItemsBlock;
}

- (void (^)(UIViewController *, SEL))leftItemsBlock
{
    if (_leftItemsBlock == nil) {
        
        _leftItemsBlock = ^ (UIViewController * vc, SEL backSEL) {
            
            CGRect frame = CGRectMake( 10, 2, 40, 40);
            
            UIButton * backBtn = [BrowserNavi getCommonButton:frame
                                                        title:nil
                                                    imageName:@"back-white"
                                                       target:vc
                                                     selector:backSEL];
            backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            [vc.view addSubview:backBtn];
            [vc.view bringSubviewToFront:backBtn];
        };
    }
    return _leftItemsBlock;
}


#pragma mark - Right

- (void (^)(UIViewController *, NSString *, NSString *, SEL))naviBarRightItemsBlock
{
    if (_naviBarRightItemsBlock == nil) {
        
        _naviBarRightItemsBlock = ^(UIViewController * vc, NSString * title, NSString * imageName, SEL tapSEL) {
            
            UIBarButtonItem * shareBtn = nil;
            
            if (title.length > 0) {
                
                CGFloat w = [BrowserNavi calculateTextWidth:title
                                                     height:H
                                                       font:[UIFont systemFontOfSize:15]] + 10;
                
                UIButton * btn = [BrowserNavi getCommonButton:CGRectMake(0, 0, w, H)
                                                        title:title
                                                    imageName:nil
                                                       target:vc
                                                     selector:tapSEL];
                btn.titleLabel.font = [UIFont systemFontOfSize:15];
                btn.titleLabel.textAlignment = NSTextAlignmentRight;
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                shareBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
            }
            else if(imageName.length > 0){
                
                UIButton * btn = [BrowserNavi getCommonButton:CGRectMake(0, 0, 40, H)
                                                        title:nil
                                                    imageName:imageName
                                                       target:vc
                                                     selector:tapSEL];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                shareBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
            }
            
            if (shareBtn) {
                
                vc.navigationItem.rightBarButtonItem = nil;
                vc.navigationItem.rightBarButtonItems = nil;
                vc.navigationItem.rightBarButtonItems = @[shareBtn];
            }
            [vc.navigationController.navigationBar setNeedsLayout];
        };
    }
    return _naviBarRightItemsBlock;
}

/// 创建通用按钮
+ (UIButton *)getCommonButton:(CGRect)frame title:(NSString *)title imageName:(NSString *)imageName target:(id)target selector:(SEL)sel
{
    UIButton * button = [[UIButton alloc] initWithFrame:frame];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTintColor:UIColorFromRGB(0x666666)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

/**
  *  固定宽度，计算文字的长度
  */
+ (CGFloat)calculateTextHeight:(NSString *)content width:(CGFloat)width font:(UIFont *)font
{
    CGRect rect = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName : font}
                                        context:nil];
    
    return rect.size.height + 1;  // 系统计算时未加入行之间的间隙，所以+1多增加一行
}

/**
  *  固定长度，计算文字的宽度
  */
+ (CGFloat)calculateTextWidth:(NSString *)content height:(CGFloat)height font:(UIFont *)font
{
    CGRect rect = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName : font}
                                        context:nil];
    
    return rect.size.width;
}

@end
