//
//  LBServerResponse.h
//  GuoPei
//
//  Created by lanbao_b on 10/8/15.
//  Copyright (c) 2015 liuyuanyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBServerResponse : NSObject
@property (nonatomic, strong, readonly) id jsonObject;
@property (nonatomic, assign, readonly) int status;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, strong, readonly) id data;
@property (nonatomic, assign, readonly) int totalPage;

@property (nonatomic, strong, readonly) NSArray *entities;

- (instancetype)initWithJSONObject:(id)object enityClass:(__unsafe_unretained Class)entityClass;

@end
