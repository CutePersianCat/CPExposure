//
//  UIViewController+CPExposure.m
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import "UIViewController+CPExposure.h"
#import <objc/Runtime.h>

static void *kExposureCallbackObjectKey = &kExposureCallbackObjectKey;

@implementation UIViewController (CPExposure)

- (void (^)(NSTimeInterval duration))exposureCallback {
    return objc_getAssociatedObject(self, kExposureCallbackObjectKey);
}

- (void)setExposureCallback:(void (^)(NSTimeInterval duration))exposureCallback {
    objc_setAssociatedObject(self, kExposureCallbackObjectKey, exposureCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
