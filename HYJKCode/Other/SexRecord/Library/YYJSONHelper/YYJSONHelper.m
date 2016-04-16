//
// Created by ivan on 13-7-17.
//
//
#import "YYJSONHelper.h"

static void YY_swizzleInstanceMethod(Class c, SEL original, SEL replacement);

@implementation NSObject (YYJSONHelper)

static NSMutableDictionary *YY_JSON_OBJECT_KEYDICTS = nil;

+ (void)copyPropertiesFrom:(id)object to:(id)targetObject ignoreNil:(BOOL)ignore
{
    if (object && targetObject && [object class] == [targetObject class])
    {
        NSArray *array = [object yyPropertiesOfClass:[object class]];
        for (NSString *key in array)
        {
            if (![key isEqualToString:@"rowid"])
            {
                id value = [object valueForKey:key];
                if (ignore)
                {
                    [targetObject setValue:value forKey:key];
                }
                else
                {
                    if (value != nil)
                    {
                        [targetObject setValue:value forKey:key];
                    }
                }
            }
        }
    }
}

#if DEBUG
- (NSString *)YY
{
    return self.YYJSONString;
}

#endif

+ (BOOL)YYSuper
{
    return NO;
}
+(NSArray *)YYIgnorePropertyNames
{
    return nil;
}

+ (NSDictionary *)YYJSONKeyDict
{
    return [self _YYJSONKeyDict];
}


+ (NSMutableDictionary *)_YYJSONKeyDict
{
    if (!YY_JSON_OBJECT_KEYDICTS)
    {
        YY_JSON_OBJECT_KEYDICTS = [[NSMutableDictionary alloc] init];
    }
    NSString *YYObjectKey = [NSString stringWithFormat:@"YY_JSON_%@", NSStringFromClass([self class])];
    NSMutableDictionary *dictionary = [YY_JSON_OBJECT_KEYDICTS safeObjectForKey:YYObjectKey];
    if (!dictionary)
    {
        dictionary = [[NSMutableDictionary alloc] init];
        if ([self YYSuper] && ![[self superclass] isMemberOfClass:[NSObject class]])
        {
            [dictionary setValuesForKeysWithDictionary:[[self superclass] YYJSONKeyDict]];
        }
        //因为我们的Model可能已经继承了自己写的BaseModel，如果再让你继承我自己写的一个BaseJsonModel，那么可能会破坏你的设计。
        //由于我不喜欢继承，所以无法重写  valueForUndefinedKey: 和 setValue:forUndefinedKey:
        //所以把有使用YYJsonHelper的类的以上俩方法替换了，如果你需要在这俩方法里面进行其他控制
        //请重写新的两个方法 YY_valueForUndefinedKey:和YY_setValue:forUndefinedKey:
        YY_swizzleInstanceMethod(self, @selector(valueForUndefinedKey:), @selector(YY_valueForUndefinedKey:));
        YY_swizzleInstanceMethod(self, @selector(setValue:forUndefinedKey:), @selector(YY_setValue:forUndefinedKey:));
        NSArray *properties = [self yyPropertiesOfClass:[self class]];
        [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *typeName = [self propertyConformsToProtocol:@protocol(YYJSONHelperProtocol) propertyName:obj];
            if (typeName)
            {
                [dictionary setObject:typeName forKey:obj];
            }
            else
            {
                [dictionary setObject:obj forKey:obj];
            }
        }];
        [YY_JSON_OBJECT_KEYDICTS setObject:dictionary forKey:YYObjectKey];
    }
    return dictionary;
}

+ (void)bindYYJSONKey:(NSString *)jsonKey toProperty:(NSString *)property
{
    NSMutableDictionary *dictionary = [self _YYJSONKeyDict];
    [dictionary removeObjectForKey:property];
    [dictionary setObject:property forKey:jsonKey];
}

- (NSString *)YYJSONString
{
    return [self YYJSONDictionary].YYJSONString;
}

- (NSData *)YYJSONData
{
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        if (!error)
        {
            return jsonData;
        }
    }
    return self.YYJSONDictionary.YYJSONData;
}


/**
*  应该比较脆弱，不支持太复杂的对象。
*/
- (NSDictionary *)YYJSONDictionary
{
    NSDictionary        *keyDict  = [self.class YYJSONKeyDict];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithCapacity:keyDict.count];
    [keyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value         = nil;
        id originalValue = [self valueForKey:key];
        if (NSClassFromString(obj))
        {
            if ([originalValue isKindOfClass:[NSArray class]])
            {
                value = @{key : [[originalValue YYJSONData] YYJSONString]};
            }
            else
            {
                value = [originalValue YYJSONDictionary];
            }
        }
        else
        {
            value = [self valueForKey:obj];
        }
        if (value)
        {
            [jsonDict setValue:value forKey:key];
        }
    }];
    return jsonDict;
}

-(BOOL)isBlankString:(NSString *)string
{
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if([string isKindOfClass:[NSString class]] == NO)
    {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    if ([string.lowercaseString isEqualToString:@"(null)"] || [string.lowercaseString isEqualToString:@"null"] || [string.lowercaseString isEqualToString:@"<null>"])
    {
        return YES;
    }
    return NO;
}


static void YY_swizzleInstanceMethod(Class c, SEL original, SEL replacement) {
    Method a = class_getInstanceMethod(c, original);
    Method b = class_getInstanceMethod(c, replacement);
    if (class_addMethod(c, original, method_getImplementation(b), method_getTypeEncoding(b)))
    {
        class_replaceMethod(c, replacement, method_getImplementation(a), method_getTypeEncoding(a));
    }
    else
    {
        method_exchangeImplementations(a, b);
    }
}

- (id)YY_valueForUndefinedKey:(NSString *)key
{
#ifdef DEBUG
//    NSLog(@"%@ undefinedKey %@", self.class, key);
#endif
    return nil;
}

- (void)YY_setValue:(id)value forUndefinedKey:(NSString *)key
{
#ifdef DEBUG
//    NSLog(@"%@ undefinedKey %@ and value is %@", self.class, key, value);
#endif
}


@end

@implementation NSObject (YYProperties)
- (NSArray *)yyPropertiesOfClass:(Class)aClass
{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    id obj = objc_getClass([NSStringFromClass(aClass) cStringUsingEncoding:4]);
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(obj, &outCount);
    NSArray* igonreArray = [aClass YYIgnorePropertyNames];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:4];
        if(igonreArray.count)
        {
            if([igonreArray indexOfObject:propertyName]!=NSNotFound)
            {
                continue;
            }
        }
        [propertyNames addObject:propertyName];
    }
    free(properties);
    return propertyNames;
}

+ (NSString *)propertyConformsToProtocol:(Protocol *)protocol propertyName:(NSString *)propertyName
{
    NSString *typeName = [self typeOfPropertyNamed:propertyName];
    if ([typeName isKindOfClass:[NSString class]])
    {
        typeName      = [typeName stringByReplacingOccurrencesOfString:@"T@" withString:@""];
        typeName      = [typeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSRange range = [typeName rangeOfString:@"Array"];
        if (range.location != NSNotFound)
        {
            NSRange beginRange = [typeName rangeOfString:@"<"];
            NSRange endRange   = [typeName rangeOfString:@">"];
            if (beginRange.location != NSNotFound && endRange.location != NSNotFound)
            {
                NSString *protocalName = [typeName substringWithRange:NSMakeRange(beginRange.location + beginRange.length, endRange.location - beginRange.location - 1)];
                if (NSClassFromString(protocalName))
                {
                    return protocalName;
                }
            }
        }
    }
    NSObject *obj      = [NSClassFromString(typeName) new];
    if ([obj conformsToProtocol:protocol])
    {
        return typeName;
    }
    return nil;
}

+ (NSString *)typeOfPropertyNamed:(NSString *)name
{
    objc_property_t property = class_getProperty(self, [name UTF8String]);
    if (property == NULL )
    {
        return (NULL);
    }
    return [NSString stringWithUTF8String:(property_getTypeString(property))];
}

const char *property_getTypeString(objc_property_t property) {
    const char *attrs = property_getAttributes(property);
    if (attrs == NULL )
        return (NULL);

    static char buffer[256];
    const char *e = strchr(attrs, ',');
    if (e == NULL )
        return (NULL);

    int len = (int) (e - attrs);
    memcpy( buffer, attrs, len );
    buffer[len] = '\0';

    return (buffer);
}

@end

@implementation NSString (YYJSONHelper)
- (NSData*)toData
{
    return [self toYYData];
}
- (id)toModel:(Class)modelClass
{
    return [self.toYYData toModel:modelClass];
}

- (id)toModel:(Class)modelClass forKey:(NSString *)jsonKey
{
    return [self.toYYData toModel:modelClass forKey:jsonKey];
}

- (NSArray *)toModels:(Class)modelClass
{
    return [self.toYYData toModels:modelClass];
}

- (NSArray *)toModels:(Class)modelClass forKey:(NSString *)jsonKey
{
    return [self.toYYData toModels:modelClass forKey:jsonKey];
}

- (NSData *)toYYData
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (YYJSONHelper)
- (id)toYYJSONObject
{
    id YYJSONObject = [self YYJSONObjectForKey:nil];
    return YYJSONObject;
}

- (id)toModel:(Class)modelClass
{
    return [self toModel:modelClass forKey:nil];
}

- (id)toModel:(Class)modelClass forKey:(NSString *)key
{
    if (modelClass == nil)return nil;
    id YYJSONObject = [self YYJSONObjectForKey:key];
    if (YYJSONObject == nil || [NSNull null] == YYJSONObject)return nil;
    NSDictionary *YYJSONKeyDict = [modelClass YYJSONKeyDict];
    id model = [NSData objectForModelClass:modelClass fromDict:YYJSONObject withJSONKeyDict:YYJSONKeyDict];
    return model;
}

- (NSArray *)toModels:(Class)modelClass
{
    return [self toModels:modelClass forKey:nil];
}

- (NSArray *)toModels:(Class)modelClass forKey:(NSString *)key
{
    if (modelClass == nil)return nil;
    id YYJSONObject = [self YYJSONObjectForKey:key];
    if (YYJSONObject == nil || [NSNull null] == YYJSONObject)return nil;
    NSDictionary *YYJSONKeyDict = [modelClass YYJSONKeyDict];
    if ([YYJSONObject isKindOfClass:[NSArray class]])
    {
        NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:[YYJSONObject count]];
        [YYJSONObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id model = [NSData objectForModelClass:modelClass fromDict:obj withJSONKeyDict:YYJSONKeyDict];
            [models addObject:model];
        }];
        return models;
    }
    else if ([YYJSONObject isKindOfClass:[NSDictionary class]])
    {
        id model = [NSData objectForModelClass:modelClass fromDict:YYJSONObject withJSONKeyDict:YYJSONKeyDict];
        if (model)
        {
            return @[model];
        }
    }
    return nil;
}

+ (id)objectsForModelClass:(Class)modelClass fromArray:(NSArray *)array
{
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:array.count];
    NSDictionary *YYJSONKeyDict = [modelClass YYJSONKeyDict];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [models addObject:[self objectForModelClass:modelClass fromDict:obj withJSONKeyDict:YYJSONKeyDict]];
    }];
    return models;
}

+ (id)objectForModelClass:(Class)modelClass fromDict:(NSDictionary *)dict withJSONKeyDict:(NSDictionary *)YYJSONKeyDict
{
    id model = [[modelClass alloc] init];
    [YYJSONKeyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([dict[key] isKindOfClass:[NSArray class]])
        {
            if (NSClassFromString(obj))
            {
                NSArray *array = [self objectsForModelClass:NSClassFromString(obj) fromArray:dict[key]];
                if (array.count)
                {
                    [model setValue:array forKey:key];
                }
            }
            else
            {
                [model setValue:dict[key] forKey:obj];
            }
        }
        else if ([dict[key] isKindOfClass:[NSDictionary class]])
        {
            Class otherClass = NSClassFromString(obj);
            if (otherClass)
            {
                id object = [self objectForModelClass:otherClass fromDict:dict[key] withJSONKeyDict:[otherClass YYJSONKeyDict]];
                if (object)
                {
                    [model setValue:object forKey:key];
                }
            }
        }
        else
        {
            id value = dict[key];
            if (![value isKindOfClass:[NSNull class]] && value != nil)
            {
                if ([value isKindOfClass:[NSNumber class]]) {
                    id member = [model valueForKey:obj];
                    if (member && [member isKindOfClass:[NSNumber class]]) {
                        [model setValue:value forKey:obj];
                    } else {
                        NSNumber* numValue = value;
                        NSString* valueString = [NSString stringWithFormat:@"%@",numValue.stringValue];
                        [model setValue:valueString forKey:obj];
                    }
                } else {
                    [model setValue:dict[key] forKey:obj];
                }
            }
        }
    }];
    return model;
}

- (NSString *)YYJSONString
{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}


- (id)YYJSONObject
{
    return [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:nil];
}

- (id)YYJSONObjectForKey:(NSString *)key
{
    if (key && [[self YYJSONObject] isKindOfClass:[NSDictionary class]])
    {
        return [[self YYJSONObject] objectForKey:key];
    }
    else
    {
        return [self YYJSONObject];
    }
}


- (id)valueForJsonKey:(NSString *)key
{
    id rootJsonObj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:nil];
    if ([rootJsonObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *) rootJsonObj;
        return [dict valueForKey:key];
    }
    return nil;
}
@end

@implementation NSDictionary (YYJSONHelper)
- (NSString *)YYJSONString
{
    NSData *jsonData = self.YYJSONData;
    if (jsonData)
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (id)yyObjectForKey:(id)key
{
    if (key)
    {
        return [self objectForKey:key];
    }
    return nil;
}
-(id)toModel:(Class)modelClass
{
    if([self isKindOfClass:[NSDictionary class]] && self.count > 0)
    {
        NSDictionary *YYJSONKeyDict = [modelClass YYJSONKeyDict];
        id model = [NSData objectForModelClass:modelClass fromDict:self withJSONKeyDict:YYJSONKeyDict];
        return model;
    }
    return nil;
}
@end

@implementation NSArray (YYJSONHelper)

- (NSString *)YYJSONString
{
    return self.YYJSONData.YYJSONString;
}

/**
*   循环集合将每个对象转为字典，得到字典集合，然后转为jsonData
*/
- (NSData *)YYJSONData
{
    NSMutableArray *jsonDictionaries = [[NSMutableArray alloc] init];
    [self enumerateObjectsUsingBlock:^(NSObject *obj, NSUInteger idx, BOOL *stop) {
        [jsonDictionaries addObject:obj.YYJSONDictionary];
    }];
    if ([NSJSONSerialization isValidJSONObject:jsonDictionaries])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionaries options:NSJSONWritingPrettyPrinted error:&error];
        if (!error)
        {
            return jsonData;
        }
    }
    return nil;
}
-(NSArray *)toModels:(Class)modelClass
{
    if([self isKindOfClass:[NSArray class]] && self.count > 0)
    {
        NSDictionary *YYJSONKeyDict = [modelClass YYJSONKeyDict];
        NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:[self count]];
        [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id model = [NSData objectForModelClass:modelClass fromDict:obj withJSONKeyDict:YYJSONKeyDict];
            [models addObject:model];
        }];
        return models;
    }
    return nil;
}

/**
 *   传入modelClass，返回对应的实例
 */
- (NSMutableArray *)toModelsEx:(Class)modelClass
{
    if([self isKindOfClass:[NSArray class]] && self.count > 0)
    {
        NSDictionary *YYJSONKeyDict = [modelClass YYJSONKeyDict];
        NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:[self count]];
        [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id model = [NSData objectForModelClass:modelClass fromDict:obj withJSONKeyDict:YYJSONKeyDict];
            [models addObject:model];
        }];
        return models;
    }
    return nil;
}
@end

