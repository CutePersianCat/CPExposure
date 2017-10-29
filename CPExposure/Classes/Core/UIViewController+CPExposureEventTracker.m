//
//  UIViewController+CPExposureEventTracker.m
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import "UIViewController+CPExposureEventTracker.h"
#import <objc/runtime.h>
#import "CPExposureEventTracker.h"
#import "UIViewController+CPExposure.h"
#import "CPExposureDefine.h"

static void *kShowTimeObjectKey = &kShowTimeObjectKey;

@implementation UIViewController (CPExposureEventTracker)

+ (void)load {
    SwizzleMethod([self class], @selector(viewDidAppear:), @selector(CP_viewDidAppear:));
    SwizzleMethod([self class], @selector(viewDidDisappear:), @selector(CP_viewDidDisappear:));
}

- (void)CP_viewDidAppear:(BOOL)animated {
    [self CP_viewDidAppear:animated];
    
    if (self.exposureCallback != nil) {
        self.showTime = [NSDate date];
    }
    
    [[CPExposureEventTracker defaultTracker] viewDidAppear:self];
}

- (void)CP_viewDidDisappear:(BOOL)animated {
    [self CP_viewDidDisappear:animated];
    
    if (self.exposureCallback != nil && self.showTime!=nil) {
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.showTime];
        self.exposureCallback(duration);
    }
    
    [[CPExposureEventTracker defaultTracker] viewDidDisappear:self];
}

- (NSDate *)showTime {
    return objc_getAssociatedObject(self, kShowTimeObjectKey);
}

- (void)setShowTime:(NSDate *)showTime {
    objc_setAssociatedObject(self, kShowTimeObjectKey, showTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
