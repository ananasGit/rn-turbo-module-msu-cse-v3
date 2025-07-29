import type { TurboModule } from 'react-native';
export interface Spec extends TurboModule {
    encrypt(pan: string, cardHolderName: string, expiryYear: number, expiryMonth: number, cvv: string, nonce: string): Promise<string>;
    initialize(developmentMode: boolean): void;
}
declare const _default: Spec;
export default _default;
//# sourceMappingURL=NativeRnTurboModuleMsuCseV3.d.ts.map