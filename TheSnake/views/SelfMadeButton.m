//
//  SelfMadeButton.m
//  TheSnake
//
//  Created by JiangXuanke on 2018/10/11.
//  Copyright © 2018年 JiangXuanke. All rights reserved.
//

#import "SelfMadeButton.h"

@implementation SelfMadeButton

- (instancetype)init {
    self = [super init];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 3.0f;
    self.layer.cornerRadius = 5;
    
    [self.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:20.0f]];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return self;
}

@end
