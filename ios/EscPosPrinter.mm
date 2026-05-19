#import "EscPosPrinter.h"
#import <React/RCTConvert.h>


#import "ThePrinter.h"
#import "ThePrinterManager.h"
#import "EposStringHelper.h"


@interface EscPosPrinter() <PrinterDelegate, Epos2ScanDelegate, Epos2ConnectionDelegate>

@end

@implementation EscPosPrinter

RCT_EXPORT_MODULE()
- (id)init {
    self = [super init];
    if (self) {
         objManager_ = [ThePrinterManager sharedManager];
         [objManager_ removeAll];
    }

    return  self;
}

#if RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeEscPosPrinterSpecJSI>(params);
}
#endif

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onPrintSuccess", @"onPrintFailure", @"onGetPaperWidthSuccess", @"onGetPaperWidthFailure", @"onMonitorStatusUpdate", @"onScanData"];
}


- (NSDictionary *)constantsToExport
{
 return  [EposStringHelper getPrinterConstants];
}

- (NSDictionary *)getConstants {
    return [self constantsToExport];
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

RCT_EXPORT_METHOD(initWithPrinterDeviceName:(NSString *)target
                  deviceName:(NSString *)deviceName
                  lang:(double)lang
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
     @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];

        if (thePrinter == nil) {
            int series = [EposStringHelper getPrinterSeries: deviceName];
             NSLog(@"deviceName: %@", deviceName);

            NSLog(@"series: %d", series);
            thePrinter = [[ThePrinter alloc] initWith:target series:series lang:lang delegate:self];
            NSLog(@"thePrinter: %@", thePrinter);
            [objManager_ add:thePrinter];
        }

        Epos2Printer* printer = [thePrinter getEpos2Printer];

        if (printer == nil) {
          reject(@"event_failure", [@(EPOS2_ERR_MEMORY) stringValue], nil);
        } else {
          resolve(nil);
        }
    }
}

RCT_EXPORT_METHOD(connect: (nonnull NSString*)target
                  timeout: (double)timeout
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    ThePrinter* thePrinter = nil;
    @synchronized (self) {
        thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            int result = [thePrinter connect:timeout];

            if(result == EPOS2_SUCCESS) {
                resolve(nil);
            } else {
                reject(@"event_failure", [@(result) stringValue], nil);
            }
        }
    }
}

RCT_EXPORT_METHOD(disconnect: (nonnull NSString*) target
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter disconnect];
        }

        if(result == EPOS2_SUCCESS || result == EPOS2_ERR_ILLEGAL) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(clearCommandBuffer: (nonnull NSString*) target
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter clearCommandBuffer];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addText: (nonnull NSString*) target
                  data: (NSString*) data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addText:data];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addTextLang: (nonnull NSString*) target
                  lang: (double) lang
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addTextLang:lang];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addFeedLine: (nonnull NSString*) target
                  line: (double) line
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addFeedLine:line];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addLineSpace: (nonnull NSString*) target
                  linespc: (double) linespc
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addLineSpace:linespc];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addCut: (nonnull NSString*) target
                  type: (double)type
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addCut: type];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addCommand: (nonnull NSString*) target
                  base64string: (NSString*)base64string
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addCommand:base64string];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addPulse: (nonnull NSString*) target
                  drawer: (double)drawer
                  time: (double)time
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addPulse:drawer time:time];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addTextAlign: (nonnull NSString*) target
                  align: (double)align
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addTextAlign:align];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}


RCT_EXPORT_METHOD(addTextSize: (nonnull NSString*) target
                  width: (double)width
                  height:(double)height
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addTextSize:width height:height];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addTextStyle: (nonnull NSString*) target
                  reverse:(double)reverse
                  ul:(double)ul
                  em:(double)em
                  color:(double)color
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addTextStyle:reverse ul:ul em:em color:color];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}


RCT_EXPORT_METHOD(addTextSmooth: (nonnull NSString*) target
                  smooth: (double)smooth
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addTextSmooth:smooth];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(getStatus: (nonnull NSString*) target
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            reject(@"event_failure", [@([EposStringHelper getInitErrorResultCode]) stringValue], nil);
        } else {
            NSDictionary* status = [thePrinter getStatus];

            if(status) {
              resolve(status);
            } else {
              reject(@"event_failure", [@(EPOS2_ERR_FAILURE) stringValue], nil);
            }

        }
    }
}


RCT_EXPORT_METHOD(addImage: (nonnull NSString*) target
                  source:(NSDictionary *)source
                  width:(double)width
                  color:(double)color
                  mode:(double)mode
                  halftone:(double)halftone
                  brightness:(double)brightness
                  compress:(double)compress
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addImage: source width:width color:color mode:mode halftone:halftone brightness:brightness compress:compress];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}


RCT_EXPORT_METHOD(addBarcode: (nonnull NSString*) target
                  data:(NSString *)data
                  type:(double)type
                  hri:(double)hri
                  font:(double)font
                  width:(double)width
                  height:(double)height
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addBarcode: data type:type hri:hri font:font width:width height:height];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(addSymbol: (nonnull NSString*) target
                  data: (NSString *)data
                  type:(double)type
                  level:(double)level
                  width:(double)width
                  height:(double)height
                  size:(double)size
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    int result = EPOS2_SUCCESS;
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            result = [EposStringHelper getInitErrorResultCode];
        } else {
            result = [thePrinter addSymbol: data type:type level:level width:width height:height size:size];
        }

        if(result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

RCT_EXPORT_METHOD(sendData: (nonnull NSString*) target
                  timeout: (double)timeout
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{

    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            reject(@"event_failure", [@{
                    @"data": @([EposStringHelper getInitErrorResultCode]),
                    @"type": @"result"
            } description], nil);
        }

        [thePrinter sendData: timeout successHandler:^(NSDictionary *data){
            resolve(data);
        } errorHandler:^(NSString *data) {
            reject(@"event_failure", data, nil);
        }];
    }
}

RCT_EXPORT_METHOD(getPrinterSetting:(nonnull NSString*) target
                  timeout: (double)timeout
                  type: (double)type
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{

    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            reject(@"event_failure", [@{
                    @"data": @([EposStringHelper getInitErrorResultCode]),
                    @"type": @"result"
            } description], nil);
        }

        [thePrinter getPrinterSetting: timeout type:type successHandler:^(NSDictionary *data){
            resolve(data);
        } errorHandler:^(NSString *data) {
            reject(@"event_failure", data, nil);
        }];
    }
}



#pragma mark - Rendered text (text as image for arbitrary font size)

RCT_EXPORT_METHOD(addRenderedText: (nonnull NSString*) target
                  text: (NSString*) text
                  fontSize: (double) fontSize
                  bold: (BOOL) bold
                  fontFamily: (NSString*) fontFamily
                  align: (double) align
                  paperWidth: (double) paperWidth
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    @synchronized (self) {
        ThePrinter* thePrinter = [objManager_ getObject:target];
        if (thePrinter == nil) {
            reject(@"event_failure", [@([EposStringHelper getInitErrorResultCode]) stringValue], nil);
            return;
        }

        // Build font
        UIFont *font;
        if (fontFamily != nil && [fontFamily length] > 0) {
            UIFont *customFont = [UIFont fontWithName:fontFamily size:(CGFloat)fontSize];
            if (customFont) {
                if (bold) {
                    UIFontDescriptor *descriptor = [customFont.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
                    if (descriptor) {
                        font = [UIFont fontWithDescriptor:descriptor size:(CGFloat)fontSize];
                    } else {
                        font = customFont;
                    }
                } else {
                    font = customFont;
                }
            } else {
                font = bold ? [UIFont boldSystemFontOfSize:(CGFloat)fontSize] : [UIFont systemFontOfSize:(CGFloat)fontSize];
            }
        } else {
            font = bold ? [UIFont boldSystemFontOfSize:(CGFloat)fontSize] : [UIFont systemFontOfSize:(CGFloat)fontSize];
        }

        // Set up paragraph style for alignment
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        if ((int)align == EPOS2_ALIGN_CENTER) {
            paragraphStyle.alignment = NSTextAlignmentCenter;
        } else if ((int)align == EPOS2_ALIGN_RIGHT) {
            paragraphStyle.alignment = NSTextAlignmentRight;
        } else {
            paragraphStyle.alignment = NSTextAlignmentLeft;
        }

        NSDictionary *attributes = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: [UIColor blackColor],
            NSParagraphStyleAttributeName: paragraphStyle,
        };

        // Calculate text size within paper width
        CGFloat maxWidth = (CGFloat)paperWidth;
        CGRect textRect = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
        CGSize imageSize = CGSizeMake(maxWidth, ceil(textRect.size.height));

        // Render text to image
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1.0);
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
        [text drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)
          withAttributes:attributes];
        UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        if (textImage == nil) {
            reject(@"event_failure", [@(EPOS2_ERR_FAILURE) stringValue], nil);
            return;
        }

        // Add image to printer command buffer
        Epos2Printer* printer = [thePrinter getEpos2Printer];
        int result = [printer addImage:textImage
                                     x:0
                                     y:0
                                 width:(long)imageSize.width
                                height:(long)imageSize.height
                                 color:EPOS2_COLOR_1
                                  mode:EPOS2_MODE_MONO
                              halftone:EPOS2_HALFTONE_DITHER
                            brightness:1.0
                              compress:EPOS2_COMPRESS_AUTO];

        if (result == EPOS2_SUCCESS) {
            resolve(nil);
        } else {
            reject(@"event_failure", [@(result) stringValue], nil);
        }
    }
}

#pragma mark - Force reset / recover

RCT_EXPORT_METHOD(forceReset: (nonnull NSString*) target
                  timeout: (double)timeout
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            ThePrinter* thePrinter = [objManager_ getObject:target];
            if (thePrinter == nil) {
                reject(@"event_failure", [@([EposStringHelper getInitErrorResultCode]) stringValue], nil);
                return;
            }

            int result = [thePrinter forceReset:(long)timeout];
            if(result == EPOS2_SUCCESS) {
                resolve(nil);
            } else {
                reject(@"event_failure", [@(result) stringValue], nil);
            }
        }
    });
}

RCT_EXPORT_METHOD(forceRecover: (nonnull NSString*) target
                  timeout: (double)timeout
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            ThePrinter* thePrinter = [objManager_ getObject:target];
            if (thePrinter == nil) {
                reject(@"event_failure", [@([EposStringHelper getInitErrorResultCode]) stringValue], nil);
                return;
            }

            int result = [thePrinter forceRecover:(long)timeout];
            if(result == EPOS2_SUCCESS) {
                resolve(nil);
            } else {
                reject(@"event_failure", [@(result) stringValue], nil);
            }
        }
    });
}


#pragma mark - Barcode scanner API

RCT_EXPORT_METHOD(initBarcodeScanner:(NSString *)target
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    if (barcodeScanner_ != nil) {
        resolve(nil);
        return;
    }

    barcodeScanner_ = [[Epos2BarcodeScanner alloc] init];
    if (barcodeScanner_ == nil) {
        reject(@"event_failure", [@(EPOS2_ERR_MEMORY) stringValue], nil);
        return;
    }

    scannerTarget_ = target;
    [barcodeScanner_ setScanEventDelegate:self];
    [barcodeScanner_ setConnectionEventDelegate:self];
    resolve(nil);
}

RCT_EXPORT_METHOD(connectBarcodeScanner:(double)timeout
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    if (barcodeScanner_ == nil || scannerTarget_ == nil) {
        reject(@"event_failure", [@(EPOS2_ERR_PARAM) stringValue], nil);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int result = [self->barcodeScanner_ connect:self->scannerTarget_ timeout:(int)timeout];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == EPOS2_SUCCESS) {
                resolve(nil);
            } else {
                reject(@"event_failure", [@(result) stringValue], nil);
            }
        });
    });
}

RCT_EXPORT_METHOD(disconnectBarcodeScanner:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    if (barcodeScanner_ == nil) {
        resolve(nil);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int result = [self->barcodeScanner_ disconnect];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == EPOS2_SUCCESS) {
                resolve(nil);
            } else {
                reject(@"event_failure", [@(result) stringValue], nil);
            }
            self->barcodeScanner_ = nil;
        });
    });
}

#pragma mark - Epos2ScanDelegate

- (void)onScanData:(Epos2BarcodeScanner *)scannerObj scanData:(NSString *)scanData
{
    if (!scanData) { return; }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"onScanData" body:@{@"data": scanData}];
    });
}

#pragma mark - Epos2ConnectionDelegate

- (void)onConnection:(id)deviceObj eventType:(int)eventType
{
    NSLog(@"[EscPosPrinter] onConnection eventType: %d", eventType);
}

@end
