//
//  TestModel.h
//  Demo_JRDB
//
//  Created by JR_Rafael on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject

@property (nonatomic, retain) NSString *strTest;
@property (nonatomic, retain) NSNumber *numTest;
@property (nonatomic, assign) int intTest;
@property (nonatomic, assign) float floatTest;
@property (nonatomic, assign) long longTest;
@property (nonatomic, assign) double doubleTest;
@property (nonatomic, retain) NSData *dataTest;
@property (nonatomic, retain) NSDictionary *dicTest;
@property (nonatomic, retain) NSArray *arrTest;

- (instancetype)initWithStrTest:(NSString *)strTest numTest:(NSNumber *)numTest intTest:(int)intTest floatTest:(float)floatTest longTest:(long)longTest double:(double)doubleTest dataTest:(NSData *)dataTest dicTest:(NSDictionary *)dicTest arrTest:(NSArray *)arrTest;

+ (TestModel *)testModelWithStrTest:(NSString *)strTest numTest:(NSNumber *)numTest intTest:(int)intTest floatTest:(float)floatTest longTest:(long)longTest double:(double)doubleTest dataTest:(NSData *)dataTest dicTest:(NSDictionary *)dicTest arrTest:(NSArray *)arrTest;

@end
