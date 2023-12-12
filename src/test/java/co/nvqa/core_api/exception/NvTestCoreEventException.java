package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestEnvironmentException;

public class NvTestCoreEventException extends NvTestEnvironmentException {

  public NvTestCoreEventException() {
  }

  public NvTestCoreEventException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreEventException(String message) {
    super(message);
  }

  public NvTestCoreEventException(String message, Throwable cause, boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }

}
