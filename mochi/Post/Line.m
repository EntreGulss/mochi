//
//  Line.m
//  mochi
//
//  Created by 大竹 雅登 on 13/01/13.
//  Copyright (c) 2013年 大竹 雅登. All rights reserved.
//

#import "Line.h"

@implementation NSString(stringWithURLEncoding) // NSStringを拡張
// URLエンコードに変換
- (NSString *)stringWithURLEncoding
{
    // ref: http://blog.daisukeyamashita.com/post/1686.html
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                        NULL,
                                                                        (CFStringRef)self,
                                                                        NULL,
                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                        kCFStringEncodingUTF8 );
}
@end

@implementation Line
// LINEで送る
+ (void)shareToLine:(NSString*)content {
    NSString *contentType = @"text";
    NSString *contentKey = [content stringWithURLEncoding];
    NSString *urlString = [NSString
                           stringWithFormat: @"http://line.naver.jp/R/msg/%@/?%@",
                           contentType, contentKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}


@end
