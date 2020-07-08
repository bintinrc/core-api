package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route_monitoring.RouteMonitoringResponse;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import cucumber.api.java.en.Given;
import cucumber.runtime.java.guice.ScenarioScoped;
import org.junit.Assert;

import java.util.List;

/**
 * @author Binti Cahayati on 2020-07-06
 */
@ScenarioScoped
public class RouteMonitoring extends BaseSteps {
    private static final String KEY_ROUTE_MONITORING_RESULT = "KEY_ROUTE_MONITORING_RESULT";

    @Override
    public void init(){

    }

    @Given("^Operator Filter Route Monitoring Data for Today's Date$")
    public void operatorFilterRouteMinitoring(){
        List<Long> hubIds = get(KEY_LIST_OF_HUB_IDS);
        List<Long> zoneIds = get(KEY_LIST_OF_ZONE_IDS);
        String date = DateUtil.displayDate(DateUtil.getDate());
        long routeId = get(KEY_CREATED_ROUTE_ID);
        callWithRetry(() -> {
            List<RouteMonitoringResponse> routeMonitoringDetails = getRouteClient().getRouteMonitoringDetails(date, hubIds, zoneIds, 1000);
            try {
                RouteMonitoringResponse result = routeMonitoringDetails.stream().filter(e-> e.getRouteId().equals(routeId)).findAny().get();
                put(KEY_ROUTE_MONITORING_RESULT, result);
            } catch (Exception ex){
                throw new AssertionError("created route is not found in Route Monitoring Result");
            }
        }, "get route monitoring data");

    }

    @Given("^Operator verifies Route Monitoring Data has correct total parcels count$")
    public void operatorChecksTotalParcelsCount(){
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
        int reservationCounts = 0;
        if(pickups != null) {
            reservationCounts = pickups.size();
        }
        RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
        int expectedTotalParcels = trackingIds.size() - reservationCounts;
        int actualTotalParcels = result.getTotalParcels();
        Assert.assertEquals("total parcels count is correct", expectedTotalParcels, actualTotalParcels);
        NvLogger.successf("total parcels count %d is correct", actualTotalParcels);
    }
}
