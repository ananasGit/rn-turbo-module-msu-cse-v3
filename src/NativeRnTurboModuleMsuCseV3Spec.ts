import type {TurboModule} from 'react-native';
import {TurboModuleRegistry} from 'react-native';

export interface Spec extends TurboModule {
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

export default TurboModuleRegistry.getEnforcing<Spec>('RnTurboModuleMsuCseV3');