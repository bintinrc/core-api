package co.nvqa.core_api.exception;

import co.nvqa.common.utils.NvTestProductException;

public class NvTestCoreFailedOrdersNotFoundException extends NvTestProductException {

  public NvTestCoreFailedOrdersNotFoundException() {
  }

  public NvTestCoreFailedOrdersNotFoundException(String message, Throwable t) {
    super(message, t);
  }

  public NvTestCoreFailedOrdersNotFoundException(String message) {
    super(message);
  }

  public NvTestCoreFailedOrdersNotFoundException(String message, Throwable cause, boolean enableSuppression,
      boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
