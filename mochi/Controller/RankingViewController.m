//
//  RankingViewController.m
//  mochi
//
//  Created by 大竹 雅登 on 13/01/04.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import "RankingViewController.h"

#import "Score.h"
#import "ScoreManager.h"

@interface RankingViewController ()
{    
    IBOutlet UILabel *nowScoreLabel;    // 直前のプレイのスコア
    IBOutlet UILabel *bestScoreLabel;   // 今までのベストスコア
    
    IBOutlet UIImageView *newHighScoreLabel; // 記録更新のラベル
    
    IBOutlet UIButton *retryButton; // リトライボタン（Homeから来た時は消す）
    IBOutlet UIButton *titleButton;
    
    // 新記録かどうか
    BOOL newScoreOrNot;
    
    // 匠くんの画像
    IBOutlet UIImageView *takumikunImageView;
    
    // Social
    IBOutlet UIButton *LineButton;
    IBOutlet UIButton *FacebookButton;
    IBOutlet UIButton *TwitterButton;
    IBOutlet UIButton *GameCenterButton;
    
    // GameCenter
    IBOutlet UILabel *messageLabel;
}

@end

@implementation RankingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    // ==== Game Center ==========
    if ([MyGameCenter sharedManager].localPlayer.isAuthenticated) {
        messageLabel.text = @"ログイン中";
    } else {
        messageLabel.text = @"ログアウト中";
    }
    // ===========================
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ==== Google Analytics =====
    self.trackedViewName = @"RankingViewController";
    [GAManager postTrackView:@"Ranking"];
    // ===========================
    
    // ==== Add Sounds to Buttons ====
    [retryButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [titleButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [LineButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [TwitterButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [FacebookButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [GameCenterButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    // ===============================
    
    // ========= Nend広告（320*100）========
    NSURL *url = [NSURL URLWithString:@"http://masato-python.appspot.com/nend"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [nendWebView loadRequest:req];
    // 一定時間で更新
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(loadNendRequest) userInfo:nil repeats:YES];
    [nendWebView.scrollView setScrollEnabled:NO];
    defaultNendFrame = nendWebView.frame;
    // 初めは下に隠す
    nendWebView.frame = CGRectMake(defaultNendFrame.origin.x, defaultNendFrame.origin.y+116, defaultNendFrame.size.width, defaultNendFrame.size.height);
    // ===================================
    
    // =========== iOSバージョンで、処理を分岐 ============
    // iOS Version
    NSString *iosVersion = [[[UIDevice currentDevice] systemVersion] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([iosVersion floatValue] < 5.0) { // iOSのバージョンが5.0以上でないときは、TwitterとFacebookボタンを隠す
        // Twitter,Facebookのどちらも連携に対応していない。
        FacebookButton.hidden = YES;
        TwitterButton.hidden = YES;
    } else if ([iosVersion floatValue] < 6.0) { // iOSのバージョンが6.0以上でないときは、Facebookボタンを隠す
        // iOS5.0用のTwitter.frameworkを使い、Facebookだけ隠す
        FacebookButton.hidden = YES;
    }
    // ===============================================
    
    // 匠くんの画像の初期設定
    CABasicAnimation* takumikunAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    takumikunAnim.fromValue = [NSNumber numberWithFloat:M_PI/180*(-8)];
    takumikunAnim.toValue = [NSNumber numberWithFloat:M_PI/180*(8)];
    takumikunAnim.duration = 0.4;
    takumikunAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    takumikunAnim.autoreverses = YES;
    takumikunAnim.repeatCount = MAXFLOAT;
    [takumikunImageView.layer addAnimation:takumikunAnim forKey:@"takumikunAnimation"];
    
    
    newHighScoreLabel.alpha = 0; // デフォルトでは消しておく
    
    // データをロードしておく
    [[ScoreManager sharedManager] load];
    
    
    // Home画面からの遷移の場合
    if (!_showRetryOrNot) {
        retryButton.hidden = YES;
        // 未プレイ時を除き、最高スコアと前回スコアが一致する場合
        if ([[ScoreManager sharedManager].lastScore.score intValue]==[[ScoreManager sharedManager].maxScore.score intValue] && [[ScoreManager sharedManager].maxScore.score intValue] != 0)
        {
            newHighScoreLabel.alpha = 1;
        }
    }
    // Game画面からの遷移の場合
    else {
        // 前回のスコアを更新して、保存
        [[ScoreManager sharedManager] updateLastScore:_nowScore];
        [[ScoreManager sharedManager] save]; // saveしないと、スコープを外れたときに変更が反映されていない（重要！）
        
        // ======= Game Center Post Score =======
        // 直前のスコアをプレイ終了後に投稿する
        [[MyGameCenter sharedManager] submitScore:[[ScoreManager sharedManager].lastScore.score intValue] category:@"score"];
        // ======================================
        
        // 記録更新だったら記録更新ラベルを表示（_nowScore.score > maxScore.score）
        if ([_nowScore.score intValue] > [[ScoreManager sharedManager].maxScore.score intValue]) {
            // 新記録のアニメーション
            newScoreOrNot = YES;
            newHighScoreLabel.alpha = 1;
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startNewHighScoreAnimation) userInfo:nil repeats:NO];
            
            // 新記録のデータを保存
            [[ScoreManager sharedManager] updateMaxScore:_nowScore];
            [[ScoreManager sharedManager] save];
        }
        else {
            // 新記録でない時のアニメーション
            newScoreOrNot = NO;
            newHighScoreLabel.alpha = 0;
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startNewHighScoreAnimation) userInfo:nil repeats:NO];
        }
    }
    
    // 自己ベストのスコアを表示
    bestScoreLabel.text = [NSString stringWithFormat:@"%d", [[ScoreManager sharedManager].maxScore.score intValue]];
    // 直前のプレイのスコアを表示
    nowScoreLabel.text = [NSString stringWithFormat:@"%d", [[ScoreManager sharedManager].lastScore.score intValue]];
}

#pragma mark - Animation -
- (void)startNewHighScoreAnimation {
    if (newScoreOrNot) {
        [self soundOn:@"newscore" withExtension:@"mp3"];
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.8, 1.8, 1.0)];
        scaleAnim.duration = 0.3;
        //scaleAnim.beginTime = 1.5; // delay ??
        scaleAnim.autoreverses = YES;
        [newHighScoreLabel.layer addAnimation:scaleAnim forKey:@"ScaleAnimation"];
    } else {
        // ゲーム終了後だけ音を鳴らす
        if (_showRetryOrNot) {
            [self soundOn:@"not_newscore" withExtension:@"mp3"];
        }
    }
}


#pragma mark - WebView Delegate -
- (void)loadNendRequest {
    // 下に隠す
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    //nendWebView.frame = CGRectMake(defaultNendFrame.origin.x, defaultNendFrame.origin.y+116, defaultNendFrame.size.width, defaultNendFrame.size.height);
    nendWebView.alpha = 0;
    [UIView commitAnimations];
    // 再リクエスト
    NSURL *url = [NSURL URLWithString:@"http://masato-python.appspot.com/nend"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [nendWebView loadRequest:req];
}
- (void)webViewDidStartLoad:(UIWebView*)webView{
}
- (void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.15];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    nendWebView.frame = defaultNendFrame;
    nendWebView.alpha = 1;
    [UIView commitAnimations];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // クリックしたリンクのURLを取得し、サファリで開く
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [nendWebView reload]; // サファリに行く前に再読み込み
        NSString *url = [NSString stringWithFormat:@"%@",[request URL]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Test Action -
- (IBAction)retryButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate restartGame];
}

#pragma mark - Close Button -
- (IBAction)closeButton:(id)sender
{
    [self.delegate closeViewController:self];
}


#pragma mark - Social -
// LINE
- (IBAction)postLine:(id)sender {
    NSString* postContent = [NSString stringWithFormat:@"%@個の餅をたたいたぞ！[匠くんの餅つき] #takumikun_mochitsuki %@",[[ScoreManager sharedManager].maxScore.score stringValue], APPURL];
    [Line shareToLine:postContent];
}
// Facebook
- (IBAction)postFacebook:(id)sender {
    SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString* postContent = [NSString stringWithFormat:@"%@個の餅をたたいたぞ！[匠くんの餅つき] #takumikun_mochitsuki",[[ScoreManager sharedManager].maxScore.score stringValue]];
    [facebookPostVC setInitialText:postContent];
    [facebookPostVC addURL:[NSURL URLWithString:APPURL]]; // アプリURL
    [self presentViewController:facebookPostVC animated:YES completion:nil];
}
// Twitter
- (IBAction)postTwitter:(id)sender {
    NSString* postContent = [NSString stringWithFormat:@"%@個の餅をたたいたぞ！[匠くんの餅つき] #takumikun_mochitsuki",[[ScoreManager sharedManager].maxScore.score stringValue]];
    NSURL* appURL = [NSURL URLWithString:APPURL];
    // =========== iOSバージョンで、処理を分岐 ============
    // iOS Version
    NSString *iosVersion = [[[UIDevice currentDevice] systemVersion] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // Social.frameworkを使う
    if ([iosVersion floatValue] >= 6.0) {
        SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterPostVC setInitialText:postContent];
        [twitterPostVC addURL:appURL]; // アプリURL
        [self presentViewController:twitterPostVC animated:YES completion:nil];
    }
    // Twitter.frameworkを使う
    else if ([iosVersion floatValue] >= 5.0) {
        // Twitter画面を保持するViewControllerを作成する。
        TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
        // 初期表示する文字列を指定する。
        [twitter setInitialText:postContent];
        // TweetにURLを追加することが出来ます。
        [twitter addURL:appURL];
        // Tweet後のコールバック処理を記述します。
        // ブロックでの記載となり、引数にTweet結果が渡されます。
        twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
            if (res == TWTweetComposeViewControllerResultDone)
                NSLog(@"tweet done.");
            else if (res == TWTweetComposeViewControllerResultCancelled)
                NSLog(@"tweet canceled.");
        };
        // Tweet画面を表示します。
        [self presentModalViewController:twitter animated:YES];
    }
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

#pragma mark - Game Center -
- (IBAction)gameCenterButton:(id)sender {
    // ログイン済み
    if ([MyGameCenter sharedManager].localPlayer.isAuthenticated) {
        [self showLeaderboard];
    }
    // ログインしていない
    else {
        // ログイン画面
        [[MyGameCenter sharedManager] loginGameCenter];
    }
}
// LeaderBoardを立ち上げる
- (void)showLeaderboard
{
    GKLeaderboardViewController* leaderboardVC = [[GKLeaderboardViewController alloc] init];
    if (leaderboardVC != nil)
    {
        leaderboardVC.leaderboardDelegate = self;
        [self presentViewController:leaderboardVC animated:YES completion:nil];
    }
}
// LeaderBoardで完了を押した時に呼ばれる
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    // ==== Game Center ==========
    if ([MyGameCenter sharedManager].localPlayer.isAuthenticated) {
        messageLabel.text = @"ログイン中";
    } else {
        messageLabel.text = @"ログアウト中";
    }
    // ===========================
}


- (void)viewDidUnload {
    bestScoreLabel = nil;
    nowScoreLabel = nil;
    newHighScoreLabel = nil;
    nendWebView = nil;
    retryButton = nil;
    LineButton = nil;
    FacebookButton = nil;
    TwitterButton = nil;
    takumikunImageView = nil;
    messageLabel = nil;
    titleButton = nil;
    GameCenterButton = nil;
    [super viewDidUnload];
}
@end
