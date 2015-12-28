//
//  LBUploadFileRequest.h
//  GuoPei
//
//  Created by Jessica on 10/23/15.
//  Copyright (c) 2015 liuyuanyuan. All rights reserved.
//

#import "LBRequest.h"
typedef void(^LBUploadResultHandle)(id object);

@interface LBUploadFileRequest : LBRequest

@property (nonatomic, strong)NSMutableDictionary *parameters;
- (void)uploadImages:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult;
- (void)uploadProgressImages:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult;
- (void)uploadVoices:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult;
- (void)uploadProgressVoices:(NSArray *)files uploadResult:(LBUploadResultHandle)uploadResult;
- (void)uploadVideo:(NSArray *)videos uploadResult:(LBUploadResultHandle)uploadResult;
- (void)uploadProgressVideo:(NSArray *)videos uploadResult:(LBUploadResultHandle)uploadResult;
- (NSString *)requestUrl;

@end
