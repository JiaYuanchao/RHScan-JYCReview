//
//  RHScanViewStyle.m
//
//
//  Created by Richinfo on 16/11/16.
//  Copyright © 2016年 Richinfo. All rights reserved.
//

#import "RHScanViewStyle.h"

@implementation RHScanViewStyle

- (id)init
{
    if (self =  [super init])
    {
        _isNeedShowRetangle = YES;
        
        _whRatio = 1.0;
       
        _colorRetangleLine = [UIColor colorWithRed:0. green:167./255. blue:231./255. alpha:1.0];
        
        _centerUpOffset = 80;
        _xScanRetangleOffset = 60;
        
        _anmiationStyle = RichScanViewAnimationStyle_LineMove;
        _animationImage = [UIImage imageNamed:@"sc_qrcode_scan_light_green"];
        _photoframeAngleStyle = RichScanViewPhotoframeAngleStyle_Inner;
        _colorAngle = [UIColor colorWithRed:0. green:167./255. blue:231./255. alpha:1.0];
        _notRecoginitonArea = [UIColor colorWithRed:0. green:.0 blue:.0 alpha:.5];
        
        _photoframeAngleW = 18;
        _photoframeAngleH = 18;
        _photoframeLineW = 4;
        
    }
    
    return self;
}

@end

