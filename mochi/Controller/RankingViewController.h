//
//  RankingViewController.h
//  mochi
//
//  Created by 大竹 雅登 on 13/01/04.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// Twitter/Facebook
#import <Social/Social.h>   // iOS6
#import <Twitter/Twitter.h> // iOS5

#import "Score.h"
#import "Line.h"

#import "MyGameCenter.h"

@protocol RankingViewControllerDelegate;

@interface RankingViewController : GAITrackedViewController <GKLeaderboardViewControllerDelegate>
{
    // Nend広告
    IBOutlet UIWebView *nendWebView;
    CGRect defaultNendFrame;
}

@property (nonatomic, assign) id<RankingViewControllerDelegate> delegate;

@property (nonatomic, strong) Score* nowScore; // そのゲームでのスコア
@property (nonatomic, assign) BOOL showRetryOrNot; // リトライボタンを表示するかどうか

@end

@protocol RankingViewControllerDelegate <NSObject>
- (void)closeViewController:(UIViewController*)viewController;
@optional
- (void)restartGame;
@end