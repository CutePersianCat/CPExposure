//
//  UIView+CPExposure.m
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import "UIView+CPExposure.h"
#import "CPExposureEventTracker.h"

@implementation CPExposureArea

@end

@implementation UIView (CPExposure)

- (void)registerExposureAreaWithValidScreenFrame:(CGRect)screenFrame
                                   thresholdTime:(NSTimeInterval)time
                                        callback:(void(^)(void))callback {
    CPExposureArea *area = [[CPExposureArea alloc] init];
    area.frame = CGRectZero;
    area.tag = 0;
    
    [self registerExposureAreas:@[area]
           withValidScreenFrame:screenFrame
                  thresholdTime:time
                       callback:callback
                callbackWithTag:nil];
}

- (void)registerExposureAreas:(NSArray <CPExposureArea *> *)areas
         withValidScreenFrame:(CGRect)screenFrame
                thresholdTime:(NSTimeInterval)time
                     callback:(void(^)(NSInteger tag))callback {
    [self registerExposureAreas:areas
           withValidScreenFrame:screenFrame
                  thresholdTime:time
                       callback:nil
                callbackWithTag:callback];
}

- (void)registerExposureAreas:(NSArray <CPExposureArea *> *)areas
         withValidScreenFrame:(CGRect)screenFrame
                thresholdTime:(NSTimeInterval)time
                     callback:(void(^)(void))callback
              callbackWithTag:(void(^)(NSInteger tag))callbackWithTag {
    // 需要移除之前被添加
    [[CPExposureEventTracker defaultTracker] removeExposureItemsInView:self];
    
    // 把所有的父视图的scrollview找出来
    NSMutableArray *scrollViews = [NSMutableArray array];
    UIView *superView = self.superview;
    while (superView != nil) {
        if ([superView isKindOfClass:[UIScrollView class]]) {
            [scrollViews addObject:superView];
        }
        
        superView = superView.superview;
    }
    
    // 如果页面层级中没有scrollview，无效的曝光实现，取消这次注册
    if (scrollViews.count == 0) {
        return;
    }
    
    // 找出最近的viewcontroller，通过响应者链的方式
    UIViewController *viewController = nil;
    UIResponder *nextResponder = self.nextResponder;
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            viewController = (UIViewController *)nextResponder;
            break;
        }
        
        nextResponder = nextResponder.nextResponder;
    }
    
    // 如果视图控制器没有显示，那么也取消这次注册
    BOOL isViewControllerVisible = [viewController isViewLoaded] && viewController.view.window!=nil;
    if (!isViewControllerVisible) {
        return;
    }
    
    for (CPExposureArea *area in areas) {
        CPExposureItem *item = [[CPExposureItem alloc] init];
        item.view = self;
        item.screenFrame = screenFrame;
        item.frame = area.frame;
        item.tag = area.tag;
        item.scrollViews = scrollViews;
        item.viewController = viewController;
        item.callback = callback;
        item.callbackWithTag = callbackWithTag;
        item.thresholdOfExposureTime = time;
        
        [[CPExposureEventTracker defaultTracker] addExposureItems:@[item]];
    }
}



@end
