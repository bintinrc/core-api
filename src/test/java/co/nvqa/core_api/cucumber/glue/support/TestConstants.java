package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.common.utils.StandardTestConstants;
import co.nvqa.commons.util.NvLogger;

/**
 * @author Binti Cahayati on 2020-07-01
 */
public class TestConstants extends StandardTestConstants {

  public static final long FAILURE_REASON_ID;
  public static final String ROUTE_MONITORING_DRIVER_NAME;
  public static final String SORTING_HUB_NAME;
  public static final String ZONE_NAME;
  public static final long ORDER_TAG_PRIOR_ID;
  public static final String PICKUP_FAILURE_REASON;
  public static final String DELIVERY_FAILURE_REASON;
  public static final String RESERVATION_FAILURE_REASON;
  public static final int PICKUP_FAILURE_REASON_ID;
  public static final int PICKUP_FAILURE_REASON_CODE_ID;
  public static final int DELIVERY_FAILURE_REASON_ID;
  public static final int DELIVERY_FAILURE_REASON_CODE_ID;
  public static final int RESERVATION_FAILURE_REASON_ID;
  public static final int RESERVATION_FAILURE_REASON_CODE_ID;
  public static final int PICKUP_VALID_FAILURE_REASON_ID;
  public static final int PICKUP_VALID_FAILURE_REASON_CODE_ID;
  public static final int DELIVERY_VALID_FAILURE_REASON_ID;
  public static final int DELIVERY_VALID_FAILURE_REASON_CODE_ID;
  public static final int RESERVATION_VALID_FAILURE_REASON_ID;
  public static final String PICKUP_VALID_FAILURE_REASON;
  public static final String DELIVERY_VALID_FAILURE_REASON;
  public static final String RESERVATION_VALID_FAILURE_REASON;
  public static final long DEFAULT_DP_ADDRESS_ID;
  public static final long DEFAULT_DP_SHIPPER_ID;

  static {
    FAILURE_REASON_ID = getInt("failure-reason-id");
    ROUTE_MONITORING_DRIVER_NAME = getString("driver-2-name");
    SORTING_HUB_NAME = getString("sorting-hub-name");
    ZONE_NAME = getString("zone-name");
    ORDER_TAG_PRIOR_ID = getInt("order-tag-prior-id");
    PICKUP_FAILURE_REASON_ID = getInt("pickup-failure-reason-id");
    PICKUP_FAILURE_REASON_CODE_ID = getInt("pickup-failure-reason-code-id");
    DELIVERY_FAILURE_REASON_ID = getInt("delivery-failure-reason-id");
    DELIVERY_FAILURE_REASON_CODE_ID = getInt("delivery-failure-reason-code-id");
    RESERVATION_FAILURE_REASON_ID = getInt("reservation-failure-reason-id");
    RESERVATION_FAILURE_REASON_CODE_ID = getInt("reservation-failure-reason-code-id");
    PICKUP_FAILURE_REASON = getString("pickup-failure-reason-string");
    DELIVERY_FAILURE_REASON = getString("delivery-failure-reason-string");
    RESERVATION_FAILURE_REASON = getString("reservation-failure-reason-string");
    PICKUP_VALID_FAILURE_REASON_ID = getInt("pickup-valid-failure-reason-id");
    PICKUP_VALID_FAILURE_REASON_CODE_ID = getInt("pickup-valid-failure-reason-code-id");
    DELIVERY_VALID_FAILURE_REASON_ID = getInt("delivery-valid-failure-reason-id");
    DELIVERY_VALID_FAILURE_REASON_CODE_ID = getInt("delivery-valid-failure-reason-code-id");
    RESERVATION_VALID_FAILURE_REASON_ID = getInt("reservation-valid-failure-reason-id");
    PICKUP_VALID_FAILURE_REASON = getString("pickup-valid-failure-reason-string");
    DELIVERY_VALID_FAILURE_REASON = getString("delivery-valid-failure-reason-string");
    RESERVATION_VALID_FAILURE_REASON = getString("reservation-valid-failure-reason-string");
    DEFAULT_DP_ADDRESS_ID = getInt("default-dp-address-id");
    DEFAULT_DP_SHIPPER_ID = getInt("default-dp-shipper-id");
  }

  public static void init() {
    NvLogger.info("CONFIGURATION HELPER INITIATED");
  }
}
