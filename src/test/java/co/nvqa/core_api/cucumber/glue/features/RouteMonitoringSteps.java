package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route_monitoring.RouteMonitoringResponse;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import cucumber.api.java.en.Given;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.util.List;
import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-06
 */
@ScenarioScoped
public class RouteMonitoringSteps extends BaseSteps {
    private static final String KEY_ROUTE_MONITORING_RESULT = "KEY_ROUTE_MONITORING_RESULT";
    private static final String KEY_TOTAL_EXPECTED_WAYPOINT = "total-expected-waypoints";

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
    public void operatorChecksTotalParcelsCount(Map<String, Integer> arg1){
        callWithRetry( () -> {
            operatorFilterRouteMinitoring();
            List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
            List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
            List<Long> pullOutOrderIds = get(RoutingSteps.KEY_LIST_OF_PULL_OUT_OF_ROUTE_ORDER_ID);
            long routeId = get(KEY_CREATED_ROUTE_ID);
            int reservationCounts = 0;
            if(pickups != null) {
                reservationCounts = pickups.size();
            }
            int pullOutOfRouteOrderCount = 0;
            if (pullOutOrderIds != null){
                pullOutOfRouteOrderCount = pullOutOrderIds.size();
            }
            RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
            int expectedTotalParcels = trackingIds.size() - reservationCounts - pullOutOfRouteOrderCount;
            int actualTotalParcels = result.getTotalParcels();
            assertEquals(String.format("total parcels count for route id %d",routeId), expectedTotalParcels, actualTotalParcels);
            int expectedTotalWaypoints = arg1.get(KEY_TOTAL_EXPECTED_WAYPOINT);
            int actualTotalWaypoints = result.getTotalWaypoints();
            assertEquals(String.format("total waypoints count for route id %d", routeId), expectedTotalWaypoints,actualTotalWaypoints);
            assertEquals(String.format("total pending waypoints count for route id %d", routeId), expectedTotalWaypoints,actualTotalWaypoints);
        }, "check total parcels count", 70);
    }
}
