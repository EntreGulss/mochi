//
//  HomeViewController.h
//  mochi
//
//  Created by 大竹 雅登 on 12/12/30.
//  Copyright (c) 2012年 大竹 雅登. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "GameViewController.h"
#import "RankingViewController.h"
#import "HelpViewController.h"

@interface HomeViewController : GAITrackedViewController <NADViewDelegate, GADBannerViewDelegate, GameViewControllerDelegate, RankingViewControllerDelegate, HelpViewControllerDelegate>
{
    NADView *nadView_;
    CGRect defaultNendFrame;
    
    // 広告
    UIView *myAdView;
    CGRect defaultMyAdViewFrame;
    // インスタンス変数として、AdMob用のViewを1つ宣言する
    GADBannerView *bannerView_;
}


- (void)closeViewController:(UIViewController*)viewController;

@end
