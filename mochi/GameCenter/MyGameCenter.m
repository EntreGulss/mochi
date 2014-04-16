//
//  MyGameCenter.m
//  mochi
//
//  Created by 大竹 雅登 on 13/01/25.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import "MyGameCenter.h"

@implementation MyGameCenter

static MyGameCenter *_sharedInstance = nil;

+ (id)alloc
{
    @synchronized(self)
    {
        NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of the singleton: GameKitHelper");
        _sharedInstance = [super alloc];
        return _sharedInstance;
    }
    return nil;
}

+ (MyGameCenter*)sharedManager
{
    @synchronized(self)
    {
        if (_sharedInstance == nil)
        {
            _sharedInstance = [[MyGameCenter alloc] init];
        }
        
        return _sharedInstance;
    }
    return nil;
}

// スコアを投稿
- (void)submitScore:(int)score category:(NSString*)category {
    NSLog(@"submit");
    if (_localPlayer.isAuthenticated) {
        GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"takumikun_mochitsuki"];
        scoreReporter.value = score;
        // スコアを投稿する
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                // 報告エラーの処理
                NSLog(@"error %@",error);
            }
        }];
    }   
}

// GameCenterにログイン
- (void)loginGameCenter {
    _localPlayer = [GKLocalPlayer localPlayer];
    [_localPlayer authenticateWithCompletionHandler:^(NSError* error) {
        if (_localPlayer.isAuthenticated)
        {
            NSLog(@"ログイン状態");
        }
        else {
            NSLog(@"ログアウト状態");
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用停止中"
//                                                                message:@"Game Centerアプリからログインしてください"
//                                                               delegate:self
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//            [alertView show];
        }
    }];
}

@end
