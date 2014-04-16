//
//  Rate.m
//  mochi
//
//  Created by 大竹 雅登 on 13/01/07.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import "Rate.h"

@implementation Rate

- (id)init {
    if (!self) {
        return nil;
    }
    // 初期化
    _speedRate = 1.0;
    _scoreRate = 1;
    _sequence = 0;
    _moreValueForTrash = 1.0;

    return self;
}

@end
