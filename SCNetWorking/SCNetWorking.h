//
//  SCNetMethod.h
//  
//
//  Created by user on 15/4/20.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "SCNetWorkingConfig.h"
#import "SCNetWorkingResult.h"
@class SCNetWorking;
typedef enum {
    SCNetURLEstate,
    SCNetURLMerchant,
    SCNetURLBackup
}SCNetURLType;

typedef id (^NetBlock)(void);
typedef void (^CompleteHandle)(id result);

@interface SCNetWorking : NSObject

+ (SCNetWorking*)shareInstance;
- (SCNetWorkingResult*)getDataWithMethodName:(NSString*)methodName URLtype:(SCNetURLType)urlType Timeout:(NSUInteger)timeout Sync:(BOOL)isSync Progress:(void(^)(NSURLSessionTask *task))progress Complete:(void(^)(SCNetWorkingResult *result,NSURLSessionTask *task))complete ParaNameArr:(NSArray*)paraNameArr ParaValue:(id)paraValue,... NS_REQUIRES_NIL_TERMINATION;

- (SCNetWorkingResult*)getDataWithMethodName:(NSString*)methodName URLtype:(SCNetURLType)urlType Timeout:(NSUInteger)timeout Sync:(BOOL)isSync Progress:(void(^)(NSURLSessionTask *task))progress Complete:(void(^)(SCNetWorkingResult *result,NSURLSessionTask *task))complete ParaArr:(NSArray*)paraArr;

@end
