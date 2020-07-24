package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route_monitoring.RouteMonitoringResponse;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
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

    @Given("^Operator verifies Route Monitoring Data Has Correct Details for Pending Case$")
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
            checkRouteDetails(result);
            int expectedTotalParcels = trackingIds.size() - reservationCounts - pullOutOfRouteOrderCount;
            int actualTotalParcels = result.getTotalParcels();
            //add more assertion for list of pending waypoints
            assertEquals(String.format("total parcels for route id %d",routeId), expectedTotalParcels, actualTotalParcels);
            int expectedTotalWaypoints = arg1.get(KEY_TOTAL_EXPECTED_WAYPOINT);
            int actualTotalWaypoints = result.getTotalWaypoints();
            assertEquals(String.format("total waypoints for route id %d", routeId), expectedTotalWaypoints,actualTotalWaypoints);
            assertEquals(String.format("total pending waypoints for route id %d", routeId), expectedTotalWaypoints,actualTotalWaypoints);
            checkPendingDetails(routeId, result);
        }, "check pending case", 50);
    }

    @Given("^Operator verifies Route Monitoring Data for Empty Route has correct details$")
    public void operatorChecksEmptyRouteData(){
        callWithRetry( () -> {
            operatorFilterRouteMinitoring();
            long routeId = get(KEY_CREATED_ROUTE_ID);
            RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
            checkRouteDetails(result);
            assertTrue("waypoints is empty", result.getWaypoints().isEmpty());
            assertEquals(String.format("total parcels for route id %d",routeId), 0, result.getTotalParcels());
            assertEquals(String.format("total waypoints for route id %d", routeId),0, result.getTotalWaypoints());
            assertEquals(String.format("total pending waypoints for route id %d", routeId), 0, result.getNumPending());
            checkPendingDetails(routeId, result);
            assertEquals(String.format("total impending waypoints for route id %d", routeId),0, result.getNumImpending());
            assertEquals(String.format("total late and pending waypoints for route id %d", routeId),0, result.getNumLateAndPending());
            assertNull("last seen", result.getLastSeen());
        }, "check empty route", 50);
    }

    private void checkRouteDetails(RouteMonitoringResponse result){
        assertEquals("driver name", TestConstants.ROUTE_MONITORING_DRIVER_NAME.toLowerCase(), result.getDriverName().toLowerCase());
        assertEquals("hub name", TestConstants.SORTING_HUB_NAME.toLowerCase(), result.getHubName().toLowerCase());
        assertEquals("zone name", TestConstants.ZONE_NAME.toLowerCase(), result.getZoneName().toLowerCase());
    }

    private void checkPendingDetails(long routeId, RouteMonitoringResponse result){
        assertEquals(String.format("total success waypoints for route id %d",routeId), 0, result.getNumSuccess());
        assertEquals(String.format("total valid failed waypoints for route id %d", routeId),0, result.getNumValidFailed());
        assertEquals(String.format("total invalid failed waypoints for route id %d", routeId),0, result.getNumInvalidFailed());
        assertEquals(String.format("total early waypoints for route id %d", routeId), 0, result.getNumEarlyWp());
        assertEquals(String.format("total late waypoints for route id %d",routeId), 0, result.getNumLateWp());
        assertEquals(String.format("completion precentage", routeId),0.0, result.getCompletionPercentage());
    }
}
