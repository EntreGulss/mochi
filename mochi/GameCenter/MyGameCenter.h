//
//  MyGameCenter.h
//  mochi
//
//  Created by 大竹 雅登 on 13/01/25.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Score.h"

@interface MyGameCenter : NSObject

@property (nonatomic, readonly) NSError* lastError;
@property (nonatomic, readonly) GKLocalPlayer* localPlayer;

+ (MyGameCenter*)sharedManager;

- (void)submitScore:(int)score category:(NSString*)category;
- (void)loginGameCenter;

/* GameCenterはiOS4.1以前では使えない。（そもそもアプリ自体iOS5.0以降対応なので気にしなくていい） */
/* シングルトン */

@end
