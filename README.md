# JRDB
JRDB - based on the universal database sqlite3 encapsulation
# 基于sqlite3的通用数据库封装
>* 说明：
>	* 本文介绍JRDB的相关用法以及简单的实现原理。
>	* Categories：
>		* JRDataBaseManager (CreateDataBaseTable)
>		* JRDataBaseManager (OperationSQLiteTable)
>* 此文章由 @JR_Rafael 编写. 若转载此文章，请注明出处和作者

**注意事项：此类需要将Build Setting下 Enable Strict Checking of objc_msgSend Calls 改为Yes，才可以正常使用。**

## 开发者说明：
JRDB对于sqlite3的封装与其他类对于数据库的封装不同，**其中最主要的区别就是开发者在使用此类时不需要再次封装来适应不同的数据模型。**现有的iOS相关数据库封装包括基本的sqlite3都必须要进行二次封装甚至多次封装才能满足程序对于数据库的需求。**而在大多数的程序中数据库的表单还有其对表单进行的一些基本操作往往会有多套方法，这就导致了在运用数据库进行操作的时候方法过多，封装冗杂。**

此次封装的JRDB可以有效避免此类问题，封装所提供的方法很少，但可以满足一个程序对数据库的一切基本要求。**JRDB是一种基于sqlite3的通用数据库方法的封装，**他所提供的方法适用于大多数形式的数据模型，开发者仅需要提供数据模型的类就可以进行_**创建表单，添加表单数据，删除表单数据，删除表单，通过条件修改表单，查询表单数据等**_操作。方法清晰明了，使用简便，特别适用于轻量级，复杂成度一般的数据库需求。


##JRDatabaseManager Define
> * 沙盒路径

```oc
#define dataBasePath [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)) lastObject]stringByAppendingPathComponent:dataBaseName]
```
> * 数据库名称，包括App名称与版本名

```oc
#define dataBaseName @"YourAppx.x.x.sqlite"
```


##JRdataBaseManager Property
> * 返回数据库单例属性
> * @property (nonatomic, assign) sqlite3 *db; 

## JRDataBaseManager Class Methods
### Create a sqlite3 DataBase -	创建一个sqlite3的数据库
1 . + (sqlite3 *)shareDataBase;
> * 创建单例数据库

2 . + (void)closeDB;
> * 关闭数据库

3 . + (void)openDB;
> * 开启数据库 



## JRDataBaseManager Category
### CreateDataBaseTable -	创建表单
#### + (void) createTableWithModelClass:(Class)modelClass;
> * 创建数据库表单
>  * 参数：要建表的数据模型的类

**Introduction:** 参数一定要用Class类型，创建表单之后控制台输出建表成功与否。

### OperationSQLiteTable -	对表单进行操作
#### + (BOOL)insertDataWithModel:(id)model;
> * 向数据库表单中插入数据
> * 参数：任意对象类型，可用于任意的数据模型对象插入
> * 返回值：是否插入成功

**Introduction:** 如果当前表中有相同的数据，一样进行插入操作。

#### + (BOOL)deleteTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(id)value;
> * 从数据库表单中删除数据
> * 参数1：类名，确定从哪个表单中进行删除
> * 参数2：key值，确定所在表单中的key
> * 参数3：value值，确定所在表单中与key值所对应的value值
> * 返回值：是否删除成功

**Introduction:** 确定表单之后，当key = value时，进行删除数据操作。

#### + (BOOL)clearTableWithModelClass:(Class)modelClass;
> * 删除整个数据库表单
> * 参数：类名，确定在数据库中删除的表单
> * 返回值：是否删除成功

**Introduction:** 在删除这个表单之后同样会对其主键包括sqlite_sequence进行清除，以便于再下一次创建表单时重置数据库。

#### + (BOOL)updateTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(id)value setKeyAndValue:(id)firstObject, ...NS_ REQUIRES_ NIL_TERMINATION;
> * 更新表单数据
> * 参数1：类名，确定所要更新的表单
> * 参数2：key值，确定所在表单中的key
> * 参数3：value值，确定所在表单中与key值所对应的value值
> * 参数4：多参数，类型为id，用于更新表单数据，其输入格式为(@"key1", @"value1", @"key2", @"value2"...)，**注: 与字典键值输入相反**
> * 返回值：是否更新成功

**Introduction:** 如果要想在表单中存入非对象的数据，在更新过程中需要转化为对象再进行存入，键值对要一一对应。

#### + (NSArray *)selectTableWithModelClass:(Class)modelClass;
> * 查询数据库表单数据
> * 参数：类名，确定需要查询的数据库表单
> * 返回值：表单中所有的数据模型，用数组进行返回

**Introduction:** 返回所有表单数据的方法，也适用于非对象类型的数据模型。

#### + (NSArray *)selectTableWithModelClass:(Class)modelClass withKey:(NSString *)key;
> * 通过条件查询数据库表单数据
> * 参数1：类名，确定需要查询的数据库表单
> * 参数2：key值，确定所在表单中的key
> * 返回值：表单中所有数据模型中key所对应的值，用数组进行返回

**Introduction:** 取出的是表单中一列的数据(key)，用数组进行返回。

#### + (NSArray *)selectTableWithModelClass:(Class)modelClass whereKey:(NSString *)key isValue:(NSString *)value;
> * 通过条件查询数据库表单数据
> * 参数1：类名，确定需要查询的数据库表单
> * 参数2：key值，确定所在表单中的key
> * 参数3：value值，确定所在表单中与key值所对应的value值
> * 返回值：通过key-value条件查询数据库表单，用数据进行返回

**Introduction:** 取出表单中满足key-value条件的数据模型，条件查询，数组返回。

以上为JRDB对sqlite3数据库的封装方法，如有意见或问题请及时与我联系：
> * Email1：JR_Rafael@163.com
> * Email2：rafeal_mac@me.com

### GitHub address: https://github.com/JRRafaels/JRDB.git

