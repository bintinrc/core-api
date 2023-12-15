package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestProductException;

public class NvTestCoreRouteMonitoringException extends NvTestProductException {

  public NvTestCoreRouteMonitoringException() {
  }

  public NvTestCoreRouteMonitoringException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreRouteMonitoringException(String message) {
    super(message);
  }

  public NvTestCoreRouteMonitoringException(String message, Throwable cause, boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
