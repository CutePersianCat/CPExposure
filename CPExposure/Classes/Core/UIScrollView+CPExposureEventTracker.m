//
//  UIScrollView+CPExposureEventTracker.m
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import "UIScrollView+CPExposureEventTracker.h"
#import <objc/Runtime.h>
#import "CPExposureDefine.h"

static void *kScrollViewContentChangeObserverObjectKey = &kScrollViewContentChangeObserverObjectKey;

@implementation UIScrollView (CPExposureEventTracker)

+ (void)load {
    SwizzleMethod([self class], NSSelectorFromString(@"dealloc"), @selector(CP_dealloc));
}

- (NSObject *)CP_ScrollViewContentChangeObserver {
    return objc_getAssociatedObject(self, kScrollViewContentChangeObserverObjectKey);
}

- (void)CP_setScrollViewContentChangeObserver:(NSObject *)ScrollViewContentChangeObserver {
    objc_setAssociatedObject(self, kScrollViewContentChangeObserverObjectKey, ScrollViewContentChangeObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)CP_addScrollViewContentChangeObserver:(NSObject *)observer {
    if ([self CP_ScrollViewContentChangeObserver] != nil) {
        return;
    }
    
    [self addObserver:observer
           forKeyPath:@"contentOffset"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:nil];
    
    [self addObserver:observer
           forKeyPath:@"contentSize"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:nil];
    
    [self CP_setScrollViewContentChangeObserver:observer];
}

- (void)CP_removeScrollViewContentChangeObserver {
    NSObject *observer = [self CP_ScrollViewContentChangeObserver];
    if (observer == nil) {
        return;
    }
    
    [self removeObserver:observer
              forKeyPath:@"contentOffset"];
    [self removeObserver:observer
              forKeyPath:@"contentSize"];
    
    [self CP_setScrollViewContentChangeObserver:nil];
}

- (void)CP_dealloc {
    [self CP_removeScrollViewContentChangeObserver];
    
    [self CP_dealloc];
}


@end
