//
//  CPExposureItem.m
//  CPExposure
//
//  Created by PersianCat on 2017/10/29.
//

#import "CPExposureItem.h"

@interface CPExposureItem()

@end

@implementation CPExposureItem

- (void)exposureCallback {
    if (self.view.window == nil ||
        self.view.hidden ||
        self.view.alpha < 0.01 ||
        self.view.superview == nil ||
        [UIApplication sharedApplication].applicationState!=UIApplicationStateActive) {
        self.trackState = ExposureItemTrackStateIdle;
        
        return;
    }
    
    self.trackState = ExposureItemTrackStateTracked;
    
    if (self.callback != nil) {
        self.callback();
    }
    
    if (self.callbackWithTag != nil) {
        self.callbackWithTag(self.tag);
    }
}

- (void)startTracking {
    [self stopTracking];
    
    self.trackState = ExposureItemTrackStateTracking;
    
    [self performSelector:@selector(exposureCallback)
               withObject:nil
               afterDelay:self.thresholdOfExposureTime
                  inModes:@[NSRunLoopCommonModes]];
}

- (void)stopTracking {
    self.trackState = ExposureItemTrackStateIdle;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(exposureCallback)
                                               object:nil];
}

@end
