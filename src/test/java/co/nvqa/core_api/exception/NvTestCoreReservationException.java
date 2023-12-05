package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestEnvironmentException;

public class NvTestCoreReservationException extends NvTestEnvironmentException {

  public NvTestCoreReservationException() {
  }

  public NvTestCoreReservationException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreReservationException(String message) {
    super(message);
  }

  public NvTestCoreReservationException(String message, Throwable cause, boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
