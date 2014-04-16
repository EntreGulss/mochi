//
//  ScoreManager.m
//  mochi
//
//  Created by 大竹 雅登 on 12/12/30.
//  Copyright (c) 2012年 大竹 雅登. All rights reserved.
//

#import "ScoreManager.h"

@implementation ScoreManager

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

static ScoreManager* _sharedInstance = nil;

+ (ScoreManager*)sharedManager
{
    // インスタンスを作成する
    if (!_sharedInstance) {
        _sharedInstance = [[ScoreManager alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    
    // 初期化
    _scoreDic = [NSMutableDictionary dictionary];
    _maxScore = [[Score alloc] init];
    _lastScore = [[Score alloc] init];
    
    // Dictionaryにスコアをセット
    [_scoreDic setObject:_maxScore forKey:@"max_score"];
    [_scoreDic setObject:_lastScore forKey:@"last_score"];
    
    return self;
}

//--------------------------------------------------------------//
#pragma mark -- Scoreに関する処理 --
//--------------------------------------------------------------//
// 最高スコアを更新
- (void)updateMaxScore:(Score*)nowScore
{
    [_scoreDic setObject:nowScore forKey:@"max_score"]; // Dictionaryを更新
    _maxScore = nowScore; // プロパティを更新
}
// 前回のスコアを更新
- (void)updateLastScore:(Score *)nowScore
{
    [_scoreDic setObject:nowScore forKey:@"last_score"]; // Dictionaryを更新
    _lastScore = nowScore; // プロパティを更新
}

//--------------------------------------------------------------//
#pragma mark -- 永続化 --
//--------------------------------------------------------------//

- (NSString*)_scoreDir
{
    // ドキュメントパスを取得する
    NSArray*    paths;
    NSString*   path;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    path = [paths objectAtIndex:0];
    
    // .channelディレクトリを作成する
    path = [path stringByAppendingPathComponent:@".score"];
    return path;
}

- (NSString*)_scorePath
{
    // score.datパスを作成する
    NSString*   path;
    path = [[self _scoreDir] stringByAppendingPathComponent:@"score.dat"];
    return path;
}

- (void)load
{
    // ファイルパスを取得する
    NSString*   scorePath;
    scorePath = [self _scorePath];
    if (!scorePath || ![[NSFileManager defaultManager] fileExistsAtPath:scorePath]) {
        return;
    }
    
    // scoreDicの値を読み込む
    NSMutableDictionary* scoreDic_;
    scoreDic_ = [NSKeyedUnarchiver unarchiveObjectWithFile:scorePath];
    if (!scoreDic_) {
        return;
    }
    
    // scoreDicを設定する
    _scoreDic = scoreDic_;
    
    // プロパティも編集する
    _maxScore   = [scoreDic_ objectForKey:@"max_score"];
    _lastScore  = [scoreDic_ objectForKey:@"last_score"];
}

- (void)save
{
    // ファイルマネージャを取得する
    NSFileManager*  fileMgr;
    fileMgr = [NSFileManager defaultManager];
    
    // .scoreディレクトリを作成する
    NSString*   scoreDir;
    scoreDir = [self _scoreDir];
    if (![fileMgr fileExistsAtPath:scoreDir]) {
        NSError*    error;
        [fileMgr createDirectoryAtPath:scoreDir
           withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // チャンネルの配列を保存する
    NSString*   scorePath;
    scorePath = [self _scorePath];
    [NSKeyedArchiver archiveRootObject:_scoreDic toFile:scorePath];
}



@end
