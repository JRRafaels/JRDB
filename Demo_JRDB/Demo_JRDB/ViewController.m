//
//  ViewController.m
//  Demo_JRDB
//
//  Created by JR_Rafael on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "ViewController.h"
#import "JRDataBaseManager.h"
#import "TestModel.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [JRDataBaseManager createTableWithModelClass:[TestModel class]];
    
    
}

- (IBAction)insertAction:(id)sender {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", @"value2", @"key2", nil];
    NSArray *arr = [NSArray arrayWithObjects:@"obj1", @"obj2", nil];
    
    [JRDataBaseManager insertDataWithModel:[TestModel testModelWithStrTest:@"小明" numTest:@18 intTest:20 floatTest:1.8 longTest:13888888888 double:3.141592654321 dataTest:[NSData data] dicTest:dic arrTest:arr]];
}

- (IBAction)deleteAction:(id)sender {
    
}

- (IBAction)updateAction:(id)sender {
    
}

- (IBAction)clearAction:(id)sender {
    [JRDataBaseManager clearTableWithModelClass:[TestModel class]];
}

- (IBAction)selectAction:(id)sender {
    NSArray * arr = [JRDataBaseManager selectTableWithModelClass:[TestModel class]];
    for (TestModel *model in arr) {
        NSLog(@"%@", model);
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
