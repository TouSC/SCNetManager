//
//  SCNetResult.m
//  
//
//  Created by Tousan on 15/12/16.
//  Copyright (c) 2015年 Tousan. All rights reserved.
//

#import "SCNetWorkingResult.h"

@implementation SCNetWorkingResult

- (id)initWithDictionary:(NSDictionary *)otherDictionary MethodName:(NSString *)methodName;
{
    self = [super init];
    if (self)
    {
        if ([otherDictionary isKindOfClass:[NSDictionary class]])
        {
            _dictionary = otherDictionary;
            if ([[otherDictionary[@"StateList"] firstObject][@"StateCode"] isEqualToNumber:@1001])
            {
                _isLegal = YES;
            }
        }
    }
    return self;
}

- (NSArray*)stateList;
{
    if ([_dictionary isKindOfClass:[NSDictionary class]])
    {
        return [(NSDictionary*)_dictionary objectForKey:@"StateList"];
    }
    else
    {
        return @[@{@"StateCode":@(-1000),
                   @"StateMsg":@"系统错误"}];
    }
}

- (NSInteger)stateCode;
{
    NSArray *stateList = [self stateList];
    return [[[stateList lastObject] objectForKey:@"StateCode"] integerValue];
}

- (NSString*)stateMessage;
{
    NSArray *stateList = [self stateList];
    return [[stateList lastObject] objectForKey:@"StateMsg"];
}

- (NSDictionary*)data_Dic;
{
    return [self getWithExpectClass:[NSDictionary class]];
}

- (NSArray*)data_Arr
{
    return [self getWithExpectClass:[NSArray class]];
}

- (NSArray*)data_Str;
{
    return [self getWithExpectClass:[NSString class]];
}

- (id)getWithExpectClass:(Class)class;
{
    id data = [_dictionary objectForKey:@"ResultData"];
    if ([data isKindOfClass:class])
    {
        return data;
    }
    else
    {
#ifdef NET_DEBUG_MODE
        NSLog(@"success but wrong format %ld--%@--%@",(long)self.stateCode,self.stateMessage,_methodName);
#endif
        if (class==[NSDictionary class])
            return @{};
        else if (class==[NSArray class])
            return @[];
        else if (class==[NSString class])
            return @"";
        else
            return nil;
    }
}

@end
