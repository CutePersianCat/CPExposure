//
//  CPExposureDefine.h
//  Pods
//
//  Created by PersianCat on 2017/10/29.
//

#ifndef CPExposureDefine_h
#define CPExposureDefine_h


#define SwizzleMethod(class, originalSelector, swizzledSelector)            \
do {                                                                          \
    Method originalMethod = class_getInstanceMethod(class, originalSelector); \
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector); \
                                                                                \
    BOOL didAddMethod = class_addMethod(class,                                  \
                                        originalSelector,                       \
                                        method_getImplementation(swizzledMethod),\
                                        method_getTypeEncoding(swizzledMethod));\
    if (didAddMethod) {                                                          \
        class_replaceMethod(class,                                              \
                            swizzledSelector,                                   \
                            method_getImplementation(originalMethod),            \
                            method_getTypeEncoding(originalMethod));            \
    } else {                                                                     \
        method_exchangeImplementations(originalMethod, swizzledMethod);            \
    }                                                                               \
} while(0)

#endif /* CPExposureDefine_h */
