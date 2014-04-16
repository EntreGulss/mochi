//
//  AppDelegate.m
//  mochi
//
//  Created by 大竹 雅登 on 12/12/28.
//  Copyright (c) 2012年 大竹 雅登. All rights reserved.
//

#import "AppDelegate.h"

#import "ScoreManager.h"

// ======= Game Center =======
#import <GameKit/GameKit.h>
#import "MyGameCenter.h"
// ===========================

@implementation AppDelegate

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

static AppDelegate* _sharaedInstance = nil;

+ (AppDelegate*)sharedController
{
    return _sharaedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
	// 共用インスタンスの設定
	_sharaedInstance = self;
    
	return self;
}

//--------------------------------------------------------------//
#pragma mark -- UIApplicationDelegate --
//--------------------------------------------------------------//

// アプリの初期化処理
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // データを読み込む
    [[ScoreManager sharedManager] load];
    
    // ==== Game Center Login ====
    [[MyGameCenter sharedManager] loginGameCenter];
    // ===========================
    
    // ===== 初回起動時の処理 =======
    // ロードしたことあるバージョンを調べる
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float loadedVersion = [[defaults objectForKey:@"version"] floatValue];
    // このバンドルのバージョンを調べる
    float bundleVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
    
    // バージョンアップされてればバージョンアップ情報を表示
    if (!loadedVersion || bundleVersion > loadedVersion) {
        NSLog(@"初回起動時");
        // アラート表示
        NSString *titleStr = @"匠くんの餅つき v1.1";
        NSString *bodyStr = @"世界ランキングに対応しました！\nNo.1を目指しましょう！";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleStr
                                                            message:bodyStr
                                                           delegate:self
                                                  cancelButtonTitle:@"はじめる"
                                                  otherButtonTitles:nil];
        [alertView show];        
        // 現在のバンドルバージョンを記録
        [defaults setObject:[NSNumber numberWithFloat:bundleVersion] forKey:@"version"];
        
        // 前バージョンでの最高スコアを、初回起動時のみ送信
        [[MyGameCenter sharedManager] submitScore:[[ScoreManager sharedManager].maxScore.score intValue] category:@"score"];
    }
    // ===========================
    
    return YES;
}
// 終了直前の後片付け処理
- (void)applicationWillTerminate:(UIApplication*)application
{
    // データを保存する
    [[ScoreManager sharedManager] save];
    
    // ======= Google Analytics 2.0v Track Event ========
    [GAManager postTrackView:@"entry_point"];
    // ==================================================
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

@end
