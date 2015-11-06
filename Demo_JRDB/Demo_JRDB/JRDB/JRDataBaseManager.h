//
//  JRDataBase.h
//  JR_Practice_runtime
//
//  Created by Rafael on 15/11/2.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <UIKit/UIKit.h>

/** 沙盒路径 */
#define dataBasePath [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)) lastObject]stringByAppendingPathComponent:dataBaseName]
/** 修改你的数据库名称和版本 */
#define dataBaseName @"YourAppx.x.x.sqlite"



#pragma mark -  创建数据库
@interface JRDataBaseManager : NSObject

@property (nonatomic, assign) sqlite3 *db; /**< 单例数据库 */

/**
 *  单例创建sqlite3数据库
 *
 *  @return 返回sqlite3单例数据库
 */
+ (sqlite3 *)shareDataBase;

/**
 *  关闭数据库
 */
+ (void)closeDB;
/**
 *  开启数据库
 */
+ (void)openDB;

@end



#pragma mark -  数据库初始化
@interface JRDataBaseManager (CreateDataBaseTable)

/**
 *  根据model创建数据库表单
 *
 *  @param model 需要建表的model
 */
+ (void)createTableWithModelClass:(Class)modelClass;

@end



#pragma mark -  数据库表单操作
@interface JRDataBaseManager (OperationSQLiteTable)

/**
 *  向数据库中插入Model
 *
 *  @param model 待插入的model
 *
 *  @return 插入是否成功
 */
+ (BOOL)insertDataWithModel:(id)model;

/**
 *  从表单中删除一条Model数据
 *
 *  @param modelClass 对应表单类
 *  @param key        对应表单key
 *  @param value      对应表单value
 *
 *  @return 执行删除是否成功
 */
+ (BOOL)deleteTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(id)value;

/**
 *  删除整个表单
 *
 *  @param modelClass 对应表单类
 *
 *  @return 执行清除是否成功
 */
+ (BOOL)clearTableWithModelClass:(Class)modelClass;

/**
 *  更新表单数据(key1, value1, key2, value2...)
 *
 *  @param modelClass  需要更新的表单类
 *  @param key         所对应条件的key
 *  @param value       所对应条件的value
 *  @param firstObject 第一个key，从key开始key1, value1, key2, value2...
 *
 *  @return 更新执行结果
 */
+ (BOOL)updateTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(id)value setKeyAndValue:(id)firstObject, ...NS_REQUIRES_NIL_TERMINATION;

/**
 *  查询数据库表单
 *
 *  @param modelClass 类名
 *
 *  @return 所有数据模型的数组
 */
+ (NSArray *)selectTableWithModelClass:(Class)modelClass;

/**
 *  查询数据库_一种键值的数据
 *
 *  @param modelClass 类名
 *  @param key        键
 *
 *  @return 查询结果的数组(NSString *)
 */
+ (NSArray *)selectTableWithModelClass:(Class)modelClass withKey:(NSString *)key;

/**
 *  查询数据库_key-value
 *
 *  @param modelClass 类名
 *  @param key        键
 *  @param value      值
 *
 *  @return 查询结果的数据模型数组
 */
+ (NSArray *)selectTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(NSString *)value;

@end


