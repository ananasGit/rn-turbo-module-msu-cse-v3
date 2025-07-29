package com.rnturbomodulemsucsev3

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = RnTurboModuleMsuCseV3Module.NAME)
class RnTurboModuleMsuCseV3Module(reactContext: ReactApplicationContext) :
  NativeRnTurboModuleMsuCseV3Spec(reactContext) {

  companion object {
    const val NAME = "RnTurboModuleMsuCseV3"
  }

  private var cse: CSE? = null

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  override fun initialize(developmentMode: Boolean) {
    cse = CSE(developmentMode)
  }

  @ReactMethod
  override fun encrypt(
    pan: String,
    cardHolderName: String,
    expiryYear: Double,
    expiryMonth: Double,
    cvv: String,
    nonce: String,
    promise: Promise
  ) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }

    cse!!.encrypt(
      pan,
      cardHolderName,
      expiryYear.toInt(),
      expiryMonth.toInt(),
      cvv,
      nonce,
      object : EncryptCallback {
        override fun onSuccess(encryptedData: String) {
          promise.resolve(encryptedData)
        }

        override fun onError(exception: EncryptException) {
          promise.reject(
            exception.code.toString(),
            exception.message,
            exception
          )
        }
      }
    )
  }
}
