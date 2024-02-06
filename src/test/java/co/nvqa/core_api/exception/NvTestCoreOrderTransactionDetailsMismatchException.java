package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestProductException;

public class NvTestCoreOrderTransactionDetailsMismatchException extends NvTestProductException {

  public NvTestCoreOrderTransactionDetailsMismatchException() {
  }

  public NvTestCoreOrderTransactionDetailsMismatchException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreOrderTransactionDetailsMismatchException(String message) {
    super(message);
  }

  public NvTestCoreOrderTransactionDetailsMismatchException(String message, Throwable cause,
      boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
