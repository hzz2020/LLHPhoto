//
//  UIColor+llh.h
//  LLHPhoto
//
//  Created by lovecj on 2016/8/18.
//  Copyright © 2017年 lovecj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (llh)

+ (UIColor*)colorWithHexInteger:(NSInteger)hexInteger alpha:(CGFloat)alpha;
+ (UIColor*)colorWithHexString:(NSString*)hexString alpha:(CGFloat)alpha;

/* Common */
+(UIColor *)commonBlueColor;
+(UIColor *)commonText1Color;
+(UIColor *)commonText3Color;
+(UIColor *)commonText6Color;
+(UIColor *)commonText9Color;
+(UIColor *)commonText12Color;
+(UIColor *)commonTextBlueColor;
+(UIColor *)commonBackgroundColor;
+(UIColor *)commonLineColor;
+(UIColor *)commonSliderMinimumTrackColor;
+(UIColor *)commonSliderMaxmumTrackColor;
+(UIColor *)commonViewEColor;
+(UIColor *)commonButtonColor;


@end
