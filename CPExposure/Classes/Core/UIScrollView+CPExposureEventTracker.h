//
//  UIScrollView+CPExposureEventTracker.h
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (CPExposureEventTracker)

- (void)CP_addScrollViewContentChangeObserver:(NSObject *)observer;

@end
