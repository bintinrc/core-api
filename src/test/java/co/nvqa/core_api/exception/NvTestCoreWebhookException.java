package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestEnvironmentException;

public class NvTestCoreWebhookException extends NvTestEnvironmentException {

  public NvTestCoreWebhookException() {
  }

  public NvTestCoreWebhookException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreWebhookException(String message) {
    super(message);
  }

  public NvTestCoreWebhookException(String message, Throwable cause, boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
