import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  // Encryption method
  encrypt(
    pan: string,
    cardHolderName: string,
    expiryYear: number, 
    expiryMonth: number,
    cvv: string,
    nonce: string
  ): Promise<string>;
  
  // Configuration
  initialize(developmentMode: boolean): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RnTurboModuleMsuCseV3');
