import { Image } from 'react-native';
import type { EmitterSubscription } from 'react-native';
import {
  CommonOperationErrorMessageMapping,
  ConnectPrinterErrorMessageMapping,
  DisconnectPrinterErrorMessageMapping,
  InitPrinterErrorMessageMapping,
  PrintErrorCodeMessageMapping,
  PrinterConstants,
  PrinterErrorCodeStatusMapping,
  PrinterErrorStatusMapping,
  PrinterGetSettingsType,
  SendDataPrinterErrorMessageMapping,
} from './constants';
import type {
  AddBarcodeParams,
  AddCutTypeParam,
  AddFontStyleParams,
  AddImageParams,
  AddPulseParams,
  AddSymbolParams,
  AddTextAlignParam,
  AddTextLangParam,
  AddTextSizeParams,
  AddTextSmoothParam,
  AddTextStyleParams,
  PrinterInitParams,
  PrinterSettingsRawResponse,
  PrinterStatusRawResponse,
} from './types';
import {
  BufferHelper,
  parsePrinterSettings,
  parsePrinterStatus,
  processComplextError,
  throwProcessedError,
} from './utils';

import { EscPosPrinter, addScanDataListener } from '../specs';

export class PrinterWrapper {
  private target: string;
  private printerPaperWidth: number = null;
  public currentFontWidth: number = 1;
  private currentAlign: number = 0;
  private scanDataSubscription?: EmitterSubscription;

  constructor(target: string) {
    this.target = target;
  }

  init = async ({ deviceName, lang }: PrinterInitParams) => {
    try {
      await EscPosPrinter.initWithPrinterDeviceName(
        this.target,
        deviceName,
        lang
      );
      this.currentFontWidth = 1;
      this.currentAlign = 0;
    } catch (error) {
      throwProcessedError({
        methodName: 'init',
        errorCode: error.message,
        messagesMapping: InitPrinterErrorMessageMapping,
      });
    }
  };

  connect = async (timeout: number = 15000) => {
    try {
      await EscPosPrinter.connect(this.target, timeout);
    } catch (error) {
      throwProcessedError({
        methodName: 'connect',
        errorCode: error.message,
        messagesMapping: ConnectPrinterErrorMessageMapping,
      });
    }
  };

  disconnect = async () => {
    try {
      await EscPosPrinter.disconnect(this.target);
    } catch (error) {
      throwProcessedError({
        methodName: 'disconnect',
        errorCode: error.message,
        messagesMapping: DisconnectPrinterErrorMessageMapping,
      });
    }
  };

  /**
   * Forcefully Clears the command buffer of the printer
   * Caution ☢️: Only use this method if disconnecting the printer is not an option.
   *
   * Disconnecting will automatically clear the command buffer.
   */
  clearCommandBuffer = async () => {
    try {
      await EscPosPrinter.clearCommandBuffer(this.target);
    } catch (error) {
      throwProcessedError({
        methodName: 'clearCommandBuffer',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addText = async (data: string) => {
    try {
      await EscPosPrinter.addText(this.target, data);
    } catch (error) {
      throwProcessedError({
        methodName: 'addText',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addTextLang = async (lang: AddTextLangParam) => {
    try {
      await EscPosPrinter.addTextLang(this.target, lang);
    } catch (error) {
      throwProcessedError({
        methodName: 'addTextLang',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addFeedLine = async (line: number = 1) => {
    try {
      if (this.fontStyleState) {
        // Generate exactly n lines of empty text to force the rendering engine
        // to create a gap exactly matching the custom font size multiplier.
        let spaceBlock = ' ';
        for (let i = 1; i < line; i++) {
          spaceBlock += '\n ';
        }
        await this.addStyledText(spaceBlock);
        return;
      }

      await EscPosPrinter.addFeedLine(this.target, line);
    } catch (error) {
      throwProcessedError({
        methodName: 'addFeedLine',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addLineSpace = async (linespc: number) => {
    try {
      await EscPosPrinter.addLineSpace(this.target, linespc);
    } catch (error) {
      throwProcessedError({
        methodName: 'addLineSpace',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addCut = async (type: AddCutTypeParam = PrinterConstants.PARAM_DEFAULT) => {
    try {
      await EscPosPrinter.addCut(this.target, type);
    } catch (error) {
      throwProcessedError({
        methodName: 'addCut',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  sendData = async (timeout: number = 5000) => {
    try {
      const result = (await EscPosPrinter.sendData(
        this.target,
        timeout
      )) as PrinterStatusRawResponse;
      return parsePrinterStatus(result);
    } catch (error) {
      const { errorType, data } = processComplextError(error.message);

      throwProcessedError({
        methodName: 'sendData',
        errorCode: data,
        messagesMapping:
          errorType === 'code'
            ? PrintErrorCodeMessageMapping
            : SendDataPrinterErrorMessageMapping,
        statusMapping:
          errorType === 'code'
            ? PrinterErrorCodeStatusMapping
            : PrinterErrorStatusMapping,
      });
    }
  };

  getPrinterSetting = async (
    type: PrinterGetSettingsType,
    timeout: number = 10000
  ) => {
    try {
      const isPrinterPaperWidthRequested =
        type === PrinterGetSettingsType.PRINTER_SETTING_PAPERWIDTH;

      if (isPrinterPaperWidthRequested && this.printerPaperWidth) {
        return parsePrinterSettings({ type, value: this.printerPaperWidth });
      }

      const result = (await EscPosPrinter.getPrinterSetting(
        this.target,
        timeout,
        type
      )) as PrinterSettingsRawResponse;

      if (isPrinterPaperWidthRequested) {
        this.printerPaperWidth = result.value;
      }

      return parsePrinterSettings(result);
    } catch (error) {
      const { errorType, data } = processComplextError(error.message);

      throwProcessedError({
        methodName: 'getPrinterSetting',
        errorCode: data,
        messagesMapping:
          errorType === 'code'
            ? PrintErrorCodeMessageMapping
            : CommonOperationErrorMessageMapping,
        statusMapping:
          errorType === 'code'
            ? PrinterErrorCodeStatusMapping
            : PrinterErrorStatusMapping,
      });
    }
  };

  getStatus = async () => {
    try {
      const result = (await EscPosPrinter.getStatus(
        this.target
      )) as PrinterStatusRawResponse;
      return parsePrinterStatus(result);
    } catch (error) {
      throwProcessedError({
        methodName: 'getStatus',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addImage = async ({
    source,
    width,
    color = PrinterConstants.PARAM_DEFAULT,
    mode = PrinterConstants.PARAM_DEFAULT,
    halftone = PrinterConstants.PARAM_DEFAULT,
    brightness = PrinterConstants.PARAM_DEFAULT,
    compress = PrinterConstants.PARAM_DEFAULT,
  }: AddImageParams) => {
    try {
      const resolvedSource = Image.resolveAssetSource(source);
      await EscPosPrinter.addImage(
        this.target,
        resolvedSource,
        width,
        color,
        mode,
        halftone,
        brightness,
        compress
      );
    } catch (error) {
      throwProcessedError({
        methodName: 'addImage',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addBarcode = async ({
    data,
    type,
    hri = PrinterConstants.PARAM_DEFAULT,
    font = PrinterConstants.PARAM_DEFAULT,
    width = PrinterConstants.PARAM_UNSPECIFIED,
    height = PrinterConstants.PARAM_UNSPECIFIED,
  }: AddBarcodeParams) => {
    try {
      await EscPosPrinter.addBarcode(
        this.target,
        data,
        type,
        hri,
        font,
        width,
        height
      );
    } catch (error) {
      throwProcessedError({
        methodName: 'addBarcode',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addSymbol = async ({
    data,
    type,
    level = PrinterConstants.PARAM_DEFAULT,
    width,
    height,
    size,
  }: AddSymbolParams) => {
    try {
      await EscPosPrinter.addSymbol(
        this.target,
        data,
        type,
        level,
        width || size,
        height || size,
        size
      );
    } catch (error) {
      throwProcessedError({
        methodName: 'addSymbol',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addCommand = async (uint8Array: Uint8Array) => {
    try {
      const buffer = new BufferHelper();
      const base64String = buffer.bytesToString(uint8Array, 'base64');
      await EscPosPrinter.addCommand(this.target, base64String);
    } catch (error) {
      throwProcessedError({
        methodName: 'addCommand',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addPulse = async ({
    drawer = PrinterConstants.PARAM_DEFAULT,
    time = PrinterConstants.PARAM_DEFAULT,
  }: AddPulseParams = {}) => {
    try {
      await EscPosPrinter.addPulse(this.target, drawer, time);
    } catch (error) {
      throwProcessedError({
        methodName: 'addPulse',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addTextAlign = async (
    align: AddTextAlignParam = PrinterConstants.PARAM_DEFAULT
  ) => {
    try {
      await EscPosPrinter.addTextAlign(this.target, align);
      this.currentAlign = align;
    } catch (error) {
      throwProcessedError({
        methodName: 'addTextAlign',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addTextSize = async ({
    width = PrinterConstants.PARAM_DEFAULT,
    height = PrinterConstants.PARAM_DEFAULT,
  }: AddTextSizeParams = {}) => {
    try {
      await EscPosPrinter.addTextSize(this.target, width, height);

      this.currentFontWidth = width || this.currentFontWidth;
    } catch (error) {
      throwProcessedError({
        methodName: 'addTextSize',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addTextSmooth = async (
    smooth: AddTextSmoothParam = PrinterConstants.TRUE
  ) => {
    try {
      await EscPosPrinter.addTextSmooth(this.target, smooth);
    } catch (error) {
      throwProcessedError({
        methodName: 'addTextSmooth',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  addTextStyle = async ({
    color = PrinterConstants.PARAM_DEFAULT,
    em = PrinterConstants.PARAM_DEFAULT,
    reverse = PrinterConstants.PARAM_DEFAULT,
    ul = PrinterConstants.PARAM_DEFAULT,
  }: AddTextStyleParams = {}) => {
    try {
      await EscPosPrinter.addTextStyle(this.target, reverse, ul, em, color);
    } catch (error) {
      throwProcessedError({
        methodName: 'addTextStyle',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  /* ------------------------------------------------------------------
   * Force Reset / Recover
   * -----------------------------------------------------------------*/

  /**
   * Force-reset the printer. Requires an active connection.
   */
  forceReset = async (timeout: number = 10000) => {
    try {
      await EscPosPrinter.forceReset(this.target, timeout);
    } catch (error) {
      throwProcessedError({
        methodName: 'forceReset',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  /**
   * Attempt to recover the printer from an error state.
   */
  forceRecover = async (timeout: number = 10000) => {
    try {
      await EscPosPrinter.forceRecover(this.target, timeout);
    } catch (error) {
      throwProcessedError({
        methodName: 'forceRecover',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  /* ------------------------------------------------------------------
   * Font Style Convenience
   * -----------------------------------------------------------------*/

  /** Paper width in dots. 80mm paper = 576 dots, 58mm paper = 384 dots */
  private paperWidth: number = 576;
  private fontStyleState: { fontSize: number; bold: boolean; fontFamily?: string } | null = null;

  /**
   * Set the paper width (needed for text-as-image rendering).
   * @param width - paper width in dots (576 for 80mm, 384 for 58mm)
   */
  setPaperWidth = (width: number) => {
    this.paperWidth = width;
  };

  /**
   * Set font size and style. Uses native text for exact multipliers (24, 48, 72...),
   * renders text as image for any other size (e.g. 32, 36, 40...).
   * @param fontSize - size in points/dots (24 = base size)
   * @param bold     - whether to enable emphasis
   */
  addFontStyle = async ({
    fontSize = 24,
    bold = false,
    fontFamily,
  }: AddFontStyleParams = {}) => {
    this.fontStyleState = { fontSize, bold, fontFamily };
  };

  /**
   * Add text using the current font style. If fontSize is a non-standard
   * value, the text is rendered as an image for true intermediate sizing.
   */
  addStyledText = async (text: string) => {
    const fontSize = this.fontStyleState?.fontSize || 24;
    const bold = this.fontStyleState?.bold || false;
    const fontFamily = this.fontStyleState?.fontFamily || 'PTMono-Regular';

    try {
      await EscPosPrinter.addRenderedText(
        this.target,
        text,
        fontSize,
        bold,
        fontFamily,
        this.currentAlign ?? PrinterConstants.ALIGN_LEFT,
        this.paperWidth
      );
    } catch (error) {
      throwProcessedError({
        methodName: 'addStyledText',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  /* ------------------------------------------------------------------
   * Barcode Scanner
   * -----------------------------------------------------------------*/

  /**
   * Initialise Epson barcode scanner for this target.
   * Must be called once before connectScanner / onScanData.
   */
  initScanner = async () => {
    try {
      await EscPosPrinter.initBarcodeScanner(this.target);
    } catch (error) {
      throwProcessedError({
        methodName: 'initScanner',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  /**
   * Connect scanner. Timeout defaults to 15 s (same as printer).
   */
  connectScanner = async (timeout: number = 15000) => {
    try {
      await EscPosPrinter.connectBarcodeScanner(timeout);
    } catch (error) {
      throwProcessedError({
        methodName: 'connectScanner',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    }
  };

  /**
   * Disconnect scanner and remove any active listener.
   */
  disconnectScanner = async () => {
    try {
      await EscPosPrinter.disconnectBarcodeScanner();
    } catch (error) {
      throwProcessedError({
        methodName: 'disconnectScanner',
        errorCode: error.message,
        messagesMapping: CommonOperationErrorMessageMapping,
      });
    } finally {
      this.removeScanListener();
    }
  };

  /**
   * Subscribe to scan-data events.
   * Calling twice will replace the previous handler.
   */
  onScanData = (handler: (data: string) => void) => {
    // clear previous
    this.scanDataSubscription?.remove();
    this.scanDataSubscription = addScanDataListener((event: { data: string }) =>
      handler(event.data)
    );
  };

  /**
   * Manually remove the scan-data listener (also invoked by disconnectScanner).
   */
  removeScanListener = () => {
    this.scanDataSubscription?.remove();
    this.scanDataSubscription = undefined;
  };
}
