//
//  JRDataBaseManager+OperationToolsMethod.h
//  JR_Practice_runtime
//
//  Created by Rafael on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "JRDataBaseManager.h"

@interface JRDataBaseManager (OperationToolsMethod)

#pragma mark -  数据库工具方法(接口)
/** 通过model来返回model的属性数组(字典中两个键值对，属性名和属性类型) */
+ (NSMutableArray *)returnPropertiesWithModel:(id)model;

/** 通过类来返回model类的属性数组(字典中两个键值对，属性名和属性类型) */
+ (NSMutableArray *)returnPropertiesWithModelClass:(Class)modelClass;

/** 获取创建表单的数据库keys字符串 */
+ (NSString *)makeSqlTableKeysStringWithType:(NSString *)type;

/** 查询数据库获取model(配合循环对model的各个属性进行赋值) */
+ (id)returnModelWithModelClass:(Class)modelClass WithModel:(id)model WithName:(NSString *)name WithType:(NSString *)type stmt:(sqlite3_stmt *)stmt index:(int)i;

/** 获取插入model时的数据占位符字符串(后期废弃方法) */
+ (NSString *)makeSqlInsertKeysStringWithType:(NSString *)type;

/** 逐个返回model属性的值 */
+ (id)formatPropertyTypeWithType:(NSString *)type propertyName:(NSString *)name model:(id)model;

@end



#pragma mark -  NSString Category
@interface NSString (FormatStringType)

+ (NSString *)formatStringTypeWithString:(NSString *)string;
+ (NSString *)stringWithKeyArray:(NSArray *)arrayKey ValueArray:(NSArray *)arrayValue;
/** 只首字母大写 */
- (NSString *)firstCapitalizedString;

@end
