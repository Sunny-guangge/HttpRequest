//
//  LBRequest.h
//  GuoPei
//
//  Created by lanbao_b on 10/8/15.
//  Copyright (c) 2015 liuyuanyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBServerResponse.h"

@class LBError;

typedef void(^LBRequestResultHandle)(LBServerResponse *response);

@interface LBRequest : NSObject

@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, assign) BOOL needOtherStatusResponse;

- (NSString *)modelClassName;
- (NSString *)requestUrl;

- (void)startRequestWithResultHandle:(LBRequestResultHandle)resultHandle;
- (void)startHiddenRequestWithResultHandle:(LBRequestResultHandle)resultHandle;
@end
