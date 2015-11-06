//
//  TestModel.m
//  Demo_JRDB
//
//  Created by JR_Rafael on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel

- (instancetype)initWithStrTest:(NSString *)strTest numTest:(NSNumber *)numTest intTest:(int)intTest floatTest:(float)floatTest longTest:(long)longTest double:(double)doubleTest dataTest:(NSData *)dataTest dicTest:(NSDictionary *)dicTest arrTest:(NSArray *)arrTest {
    self = [super init];
    if (self) {
        self.strTest = strTest;
        self.numTest = numTest;
        self.intTest = intTest;
        self.floatTest = floatTest;
        self.longTest = longTest;
        self.doubleTest = doubleTest;
        self.dataTest = dataTest;
        self.dicTest = dicTest;
        self.arrTest = arrTest;
    }
    return self;
}

+ (TestModel *)testModelWithStrTest:(NSString *)strTest numTest:(NSNumber *)numTest intTest:(int)intTest floatTest:(float)floatTest longTest:(long)longTest double:(double)doubleTest dataTest:(NSData *)dataTest dicTest:(NSDictionary *)dicTest arrTest:(NSArray *)arrTest {
    return [[TestModel alloc] initWithStrTest:strTest numTest:numTest intTest:intTest floatTest:floatTest longTest:longTest double:doubleTest dataTest:dataTest dicTest:dicTest arrTest:arrTest];
}


@end
