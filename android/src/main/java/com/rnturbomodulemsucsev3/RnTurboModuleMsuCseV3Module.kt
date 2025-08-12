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

  @ReactMethod
  override fun isValidPan(pan: String, promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val isValid = cse!!.isValidPan(pan)
    promise.resolve(isValid)
  }

  @ReactMethod
  override fun isValidCVV(cvv: String, pan: String?, promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val isValid = cse!!.isValidCVV(cvv, pan)
    promise.resolve(isValid)
  }

  @ReactMethod
  override fun isValidExpiry(month: Double, year: Double, promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val isValid = cse!!.isValidExpiry(month.toInt(), year.toInt())
    promise.resolve(isValid)
  }

  @ReactMethod
  override fun detectBrand(pan: String, promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val brand = cse!!.detectBrand(pan)
    promise.resolve(brand.toString())
  }

  @ReactMethod
  override fun encryptCVV(cvv: String, nonce: String, promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }

    cse!!.encrypt(
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

  @ReactMethod
  override fun isValidCardHolderName(name: String, promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val isValid = cse!!.isValidCardHolderName(name)
    promise.resolve(isValid)
  }

  @ReactMethod
  override fun isValidCardToken(token: String, promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val isValid = cse!!.isValidCardToken(token)
    promise.resolve(isValid)
  }

  @ReactMethod
  override fun getErrors(promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val errors = cse!!.errors
    promise.resolve(errors)
  }

  @ReactMethod
  override fun hasErrors(promise: Promise) {
    if (cse == null) {
      promise.reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.")
      return
    }
    
    val hasErrors = cse!!.hasErrors()
    promise.resolve(hasErrors)
  }
}
