//
//  Score.m
//  mochi
//
//  Created by 大竹 雅登 on 12/12/30.
//  Copyright (c) 2012年 大竹 雅登. All rights reserved.
//

#import "Score.h"

@implementation Score

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    // 初期化
    _score = [NSNumber numberWithInt:0]; 
    _sequence = [NSNumber numberWithInt:0];
    _userName = @"NO NAME"; 
    
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // インスタンス変数をデコードする
    _score = [decoder decodeObjectForKey:@"score"];
    _sequence = [decoder decodeObjectForKey:@"sequence"];
    _userName = [decoder decodeObjectForKey:@"userName"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    // インスタンス変数をエンコードする
    [encoder encodeObject:_score forKey:@"score"];
    [encoder encodeObject:_sequence forKey:@"sequence"];
    [encoder encodeObject:_userName forKey:@"userName"];
}

#pragma mark - Set User Name -
- (void)setUserName:(NSString *)userName {
    _userName = userName;
}

#pragma mark - Add Score -
// 加える
- (void)addScore:(int)addValue {
    _score = [NSNumber numberWithInt:[_score intValue] + addValue];
}

#pragma mark - Update Sequence -
// 更新する（引数の値が代入される）
- (void)updateSequence:(int)sequence {
    _sequence = [NSNumber numberWithInt:sequence];
}


@end
