import RnTurboModuleMsuCseV3 from './NativeRnTurboModuleMsuCseV3';

export interface MSUCSEModule {
  initialize(developmentMode: boolean): void;
  encrypt(
    pan: string,
    cardHolderName: string,
    expiryYear: number,
    expiryMonth: number,
    cvv: string,
    nonce: string
  ): Promise<string>;
  isValidPan(pan: string): Promise<boolean>;
  isValidCVV(cvv: string, pan?: string): Promise<boolean>;
  isValidExpiry(month: number, year: number): Promise<boolean>;
  detectBrand(pan: string): Promise<string>;
}

export default RnTurboModuleMsuCseV3 as MSUCSEModule;