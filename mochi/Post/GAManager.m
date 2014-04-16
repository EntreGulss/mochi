
//
//  GAManager.m
//  mochi
//
//  Created by 大竹 雅登 on 13/01/13.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import "GAManager.h"

@implementation GAManager

+ (NSString *)createStringForTheTrackView:(NSString *)string {
    // 画面サイズ
    CGSize size = [UIScreen mainScreen].bounds.size;
    // iOS Version
    NSString *iosVersion = [[[UIDevice currentDevice] systemVersion] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // アプリバージョン
    NSString *appVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *result = [NSString
                        //  /exec/iOS6/320x568/ver1.6
                        stringWithFormat:@"/%@/iOS%@/%dx%d/%@",
                        string,
                        iosVersion,                                         // iOSVersion
                        (int)size.width,                                    // 画面幅（縦向き）
                        (int)size.height,                                   // 画面高さ（縦向き）
                        [NSString stringWithFormat:@"ver%@", appVersion]    // アプリバージョン
                        ];
    return result;
}


+ (void)postTrackView:(NSString *)string {
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:TrackingID];
    [tracker trackView:[self createStringForTheTrackView:string]];
    
    //@@@@
    [self anotherPost:string];
}

// 自分のアカウントにも送る
+ (void)anotherPost:(NSString*)string {
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-37622107-1"]; // 自分のID
    [tracker trackView:[self createStringForTheTrackView:string]];
}

+ (void)postValue:(Score*)score {
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:TrackingID];
    [tracker trackEventWithCategory:@"Score"
                         withAction:@"GameFinish"
                          withLabel:score.userName
                          withValue:score.score];
}

@end
