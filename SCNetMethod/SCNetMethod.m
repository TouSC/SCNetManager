//
//  SCNetMethod.m
//  SCMetroHarbour
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
        timeinterrupt = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timesetinterrupt) userInfo:nil repeats:YES];
        [timeinterrupt setFireDate:[NSDate distantFuture]];
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

- (NSBlockOperation*)createOperation:(NetBlock)block CompleteHandle:(CompleteHandle)handle
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        id result = block();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handle!=nil)
            {
                handle(result);
            }
        });
    }];
    return operation;
}

- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType;
{
    NSDictionary *responseDic = [self sendRequestMethodName:methodName ParaArr:nil MYWEBURL:webURLArr[urlType] InterMethod:interMethodArr[urlType]];
    id result = [self parserWithDic:responseDic MethodName:methodName];
    return result;
}

- (id)getDataWithMethodName:(NSString*)methodName URLtype:(NSInteger)urlType ParaNameArr:(NSArray*)paraNameArr ParaValue:(NSString*)paraValue,...
{
    va_list list;
    NSMutableArray *paraArr = [[NSMutableArray alloc]init];
    if (paraValue)  //有参
    {
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
            NSLog(@"getResult===%@",netResult.dictionary);
            [self isReturnCorrectData:netResult.dictionary];
            return netResult.dictionary;
        }
        else    //传入有nil
        {
            NSLog(@"有空值");
            return @{};
        }
    }
    else    //传入有nil
    {
        NSLog(@"有空值");
        return @{};
    }
}

-(void)isReturnCorrectData:(id)result
{
    NSDictionary *resultDic = result;
    if ([resultDic isKindOfClass:[NSDictionary class]]) {
        NSArray *arr = [resultDic objectForKey:@"StateList"];
        if ([arr isKindOfClass:[NSArray class]]) {
            
            NSDictionary *statedic = [arr lastObject];
            if ([statedic isKindOfClass:[NSDictionary class]]) {
                
                // 数据正常
                NSInteger statecode = [[statedic objectForKey:@"StateCode"]integerValue];
                NSString *stateMsg = [statedic objectForKey:@"StateMsg"];
                if (statecode == 1004) {
                    [self showAlertVIewMethodLoginOff:stateMsg];
                }
            }
        }
    }
    else
    {
        NSLog(@"返回数据类型出错");
    }
}

-(void)showAlertVIewMethodLoginOff :(NSString *)loginOutTimeStr
{
    if([_delegate respondsToSelector:@selector(scshowAlertVIewMethodLoginOff:)])
    {
        [_delegate scshowAlertVIewMethodLoginOff:loginOutTimeStr];
    }
}


- (NSDictionary*)sendRequestMethodName:(NSString*)methodName ParaArr:(NSArray*)paraArr MYWEBURL:(NSString*)webURL InterMethod:(NSString*)interMethod;
{
    //封装soap消息soapMessage
    NSMutableString *soapMessage = [[NSMutableString alloc]initWithString:
                                    @"<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">"
                                    "<soap:Body>"
                                    "<METHODNAME xmlns=\"http://tempuri.org/\">"
                                    "PARAPART"
                                    "</METHODNAME>"
                                    "</soap:Body>"
                                    "</soap:Envelope>"];
    if (paraArr!=nil)   //如果有参数
    {
        NSString *paraStr = [[NSString alloc]init];
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
            paraStr = [paraStr stringByAppendingString:tempStr];
        }
        [soapMessage replaceOccurrencesOfString:@"PARAPART" withString:paraStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, soapMessage.length)];
    }
    else    //如果没有参数
    {
        [soapMessage replaceOccurrencesOfString:@"PARAPART" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, soapMessage.length)];
    }
    
    [soapMessage replaceOccurrencesOfString:@"METHODNAME" withString:methodName options:NSCaseInsensitiveSearch range:NSMakeRange(0, soapMessage.length)];
    
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
    connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [verifyDeviceData resetBytesInRange:NSMakeRange(0, verifyDeviceData.length)];
    verifyDeviceData.length = 0;
    [timeinterrupt setFireDate:[NSDate dateWithTimeInterval:60 sinceDate:[NSDate new]]];
    [connection start];
    _runType = 0;
    while (_runType==0)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    if (_runType==1)
    {
        GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithData:verifyDeviceData options:0 error:nil];
        if (doc)
        {
            GDataXMLElement *rootElement = [doc rootElement];
            GDataXMLElement *childNode = [[rootElement nodesForXPath:@"/s:Envelope/s:Body" error:nil]lastObject];
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:childNode.stringValue,methodName, nil];
            return dic;
        }
        else
        {
            NSLog(@"parser failed!");
            return nil;
        }
    }
    else if (_runType==2)
    {
        NSLog(@"%@",[NSString stringWithFormat:@"%@ been interrupt",methodName]);
        return nil;
    }
    else
    {
        NSLog(@"unexpected error");
        return nil;
    }
}

- (id)parserWithDic:(NSDictionary*)dic MethodName:(NSString*)methodName;
{
    if (dic)
    {
        NSMutableString *str = [[NSMutableString alloc]initWithFormat:@"%@",[dic objectForKey:methodName]];
        id object = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (object)
        {
            return object;
        }
        else
        {
            return str;
        }
    }
    else
    {
        return nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    [verifyDeviceData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    _runType = 1;
    [timeinterrupt setFireDate:[NSDate distantFuture]];
    NSLog(@"Loading finished");
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
    _runType = 2;
    [timeinterrupt setFireDate:[NSDate distantFuture]];
}
- (void)interrupt;
{
    if (_runType==0)
    {
        [connection cancel];
        connection = nil;
        _runType = 2;
        [timeinterrupt setFireDate:[NSDate distantFuture]];
    }
}
-(void)timesetinterrupt
{
    NSLog(@"timeout");
    [_delegate timeInterrupt];
    [connection cancel];
    connection = nil;
    _runType = 2;
    [timeinterrupt setFireDate:[NSDate distantFuture]];
}
@end
