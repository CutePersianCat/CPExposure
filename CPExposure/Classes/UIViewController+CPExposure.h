//
//  UIViewController+CPExposure.h
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CPExposure)

@property (nonatomic, copy) void (^exposureCallback)(NSTimeInterval duration);

@end
