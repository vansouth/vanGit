//
//  BaseModel.m
//  gqspace
//
//  Created by Chanbo on 15/8/24.
//  Copyright (c) 2015年 Chanbo. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

Create_Model_Imp(BaseModel)


+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{};
}


- (NSDictionary *)toJSONDictionary
{
    NSError *error = nil;
    NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    if (error) {
        MLog(@"%s : %@",__FUNCTION__,error);
    }
    return dict;
}

- (NSString *)toJSONString
{
    NSDictionary *dict = [self toJSONDictionary];
    if (dict) {
        return [dict toJsonString];
    }
    return nil;
}

@end
