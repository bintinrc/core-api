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

    static {
        FAILURE_REASON_ID = getInt("failure-reason-id");
        ROUTE_MONITORING_DRIVER_NAME = getString("route-monitoring-driver-name");
        SORTING_HUB_NAME = getString("sorting-hub-name");
        ZONE_NAME = getString("zone-name");
    }

    public static void init(){
        NvLogger.info("CONFIGURATION HELPER INITIATED");
    }
}
