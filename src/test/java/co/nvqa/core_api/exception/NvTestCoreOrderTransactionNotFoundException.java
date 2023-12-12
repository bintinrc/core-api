package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestEnvironmentException;

public class NvTestCoreOrderTransactionNotFoundException extends NvTestEnvironmentException {

  public NvTestCoreOrderTransactionNotFoundException() {
  }

  public NvTestCoreOrderTransactionNotFoundException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreOrderTransactionNotFoundException(String message) {
    super(message);
  }

  public NvTestCoreOrderTransactionNotFoundException(String message, Throwable cause, boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
