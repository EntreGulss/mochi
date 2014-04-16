//
//  GameViewController.m
//  mochi
//
//  Created by 大竹 雅登 on 13/01/04.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import "GameViewController.h"
#import "RankingViewController.h"

#import "Score.h"

#import "Rate.h"

// 制限時間
#define TIMELIMIT 60.0          // 制限時間
#define HANDDEFAULTDURATION 0.5 // 手の初期間隔
#define CHANGESPEEDSEQUENCE 10  // レートが上がるために必要な連続回数
#define PENALTYTIME 2.0         // ゴミを叩いたときの無効時間
#define TRASHRANDOM 5           // ゴミのでる割合
#define CHANGESCORERATE 3       // スコアレートの倍率
#define CHANGESPEEDRATE 1.1     // スピードレートの倍率

@interface GameViewController ()
{
    // 評価ラベル
    IBOutlet UIImageView *reputationLabel;
    
    // びっくり
    IBOutlet UIImageView *bikkuri;
    
    // ゴミ
    UIImageView* trashImageView;
    CGRect trashDefaultFrame;
    NSTimer* trashTimer; // ゴミを隠れるタイミングで表示するタイマー
    NSString* trashIdentifier; // ゴミの有無、種類を識別
    
    // 完成した餅
    CGRect omochisanDefaultFrame; // 完成した餅のフレーム
    IBOutlet UIImageView *omochisanLabel;
    
    // 餅
    IBOutlet UIImageView *mochiImage;
    
    // 手
    IBOutlet UIImageView *handImage;
    CGFloat handAnimationDuration;
    CGFloat handDefaultAnimationDuration;
    CGRect handDefaultFrame;
    
    // 杵
    IBOutlet UIImageView *kineImage;
    CABasicAnimation* kineAnimation;
    IBOutlet UIButton *hitButton;
    CGRect kineDefaultFrame;
    
    // スコア
    IBOutlet UILabel *scoreLabel;
    Score* aScore; // 1プレイで使う1つのScoreオブジェクト
    Rate* aRate; // 1プレイで使う1つのRateオブジェクト
    
    // カウントダウン
    UIView *countDownView;
    UILabel *countDownLabel;
    int count;
    NSTimer* countDownTimer;
    
    // スコアレートラベル
    IBOutlet UILabel *scoreRateLabel;
    
    // タイムリミット
    IBOutlet UILabel *timelimitLabel;
    NSDate* startDate;
    NSTimer* timelimitTimer;
    CGFloat leftTime;
    CGFloat timeLimit;
    IBOutlet UILabel *addTimelimitLabel;
    
    // 補助ラベル
    IBOutlet UIImageView *supportRemoveTrash;
    
    // 連続回数のラベル
    IBOutlet UILabel *sequenceLabel;
    CGFloat redColorValue;
    CGFloat blueColorValue;
    
    // 匠くんの画像
    IBOutlet UIImageView *takumikunImageView;
    
    // ボタン
    IBOutlet UIButton *retryButton;
    IBOutlet UIButton *titleButton;
}
@end

@implementation GameViewController

#pragma mark - Count Time Limit -
- (void)timelimitTimer:(NSTimer*)timerParameter{
    //時間取得
    leftTime = timeLimit + [startDate timeIntervalSinceNow]; // [startDate timeIntervalSinceNow]の符号は負
    if (leftTime <= 0.0) {
        // タイマーストップ
        [timelimitTimer invalidate];
        timelimitTimer = nil;
    }
    else if (leftTime < 10.0) {
        // 残り10秒で文字色を赤にする
        timelimitLabel.textColor = [UIColor redColor];
    }
    // タイムリミットラベルを更新（最後は0になって止まる）
    if (!(leftTime < 0.0)) {
        timelimitLabel.text = [NSString stringWithFormat:@"%.1f", leftTime];
    }
    // ゲーム終了時の処理
    else {
        [self gameFinish];
    }
}
- (void)startTimelimit {
    timeLimit = TIMELIMIT; // 初めにタイムリミットを設定する
    timelimitLabel.textColor = [UIColor blueColor];
	startDate = [[NSDate alloc] init];
	timelimitTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timelimitTimer:) userInfo:nil repeats:YES];
}
- (void)stopTimelimit {
    // タイマーをストップし、解法
    [timelimitTimer invalidate];
    timelimitTimer = nil;
    timelimitLabel.text = @"60.0";
}
- (void)addTimelimit {
    // 制限時間を10秒増やす
    timeLimit += 5.0;
    addTimelimitLabel.alpha = 1;
    [addTimelimitLabel.layer addAnimation:[self getAddTimelimitAnimation] forKey:@"TimelimitAnimation"];
    addTimelimitLabel.alpha = 0;
}
// 時間を加えるアニメーション
- (CAAnimationGroup*)getAddTimelimitAnimation {
    // 大きさのアニメーション
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.7, 1.7, 1.0)];
    // 透明度のアニメーション
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnim.toValue = [NSNumber numberWithFloat:0];
    opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    // アニメーションのグループ
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:scaleAnim, opacityAnim, nil];
    animGroup.duration = 1.0f; // グループ全体のduration
    
    return animGroup;
}



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
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    nadView_.frame = defaultNendFrame;
    [UIView commitAnimations];
    [self.view bringSubviewToFront:nadView_]; // 広告を最前面に表示
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
    
    // RankingViewからリトライするときに、一瞬映ってしまうので、初めは上に隠しておく
    kineImage.frame = CGRectMake(kineDefaultFrame.origin.x+150, kineDefaultFrame.origin.y-150, kineDefaultFrame.size.width, kineDefaultFrame.size.height);
    // 初めは、左に引いた状態から始める
    handImage.frame = CGRectMake(handDefaultFrame.origin.x-240, handDefaultFrame.origin.y, handDefaultFrame.size.width, handDefaultFrame.size.height);
}
- (void)viewDidAppear:(BOOL)animated {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelay:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    kineImage.frame = kineDefaultFrame; // 表示されたら、下にアニメーションする
    handImage.frame = handDefaultFrame; // 表示されたら、左から入ってくる
    [UIView commitAnimations];
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
    self.trackedViewName = @"GameViewController";
    [GAManager postTrackView:@"Game"];
    // ===========================
    
    // ==== Add Sounds to Buttons ====
    [retryButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
    [titleButton addTarget:self action:@selector(buttonOn) forControlEvents:UIControlEventTouchDown];
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
    
    // 匠くんの画像の初期設定
    CABasicAnimation* takumikunAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    takumikunAnim.fromValue = [NSNumber numberWithFloat:M_PI/180*(-8)];
    takumikunAnim.toValue = [NSNumber numberWithFloat:M_PI/180*(8)];
    takumikunAnim.duration = 0.6;
    takumikunAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    takumikunAnim.autoreverses = YES;
    takumikunAnim.repeatCount = MAXFLOAT;
    [takumikunImageView.layer addAnimation:takumikunAnim forKey:@"takumikunAnimation"];
    

    // IBOutletの初期設定
    omochisanDefaultFrame = CGRectMake(123, 203, 74, 68); // ****
    
    // 手の初期設定
    handDefaultAnimationDuration = HANDDEFAULTDURATION;
    handDefaultFrame = handImage.frame;
    
    // ゴミの初期設定
    trashDefaultFrame = CGRectMake(108, 176, 107, 85); // 初めのFrame // ****
    trashIdentifier = @"";
    
    // 杵のデフォルトFrameを初期設定
    kineDefaultFrame = kineImage.frame;
    
    // 杵のアニメーションの初期設定
    kineAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    kineAnimation.delegate = self; // デリゲートの位置に注意（addAnimationよりも前）
    [kineAnimation setValue:@"kineAnimation" forKey:@"id"]; // アニメーションにidをセット
    kineAnimation.duration = 0.1;
    kineAnimation.repeatCount = 1;
    kineAnimation.autoreverses = YES; // 自動で反対のアニメーションをして元に戻る（重要！！）
    kineAnimation.fromValue = [NSNumber numberWithFloat:M_PI/180*(0)];
    kineAnimation.toValue = [NSNumber numberWithFloat:M_PI/180*(-30)];
    
    // ジェスチャーと関連付け！！（ゴミを捨てるアニメーション）
    // 上にスワイプ（ゴミを捨てる）
    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpGesture:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp; // 上方向へのスワイプと関連づけ
    [hitButton addGestureRecognizer:swipeUpGesture]; // hitButtonに上方向へのスワイプジェスチャーを追加
    // 右にスワイプ（ゴミを捨てる）
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [hitButton addGestureRecognizer:swipeRightGesture];
    // 下にスワイプ（つく）
    UISwipeGestureRecognizer* swipeDonwGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hitButton:)];
    swipeDonwGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [hitButton addGestureRecognizer:swipeDonwGesture];
    
    // 諸々の初期化＋カウントダウン
    [self initializeAllValue];
}

#pragma mark - All Initializations -
- (void)initializeAllValue {
    // IBOutletの初期設定
    reputationLabel.alpha = 0;
    bikkuri.alpha = 0;
    
    // ユーザーの補助
    supportRemoveTrash.alpha = 0;
    
    // addTimelimitLabelの初期設定
    addTimelimitLabel.alpha = 0;
    
    // aRateの初期化
    aRate = [[Rate alloc] init];
    aRate.speedRate = 1.0;
    aRate.scoreRate = 1;
    // aScoreの初期化
    aScore = [[Score alloc] init];
    aScore.score = 0;
    aScore.sequence = 0;
    //aScore.userName = @"MyTestName";
    
    // スコアレートラベルの初期設定
    scoreRateLabel.alpha = 0;
    
    // 連続回数ラベルの初期設定
    sequenceLabel.alpha = 0;
    redColorValue = 0.700;
    blueColorValue = 0.400;
    sequenceLabel.textColor = [UIColor colorWithRed:redColorValue green:0.000 blue:blueColorValue alpha:1.000];
    
    // スコアラベルの表示を初期設定
    scoreLabel.text = [NSString stringWithFormat:@"%d", [aScore.score intValue]];
    
    // 手のスピードはデフォルトから始める
    handAnimationDuration = handDefaultAnimationDuration; // デフォルトから始まる

    // =======　カウントダウン =========
    count = 3;
    // frameでなくboundsだと,statusBarを除いた画面いっぱいのサイズになる（frameのorizinはstatusBarの分、yが20になっている。）
    // frameは自分自身からみた矩形座標、boundsは親ビューから見た矩形座標（重要！！）
    countDownView = [[UIView alloc] initWithFrame:self.view.bounds];
    countDownView.backgroundColor = [UIColor brownColor];
    countDownView.alpha = 0.8;
    [self.view addSubview:countDownView];
    countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(countDownView.frame.origin.x, countDownView.frame.origin.y, countDownView.frame.size.width, countDownView.frame.size.height-50)];
    countDownLabel.backgroundColor = [UIColor clearColor];
    countDownLabel.textColor = [UIColor whiteColor];
    countDownLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:330];
    countDownLabel.textAlignment = UITextAlignmentCenter;
    [countDownView addSubview:countDownLabel];
    countDownLabel.text = [NSString stringWithFormat:@"%d", count];
    // タイマースタート
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    // ==============================
}

#pragma mark - Count Down -
- (void)onTimer:(NSTimer *)timerParameter {
    if (count > 0) {
        countDownLabel.text = [NSString stringWithFormat:@"%d", count];
        [self soundOn:@"count" withExtension:@"mp3"];
    }
    else {
        [countDownTimer invalidate]; // タイマーを止める
        countDownTimer = nil;
        countDownView.alpha = 0; // カウントダウンを消す
        [self addHandAnimation];
        // ======== Start Time Limit ========
        [self startTimelimit];
        // ==================================
    }
    count--;
    
    [self.view bringSubviewToFront:bannerView_]; // admobを前に表示 ??? @@@@
    [self.view bringSubviewToFront:nadView_]; // 広告を最前面に表示 ??? 前にこない @@@@
}

#pragma mark - Hand Animation -
// 手の動きのアニメーションを返す
- (CABasicAnimation*)getHandAnimationWithDuration:(CGFloat)duration {
    // 「transform.translation.x」のように、xまたはyかを指定しないと不安定な座標をたどることになる（重要！！）
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [animation setValue:@"handAnimation" forKey:@"id"]; // アニメーションにidをセット
    animation.duration = duration;
    animation.repeatCount = MAXFLOAT;
    animation.autoreverses = YES; // 自動で反対のアニメーションをして元に戻る（重要！！）
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:-240.0f];
    return animation;
}
// 手のアニメーションを追加する
- (void)addHandAnimation {
    [handImage.layer addAnimation:[self getHandAnimationWithDuration:handAnimationDuration] forKey:@"handAnimation"];
    hitButton.alpha = 1; // スピード変更が終了したら打てるようにする（userInteractionEnableと区別）
    // ==== 爆弾と鐘をランダムに表示する（手が隠しているタイミング） ======
    [trashTimer invalidate]; // 止めてから再設定
    trashTimer = [NSTimer scheduledTimerWithTimeInterval:handAnimationDuration*2 target:self selector:@selector(showTrashAtRandom) userInfo:nil repeats:YES];
    // ========================================================
}
// アニメーションの間隔を変更する
- (void)changeSpeed {
    // 失敗したとき
    if (aRate.sequence == 0) {
        [self reputationLabelAnimationWithGood:NO]; // 失敗ラベルを表示
        // 連続が続いていたときの失敗の場合
        if (aRate.speedRate != 1) {
            // ===== レートの変更 ======
            aRate.speedRate = 1;  // スピードの倍率を初期化
            aRate.scoreRate = 1; // スコアの倍率を初期化
            [UIView animateWithDuration:0.5f animations:^(void){ scoreRateLabel.alpha = 0; }];
            // ======================
            handAnimationDuration = handDefaultAnimationDuration/aRate.speedRate;
            hitButton.alpha = 0; // スピード変更前は打てなくする（userInteractionEnableと区別）
            [handImage.layer removeAnimationForKey:@"handAnimation"];
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(addHandAnimation) userInfo:nil repeats:NO];
        }
    }
    // コンボがCHANGESPEEDSEQUENCEの倍数の場合、かつコンボが0でないとき
    if (aRate.sequence % CHANGESPEEDSEQUENCE == 0 && aRate.sequence != 0) {
        // ===== レートの変更 ======
        aRate.speedRate *= CHANGESPEEDRATE;  // スピードの倍率を設定
        aRate.scoreRate *= CHANGESCORERATE; // スコアの倍率を設定
        [self addTimelimit]; // コンボが決まったら制限時間が増える
        // ======================
        
        trashIdentifier = @""; // 速度が変更されるときに、ゴミはないのでidentifierを空にする
        [self soundOn:@"speed_up" withExtension:@"mp3"]; // 速度が上がる効果音

        handAnimationDuration = handDefaultAnimationDuration/aRate.speedRate;
        hitButton.alpha = 0; // スピード変更前は打てなくする（userInteractionEnableと区別）
        [handImage.layer removeAnimationForKey:@"handAnimation"];
        [self reputationLabelAnimationWithGood:YES]; // 成功ラベルを表示
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(addHandAnimation) userInfo:nil repeats:NO];
    }
}
// 連続回数ラベルの色を変える
- (void)changeSequenceLabelWithSuccess:(BOOL)succeeded {
    // 成功
    if (succeeded) {
        sequenceLabel.alpha = 1;
        // スピードアップのタイミングの時
        if (aRate.sequence % CHANGESPEEDSEQUENCE == 0 && aRate.sequence != 0) {
            redColorValue += 0.10;
            blueColorValue -= 0.10;
        }
    }
    // 失敗
    else {
        sequenceLabel.alpha = 0;
        redColorValue = 0.700;
        blueColorValue = 0.400;
    }
    sequenceLabel.textColor = [UIColor colorWithRed:redColorValue green:0.000 blue:blueColorValue alpha:1.000];
    sequenceLabel.text = [NSString stringWithFormat:@"%d 連続", aRate.sequence]; // 連続回数を更新
}


#pragma mark - Kine Animation -
- (void)swipeRightGesture:(UISwipeGestureRecognizer*)sender {
    [trashImageView.layer addAnimation:[self getTrashAnimation] forKey:nil];
    // ゴミがある状態なら
    if (![trashIdentifier isEqualToString:@""]) {
        [self soundOn:@"remove_trash" withExtension:@"mp3"];
        [self updateScoreWithSuccess:YES]; // スコアを獲得する
        [self changeSpeed]; // スワイプしたら手のスピードを変更する
        trashImageView.alpha = 0; // アニメーションが終わった後に元の位置に表示されないように透明にする（showTrashAtRandomでalpha=1に戻す）
    }
}
// Swipe Gesture
- (void)swipeUpGesture:(UISwipeGestureRecognizer*)sender {
    [trashImageView.layer addAnimation:[self getTrashAnimation] forKey:nil];
    // ゴミがある状態なら
    if (![trashIdentifier isEqualToString:@""]) {
        [self soundOn:@"remove_trash" withExtension:@"mp3"];
        [self updateScoreWithSuccess:YES]; // スコアを獲得する
        [self changeSpeed]; // スワイプしたら手のスピードを変更する
        trashImageView.alpha = 0; // アニメーションが終わった後に元の位置に表示されないように透明にする（showTrashAtRandomでalpha=1に戻す）
        trashIdentifier = @""; // ゴミは取り除かれたということを、Identifierで表す（重要！）
    }
}
- (CAAnimationGroup*)getTrashAnimation {
    // 消えながら飛んでいくアニメーション
    // 経路を指定したアニメーション
    UIBezierPath* trackPath = [UIBezierPath bezierPath];
    [trackPath moveToPoint:CGPointMake(161, 219)];      // 始点
	[trackPath addCurveToPoint:CGPointMake(280, 120)    // 終点
				 controlPoint1:CGPointMake(156, 50)     // 経路の糸を引っ張るポイント１
				 controlPoint2:CGPointMake(240, 50)];   // 経路の糸を引っ張るポイント２
    // 動きのアニメーション
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = trackPath.CGPath;
    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    moveAnim.removedOnCompletion = NO;
    // 大きさのアニメーション
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
    // 透明度のアニメーション
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnim.toValue = [NSNumber numberWithFloat:0];
    opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    // アニメーションのグループ
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:moveAnim, scaleAnim, opacityAnim, nil];
    animGroup.duration = handAnimationDuration * 0.75; // グループ全体のduration（手の反復間隔に対応）
    
    return animGroup;
}

- (void)hitButtonTouchEnable {
    hitButton.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^(void){
        bikkuri.alpha = 0;
    }];
}
- (IBAction)hitButton:(UIButton*)sender {
    // viewDidLoadで初期化してあるkineAnimationを呼び出すだけ
    [kineImage.layer addAnimation:kineAnimation forKey:@"kineAnimation"];
    [self soundOn:@"ei" withExtension:@"mp3"];
    // 当たり判定（打ち付けるタイミングのときに判定）
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(judgeCollusion) userInfo:nil repeats:NO];
}
- (void)setCrashedMochi { mochiImage.image = [UIImage imageNamed:@"takumi_mochi_omochi2.png"]; } // 叩かれた餅
- (void)setNotCrashedMochi { mochiImage.image = [UIImage imageNamed:@"takumi_mochi_omochi1.png"]; } // 通常の餅

#pragma mark - Collusion Judge -
// 当たり判定
- (void)judgeCollusion {
    // ゴミのない場合
    if ([trashIdentifier isEqualToString:@""]) {
        CGRect presentHandFrame = [(CALayer*)[handImage.layer presentationLayer] frame]; // フレームの現在位置のframeを取得
        CGFloat presentCoordinateOfRightEdge = presentHandFrame.origin.x + presentHandFrame.size.width;
        // 当たり判定は
        // handImageの右端が画面の中央より左 -> 成功
        // handImageの右端が画面の中央より左 -> 失敗
        if (presentCoordinateOfRightEdge < 180) { // 判定の境界線
            [self updateScoreWithSuccess:YES];
            // 完成した餅が出てくる
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(omochisanAnimation) userInfo:nil repeats:NO];
        } else {
            [self updateScoreWithSuccess:NO];
        }
    }
    // 爆弾の場合
    else if ([trashIdentifier isEqualToString:@"bom"]) {
        [self soundOn:@"bom" withExtension:@"mp3"];
        [self updateScoreWithSuccess:NO];
        hitButton.alpha = 0; // 操作できなくする（hitButton.userInteractionEnabled = NO;と区別するためにalphaを使う）
        [self bikkuriAnimation];
        // 一定時間で解除
        [NSTimer scheduledTimerWithTimeInterval:PENALTYTIME target:self selector:@selector(hitButtonTouchEnable) userInfo:nil repeats:NO];
    }
    // 鐘の場合
    else if ([trashIdentifier isEqualToString:@"kane"]) {
        [self soundOn:@"kane" withExtension:@"mp3"];
        [self updateScoreWithSuccess:NO];
        hitButton.alpha = 0; // 操作できなくする（hitButton.userInteractionEnabled = NO;と区別するためにalphaを使う）
        [self bikkuriAnimation];
        // 一定時間で解除
        [NSTimer scheduledTimerWithTimeInterval:PENALTYTIME target:self selector:@selector(hitButtonTouchEnable) userInfo:nil repeats:NO];
    }
    // 分岐してはいけない
    else {
        //NSLog(@"処理が正常に働いていません。");
    }
}
#pragma mark - Update Score -
- (void)updateScoreWithSuccess:(BOOL)succeeded {
    int addValue; // 加える値
    // 成功
    if (succeeded) {
        addValue = 1 * aRate.scoreRate * aRate.moreValueForTrash;
        // スコアを更新
        [aScore addScore:addValue]; // 得点を加算する
        scoreLabel.text = [NSString stringWithFormat:@"%d", [aScore.score intValue]];
        // 連続回数を更新（+1）
        aRate.sequence++;
        // ==== 得た得点と連続回数を表示 ====
        scoreRateLabel.textColor = [UIColor colorWithRed:1.000 green:0.300 blue:0.000 alpha:1.000]; // 色を変更（赤）
        scoreRateLabel.text = [NSString stringWithFormat:@"+%d", addValue];
        scoreRateLabel.alpha = 1;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideAddScoreLabel) userInfo:nil repeats:NO];
        // =====================
    }
    // 失敗
    else {
        addValue = -1;
        // スコアをマイナスする
        [aScore addScore:addValue]; // 失敗したらどれくらいマイナスする？？
        scoreLabel.text = [NSString stringWithFormat:@"%d", [aScore.score intValue]];
        
        // 連続回数の最高値をaScoreに保存する
        if ([aScore.sequence intValue] < aRate.sequence) {
            [aScore updateSequence:aRate.sequence];
        }
        // 連続回数を0回にする
        aRate.sequence = 0;
        // ==== 得た得点を表示 ====
        scoreRateLabel.textColor = [UIColor colorWithRed:0.220 green:0.459 blue:0.843 alpha:1.000]; // 色を変更（青）
        scoreRateLabel.text = [NSString stringWithFormat:@"%d", addValue];
        scoreRateLabel.alpha = 1;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideAddScoreLabel) userInfo:nil repeats:NO];
        // =====================
    }
    
    // 連続回数ラベルを更新
    [self changeSequenceLabelWithSuccess:succeeded];
}

#pragma mark - Some Label Animation -
// AddScoreを消す
- (void)hideAddScoreLabel {
    [UIView animateWithDuration:0.3f animations:^(void){
        scoreRateLabel.alpha = 0;
    }];
}
// 手を前に表示する
- (void)bringHandToFrontOf:(NSString*)identifier {
    // ゴミより前
    if ([identifier isEqualToString:@"trash"]) {
        [self.view bringSubviewToFront:handImage];
        [self.view bringSubviewToFront:scoreRateLabel];
        [self.view bringSubviewToFront:countDownView];
        [self.view bringSubviewToFront:nadView_]; // 広告を最前面に表示
    }
    // 餅より前
    else if ([identifier isEqualToString:@"omochisan"]) {
        [self.view bringSubviewToFront:handImage];
        [self.view bringSubviewToFront:scoreRateLabel];
        [self.view bringSubviewToFront:countDownView];
        [self.view bringSubviewToFront:nadView_]; // 広告を最前面に表示
    }
}
// ユーザー補助の画像を表示・非表示
- (void)hideSupportRemoveTrashView { [UIView animateWithDuration:0.3f animations:^(void){supportRemoveTrash.alpha = 0;}]; }
- (void)showSupportRemoveTrashView {
    supportRemoveTrash.alpha = 1;
    [NSTimer scheduledTimerWithTimeInterval:handAnimationDuration*1.1 target:self selector:@selector(hideSupportRemoveTrashView) userInfo:nil repeats:NO];
}
// 評価ラベル
- (void)reputationLabelAnimationWithGood:(BOOL)good {
    if (good) { // 良いとき
        reputationLabel.image = [UIImage imageNamed:@"takumi_mochi_good.png"];
    } else { // 悪いとき
        reputationLabel.image = [UIImage imageNamed:@"takumi_mochi_bad.png"];
    }
    // 表示する前にreputationLabelを最前面に用意する
    [self.view bringSubviewToFront:reputationLabel];
    reputationLabel.alpha = 1;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideReputationLabel) userInfo:nil repeats:NO];
}
- (void)hideReputationLabel {
    [self.view bringSubviewToFront:bikkuri];
    [UIView animateWithDuration:0.5 animations:^(void){
        reputationLabel.alpha = 0;
    }];
}
// びっくりラベル
- (void)bikkuriAnimation {
    bikkuri.alpha = 1;
}
// 爆弾と鐘（ランダム）
- (void)showTrashAtRandom {
    if (trashImageView != nil) {
        [trashImageView removeFromSuperview]; // 画面上から消す
    }
    // 1/4でゴミ、1/2で鐘か爆弾
    int mochiOrTrash = rand() % TRASHRANDOM;
    // ゴミのとき
    if (mochiOrTrash == 0) {
        aRate.moreValueForTrash = 2.0; // ゴミなので得点が2.0倍
        trashImageView = [[UIImageView alloc] initWithFrame:trashDefaultFrame];
        trashImageView.alpha = 1; // アニメーションのときにalpha=0にしたのを、元に戻す
        [self.view addSubview:trashImageView];
        [self showSupportRemoveTrashView]; // ユーザー補助の矢印を表示
        [self bringHandToFrontOf:@"trash"]; // 手の方を前にする
        int kaneOrBom = rand() % 2;
        if (kaneOrBom == 0) {
            // 爆弾
            trashIdentifier = @"bom"; // ゴミの種類をbomに設定
            trashImageView.image = [UIImage imageNamed:@"takumi_mochi_bom.png"];
        } else if (kaneOrBom == 1) {
            // 鐘
            trashIdentifier = @"kane"; // ゴミの種類をkaneに設定
            trashImageView.image = [UIImage imageNamed:@"takumi_mochi_kane.png"];
        }
    }
    // ゴミでないとき
    else {
        aRate.moreValueForTrash = 1.0; // ゴミではないので、倍率は1.0倍
        trashIdentifier = @""; // ゴミがないことを設定
    }
}
// 出来上がった餅
- (void)omochisanAnimation {
    [self soundOn:@"make_omochisan" withExtension:@"mp3"];
    UIImageView* omochisan = [self getOmochisan];
    [self.view addSubview:omochisan];
    [self bringHandToFrontOf:@"omochisan"]; // 手を餅よりも手前に表示する
    [UIView animateWithDuration:0.4f animations:^(void){
        // 得点ラベルに飛んでいく
        omochisan.frame = omochisanLabel.frame;
    }];
    omochisan = nil;
    [omochisan removeFromSuperview]; // 画面上から消す
}
// 完成した餅のUIImageViewを返すメソッド
- (UIImageView*)getOmochisan {
    UIImage* omochisanImage = [UIImage imageNamed:@"takumi_mochi_omochisan.png"];
    UIImageView* omochisanImageView = [[UIImageView alloc] initWithFrame:omochisanDefaultFrame];
    omochisanImageView.image = omochisanImage;
    return omochisanImageView;
}


#pragma mark - Core Animation Delegate -
// HitButtonが押されたときに呼ばれる
- (void)animationDidStart:(CAAnimation *)anim {
    // 杵のアニメーションの場合
    if ([[anim valueForKey:@"id"] isEqualToString:@"kineAnimation"]) {
        [self.view bringSubviewToFront:kineImage]; // アニメーション開始時に杵を最前面に持ってくる
        hitButton.userInteractionEnabled = NO; // アニメーション中はhitButtonを押せない
        // ゴミがない場合だけ
        if ([trashIdentifier isEqualToString:@""]) {
            // アニメーションの真ん中あたりで餅を変形させる
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setCrashedMochi) userInfo:nil repeats:NO];
        }
    }
    // 手のアニメーションの場合
    else if ([[anim valueForKey:@"id"] isEqualToString:@"handAnimation"]) {
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // 杵のアニメーションの場合
    if ([[anim valueForKey:@"id"] isEqualToString:@"kineAnimation"]) {
        hitButton.userInteractionEnabled = YES; // アニメーション終了後、hitButtonを解除
        [self changeSpeed]; // アニメーションが終了したタイミングで手のスピードを変化させる
        [self setNotCrashedMochi]; // アニメーションが終わったら、叩かれていない餅に切り替える
    }
    // 手のアニメーションの場合
    else if ([[anim valueForKey:@"id"] isEqualToString:@"handAnimation"]) {
    }
}


#pragma mark - Close Button -
// タイトルに戻る
- (IBAction)closeButton:(id)sender
{
    //[self.delegate closeViewController:self]; // navigationControllerだからうまくいかない
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Reset Button -
// リトライする
- (IBAction)resetButton:(id)sender {
    [self gameFinish];
}
- (void)restartGame {
    // 時計をストップ
    [self stopTimelimit];
    // アニメーションを全て削除
    [handImage.layer removeAllAnimations];
    [kineImage.layer removeAllAnimations];
    // 諸々の初期化
    [self initializeAllValue];
}

#pragma mark - Game Finish -
- (void)gameFinish {
    // StoryBoardと共存する時の画面遷移（ViewControllerのIdentifierを、StoryBoard IDで定義する。重要）
    RankingViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"RankingViewController"];
    controller.nowScore = aScore; // このプレイでのスコアを渡す
    controller.showRetryOrNot = YES;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    //[self presentModalViewController:controller animated:YES];
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


#pragma mark - Ranking View Controller Delegate -
- (void)closeViewController:(UIViewController*)viewController {
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
    //[viewController.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {    
    handImage = nil;
    kineImage = nil;
    hitButton = nil;
    scoreLabel = nil;
    countDownView = nil;
    countDownLabel = nil;
    mochiImage = nil;
    reputationLabel = nil;
    bikkuri = nil;
    omochisanLabel = nil;
    scoreRateLabel = nil;
    timelimitLabel = nil;
    supportRemoveTrash = nil;
    sequenceLabel = nil;
    addTimelimitLabel = nil;
    takumikunImageView = nil;
    retryButton = nil;
    titleButton = nil;
    [super viewDidUnload];
}

@end


