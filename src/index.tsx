import RnTurboModuleMsuCseV3 from './NativeRnTurboModuleMsuCseV3';

export function initialize(developmentMode: boolean): void {
  return RnTurboModuleMsuCseV3.initialize(developmentMode);
}

export function encrypt(
  pan: string,
  cardHolderName: string,
  expiryYear: number,
  expiryMonth: number,
  cvv: string,
  nonce: string
): Promise<string> {
  return RnTurboModuleMsuCseV3.encrypt(pan, cardHolderName, expiryYear, expiryMonth, cvv, nonce);
}
