//
//  UIColor+llh.m
//  LLHPhoto
//
//  Created by lovecj on 2016/8/18.
//  Copyright © 2017年 lovecj. All rights reserved.
//

#import "UIColor+llh.h"

@implementation UIColor (llh)

+ (UIColor*)colorWithHexInteger:(NSInteger)hexInteger alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((hexInteger >> 16) & 0xFF)/255.0 green:((hexInteger >> 8) & 0xFF)/255.0 blue:((hexInteger) & 0xFF)/255.0 alpha:alpha];
}

+ (UIColor*)colorWithHexString:(NSString*)hexString alpha:(CGFloat)alpha {
    long hex = [hexString intValue];
    return [UIColor colorWithHexInteger:hex alpha:alpha];
}

/* Common */
+(UIColor *)commonBlueColor                     {return [UIColor colorWithHexInteger:0x05beff alpha:1.0];}
+(UIColor *)commonText1Color                     {return [UIColor colorWithHexInteger:0x111111 alpha:1.0];}
+(UIColor *)commonText3Color                     {return [UIColor colorWithHexInteger:0x333333 alpha:1.0];}
+(UIColor *)commonText6Color                     {return [UIColor colorWithHexInteger:0x666666 alpha:1.0];}
+(UIColor *)commonText9Color                     {return [UIColor colorWithHexInteger:0x999999 alpha:1.0];}
+(UIColor *)commonText12Color                    {return [UIColor colorWithHexInteger:0xcccccc alpha:1.0];}
+(UIColor *)commonTextBlueColor                 {return [UIColor colorWithHexInteger:0x14AAFF alpha:1.0];}
+(UIColor *)commonBackgroundColor               {return [UIColor colorWithHexInteger:0x6cb7f1 alpha:0.6];}
+(UIColor *)commonLineColor                     {return [UIColor colorWithHexInteger:0xE5E5E5 alpha:1.0];}
+(UIColor *)commonSliderMinimumTrackColor        {return [UIColor colorWithHexInteger:0x0fc3ff alpha:1.0];}
+(UIColor *)commonSliderMaxmumTrackColor         {return [UIColor colorWithHexInteger:0xcccccc alpha:1.0];}
+(UIColor *)commonViewEColor                     {return [UIColor colorWithHexInteger:0xeeeeee alpha:1.0];}

+(UIColor *)commonButtonColor                     {return [UIColor colorWithHexInteger:0x1BB9FF alpha:1.0];}


@end
