//
//  LBRequest.m
//  GuoPei
//
//  Created by lanbao_b on 10/8/15.
//  Copyright (c) 2015 liuyuanyuan. All rights reserved.
//
#import "LBUser.h"
#import "LBRequest.h"
#import "SVProgressHUD.h"
#import "LBAlertView.h"
@interface LBRequest ()
{
    LBRequestResultHandle requestResultHandle;
    BOOL isHiddenRequest;
    NSString *urlString;
}

@end
@implementation LBRequest
@synthesize parameters;
- (instancetype)init
{
    if (self = [super init]) {
        
        urlString = REQUESTURLPATH([self requestUrl]);
        
        parameters = [NSMutableDictionary dictionary];
//        if ([LBUser isLogin]) {
//            GPUser *currentUser = [GPUser currentUser];
//            [parameters setValue:@(currentUser.uid) forKey:@"uid"];
//            [parameters setValue:currentUser.guid forKey:@"guid"];
//        }
    }
    return self;
}

- (NSString *)modelClassName
{
    return nil;
}

- (NSString *)requestUrl
{
    return nil;
}

- (void)startRequestWithResultHandle:(LBRequestResultHandle)resultHandle
{
    requestResultHandle = resultHandle;
    isHiddenRequest = NO;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self requestByPost];
}

- (void)startHiddenRequestWithResultHandle:(LBRequestResultHandle)resultHandle
{
    requestResultHandle = resultHandle;
    isHiddenRequest = YES;
    [self requestByPost];
}

- (void)logRequestUrl:(NSString *)errorString
{
    NSString *param = @"?";
    for (NSString * key in parameters.allKeys) {
        param = [NSString stringWithFormat:@"%@%@=%@&", param, key, [parameters valueForKey:key]];
    }
    
    if (errorString) {
        NSLog(@"请求链接：%@%@\n%@", urlString,[param substringToIndex:param.length-1], errorString);
    }else
        NSLog(@"请求链接：%@%@", urlString,[param substringToIndex:param.length-1]);
}

- (void)requestByPost
{
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.f];
    
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc] initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc] initWithFormat:@"%@--",MPboundary];
    
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc] init];
    NSArray *keys= [parameters allKeys];
    
    for(int i=0;i<[keys count];i++) {
        NSString *key=[keys objectAtIndex:i];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[parameters objectForKey:key]];
    }
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc] initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *content=[[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:&error];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self dealWithResult:data error:error];
        });
    });
}

- (void)dealWithResult:(NSData *)data error:(NSError *)error
{
    if (data == nil) {
        [self requestResponseFail];
        return;
    }
    
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    if (jsonObject == nil) {
        [self requestJsonFailWithError:jsonError];
        return;
    }
    
    LBServerResponse *serverResponse = [[LBServerResponse alloc] initWithJSONObject:jsonObject enityClass:NSClassFromString([self modelClassName])];
    
    [self requestSuccessWithResponse:serverResponse];

//    if (serverResponse.status == 0) {
//        [self requestSuccessWithResponse:serverResponse];
//    }else{
//        [self requestLogicFailWithResponse:serverResponse];
//    }
}

#pragma mark - 请求结果：成功

- (void)requestSuccessWithResponse:(LBServerResponse *)serverResponse
{
    if (!isHiddenRequest) {
        [SVProgressHUD dismiss];
    }
    requestResultHandle(serverResponse);
    [self logRequestUrl:nil];
}

#pragma mark - end

#pragma mark - 请求结果：失败

- (void)requestResponseFail
{
    if (!isHiddenRequest) {
        [SVProgressHUD dismiss];
        [LBAlertView showAlertViewWithSuperView:nil message:@"服务器连接失败!"];
    }
    [self logRequestUrl:@"服务器连接失败!"];
    requestResultHandle(nil);
}

- (void)requestJsonFailWithError:(NSError *)error
{
    if (!isHiddenRequest) {
        [SVProgressHUD dismiss];
        [LBAlertView showAlertViewWithSuperView:nil message:@"数据解析失败!"];
    }
    [self logRequestUrl:@"数据解析失败!"];
    requestResultHandle(nil);
}

- (void)requestLogicFailWithResponse:(LBServerResponse *)serverResponse
{
    if (!isHiddenRequest || serverResponse.status == 1) {
        [SVProgressHUD dismiss];
        [LBAlertView showAlertViewWithSuperView:nil message:serverResponse.message];
    }
    if(!isHiddenRequest && serverResponse.status == 2){
        [SVProgressHUD dismiss];
        [LBAlertView showAlertViewWithSuperView:nil message:serverResponse.message];
    }
    if(!isHiddenRequest && serverResponse.status == 3){
        [SVProgressHUD dismiss];
        [LBAlertView showAlertViewWithSuperView:nil message:serverResponse.message];
    }
    [self logRequestUrl:serverResponse.message];
    
    if (_needOtherStatusResponse) {
        requestResultHandle(serverResponse);
    }else
        requestResultHandle(nil);
}


@end
