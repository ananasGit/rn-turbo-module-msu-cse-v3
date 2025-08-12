import type {TurboModule} from 'react-native';
import {TurboModuleRegistry} from 'react-native';

export interface Spec extends TurboModule {
  initialize(developmentMode: boolean): void;
  
  // Main encryption method
  encrypt(
    pan: string,
    cardHolderName: string,
    expiryYear: number,
    expiryMonth: number,
    cvv: string,
    nonce: string
  ): Promise<string>;
  
  // CVV-only encryption (from original CSE)
  encryptCVV(
    cvv: string,
    nonce: string
  ): Promise<string>;
  
  // Validation methods (matching original CSE API)
  isValidPan(pan: string): Promise<boolean>;
  
  isValidCVV(cvv: string, pan?: string): Promise<boolean>;
  
  isValidCardHolderName(name: string): Promise<boolean>;
  
  isValidCardToken(token: string): Promise<boolean>;
  
  isValidExpiry(month: number, year: number): Promise<boolean>;
  
  detectBrand(pan: string): Promise<string>;
  
  // Error handling (from original CSE)
  getErrors(): Promise<string[]>;
  
  hasErrors(): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RnTurboModuleMsuCseV3');