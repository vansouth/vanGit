//
//  BaseModel.h
//  gqspace
//
//  Created by Chanbo on 15/8/24.
//  Copyright (c) 2015年 Chanbo. All rights reserved.
//

#import "libdef.h"

// 模型定义宏
#define Create_Model_Def(cls) + (instancetype)createWithDict:(NSDictionary *)dict

// 模型实现宏
#define Create_Model_Imp(cls) \
+ (instancetype)createWithDict:(NSDictionary *)dict \
{ \
    NSError *error = nil; \
    cls *model = [MTLJSONAdapter modelOfClass:[cls class] fromJSONDictionary:dict error:&error]; \
    if (error) { \
        MLog(@"%@",error); \
    } \
    return model; \
}

// 模型数据转换(适用于Array)
#define ModelArrayValueTransformer(key,cls) \
+ (NSValueTransformer *)key##JSONTransformer \
{ \
    return [MTLJSONAdapter arrayTransformerWithModelClass:[cls class]]; \
}

// 模型数据转换(适用于Dictionary)
#define ModelValueTransformer(key,cls) \
+ (NSValueTransformer *)key##JSONTransformer \
{ \
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[cls class]]; \
}


@interface BaseModel : MTLModel<MTLJSONSerializing>

Create_Model_Def(BaseModel);
/**
 *  属性映射(json跟模型属性的对应关系)，一定要实现
 *  对应：模型属性 -> json字典Key
 *
 */
+ (NSDictionary *)JSONKeyPathsByPropertyKey;

/**
 *  把模型属性转换成JSON字典
 *
 *  @return 成功返回字典，失败返回nil
 */
- (NSDictionary *)toJSONDictionary;

/**
 *  把模型属性转换成JSON字符串
 *
 *  @return 成功返回json字符串，失败返回nil
 */
- (NSString *)toJSONString;

@end
