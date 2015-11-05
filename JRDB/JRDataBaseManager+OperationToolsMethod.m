//
//  JRDataBaseManager+OperationToolsMethod.m
//  JR_Practice_runtime
//
//  Created by Rafael on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "JRDataBaseManager+OperationToolsMethod.h"
#import <objc/objc-runtime.h>
#import <objc/message.h>

@implementation JRDataBaseManager (OperationToolsMethod)

#pragma mark -  数据库工具方法(实现)
/** 通过model来返回model的属性数组 */
+ (NSMutableArray *)returnPropertiesWithModel:(id)model {
    
    unsigned int count;
    
    Ivar *ivarList = class_copyIvarList([model class], &count);
    NSMutableArray *arrayDic = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        
        NSMutableDictionary *dicProperties = [NSMutableDictionary dictionary];
        Ivar ivar = *(ivarList + i);
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        NSString *type1 = [NSString formatStringTypeWithString:type];
        [dicProperties setObject:name forKey:@"name"];
        [dicProperties setObject:type1 forKey:@"type"];
        [arrayDic addObject:dicProperties];
    }
    return arrayDic;
}

/** 通过类来返回model类的属性数组(字典中两个键值对，属性名和属性类型) */
+ (NSMutableArray *)returnPropertiesWithModelClass:(Class)modelClass {
    // 保存属性个数
    unsigned int count;
    
    // TODO: 获取当前类名从而获取到当前类属性的各种信息
    //    NSString *className = [NSString stringWithFormat:@"%@", [model class]];
    //    objc_property_t *property = class_copyPropertyList(objc_getClass(className.UTF8String), &count);
    
    Ivar *ivarList = class_copyIvarList(modelClass, &count);
    NSMutableArray *arrayDic = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        
        NSMutableDictionary *dicProperties = [NSMutableDictionary dictionary];
        Ivar ivar = *(ivarList + i);
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        //        objc_property_t ppty = *(property + i);
        // FIXME: Attributes可以或许到当前属性的类型、特性还有成员变量名
        //        NSLog(@"%s, %s", property_getName(ppty), property_getAttributes(ppty));
        
        NSString *type1 = [NSString formatStringTypeWithString:type];
        [dicProperties setObject:name forKey:@"name"];
        [dicProperties setObject:type1 forKey:@"type"];
        [arrayDic addObject:dicProperties];
    }
    return arrayDic;
}

/** 获取创建表单的数据库keys字符串 */
+ (NSString *)makeSqlTableKeysStringWithType:(NSString *)type {
    // 判断具体是什么类型 从而进行转化
    if ([type isEqualToString:@"d"] || [type isEqualToString:@"f"]) {
        return @"real";
    } else if ([type isEqualToString:@"i"] || [type isEqualToString:@"q"] || [type isEqualToString:@"Q"] || [type isEqualToString:@"B"]){
        return @"integer";
    } else {
        return @"text";
    }
}

/** 查询数据库获取model */
+ (id)returnModelWithModelClass:(Class)modelClass WithModel:(id)model WithName:(NSString *)name WithType:(NSString *)type stmt:(sqlite3_stmt *)stmt index:(int)i {
    
    name = [name substringFromIndex:1];
    
    NSString *selStr = [NSString stringWithFormat:@"set%@:", [name firstCapitalizedString]];
    
    if ([type isEqualToString:@"f"]) {
        float temp = sqlite3_column_double(stmt, i);
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, temp);
        
    } else if ([type isEqualToString:@"d"]) {
        CGFloat temp = sqlite3_column_double(stmt, i);
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, temp);
        
    } else if ([type isEqualToString:@"i"]) {
        int temp = sqlite3_column_int(stmt, i);
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, temp);
        
    } else if ([type isEqualToString:@"B"]) {
        BOOL temp = sqlite3_column_int(stmt, i);
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, temp);
        
    } else if ([type isEqualToString:@"q"]) {
        long temp = sqlite3_column_int64(stmt, i);
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, temp);
        
    } else if ([type isEqualToString:@"Q"]) {
        unsigned long temp = sqlite3_column_int64(stmt, i);
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, temp);
        
    } else if ([type isEqualToString:@"NSString"]) {
        const unsigned char *temp = sqlite3_column_text(stmt, i);
        NSString *temp1 = [NSString stringWithUTF8String:(const char *)temp];
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, temp1);
        
    } else if ([type isEqualToString:@"NSNumber"]) {
        int temp = sqlite3_column_int(stmt, i);
        NSNumber *tempNumber = [NSNumber numberWithInt:temp];
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, tempNumber);
        
    } else if ([type isEqualToString:@"NSValue"]) {
        const unsigned char *temp = sqlite3_column_text(stmt, i);
        NSValue *value = [NSValue valueWithPointer:temp];
        SEL setSel = NSSelectorFromString(selStr);
        objc_msgSend(model, setSel, value);
    }
    return model;
}

/* 获取插入model时的数据占位符字符串 */
+ (NSString *)makeSqlInsertKeysStringWithType:(NSString *)type {
    // 判断具体是什么类型 从而进行转化
    if ([type isEqualToString:@"d"] || [type isEqualToString:@"f"]) {
        return @"'%f'";
    } else if ([type isEqualToString:@"i"] || [type isEqualToString:@"q"] || [type isEqualToString:@"Q"] || [type isEqualToString:@"B"]){
        return @"'%d'";
    } else {
        return @"'%@'";
    }
}

/** 逐个返回model属性的值 */
+ (NSString *)formatPropertyTypeWithType:(NSString *)type propertyName:(NSString *)name model:(id)model {
    // TODO: 进行判断，因为model的属性数据类型不确定，取值要转成字符串的占位符不确定
    if ([type isEqualToString:@"B"]) {
        NSString *str = [NSString stringWithFormat:@"%d", [[model valueForKey:name] boolValue]];
        return str;
    } else if ([type isEqualToString:@"i"]) {
        NSString *str = [NSString stringWithFormat:@"%d", [[model valueForKey:name] intValue]];
        return str;
    } else if ([type isEqualToString:@"f"]) {
        NSString *str = [NSString stringWithFormat:@"%.2f", [[model valueForKey:name] floatValue]];
        return str;
    } else if ([type isEqualToString:@"NSString"]) {
        NSString *str = [NSString stringWithFormat:@"%@", [model valueForKey:name]];
        return str;
    } else if ([type isEqualToString:@"NSNumber"]) {
        NSString *str = [NSString stringWithFormat:@"%@", [model valueForKey:name]];
        return str;
    } else if ([type isEqualToString:@"d"]) {
        NSString *str = [NSString stringWithFormat:@"%.2f", [[model valueForKey:name] floatValue]];
        return str;
    } else if ([type isEqualToString:@"NSValue"]) {
        NSString *str = [NSString stringWithFormat:@"%@", [model valueForKey:name]];
        return str;
    } else if ([type isEqualToString:@"q"]) {
        NSString *str = [NSString stringWithFormat:@"%ld", [[model valueForKey:name] longValue]];
        return str;
    } else if ([type isEqualToString:@"Q"]) {
        NSString *str = [NSString stringWithFormat:@"%lu",[[model valueForKey:name] unsignedLongValue]];
        return str;
    } else {
        return nil;
    }
}

@end



#pragma mark -  NSString添加方法
@implementation NSString (FormatStringType)
/** 转化runtime中OC数据类型 */
+ (NSString *)formatStringTypeWithString:(NSString *)string {
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\"@"];
    //    NSLog(@"%@", [string stringByTrimmingCharactersInSet:set]);
    
    return [string stringByTrimmingCharactersInSet:set];
}

+ (NSString *)stringWithKeyArray:(NSArray *)arrayKey ValueArray:(NSArray *)arrayValue {
    NSString *str = @"";
    for (int i = 0; i < arrayKey.count; i++) {
        if (!i) {
            str = [NSString stringWithFormat:@"%@ = '%@'", arrayKey[i], arrayValue[i]];
        } else {
            str = [NSString stringWithFormat:@"%@, %@ = '%@'", str, arrayKey[i], arrayValue[i]];
        }
    }
    return str;
}

- (NSString *)firstCapitalizedString {
    NSString *firstLetter = [[self substringToIndex:1] capitalizedString];
    NSString *subWord = [self substringFromIndex:1];
    NSString *str = [NSString stringWithFormat:@"%@%@", firstLetter, subWord];
    return str;
}

@end
