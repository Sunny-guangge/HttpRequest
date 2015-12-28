//
//  LBServerResponse.m
//  GuoPei
//
//  Created by lanbao_b on 10/8/15.
//  Copyright (c) 2015 liuyuanyuan. All rights reserved.
//

#import "LBServerResponse.h"
#import "LBEntity.h"

@implementation LBServerResponse
@synthesize jsonObject;
@synthesize status;
@synthesize message;
@synthesize data;
@synthesize totalPage;
@synthesize entities;

- (instancetype)initWithJSONObject:(id)object enityClass:(__unsafe_unretained Class)entityClass
{
    if (self = [super init]) {
        jsonObject = object;
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            if ([object objectForKey:@"status"]) {
                status = [[object objectForKey:@"status"] intValue];
            }
        }
        
//        message = [object objectForKey:@"msg"];
        data = object;
//        totalPage = [[object objectForKey:@"totalPage"] intValue];
        
        if (data && entityClass != nil) {
            if ([data isKindOfClass:[NSArray class]]) {
                entities = [LBEntity entityListWithData:data entityClass:entityClass];
            }else if ([data isKindOfClass:[NSDictionary class]]){
                entities = @[[LBEntity entityWithData:data entityClass:entityClass]];
            }else{
                
            }
        }
    }
    return self;
}


@end
