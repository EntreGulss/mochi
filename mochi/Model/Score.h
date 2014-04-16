//
//  Score.h
//  mochi
//
//  Created by 大竹 雅登 on 12/12/30.
//  Copyright (c) 2012年 大竹 雅登. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber* score; // 得点
@property (nonatomic, strong) NSNumber* sequence; // 連続回数
@property (nonatomic, strong) NSString* userName; // ユーザ名


// スコアを編集する操作は、メソッド経由で行う
- (void)setUserName:(NSString *)userName;
- (void)addScore:(int)addValue;
- (void)updateSequence:(int)sequence;

@end
