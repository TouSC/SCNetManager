//
//  SCNetResult.h
//  XStudio
//
//  Created by Tousan on 15/12/16.
//  Copyright (c) 2015年 Tousan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNetWorkingConfig.h"

@interface SCNetResult : NSObject

@property(nonatomic,strong)NSDictionary *dictionary;
@property(nonatomic,assign)BOOL isLegal;

@property(nonatomic,strong)NSArray *stateList;
@property(nonatomic,assign)NSInteger stateCode;
@property(nonatomic,strong)NSString *stateMessage;
@property(nonatomic,strong)NSString *methodName;
@property(nonatomic,strong)NSDictionary *data_Dic;
@property(nonatomic,strong)NSArray *data_Arr;
@property(nonatomic,strong)NSString *data_Str;

- (id)initWithDictionary:(NSDictionary *)otherDictionary MethodName:(NSString *)methodName;

@end
