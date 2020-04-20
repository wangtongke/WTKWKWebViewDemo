//
//  TKJSMethodManager.m
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/4/1.
//  Copyright © 2020 王同科. All rights reserved.
//

#import "TKJSMethodManager.h"
#import <objc/runtime.h>

@interface TKJSMethodManager ()
@property(nonatomic, strong)id impObj;
@property(nonatomic, strong)NSMutableDictionary *methodList;
@end

@implementation TKJSMethodManager


- (WKUserScript *)createUserScript:(id)obj forKeyedSubscript:(NSString *)key {
    self.impObj = obj;
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[self createJSCode:obj subscriptKey:key] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    return userScript;
}
- (void)exeMethodWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    if (defaultText.length > 0) {
        NSData * jsonData = [defaultText dataUsingEncoding:NSUTF8StringEncoding];
            //json解析
        arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
    NSString *methodName = prompt;
    SEL ssel = [self createSEL:methodName param:arr];
    if (!ssel) {
        // 不能执行此方法
        completionHandler(@"");
        return;
    }
    id result = [self performSelector:ssel withObjects:arr];
    if (result == nil) {
        result = @"";
    }
    completionHandler([NSString stringWithFormat:@"%@", result]);
}

- (SEL)createSEL:(NSString *)methodName param:(NSArray *)arr {
    SEL ssel = NSSelectorFromString(methodName);
    if (![self.impObj respondsToSelector:(ssel)]) {
        NSString *cacheName = _methodList[methodName];
        ssel = NSSelectorFromString(cacheName);
        if ([self.impObj respondsToSelector:(ssel)]) {
            return ssel;
        }
    }
    return nil;
}

- (id)performSelector:(SEL)selector withObjects:(NSArray *)objects
{
    // 方法签名(方法的描述)
    NSMethodSignature *signature = [[self.impObj class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        NSLog(@"调用该方法异常");
        //可以抛出异常也可以不操作。
        return nil;
    }
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.impObj;
    invocation.selector = selector;
    
    // 设置参数
    NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    paramsCount = MIN(paramsCount, objects.count);
    for (NSInteger i = 0; i < paramsCount; i++) {
        [self setArgument:invocation index:i type:objects];
    }
    // 调用方法
    [invocation invoke];
    // 获取返回值
    id returnValue = nil;
    if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
//        获取返回值类型
        NSString *returnType = [[NSString alloc]initWithCString:signature.methodReturnType encoding:NSUTF8StringEncoding];
        returnValue = [self getResultFor:invocation type:returnType];
    }
    return returnValue;
}
-(void)setArgument:(NSInvocation *)invocation index: (NSInteger)index type: (NSArray *)arr{
    const char* name_s = [invocation.methodSignature getArgumentTypeAtIndex:index + 2];
    NSString *type = [NSString stringWithUTF8String:name_s];
    type = [type lowercaseString];
    id object = arr[index];
    if ([object isKindOfClass:[NSNull class]]) {
        NSLog(@"接受到的参数为null类型");
        return;
    }
    if ([type isEqualToString:@"c"]) {
        NSNumber *value = arr[index];
        char object = [value charValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"i"]) {
        // int
        NSNumber *value = arr[index];
        int object = [value intValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"s"]) {
        // short
        NSNumber *value = arr[index];
        short object = [value shortValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"l"]) {
        // long
        NSNumber *value = arr[index];
        long object = [value longValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"q"]) {
        // longlong
        NSNumber *value = arr[index];
        long long object = [value longLongValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"f"]) {
        // float
        NSNumber *value = arr[index];
        float object = [value floatValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"d"]) {
        // CGFloat double
        NSNumber *value = arr[index];
        CGFloat object = [value doubleValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"b"]) {
        // bool
        NSNumber *value = arr[index];
        bool object = [value boolValue];
        [invocation setArgument:&object atIndex:index + 2];
    } else if ([type isEqualToString:@"@"]) {
        // 对象
        id object = arr[index];
        if (![object isKindOfClass:[NSString class]]) {
            // 接受到的参数不是字符串类型
            id o = [NSString stringWithFormat:@"%@", object];
            [invocation setArgument:&o atIndex:index + 2];
            return;
        }
        [invocation setArgument:&object atIndex:index + 2];
    }
}
-(id)getResultFor:(NSInvocation *)invocation type: (NSString *)type {
    
    type = [type lowercaseString];
    id result = nil;
    if ([type isEqualToString:@"c"]) {
        // char
        char value = 'c';
        [invocation getReturnValue:&value];
        return [NSNumber numberWithChar:value];
    } else if ([type isEqualToString:@"i"]) {
        // int
        int value = 0;
        [invocation getReturnValue:&value];
        return [NSNumber numberWithInt:value];
    } else if ([type isEqualToString:@"s"]) {
        // short
        short value = 0;
        [invocation getReturnValue:&value];
        return [NSNumber numberWithShort:value];
    } else if ([type isEqualToString:@"l"]) {
        // long
        long value = 0;
        [invocation getReturnValue:&value];
        return [NSNumber numberWithLong:value];
    } else if ([type isEqualToString:@"q"]) {
        // longlong
        long long value = 0;
        [invocation getReturnValue:&value];
        return [NSNumber numberWithLongLong:value];
    } else if ([type isEqualToString:@"f"]) {
        // float
        float value = 0;
        [invocation getReturnValue:&value];
        return [NSNumber numberWithFloat:value];
    } else if ([type isEqualToString:@"d"]) {
        // CGFloat double
        CGFloat value = 0;
        [invocation getReturnValue:&value];
        return [NSNumber numberWithDouble:value];
    } else if ([type isEqualToString:@"b"]) {
        // bool
        BOOL value = 0;
        [invocation getReturnValue:&value];
        return [NSNumber numberWithBool:value];
    } else if ([type isEqualToString:@"@"]) {
        // 对象
        id value = 0;
        [invocation getReturnValue:&value];
        return value;
    }
    return result;
}

- (NSString *)createJSCode:(id)obj subscriptKey:(NSString *)key {
    NSString * code = [NSString stringWithFormat:@"var %@ = {};", key];
    unsigned int methodCount =0;
    
    Method* methodList = class_copyMethodList([obj class],&methodCount);
    NSMutableArray *methodsArray = [NSMutableArray arrayWithCapacity:methodCount];
    
    for(int i=0;i<methodCount;i++)
    {
        Method temp = methodList[i];
        const char* name_s = sel_getName(method_getName(temp));
        NSString *methodName = [NSString stringWithUTF8String:name_s];
        if ([methodName isEqualToString:@"init"] || [methodName hasPrefix:@"."]) {
            continue;
        }
        char *returnType = method_copyReturnType(temp);
        NSString *rStr = [[NSString alloc]initWithCString:returnType encoding:NSUTF8StringEncoding];
        free(returnType);
        code = [NSString stringWithFormat:@"%@%@", code, [self createMethodCode:methodName forKey:key returnType:rStr]];
        [methodsArray addObject:[NSString stringWithUTF8String:name_s]];
    }
    free(methodList);
    return code;
}

- (NSString *)createMethodCode:(NSString *)methodStr forKey:(NSString *)key returnType: (NSString *)type {
    
    NSString * code = @"";
    NSArray *arr = [methodStr componentsSeparatedByString:@":"];
    NSString *param = @"";
    for (int index = 0; index < arr.count; index++) {
        param = [NSString stringWithFormat:@"%@param%d,", param, index];
    }
    if ([param hasSuffix:@","]) {
        param = [param substringToIndex:param.length - 1];
    }
    NSString * firName = arr.firstObject;
    self.methodList[firName] = methodStr;
    code = [NSString stringWithFormat:@"%@.%@ = function(%@) {var secParam = JSON.stringify([%@]); ", key, firName, param, param];
    if ([type isEqualToString:@"d"] || [type isEqualToString:@"q"] || [type isEqualToString:@"f"] || [type isEqualToString:@"i"] || [type isEqualToString:@"l"]) {
        code = [NSString stringWithFormat:@"%@ return parseFloat(window.prompt(\"%@\", secParam))", code, firName];
    } else {
        code = [NSString stringWithFormat:@"%@ return window.prompt(\"%@\", secParam)", code, firName];
    }
    code = [NSString stringWithFormat:@"%@};", code];
    return code;
}

- (NSDictionary *)methodList {
    if (!_methodList) {
        _methodList = [[NSMutableDictionary alloc] init];
    }
    return _methodList;
}

- (void)dealloc
{
    NSLog(@"TKJSMethodManager释放了");
}
@end

@implementation WKWebView(tk)
- (TKJSMethodManager *)tk_addUserScript:(id)obj forKeyedSubscript:(NSString *)key {
    TKJSMethodManager *manager = [[TKJSMethodManager alloc]init];
    WKUserScript *userScript = [manager createUserScript:obj forKeyedSubscript:key];
    [self.configuration.userContentController addUserScript:userScript];
    return manager;
}

@end

