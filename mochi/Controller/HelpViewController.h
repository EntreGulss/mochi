//
//  HelpViewController.h
//  mochi
//
//  Created by 大竹 雅登 on 13/01/12.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HelpViewControllerDelegate;

@interface HelpViewController : GAITrackedViewController

@property (nonatomic, assign) id<HelpViewControllerDelegate> delegate;

@end

@protocol HelpViewControllerDelegate <NSObject>
- (void)closeViewController:(UIViewController*)viewController;
@end
