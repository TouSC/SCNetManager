//
//  SCNetMethod.m
//  
//
//  Created by user on 15/4/20.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import "SCNetMethod.h"
#import "GDataXMLNode.h"

@implementation SCNetMethod
{
    NSMutableData *verifyDeviceData;
    NSURLConnection *connection;
    NSArray *webURLArr;
    NSArray *interMethodArr;
    NSTimer * timeinterrupt ;
    
    NSString *mmethodName;
    NSArray *mparaArr;
    NSInteger murlType;
}

+ (SCNetMethod*)shareInstance;
{
    static SCNetMethod *netMethod;
    if (netMethod==nil)
    {
        netMethod = [[SCNetMethod alloc]init];
    }
    return netMethod;
}

- (instancetype)init;
{
    self = [super init];
    if (self)
    {
        verifyDeviceData = [[NSMutableData alloc]init];
        NSString *webLocalURL;
        NSString *webGlobalURL;
        NSString *webBackupURL;
        NSDictionary *config_Plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]];
        NSDictionary *interface_Plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Interface" ofType:@"plist"]];
        webLocalURL = config_Plist[[interface_Plist[@"IsWebLocalURLRelease"] boolValue]?@"WebLocalURL_release":@"WebLocalURL_debug"];
        webGlobalURL = config_Plist[[interface_Plist[@"IsWebGlobalURLRelease"] boolValue]?@"WebGlobalURL_release":@"WebGlobalURL_debug"];
        webBackupURL = config_Plist[[interface_Plist[@"IsWebBackupURLRelease"] boolValue]?@"WebBackupURL_release":@"WebBackupURL_debug"];
        webURLArr = @[webLocalURL,webGlobalURL,webBackupURL];
        interMethodArr = @[config_Plist[@"WebLocalInterface"],config_Plist[@"WebGlobalInterface"],config_Plist[@"WebBackupInterface"]];
    }
    return self;
}

- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType ParaNameArr:(NSArray*)paraNameArr ParaValue:(NSString*)paraValue,...
{
    va_list list;
    NSMutableArray *paraArr = [[NSMutableArray alloc]init];

    va_start(list, paraValue);
    NSString *curStr = paraValue;
    int paraIndex = 0;
    do
    {
        if (([curStr isKindOfClass:[NSNull class]])||(curStr==nil))
        {
            break;
        }
        else
        {
            NSDictionary *paraDic = @{@"paraName":paraNameArr[paraIndex],@"paraValue":curStr};
            [paraArr addObject:paraDic];
            paraIndex++;
        }
    }while ((curStr = va_arg(list, id)));
    va_end(list);
    if (paraIndex==paraNameArr.count)
    {
        SCNetURLType type = SCNetURLEstate;
        switch (urlType)
        {
            case 0:
                type = SCNetURLEstate;
                break;
            case 1:
                type = SCNetURLMerchant;
                break;
            case 2:
                type = SCNetURLBackup;
                break;
            default:
                type = SCNetURLEstate;
                break;
        }
        SCNetWorkingResult* netResult = [[SCNetWorking shareInstance] getDataWithMethodName:methodName URLtype:type Timeout:60 Sync:YES Progress:^(NSURLSessionTask *task) {
            [task resume];
        } Complete:^(SCNetWorkingResult *result, NSURLSessionTask *task) {
            ;
        } ParaArr:paraArr];
        return netResult.dictionary;
    }
    else    //传入有nil
    {
        NSLog(@"有空值");
        return @{};
    }
}

@end
