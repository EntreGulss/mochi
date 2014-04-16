//
//  GAManager.h
//  mochi
//
//  Created by 大竹 雅登 on 13/01/13.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Score.h"

// トラッキングID
//#define TrackingID @"UA-37622107-1" // Masato
#define TrackingID @"UA-25919176-11" // Kitagawa

@interface GAManager : NSObject

+ (void)postTrackView:(NSString*)string;
+ (NSString *)createStringForTheTrackView:(NSString *)string;
+ (void)postValue:(Score*)score;
@end
