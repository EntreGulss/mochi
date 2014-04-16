//
//  HelpViewController.m
//  mochi
//
//  Created by 大竹 雅登 on 13/01/12.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
{
    IBOutlet UIButton *titleButton;
}
@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ==== Google Analytics =====
    self.trackedViewName = @"HelpViewController";
    [GAManager postTrackView:@"Help"];
    // ===========================
    
    // ==== Add Sounds to Buttons ====
    [titleButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    // ===============================
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)homeButton:(id)sender {
    [self.delegate closeViewController:self];
}

#pragma mark - Sound Effect -
// ボタンを押したとき
- (void)buttonOn {
    [self soundOn:@"short8" withExtension:@"mp3"];
}
// 音をならす
- (void)soundOn:(NSString*)url withExtension:(NSString*)extention {
    SystemSoundID soundID;
    NSURL* soundURL = [[NSBundle mainBundle] URLForResource:url
                                              withExtension:extention];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound (soundID);
}


- (void)viewDidUnload {
    titleButton = nil;
    [super viewDidUnload];
}
@end
