import {
  NativeModules,
  NativeEventEmitter,
  DeviceEventEmitter,
  Platform,
} from 'react-native';
import type { EmitterSubscription } from 'react-native';
import type { Spec as NativeEscPosPrinterSpec } from './NativeEscPosPrinter';
import type { Spec as NativeEscPosPrinterDiscoverySpec } from './NativeEscPosPrinterDiscovery';

const isTurboModuleEnabled =
  !!global.__turboModuleProxy || !!global.RN$Bridgeless;

let EscPosPrinter: NativeEscPosPrinterSpec;
let EscPosPrinterDiscovery: NativeEscPosPrinterDiscoverySpec;

// Unified scanner event listener that works in both architectures.
// In TurboModule/bridgeless mode we CANNOT call new NativeEventEmitter()
// without a native module — it throws in RN 0.76+.
// DeviceEventEmitter is a global bus that needs no module reference,
// and sendEventWithName:body: on the iOS side routes to it correctly.
const addScanDataListener = (
  handler: (event: { data: string }) => void
): EmitterSubscription => {
  if (isTurboModuleEnabled) {
    return DeviceEventEmitter.addListener('onScanData', handler);
  }
  // Old arch: use NativeEventEmitter bound to the native module
  const emitter = new NativeEventEmitter(NativeModules.EscPosPrinter);
  return emitter.addListener('onScanData', handler);
};

if (isTurboModuleEnabled) {
  EscPosPrinter = require('./NativeEscPosPrinter').default;
  EscPosPrinterDiscovery = require('./NativeEscPosPrinterDiscovery').default;
} else {
  const {
    EscPosPrinterDiscovery: OldArchEscPosPrinterDiscovery,
    EscPosPrinter: OldArchEscPosPrinter,
  } = NativeModules;
  const DiscoveryEventEmitter = new NativeEventEmitter(
    OldArchEscPosPrinterDiscovery
  );

  EscPosPrinterDiscovery = {
    ...NativeModules.EscPosPrinterDiscovery,
    onDiscovery: (callback: any) => {
      return DiscoveryEventEmitter.addListener('onDiscovery', callback);
    },
    ...(Platform.OS === 'android'
      ? {
          enableLocationSettingSuccess: (callback: any) => {
            return DiscoveryEventEmitter.addListener(
              'enableLocationSettingSuccess',
              callback
            );
          },
          enableLocationSettingFailure: (callback: any) => {
            return DiscoveryEventEmitter.addListener(
              'enableLocationSettingFailure',
              callback
            );
          },
        }
      : {}),
  };

  EscPosPrinter = OldArchEscPosPrinter;
}

export { EscPosPrinter, EscPosPrinterDiscovery, addScanDataListener };
