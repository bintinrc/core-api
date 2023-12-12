package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestEnvironmentException;

public class NvTestCoreOrderEventNotFoundException extends NvTestEnvironmentException {

  public NvTestCoreOrderEventNotFoundException() {
  }

  public NvTestCoreOrderEventNotFoundException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreOrderEventNotFoundException(String message) {
    super(message);
  }

  public NvTestCoreOrderEventNotFoundException(String message, Throwable cause, boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
