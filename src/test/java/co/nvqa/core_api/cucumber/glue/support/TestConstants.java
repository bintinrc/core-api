package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.commons.util.NvLogger;
import co.nvqa.commons.util.StandardTestConstants;

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
    public static final int PICKUP_FAILURE_REASON_ID;
    public static final int DELIVERY_FAILURE_REASON_ID;


    static {
        FAILURE_REASON_ID = getInt("failure-reason-id");
        ROUTE_MONITORING_DRIVER_NAME = getString("route-monitoring-driver-name");
        SORTING_HUB_NAME = getString("sorting-hub-name");
        ZONE_NAME = getString("zone-name");
        ORDER_TAG_PRIOR_ID = getInt("order-tag-prior-id");
        PICKUP_FAILURE_REASON_ID = getInt("pickup-failure-reason-id");
        DELIVERY_FAILURE_REASON_ID = getInt("delivery-failure-reason-id");
        PICKUP_FAILURE_REASON = getString("pickup-failure-reason");
        DELIVERY_FAILURE_REASON = getString("delivery-failure-reason");
    }

    public static void init(){
        NvLogger.info("CONFIGURATION HELPER INITIATED");
    }
}
