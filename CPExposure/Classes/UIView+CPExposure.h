//
//  UIView+CPExposure.h
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import <UIKit/UIKit.h>

/**
 View内的区域曝光使用
 */
@interface CPExposureArea : NSObject

/**
 曝光区域，是相对当前整个视图来说的，如tableCell是当前视图，需要统计cell里面的frame指定区域内曝光事件
 */
@property (nonatomic, assign) CGRect frame;

/**
 曝光区域，标记，用来在回调中识别是哪块区域的曝光
 */
@property (nonatomic, assign) NSInteger tag;

@end

@interface UIView (CPExposure)

- (void)registerExposureAreaWithValidScreenFrame:(CGRect)screenFrame
                                   thresholdTime:(NSTimeInterval)time
                                        callback:(void(^)(void))callback;

- (void)registerExposureAreas:(NSArray <CPExposureArea *> *)areas
         withValidScreenFrame:(CGRect)screenFrame
                thresholdTime:(NSTimeInterval)time
                     callback:(void(^)(NSInteger tag))callback;

@end
