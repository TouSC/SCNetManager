//
//  SCNetMethod.m
//  
//
//  Created by user on 15/4/20.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import "SCNetWorking.h"

@implementation SCNetWorking

+ (SCNetWorking*)shareInstance;
{
    static SCNetWorking *netMethod;
    if (netMethod==nil)
    {
        netMethod = [[SCNetWorking alloc]init];
    }
    return netMethod;
}

- (instancetype)init;
{
    self = [super init];
    if (self)
    {
        ;
    }
    return self;
}

- (SCNetWorkingResult*)getDataWithMethodName:(NSString*)methodName URLtype:(SCNetURLType)urlType Timeout:(NSUInteger)timeout Sync:(BOOL)isSync Progress:(void(^)(NSURLSessionTask *task))progress Complete:(void(^)(SCNetWorkingResult *result,NSURLSessionTask *task))complete ParaNameArr:(NSArray*)paraNameArr ParaValue:(id)paraValue,... NS_REQUIRES_NIL_TERMINATION;
{
    va_list list;
    NSMutableArray *paraArr = [[NSMutableArray alloc]init];
    va_start(list, paraValue);
    id curValue = paraValue;
    int paraIndex = 0;
    do
    {
        if (([curValue isKindOfClass:[NSNull class]])||(curValue==nil))
        {
            break;
        }
        else
        {
            NSDictionary *paraDic = @{@"paraName":paraNameArr[paraIndex],@"paraValue":curValue};
            [paraArr addObject:paraDic];
            paraIndex++;
        }
    }while ((curValue = va_arg(list, id)));
    va_end(list);
    NSString *webURL;
    NSString *interMethod;
    
    NSLog(@"SCNetworking -----%@",paraArr);
    if (paraIndex != paraNameArr.count)
    {
        if(complete)
        {
            complete([SCNetWorkingResult new],nil);
        }
        return [SCNetWorkingResult new];
    }
    switch (urlType)
    {
        case SCNetURLEstate:
        {
#ifdef NET_URL_ESTATE
            webURL = NET_URL_ESTATE;
            interMethod = NET_INTERMETHOD_ESTATE;
#endif
            break;
        }
        case SCNetURLMerchant:
        {
#ifdef NET_URL_MERCHANT
            webURL = NET_URL_MERCHANT;
            interMethod = NET_INTERMETHOD_MERCHANT;
#endif
            break;
        }
        case SCNetURLBackup:
        {
#ifdef NET_URL_BACKUP
            webURL = NET_URL_BACKUP;
            interMethod = NET_INTERMETHOD_BACKUP;
#endif
            break;
        }
    }
    
    //封装soap消息soapMessage
    NSMutableString *paraStr = [NSMutableString string];
    if (paraArr!=nil)   //如果有参数
    {
        for (int i=0;i<paraArr.count;i++)
        {
            NSMutableString *contentStr = [[NSMutableString alloc] initWithFormat:@"%@",[paraArr[i] objectForKey:@"paraValue"]];
            [contentStr replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentStr.length)];
            [contentStr replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentStr.length)];
            [contentStr replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentStr.length)];
            NSString *tempStr = [NSString stringWithFormat:@"<%@>%@</%@>",
                                 [paraArr[i] objectForKey:@"paraName"],
                                 contentStr,
                                 [paraArr[i] objectForKey:@"paraName"]];
            [paraStr appendString:tempStr];
        }
    }
    NSMutableString *soapMessage = [[NSMutableString alloc]initWithFormat:
                                    @"<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">"
                                    "<soap:Body>"
                                    "<%@ xmlns=\"http://tempuri.org/\">"
                                    "%@"
                                    "</%@>"
                                    "</soap:Body>"
                                    "</soap:Envelope>",methodName,paraStr?:@"",methodName];
    
    //设置请求
    NSURL *url = [NSURL URLWithString:webURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d",(int)soapMessage.length];
    NSString *soapActionStr = [NSString stringWithFormat:@"http://tempuri.org/%@/%@",interMethod,methodName];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:soapActionStr forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block SCNetWorkingResult *result;
    __block NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
//        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        result = [self parserData:data MethodName:methodName];
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(result,task);
        });
        dispatch_semaphore_signal(semaphore);
    }];
                                          
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [task cancel];
    });
    progress(task);
    if (isSync)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    return result;
}

- (SCNetWorkingResult*)getDataWithMethodName:(NSString*)methodName URLtype:(SCNetURLType)urlType Timeout:(NSUInteger)timeout Sync:(BOOL)isSync Progress:(void(^)(NSURLSessionTask *task))progress Complete:(void(^)(SCNetWorkingResult *result,NSURLSessionTask *task))complete ParaArr:(NSArray*)paraArr;
{
    NSString *webURL;
    NSString *interMethod;
    if (paraArr.count)
    {
        NSLog(@"sendPara---%@,%@",methodName,paraArr);
    }
    switch (urlType)
    {
        case SCNetURLEstate:
        {
#ifdef NET_URL_ESTATE
            webURL = NET_URL_ESTATE;
            interMethod = NET_INTERMETHOD_ESTATE;
#endif
            break;
        }
        case SCNetURLMerchant:
        {
#ifdef NET_URL_MERCHANT
            webURL = NET_URL_MERCHANT;
            interMethod = NET_INTERMETHOD_MERCHANT;
#endif
            break;
        }
        case SCNetURLBackup:
        {
#ifdef NET_URL_BACKUP
            webURL = NET_URL_BACKUP;
            interMethod = NET_INTERMETHOD_BACKUP;
#endif
            break;
        }
    }
    
    //封装soap消息soapMessage
    NSMutableString *paraStr = [NSMutableString string];
    if (paraArr!=nil)   //如果有参数
    {
        for (int i=0;i<paraArr.count;i++)
        {
            NSMutableString *contentStr = [[NSMutableString alloc] initWithFormat:@"%@",[paraArr[i] objectForKey:@"paraValue"]];
            [contentStr replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentStr.length)];
            [contentStr replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentStr.length)];
            [contentStr replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentStr.length)];
            NSString *tempStr = [NSString stringWithFormat:@"<%@>%@</%@>",
                                 [paraArr[i] objectForKey:@"paraName"],
                                 contentStr,
                                 [paraArr[i] objectForKey:@"paraName"]];
            [paraStr appendString:tempStr];
        }
    }
    NSMutableString *soapMessage = [[NSMutableString alloc]initWithFormat:
                                    @"<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">"
                                    "<soap:Body>"
                                    "<%@ xmlns=\"http://tempuri.org/\">"
                                    "%@"
                                    "</%@>"
                                    "</soap:Body>"
                                    "</soap:Envelope>",methodName,paraStr?:@"",methodName];
    
    //设置请求
    NSURL *url = [NSURL URLWithString:webURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d",(int)soapMessage.length];
    NSString *soapActionStr = [NSString stringWithFormat:@"http://tempuri.org/%@/%@",interMethod,methodName];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:soapActionStr forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block SCNetWorkingResult *result;
    __block NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
        //        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        result = [self parserData:data MethodName:methodName];
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(result,task);
        });
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [task cancel];
    });
    progress(task);
    if (isSync)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    return result;
}

- (SCNetWorkingResult*)parserData:(NSData*)data MethodName:(NSString*)methodName;
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithData:data error:nil];
    NSDictionary *dic;
    if (doc)
    {
        GDataXMLElement *rootElement = [doc rootElement];
        GDataXMLElement *childNode = [[rootElement nodesForXPath:@"/s:Envelope/s:Body" error:nil]lastObject];
        dic = [[NSDictionary alloc]initWithObjectsAndKeys:childNode.stringValue,methodName, nil];
    }
    else
    {
        NSLog(@"%@--解析错误",methodName);
    }
    if (dic)
    {
        NSMutableString *str = [[NSMutableString alloc]initWithFormat:@"%@",[dic objectForKey:methodName]];
        id object = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return [[SCNetWorkingResult alloc] initWithDictionary:object MethodName:(NSString*)methodName];
    }
    return [SCNetWorkingResult new];
}

@end
