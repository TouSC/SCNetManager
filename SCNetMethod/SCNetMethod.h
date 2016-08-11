//
//  SCNetMethod.h
//  
//
//  Created by user on 15/4/20.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNetWorking.h"

@interface SCNetMethod : NSObject

+ (SCNetMethod*)shareInstance;
- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType ParaNameArr:(NSArray*)paraNameArr ParaValue:(NSString*)paraValue,...;

@end
