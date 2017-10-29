//
//  CPExposureEventTracker.h
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import <Foundation/Foundation.h>
#import "CPExposureItem.h"

@interface CPExposureEventTracker : NSObject

+ (instancetype)defaultTracker;

- (void)addExposureItems:(NSArray <CPExposureItem *> *)items;

- (void)removeExposureItemsInView:(UIView *)view;

- (void)viewDidAppear:(UIViewController *)viewController;

- (void)viewDidDisappear:(UIViewController *)viewController;

@end
