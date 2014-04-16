//
//  HomeViewController.m
//  mochi
//
//  Created by 大竹 雅登 on 12/12/30.
//  Copyright (c) 2012年 大竹 雅登. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
{
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *rankingButton;
    IBOutlet UIButton *helpButton;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - NAdView Delegate -
// ロード完了したとき（初回読み込み）
-(void)nadViewDidFinishLoad:(NADView *)adView {
    //NSLog(@"delegate nadViewDidFinishLoad:");
    // 上がってくるアニメーション
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    nadView_.frame = defaultNendFrame;
    [UIView commitAnimations];
}
// 広告受信通知
-(void)nadViewDidReceiveAd:(NADView *)adView {
    //NSLog(@"delegate nadViewDidReceiveAd:");
    // Nendの広告を受信したら、Admobを取り除く
    [self removeAdmob];
    [self.view bringSubviewToFront:nadView_]; // 広告を最前面に表示
}
// 広告受信エラー通知
-(void)nadViewDidFailToReceiveAd:(NADView *)adView {
    //NSLog(@"delegate nadViewDidFailToLoad:");
    // Nendの在庫がない時は、Admobを表示
    [self loadAdmobRequest];
}
// 定期ロード中断
- (void)viewWillDisappear:(BOOL)animated {
    [nadView_ pause];
}
// 定期ロード再開
- (void)viewWillAppear:(BOOL)animated {
    [nadView_ resume];
}
// 解放（忘れるとクラッシュするので注意）
- (void)dealloc {
    [nadView_ setDelegate:nil]; // delegate に nil をセット
    nadView_ = nil;
}
#pragma mark - Admob関連 -
// リクエストが成功したとき
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    //NSLog(@"%s", __FUNCTION__);
    [UIView animateWithDuration:0.8f animations:^(void){
        // 右から入ってくる
        myAdView.frame = defaultMyAdViewFrame;
    }];
}

// リクエストが失敗したとき
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    //NSLog(@"%s", __FUNCTION__);
    //NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}
// AdMobを読み込む
- (void)loadAdmobRequest {
    [self.view addSubview:myAdView];
    // 一般的なリクエストを行って広告を読み込む。
    GADRequest *request = [GADRequest request];
    request.testing = TESTMODE;  // mochi-Prefix.pchで定義
    [bannerView_ loadRequest:request];
    [self.view bringSubviewToFront:myAdView];   // 最前面に持ってくる
}
// Admobを外す
- (void)removeAdmob {
    [myAdView removeFromSuperview];
    // 右にずらす
    myAdView.frame = CGRectMake(defaultMyAdViewFrame.origin.x+320, defaultMyAdViewFrame.origin.y, defaultMyAdViewFrame.size.width, defaultMyAdViewFrame.size.height);
}


#pragma mark - viewDidLoad -
- (void)viewDidLoad
{
    [super viewDidLoad];

    // ==== Google Analytics =====
    self.trackedViewName = @"HomeViewController";
    [GAManager postTrackView:@"Home"];
    // ===========================

    // ==== Add Sounds to Buttons ====
    [startButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [rankingButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [helpButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    // ===============================
    
    /* Admob=右から、Nend=下から */
    // ============== Nend広告 ============
    defaultNendFrame = CGRectMake(0,self.view.frame.size.height-NAD_ADVIEW_SIZE_320x50.height,NAD_ADVIEW_SIZE_320x50.width, NAD_ADVIEW_SIZE_320x50.height);
    // (2) NADView の作成
    // アニメーションに備えて下に用意
    nadView_ = [[NADView alloc] initWithFrame:CGRectMake(defaultNendFrame.origin.x, defaultNendFrame.origin.y+NAD_ADVIEW_SIZE_320x50.height, defaultNendFrame.size.width, defaultNendFrame.size.height)];
    // (3) set apiKey, spotId.
    [nadView_ setNendID:NENDAPIKEY spotID:NENDSPOTID];
    [nadView_ setDelegate:self]; //(4)
    [nadView_ setRootViewController:self]; //(5)
    [nadView_ load]; //(6)
    [self.view addSubview:nadView_]; // 最初から表示する場合
    nadView_.backgroundColor = [UIColor darkGrayColor];
    [self.view bringSubviewToFront:nadView_];
    // ===================================
    
    //=============== AdMobの初期設定 ==================================    
    //****************** AdMob *********************
    myAdView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kGADAdSizeBanner.size.height, kGADAdSizeBanner.size.width, kGADAdSizeBanner.size.height)];
    defaultMyAdViewFrame = myAdView.frame;
    // 画面下部に標準サイズのビューを作成する
    CGRect bannerViewFrame = CGRectMake(0, 0, 320, 50);
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView_.frame = bannerViewFrame;
    
    // 広告の「ユニット ID」を指定する。パブリッシャーIDかメディエーションIDかに注意
    bannerView_.adUnitID = ADMOB_UNIT_ID;
    
    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
    // ビュー階層に追加する。
    bannerView_.rootViewController = self;
    [myAdView addSubview:bannerView_];
    
    // デリゲートを設定
    [bannerView_ setDelegate:self];
    //***********************************************
    // アニメーションのために右にずらす
    myAdView.frame = CGRectMake(defaultMyAdViewFrame.origin.x+320, defaultMyAdViewFrame.origin.y, defaultMyAdViewFrame.size.width, defaultMyAdViewFrame.size.height);
    //==============================================================
    
    // サイズ対応 
    if ([UIScreen mainScreen].bounds.size.height == 568.0) { // 4インチ
        // そのまま
    } else { // 3.5インチ
        // 背景画像を、4インチと同じ大きさのまま、上にぎりぎりまでずらす // ****
        backgroundImageView.frame = CGRectMake(0, -30, self.view.frame.size.width, self.view.frame.size.height+88);
        // ボタンの位置を調整する
        startButton.frame = CGRectMake(startButton.frame.origin.x, startButton.frame.origin.y-2, startButton.frame.size.width, startButton.frame.size.height-10);
        rankingButton.frame = CGRectMake(rankingButton.frame.origin.x, rankingButton.frame.origin.y+3, rankingButton.frame.size.width, rankingButton.frame.size.height-10);
        helpButton.frame = CGRectMake(helpButton.frame.origin.x, helpButton.frame.origin.y+8, helpButton.frame.size.width, helpButton.frame.size.height-10);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Resize Image -
- (UIImage*)resizeImage:(UIImage*)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    
    return image;
}


#pragma mark - ViewController Delegate -
- (void)closeViewController:(UIViewController*)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Segue -
// StoryBoardを使ってデリゲートを実装するときはここでする。
// 遷移先のコントローラーでプロパティを宣言していたらそれを、設定することもできる。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showGameViewController"]) {
        GameViewController* controller = segue.destinationViewController;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"showRankingViewController"]) {
        RankingViewController* controller = segue.destinationViewController;
        controller.delegate = self;
        controller.nowScore = nil;
        controller.showRetryOrNot = NO;
    }
    else if ([segue.identifier isEqualToString:@"showHelpViewController"]) {
        HelpViewController* controller = segue.destinationViewController;
        controller.delegate = self;
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


- (void)viewDidUnload {
    backgroundImageView = nil;
    [super viewDidUnload];
}

@end
