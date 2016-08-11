//
//  SCNetWorkingConfig.h
//  CardAppSample
//
//  Created by 唐绍成 on 16/3/10.
//  Copyright © 2016年 唐绍成. All rights reserved.
//

#define NET_DEBUG_MODE

#define NET_URL_ESTATE [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]][[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Interface" ofType:@"plist"]][@"IsWebLocalURLRelease"] boolValue]?@"WebLocalURL_release":@"WebLocalURL_debug"] //屋苑

#define NET_URL_MERCHANT [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]][[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Interface" ofType:@"plist"]][@"IsWebGlobalURLRelease"] boolValue]?@"WebGlobalURL_release":@"WebGlobalURL_debug"] //商户

#define NET_URL_BACKUP [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]][[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Interface" ofType:@"plist"]][@"IsWebBackupURLRelease"] boolValue]?@"WebBackupURL_release":@"WebBackupURL_debug"] //备用

#define NET_INTERMETHOD_ESTATE [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]][@"WebLocalInterface"] //屋苑地址方法
#define NET_INTERMETHOD_MERCHANT [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]][@"WebGlobalInterface"] //商户地址方法
#define NET_INTERMETHOD_BACKUP [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]][@"WebBackupInterface"] //备用地址方法

