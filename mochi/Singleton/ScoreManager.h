//
//  ScoreManager.h
//  mochi
//
//  Created by 大竹 雅登 on 12/12/30.
//  Copyright (c) 2012年 大竹 雅登. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Score.h"

@interface ScoreManager : NSObject

@property (nonatomic, readonly) NSMutableDictionary* scoreDic;
@property (nonatomic, readonly) Score* maxScore;
@property (nonatomic, readonly) Score* lastScore;

// 初期化
+ (ScoreManager*)sharedManager;

// スコアの更新
- (void)updateMaxScore:(Score*)nowScore;
- (void)updateLastScore:(Score*)nowScore;


// 永続化
- (void)load;
- (void)save;


@end
