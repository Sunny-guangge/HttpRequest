//
//  LBUploadFileRequest.m
//  GuoPei
//
//  Created by Jessica on 10/23/15.
//  Copyright (c) 2015 liuyuanyuan. All rights reserved.
//
#import "LBServerResponse.h"
#import "LBUploadFileRequest.h"
#import "SVProgressHUD.h"
@interface LBUploadFileRequest ()
{
    LBUploadResultHandle requestResultHandle;
    BOOL isHiddenRequest;
    NSMutableDictionary *parameters;
    NSString *urlString;
}

@end
@implementation LBUploadFileRequest
@synthesize parameters;
- (id)init
{
    if (self = [super init]) {
        urlString = REQUESTURLPATH([self requestUrl]);

        parameters = [NSMutableDictionary dictionary];

    }
    return self;
}
- (NSString *)requestUrl
{
    return nil;
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
    
    LBServerResponse *serverResponse = [[LBServerResponse alloc] initWithJSONObject:jsonObject enityClass:nil];
    if (serverResponse.status == 1) {
        [self requestSuccessWithResponse:serverResponse];
    }else{
        [self requestLogicFailWithResponse:serverResponse];
    }
}

#pragma mark - 请求结果：成功

- (void)requestSuccessWithResponse:(LBServerResponse *)serverResponse
{
    [SVProgressHUD dismiss];
    requestResultHandle(serverResponse.data);
}

#pragma mark - end

#pragma mark - 请求结果：失败

- (void)requestResponseFail
{
    [SVProgressHUD dismiss];
    [LBAlertView showAlertViewWithSuperView:nil message:@"服务器连接失败!"];
}

- (void)requestJsonFailWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    [LBAlertView showAlertViewWithSuperView:nil message:@"数据解析失败!"];
}

- (void)requestLogicFailWithResponse:(LBServerResponse *)serverResponse
{
    [SVProgressHUD dismiss];
    requestResultHandle(serverResponse.data);
    [LBAlertView showAlertViewWithSuperView:nil message:serverResponse.message];
}

#pragma mark - end

#pragma mark - post多张图片

- (void)uploadProgressImages:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self uploadImages:files uploadResult:uploadResult];
}

- (void)uploadImages:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    requestResultHandle = uploadResult;
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    NSMutableString *body=[[NSMutableString alloc]init];
    NSArray *keys= [parameters allKeys];
    for(int i=0;i<[keys count];i++) {
        NSString *key=[keys objectAtIndex:i];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[parameters objectForKey:key]];
    }
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    for(int i = 0; i< [files count] ; i++){
        NSData* data =  UIImageJPEGRepresentation(files[i], 0.0);
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"uploadfile\"; filename=\"file%d.jpg\"\r\n", i];
        [imgbody appendFormat:@"Content-Type: application/octet-stream; charset=utf-8\r\n\r\n"];
        
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
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

#pragma mark - 上传文件

- (void)uploadProgressVoices:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self uploadVoices:files uploadResult:uploadResult];
}

- (void)uploadVoices:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult
{
    
    requestResultHandle = uploadResult;
    
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    NSMutableString *body=[[NSMutableString alloc]init];
    NSArray *keys= [parameters allKeys];
    for(int i=0;i<[keys count];i++) {
        NSString *key = [keys objectAtIndex:i];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[parameters objectForKey:key]];
    }
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    for(int i = 0; i< [files count] ; i++){
        NSData *data = [[NSData alloc] initWithContentsOfFile:files[i]];
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"files\"; filename=\"file%d.caf\"\r\n", i];
        [imgbody appendFormat:@"Content-Type: audio/x-caf; charset=utf-8\r\n\r\n"];
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
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

- (void)uploadProgressVideo:(NSArray *)videos uploadResult:(LBUploadResultHandle)uploadResult
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self uploadVideo:videos uploadResult:uploadResult];
}

- (void)uploadVideo:(NSArray *)videos uploadResult:(LBUploadResultHandle)uploadResult
{
    requestResultHandle = uploadResult;
    
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    NSMutableString *body=[[NSMutableString alloc]init];
    NSArray *keys= [parameters allKeys];
    for(int i=0;i<[keys count];i++) {
        NSString *key = [keys objectAtIndex:i];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[parameters objectForKey:key]];
    }
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    for(int i = 0; i< [videos count] ; i++){
        NSData *data = [[NSData alloc] initWithContentsOfFile:videos[i]];
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"files\"; filename=\"file%d.mov\"\r\n", i];
        [imgbody appendFormat:@"Content-Type: video/quicktime; charset=utf-8\r\n\r\n"];
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
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

@end
