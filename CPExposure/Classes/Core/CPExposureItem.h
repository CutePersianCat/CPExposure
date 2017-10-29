//
//  CPExposureItem.h
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ExposureItemTrackState) {
    ExposureItemTrackStateIdle,
    ExposureItemTrackStateTracking,
    ExposureItemTrackStateTracked,
};

@interface CPExposureItem : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) CGRect screenFrame;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) NSTimeInterval thresholdOfExposureTime; //开始计算曝光的显示时间


#pragma mark - Internal

@property (nonatomic, assign) ExposureItemTrackState trackState; 
@property (nonatomic, strong) NSArray <UIScrollView *> *scrollViews;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) void (^callback)(void);
@property (nonatomic, strong) void (^callbackWithTag)(NSInteger tag);

- (void)startTracking;
- (void)stopTracking;

@end
