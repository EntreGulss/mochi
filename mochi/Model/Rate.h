//
//  Rate.h
//  mochi
//
//  Created by 大竹 雅登 on 13/01/07.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rate : NSObject

@property (nonatomic, assign) int scoreRate;  // 得点の倍率
@property (nonatomic, assign) float speedRate; // 速さの倍率
@property (nonatomic, assign) int sequence; // 連続回数
@property (nonatomic, assign) float moreValueForTrash; // ゴミを取り除いたときの倍率

// rateの編集メソッドを作る必要があるかも？

@end
