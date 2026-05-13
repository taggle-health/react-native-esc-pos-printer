#import "ePOS2.h"
#import "ThePrinterManager.h"

#if RCT_NEW_ARCH_ENABLED
#import "RNEscPosPrinterSpec.h"
#import <React/RCTEventEmitter.h>

@interface EscPosPrinter : RCTEventEmitter <NativeEscPosPrinterSpec, Epos2ScanDelegate, Epos2ConnectionDelegate>
{
    ThePrinterManager* objManager_;
    Epos2BarcodeScanner* barcodeScanner_;
    NSString* scannerTarget_;
}
@end
#else

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
@interface EscPosPrinter : RCTEventEmitter <RCTBridgeModule, Epos2ScanDelegate, Epos2ConnectionDelegate>
{
    ThePrinterManager* objManager_;
    Epos2BarcodeScanner* barcodeScanner_;
    NSString* scannerTarget_;
}
@end


#endif
