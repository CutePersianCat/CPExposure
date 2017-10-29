//
//  CPExposureEventTracker.m
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import "CPExposureEventTracker.h"
#import "UIViewController+CPExposureEventTracker.h"
#import "UIScrollView+CPExposureEventTracker.h"
#import "UIViewController+CPExposure.h"

@interface CPExposureEventTracker()

@property (nonatomic, strong) NSMutableArray *allExposureItems;

/**
 exposureItemsInScreen, scrollViewsInScreen 当前显示的视图控制器中的信息，InScreen不是代表
 显示在屏幕上，只是表示这些内容对应的视图控制器当前是显示中的。
 
 添加时机: addExposureItems, becomeActive, didAppear
 删除时机: becomeInactive, didDisappear
 */
@property (nonatomic, strong) NSMutableArray *exposureItemsInScreen;
@property (nonatomic, strong) NSMutableArray *scrollViewsInScreen;

@end

@implementation CPExposureEventTracker

+ (instancetype)defaultTracker {
    static CPExposureEventTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CPExposureEventTracker alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _allExposureItems = [NSMutableArray array];
        
        _exposureItemsInScreen = [NSMutableArray array];
        _scrollViewsInScreen = [NSMutableArray array];
    }
    
    return self;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    for (CPExposureItem *item in self.exposureItemsInScreen) {
        if (item.view.window == nil) {
            continue;
        }
        
        if (item.frame.size.width==0 || item.frame.size.height==0) {
            item.frame = item.view.bounds;
        }
        CGRect rect = [item.view convertRect:item.frame toView:item.view.window];
        CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        if (CGRectContainsPoint(UIScreen.mainScreen.bounds, center)) {
            [item startTracking];
        } else {
            [item stopTracking];
        }
    }
    
    UIViewController *topViewController = [self topViewController];
    if (topViewController.exposureCallback != nil) {
        topViewController.showTime = [NSDate date];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    for (CPExposureItem *item in self.allExposureItems) {
        [item stopTracking];
    }
    
    UIViewController *topViewController = [self topViewController];
    if (topViewController.exposureCallback != nil && topViewController.showTime!=nil) {
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:topViewController.showTime];
        topViewController.exposureCallback(duration);
    }
}

- (void)addExposureItems:(NSArray <CPExposureItem *> *)items {
    // 添加应用切换到前后台的通知
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    });
    
    for (CPExposureItem *item in items) {
        [self.allExposureItems addObject:item];
        [self.exposureItemsInScreen addObject:item];
        
        for (UIScrollView *scrollView in item.scrollViews) {
            if (![self.scrollViewsInScreen containsObject:scrollView]) {
                [scrollView CP_addScrollViewContentChangeObserver:self];
                [self.scrollViewsInScreen addObject:scrollView];
            }
            
            [self checkScrollView:scrollView];
        }
    }
}

- (void)removeExposureItemsInView:(UIView *)view {
    NSMutableIndexSet *indexSetToRemove = [NSMutableIndexSet indexSet];
    for (NSInteger index=0; index<self.allExposureItems.count; index++) {
        CPExposureItem *item = self.allExposureItems[index];
        if (item.view == view) {
            [item stopTracking];
            [indexSetToRemove addIndex:index];
        }
    }
    [self.allExposureItems removeObjectsAtIndexes:indexSetToRemove];
    
    [indexSetToRemove removeAllIndexes];
    for (NSInteger index=0; index<self.exposureItemsInScreen.count; index++) {
        CPExposureItem *item = self.exposureItemsInScreen[index];
        if (item.view == view) {
            [item stopTracking];
            [indexSetToRemove addIndex:index];
        }
    }
    [self.exposureItemsInScreen removeObjectsAtIndexes:indexSetToRemove];
}

- (void)viewDidAppear:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]] ||
        [viewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    NSMutableIndexSet *indexSetToRemove = [NSMutableIndexSet indexSet];
    for (NSInteger index=0; index<self.allExposureItems.count; index++) {
        CPExposureItem *item = self.allExposureItems[index];
        if (item.viewController == viewController) {
            [self.exposureItemsInScreen addObject:item];
            
            if (item.frame.size.width==0 || item.frame.size.height==0) {
                item.frame = item.view.bounds;
            }
            CGRect rect = [item.view convertRect:item.frame toView:item.view.window];
            CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
            if (CGRectContainsPoint(UIScreen.mainScreen.bounds, center)) {
                [item startTracking];
            } else {
                [item stopTracking];
            }
            
            for (UIScrollView *scrollView in item.scrollViews) {
                if (![self.scrollViewsInScreen containsObject:scrollView]) {
                    [self.scrollViewsInScreen addObject:scrollView];
                    [scrollView CP_addScrollViewContentChangeObserver:self];
                }
            }
        } else if (item.view==nil || item.viewController==nil) { // 表示页面销毁了
            [item stopTracking];
            [indexSetToRemove addIndex:index];
        }
    }
    [self.allExposureItems removeObjectsAtIndexes:indexSetToRemove];
    
    [indexSetToRemove removeAllIndexes];
    for (NSInteger index=0; index<self.scrollViewsInScreen.count; index++) {
        UIScrollView *scrollView = self.scrollViewsInScreen[index];
        if (scrollView.window == nil) {
            [indexSetToRemove addIndex:index];
        }
    }
    [self.scrollViewsInScreen removeObjectsAtIndexes:indexSetToRemove];
}

- (void)viewDidDisappear:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]] ||
        [viewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    NSMutableIndexSet *indexSetToRemove = [NSMutableIndexSet indexSet];
    for (NSInteger index=0; index<self.exposureItemsInScreen.count; index++) {
        CPExposureItem *item = self.exposureItemsInScreen[index];
        BOOL isViewControllerVisible = [item.viewController isViewLoaded] && item.viewController.view.window!=nil;
        if (item.view==nil || !isViewControllerVisible) {
            [item stopTracking];
            [indexSetToRemove addIndex:index];
        }
    }
    [self.exposureItemsInScreen removeObjectsAtIndexes:indexSetToRemove];
    
    [indexSetToRemove removeAllIndexes];
    for (NSInteger index=0; index<self.scrollViewsInScreen.count; index++) {
        UIScrollView *scrollView = self.scrollViewsInScreen[index];
        if (scrollView.window == nil) {
            [indexSetToRemove addIndex:index];
        }
    }
    [self.scrollViewsInScreen removeObjectsAtIndexes:indexSetToRemove];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
ofObject:(id)object
change:(NSDictionary<NSKeyValueChangeKey,id> *)change
context:(void *)context {
    if (![keyPath isEqualToString:@"contentOffset"] && ![keyPath isEqualToString:@"contentSize"]) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        
        return;
    }
    
    [self checkScrollView:(UIScrollView *)object];
}

- (void)checkScrollView:(UIScrollView *)scrollView {
    for (CPExposureItem *item in self.exposureItemsInScreen) {
        if ([item.scrollViews containsObject:scrollView]) {
            if (item.frame.size.width==0 || item.frame.size.height==0) {
                item.frame = item.view.bounds;
            }
            CGRect rect = [item.view convertRect:item.frame toView:item.view.window];
            CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
            if (CGRectContainsPoint(item.screenFrame, center)) {
                if (item.trackState == ExposureItemTrackStateIdle) {
                    [item startTracking];
                }
            } else {
                [item stopTracking];
            }
        }
    }
}

#pragma mark - TopMostViewController

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)viewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navContObj = (UINavigationController*)viewController;
        return [self topViewControllerWithRootViewController:navContObj.visibleViewController];
    } else if (viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed) {
        UIViewController* presentedViewController = viewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        for (UIView *view in [viewController.view subviews]) {
            id subViewController = [view nextResponder];
            if (subViewController && [subViewController isKindOfClass:[UIViewController class]]) {
                if ([(UIViewController *)subViewController presentedViewController]  && ![subViewController presentedViewController].isBeingDismissed) {
                    return [self topViewControllerWithRootViewController:[(UIViewController *)subViewController presentedViewController]];
                }
            }
        }
        
        return viewController;
    }
}

@end


