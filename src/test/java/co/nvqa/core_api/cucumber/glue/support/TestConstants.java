package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.commons.util.NvLogger;
import co.nvqa.commons.util.StandardTestConstants;

/**
 * @author Binti Cahayati on 2020-07-01
 */
public class TestConstants extends StandardTestConstants {
    public static final long FAILURE_REASON_ID;

    static {
        FAILURE_REASON_ID = getInt("failure-reason-id");
    }

    public static void init(){
        NvLogger.info("CONFIGURATION HELPER INITIATED");
    }
}
