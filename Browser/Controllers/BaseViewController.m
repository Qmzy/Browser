//
//  BaseViewController.m
//  Browser
//
//  Created by CYKJ on 2018/9/29.
//  Copyright © 2018年 D. All rights reserved.


#import "BaseViewController.h"

@interface BaseViewController ()
@property (nonatomic, readwrite, strong) BaseViewModel * viewModel;
@end


@implementation BaseViewController

- (void)dealloc
{
    NSLog(@"\n =========+++ %@  销毁了 +++======== \n", [self class]);
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    BaseViewController * vc = [super allocWithZone:zone];
    @weakify(vc)
    [[vc rac_signalForSelector:@selector(viewDidLoad)] subscribeNext:^(id x) {
         @strongify(vc)
         [vc bindViewModel];
     }];
    return vc;
}

- (instancetype)initWithViewModel:(BaseViewModel *)viewModel
{
    if (self = [super init]) {
        self.viewModel = viewModel;
    }
    return self;
}

- (instancetype)initWithViewModel:(BaseViewModel *)viewModel clsName:(NSString *)name
{
    self = [BaseViewController instanceFromStoryboard:NSClassFromString(name)];
    
    if (!self) {
        self = [super init];
    }
    
    if (self) {
        self.viewModel = viewModel;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.viewModel.willDisappearSignal sendNext:nil];
}

- (void)bindViewModel
{
    // 绑定错误信息
    [self.viewModel.errors subscribeNext:^(NSError *error) {
        NSLog(@"...错误...");
    }];
}


#pragma mark - Tool
/**
  *  @brief   从 storyboard 中生成当前 controller 的实例
  */
+ (nullable instancetype)instanceFromStoryboard:(Class)cls
{
    NSString * identifier = NSStringFromClass(cls);
    
    // 取缓存的 storyboard 名
    NSCache * cache = [self cache];
    
    NSString * cacheStoryboardName = [cache objectForKey:identifier];
    if (cacheStoryboardName) {
        return [self tryTakeOutInstanceFromStoryboardNamed:cacheStoryboardName identifier:identifier];
    }
    
    // 未缓存。遍历 storyboard 文件名列表，开始尝试取出实例。
    for (NSString * name in [self storyboardList:cls]) {
        BaseViewController * instance = [self tryTakeOutInstanceFromStoryboardNamed:name identifier:identifier];
        
        if (instance) {
            [cache setObject:name forKey:identifier];  // 缓存
            
            return instance;
        }
    }
    return nil;
}

+ (nullable instancetype)tryTakeOutInstanceFromStoryboardNamed:(nonnull NSString *)storyboardName identifier:(nonnull NSString *)identifier
{
    if (!storyboardName || !identifier) {
        return nil;
    }
    
    @try {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
        BaseViewController * vc = [sb instantiateViewControllerWithIdentifier:identifier];
        return vc;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

+ (NSCache *)cache
{
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (nonnull NSArray *)storyboardList:(Class)cls
{
    static NSArray *kBundleStoryboardNameList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *tmp = [NSMutableArray array];
        
        /**
         *  找到所有storyboard文件。
         *  @warning 会忽略带有 ~iphone(iPhone应用)或 ~ipad(ipad应用)标志的 storyboard文件名
         */
        NSBundle *bundle = [NSBundle bundleForClass:cls];
        NSArray *list = [NSBundle pathsForResourcesOfType:@"storyboardc" inDirectory:bundle.resourcePath];
        for (NSString *path in list) {
            NSString *ext = [path lastPathComponent];
            NSString *name = [ext stringByDeletingPathExtension];
            if ([name rangeOfString:@"~"].location == NSNotFound) {
                
                [tmp addObject:name];
            }
        }
        
        kBundleStoryboardNameList = [NSArray arrayWithArray:tmp];
    });
    return kBundleStoryboardNameList;
}


#pragma mark - Device
/**
  *  @brief   屏幕方向
  */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

/**
  *  @brief   状态栏
  */
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
