### RHScan——实现二维码扫描功能，含各种UI、手势放大缩小镜头、仿微信扫码放大
[iOS原生实现二维码拉近放大](https://www.jianshu.com/p/080814eff67e)
---
> 说明
> 本程序仅供学习交流，不可用于任何商业用途。


### 引用
 CocoaPods安装
> pod 'RHScan'



## 前言

生活中，我们都是使用支付宝支付，当我们再扫描一个较远的二维码过程中，我们会发现，镜头会自动放大很容易扫到二维码进行支付。看起来这么人性化的操作，又是什么原理，该怎么实现呢？扫码现在很常见, 很多App基本都具备扫码功能， 网上也有很多对iOS二维码的讲解, Github上也有很多事例、开源的代码，但是发现APP扫码功能上，自动拉近扫描二维码的这波神操作，很少涉及。本文简单介绍如何iOS原生如何实现扫描较小二维码过程中拉近放大。
先看看本文效果图：
![Demo](https://upload-images.jianshu.io/upload_images/11651769-25bb31fe68432bd2.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/290)

对比支付宝扫码放大效果图：

![支付宝](https://upload-images.jianshu.io/upload_images/11651769-65878e3ed8694a53.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/290)

##实现
从网络技术博客、Github上，我们都能很快实现一个二维码扫描功能，本文不再重复这些知识点。重点是如何拉近镜头和定位到二维码判断二维码大小。
### iOS原生扫码
以下是iOS AVFoundation的扫码原理图。
![原理图](https://upload-images.jianshu.io/upload_images/11651769-a17ad580da0d6ec9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 拉近镜头
苹果提供了AVCaptureConnection中，videoScaleAndCropFactor：缩放裁剪系数,使用该属性，可以实现拉近拉远镜头。
```
- (void)setVideoScale:(CGFloat)scale{

	//注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    [_input.device lockForConfiguration:nil];
    
    //获取放大最大倍数
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    CGFloat maxScaleAndCropFactor = ([[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor])/16; 
    
    if (scale > maxScaleAndCropFactor)
        scale = maxScaleAndCropFactor;
    
    CGFloat zoom = scale / videoConnection.videoScaleAndCropFactor;
    
    videoConnection.videoScaleAndCropFactor = scale;
    
    [_input.device unlockForConfiguration];
    
    CGAffineTransform transform = _videoPreView.transform;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    
     _videoPreView.transform = CGAffineTransformScale(transform, zoom, zoom);
    
    [CATransaction commit];
   
} 
```
实现步骤：
1、首先调用lockForConfiguration。
2、获取系统相机最大倍数，根据需求自定义MAX倍数。
3、改变videoScaleAndCropFactor。
4、unlockForConfiguration方法解锁。
5、将视图layer层放大对应的倍数。

*1、注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁。*
*2、the videoScaleAndCropFactor property may be set to a value in the range of 1.0 to videoMaxScaleAndCropFactor，videoScaleAndCropFactor这个属性取值范围是1.0-videoMaxScaleAndCropFactor，如果你设置超出范围会崩溃哦*
   ----------
###二维码定位
我们都知道，原生扫描结果AVCaptureMetadataOutputObjectsDelegate是返回了一个数组，而数组里面是一个个的AVMetadataMachineReadableCodeObject，而AVMetadataMachineReadableCodeObject中有个corners数组，记录二维码的坐标。查阅了官方文档和相关资料，我们很容易联想到，通过corners来获取二维码的坐标，大小形状。
>  @@property corners  
>  @abstract  The points defining the (X,Y)
> locations of the corners of the machine-readable code.
> 
> @discussion  
> The value of this property is an NSArray of
> NSDictionaries, each of which has been created from a CGPoint using
> CGPointCreateDictionaryRepresentation(), representing the coordinates
> of the corners of the object with respect to the image in which it
> resides. If the metadata originates from video, the points may be
> expressed as scalar values from 0. - 1. The points in the corners
> differ from the bounds rectangle in that bounds is axis-aligned to
> orientation of the captured image, and the values of the corners
> reside within the bounds rectangle. The points are arranged in
> counter-clockwise order (clockwise if the code or image is mirrored),
> starting with the top-left of the code in its canonical orientation. 


```
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!bNeedScanResult) {
        return;
    }
    
    bNeedScanResult = NO;
    
    if (!_arrayResult) {
        
        self.arrayResult = [NSMutableArray arrayWithCapacity:1];
    }
    else
    {
        [_arrayResult removeAllObjects];
    }
    
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects)
    {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] )
        {
            bNeedScanResult = NO;
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            
            if (scannedResult && ![scannedResult isEqualToString:@""])
            {
                [_arrayResult addObject:scannedResult];
            }
            //测试可以同时识别多个二维码
        }
    }
    
    if (_arrayResult.count < 1)
    {
        bNeedScanResult = YES;
        return;
    }
    if (_isAutoVideoZoom && !bHadAutoVideoZoom) {
        
        AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)[self.preview transformedMetadataObjectForMetadataObject:metadataObjects.lastObject];
        [self changeVideoScale:obj];
         bNeedScanResult = YES;
         bHadAutoVideoZoom  =YES;
        return;
    }
    if (_isNeedCaputureImage)
    {
        [self captureImage];
    }
    else
    {
        [self stopScan];

        if (_blockScanResult) {
            _blockScanResult(_arrayResult);
        }
    }
}
```

当使用iOS原生扫码过程中，当系统相机检测到二维码类型，回调通知我们，第一次我们可以检测二维码大小及其位置（如果非原生扫码，可以通过OpenCV识别二维码，将其定位，有待研究）。
```
- (void)changeVideoScale:(AVMetadataMachineReadableCodeObject *)objc
{
    NSArray *array = objc.corners;
    CGPoint point = CGPointZero;
    int index = 0;
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把点转换为不可变字典
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    NSLog(@"X:%f -- Y:%f",point.x,point.y);
    CGPoint point2 = CGPointZero;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[2], &point2);
    NSLog(@"X:%f -- Y:%f",point2.x,point2.y);
    CGFloat scace =150/(point2.x-point.x); //当二维码图片宽小于150，进行放大
    if (scace > 1) {
        //实现动画效果
        for (CGFloat i= 1.0; i<=scace; i = i+0.001) {
            [self setVideoScale:i];
        }
    }
    return;
}
```
上代码块中changeVideoScale函数已将二维码位置和宽定位出来，根据需求当相机识别的二维码的宽少于150时，我们可以通过拉近镜头来实现放大二维码。
     
##小结

> 本文使用iOS原生扫码实现如何扫码过程拉近镜头放大二维码，上述方法并无提高识别的速率，反而减慢了，如果要提高识别速度，可以从OpenCV识别二维码定位的方向考虑。如果你有更好的方法或方案麻烦告知。

[ iOS 模仿微信扫描二维码放大功能](https://blog.csdn.net/sinat_30336277/article/details/79314472)

[ iOS 扫描二维码实现手势拉近拉远镜头](https://blog.csdn.net/sinat_30336277/article/details/79276113)

[ iOS 识别过程中描绘二维码边框](https://blog.csdn.net/sinat_30336277/article/details/79295025)

## 喜欢的朋友希望可以给个 Star，十分感谢您的支持！~

