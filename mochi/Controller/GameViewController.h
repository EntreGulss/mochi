//
//  GameViewController.h
//  mochi
//
//  Created by 大竹 雅登 on 13/01/04.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#import "RankingViewController.h"


@protocol GameViewControllerDelegate;

@interface GameViewController : GAITrackedViewController <RankingViewControllerDelegate, NADViewDelegate, GADBannerViewDelegate>
{
    NADView *nadView_;
    CGRect defaultNendFrame;
    
    // 広告
    UIView *myAdView;
    CGRect defaultMyAdViewFrame;
    // インスタンス変数として、AdMob用のViewを1つ宣言する
    GADBannerView *bannerView_;
}

@property (nonatomic, assign) id<GameViewControllerDelegate> delegate;

- (void)closeViewController:(UIViewController*)viewController;
- (void)restartGame;

@end

@protocol GameViewControllerDelegate <NSObject>
- (void)closeViewController:(UIViewController*)viewController;
@end