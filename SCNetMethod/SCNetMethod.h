//
//  SCNetMethod.h
//  SCMetroHarbour
//
//  Created by user on 15/4/20.
//  Copyright (c) 2015年 tousan. All rights reserved.
//
/*
- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType;
 
* 不带参数的请求
 
- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType ParaNameArr:(NSArray*)paraNameArr ParaValue:(NSString*)paraValue,...;
 
* 带参数的请求，最后一个参数必须接一个nil
* 返回id类型，可以用数组、字典、字符串接收
* MethodName:   接口名
* URLtype:      WEBURL类型，需要在.m补充代码，只有一个WEBURL可不填
* ParaNameArr:  参数名数组
* ParaValue:    参数值，数量必须与ParaNameArr元素数量一致
* eg.   
  NSDictionary *dic = [[SCNetMethod shareInstance]getDataWithMethodName:@"GetManagerUserLoginInfo" URLtype:0 ParaNameArr:@[@"UserName"] ParaValue:@"123456",nil];

- (void)interrupt;
* 中断当前的网络请求，会导致返回为null
 
*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Enum.h"
#import "Header.h"
#import "String.h"
#import "LoginModel.h"
#import "SCNetWorking.h"

typedef id (^NetBlock)(void);
typedef void (^CompleteHandle)(id result);

@protocol SCNetMethodDelegate <NSObject>
@optional

-(void)timeInterrupt;
-(void)scshowAlertVIewMethodLoginOff :(NSString *)loginOutTimeStr;

@end

@interface SCNetMethod : NSObject <NSURLConnectionDataDelegate,UIAlertViewDelegate>

+ (SCNetMethod*)shareInstance;
- (NSBlockOperation*)createOperation:(NetBlock)block CompleteHandle:(CompleteHandle)handle;
- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType;
- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType ParaNameArr:(NSArray*)paraNameArr ParaValue:(NSString*)paraValue,...;
- (void)interrupt;


@property(nonatomic,weak)id<SCNetMethodDelegate>delegate;
@property(nonatomic,assign)NSInteger runType;//temp private

@end
