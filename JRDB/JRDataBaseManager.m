//
//  JRDataBase.m
//  JR_Practice_runtime
//
//  Created by Rafael on 15/11/2.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "JRDataBaseManager.h"
#import "JRDataBaseManager+OperationToolsMethod.h"

#pragma mark -  创建数据库
@implementation JRDataBaseManager

/** 单例创建sqlite数据库 */
+ (sqlite3 *)shareDataBase {
    static sqlite3 *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        int result = sqlite3_open(dataBasePath.UTF8String, &db);
        if (result == SQLITE_OK) {
            NSLog(@"数据库创建成功");
            NSLog(@"沙盒 : %@", dataBasePath);
        } else {
            NSLog(@"数据库创建失败");
        }
    });
    return db;
}

/** 开启数据库 */
+ (void)openDB {
    [JRDataBaseManager shareDataBase];
}

/** 关闭数据库 */
+ (void)closeDB {
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int result = sqlite3_close(db);
    if (result == SQLITE_OK) {
        db = nil;
    }
}

- (sqlite3 *)db {
    if (!_db) {
        self.db = [JRDataBaseManager shareDataBase];
    }
    return _db;
}

@end



#pragma mark -  数据库初始化
@implementation JRDataBaseManager (CreateDataBaseTable)

+ (void)createTableWithModelClass:(Class)modelClass {
    // TODO: 从model中获取其属性列表(数据类型，属性名), 返回值为字典数组
    NSMutableArray *arrPptyDic = [self returnPropertiesWithModelClass:modelClass];
    NSString *sqlKeys = @"";
    for (NSUInteger i = 0; i < arrPptyDic.count; i++) {
        NSDictionary *dic = arrPptyDic[i];
        NSString *name = [dic[@"name"] substringFromIndex:1];
        NSString *type = dic[@"type"];
        // TODO: 判断当前属性类型，并转化成数据库的数据类型
        sqlKeys = [NSString stringWithFormat:@"%@, %@ %@", sqlKeys, name, [self makeSqlTableKeysStringWithType:type]];
    }
    // TODO: 拼接成sql语句
    NSString *className = [NSString stringWithFormat:@"%@", modelClass];
    NSString *sqlCreate = [NSString stringWithFormat:@"create table if not exists %@(number integer primary key autoincrement%@)", className, sqlKeys];
    NSLog(@"%@", sqlCreate);
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int result = sqlite3_exec(db, sqlCreate.UTF8String, NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"创建%@表成功", className);
    } else {
        NSLog(@"创建%@表失败", className);
    }
    
}

@end



#pragma mark -  操作数据库
@implementation JRDataBaseManager (OperationSQLiteTable)
/** 向表中添加model */
+ (BOOL)insertDataWithModel:(id)model {
    
    // TODO: 从model中获取其属性列表(数据类型，属性名), 返回值为字典数组
    NSMutableArray *arrPptyDic = [self returnPropertiesWithModel:model];
    
    NSString *sqlName = @"";
    NSString *sqlType = @"";

    for (NSUInteger i = 0; i < arrPptyDic.count; i++) {
        NSDictionary *dic = arrPptyDic[i];
        // 属性名相关操作
        NSString *name = [dic[@"name"] substringFromIndex:1];
        // 属性类型相关操作
        NSString *type = dic[@"type"];
        if (!i) {
            sqlName = [NSString stringWithFormat:@"%@", name];
            sqlType = [NSString stringWithFormat:@"'%@'", [self formatPropertyTypeWithType:type propertyName:name model:model]];
        } else {
            sqlName = [NSString stringWithFormat:@"%@, %@", sqlName, name];
            sqlType = [NSString stringWithFormat:@"%@, '%@'", sqlType, [self formatPropertyTypeWithType:type propertyName:name model:model]];
        }
    }
    
    // TODO: 创建SQL插入语句
    NSString *sqlInsert = [NSString stringWithFormat:@"insert into %@(%@) values(%@)", [model class], sqlName, sqlType];
    
    // 执行sql语句
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int reslut = sqlite3_exec(db, sqlInsert.UTF8String, NULL, NULL, NULL);
    if (reslut == SQLITE_OK) {
        NSLog(@"插入%@成功", [model class]);
        return YES;
    } else {
        NSLog(@"插入%@失败", [model class]);
        return NO;
    }
}

/** 删除表单数据，根据key-value */
+ (BOOL)deleteTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(id)value {
    
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'", modelClass, key, value];
    NSLog(@"%@", sqlDelete);
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int result = sqlite3_exec(db, sqlDelete.UTF8String, NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"执行成功");
        return YES;
    } else {
        NSLog(@"删除失败");
        return NO;
    }
}

/** 删除整个表单数据 */
+ (BOOL)clearTableWithModelClass:(Class)modelClass {
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    NSString *sqlClear = [NSString stringWithFormat:@"delete from %@", modelClass];
    NSString *sqlClearSequence = [NSString stringWithFormat:@"DELETE FROM sqlite_sequence WHERE name = '%@'", modelClass];
    NSLog(@"%@", sqlClear);
    
    int result1 = sqlite3_exec(db, sqlClearSequence.UTF8String, NULL, NULL, NULL);
    int result = sqlite3_exec(db, sqlClear.UTF8String, NULL, NULL, NULL);
    
    if (result == SQLITE_OK || result1 == SQLITE_OK) {
        NSLog(@"清除%@表成功", modelClass);
        return YES;
    } else {
        NSLog(@"清除%@表失败", modelClass);
        return NO;
    }
}

/** 更新数据库key1, value1... */
+ (BOOL)updateTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(id)value setKeyAndValue:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    // 定义一个 va_list 指针访问参数表
    va_list args;
    // 初始化 va_list 指向第一个参数, firstObject为第一个参数
    va_start(args, firstObject);
    NSMutableArray *mArrKey = [@[firstObject] mutableCopy];
    NSMutableArray *mArrValue = [NSMutableArray array];
    id tempObject;
    // 遍历参数list
    int i = 0;
    // va_arg逐个获取参数 自动指向下一个参数
    while ((tempObject = va_arg(args, id))) {
        if(i++ % 2 != 0) {
            // key数组
            [mArrKey addObject:tempObject];
        } else {
            // value数组
            [mArrValue addObject:tempObject];
        }
    }
    va_end(args);
    
    // 更新数据所用字符串
    NSString *setStr = [NSString stringWithKeyArray:mArrKey ValueArray:mArrValue];
    // 更新sql语句
    NSString *sqlUpdate = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'", modelClass, setStr, key, value];
    NSLog(@"%@", sqlUpdate);
    
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int result = sqlite3_exec(db, sqlUpdate.UTF8String, NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"更新%@成功", modelClass);
        return YES;
    } else {
        NSLog(@"更新%@失败", modelClass);
        return NO;
    }
}

/** 查询数据库 */
+ (NSArray *)selectTableWithModelClass:(Class)modelClass {
    // 查询sql语句
    NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@", modelClass];
    // 跟随指针
    sqlite3_stmt *stmt = nil;
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int result = sqlite3_prepare_v2(db, sqlSelect.UTF8String, -1, &stmt, NULL);
    NSLog(@"%@", sqlSelect);
    
    NSMutableArray *arrPptyDic = [self returnPropertiesWithModelClass:modelClass];
    NSMutableArray *modelArr = [NSMutableArray array];
    
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            id model = [[modelClass alloc] init];
            // 遍历数组中的字典, 取出相关的model
            for (int i = 0; i < arrPptyDic.count; i++) {
                NSDictionary *dic = arrPptyDic[i];
                NSString *name = dic[@"name"];
                NSString *type = dic[@"type"];
                model = [self returnModelWithModelClass:modelClass WithModel:model WithName:name WithType:type stmt:stmt index:i + 1];
            }
            [modelArr addObject:model];
        }
    }
    sqlite3_finalize(stmt);
    
    return modelArr;
}

/** 查询数据库通过key-value */
+ (NSArray *)selectTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(NSString *)value {
    // 查询sql语句
    NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'", modelClass, key, value];
    // 跟随指针
    sqlite3_stmt *stmt = nil;
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int result = sqlite3_prepare_v2(db, sqlSelect.UTF8String, -1, &stmt, NULL);
    NSLog(@"%@", sqlSelect);
    
    NSMutableArray *arrPptyDic = [self returnPropertiesWithModelClass:modelClass];
    NSMutableArray *modelArr = [NSMutableArray array];
    
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            id model = [[modelClass alloc] init];
            for (int i = 0; i < arrPptyDic.count; i++) {
                NSDictionary *dic = arrPptyDic[i];
                model = [self returnModelWithModelClass:modelClass WithModel:model WithName:dic[@"name"] WithType:dic[@"type"] stmt:stmt index:i + 1];
            }
            [modelArr addObject:model];
        }
    }
    
    sqlite3_finalize(stmt);
    return modelArr;
}

/** 通过字段查询数据库 */
+ (NSArray *)selectTableWithModelClass:(Class)modelClass withKey:(NSString *)key {
    // 查询表中的字段key
    NSString *sqlSelect = [NSString stringWithFormat:@"select %@ from %@", key, modelClass];
    sqlite3_stmt *stmt = nil;
    sqlite3 *db = [JRDataBaseManager shareDataBase];
    int result = sqlite3_prepare_v2(db, sqlSelect.UTF8String, -1, &stmt, NULL);
    
    // 判断键值在数组中（数据库中）所在的位置
    NSMutableArray *arrPptyDic = [self returnPropertiesWithModelClass:modelClass];
    int index = 0;
    for (int i = 0; i < arrPptyDic.count; i++) {
        NSDictionary *dic = arrPptyDic[i];
        if ([dic[@"name"] isEqualToString:key]) {
            index = i;
            break;
        }
    }
    // 取出对应的值, 返回值均为字符串
    NSMutableArray *keyArr = [NSMutableArray array];
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *key = sqlite3_column_text(stmt, index);
            NSString *keyStr = [NSString stringWithUTF8String:(const char *)key];
            [keyArr addObject:keyStr];
        }
    }
    
    sqlite3_finalize(stmt);
    return keyArr;
}

@end





