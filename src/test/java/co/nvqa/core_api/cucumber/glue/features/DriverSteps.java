package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.driver.DriverClient;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.model.driver.DriverLoginRequest;
import co.nvqa.commons.model.driver.RouteResponse;
import co.nvqa.commons.model.driver.Waypoint;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import cucumber.api.java.en.Given;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.util.List;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class DriverSteps  extends BaseSteps {
    public static final String KEY_LIST_OF_CREATED_JOB_ORDERS = "key-list-of-created-job-orders";
    private static final String KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS = "key-list-of-driver-waypoint-details";
    private static final String KEY_DRIVER_WAYPOINT_DETAILS = "key-driver-waypoint-details";
    private DriverClient driverClient;

    @Override
    public void init(){

    }

    @Given("^Driver authenticated to login with username \"([^\"]*)\" and password \"([^\"]*)\"$")
    public void driverLogin(String username, String password){
        callWithRetry(() -> {
            driverClient = new DriverClient(TestConstants.API_BASE_URL);
            driverClient.authenticate(new DriverLoginRequest(username, password));
        }, "driver login");
    }

    @Given("^Deleted route is not shown on his list routes$")
    public void driverRouteNotShown(){
        List<Long> routes = get(KEY_LIST_OF_CREATED_ROUTE_ID);
        callWithRetry( () -> {
            RouteResponse routeResponse = driverClient.getRoutes();
            List<co.nvqa.commons.model.driver.Route> result = routeResponse.getRoutes();
            routes.stream().forEach(e -> {
                boolean found = result.stream().anyMatch( o -> o.getId().equals(e));
                assertFalse("route is shown in driver list routes", found);
            });
        }, "get list driver routes");
    }

    @Given("^Archived route is not shown on his list routes$")
    public void archivedDriverRouteNotShown(){
       driverRouteNotShown();
    }

    @Given("^Driver Starts the route$")
    public void driverStartRoute(){
        Route route = get(KEY_CREATED_ROUTE);
        long routeId = route.getId();
        callWithRetry(() -> {
            driverClient.startRoute(routeId);
        }, "driver starts route");
    }

    private void driverGetWaypointDetails(){
        Route route = get(KEY_CREATED_ROUTE);
        long routeId = route.getId();
        long waypointId = get(KEY_WAYPOINT_ID);
        callWithRetry(() -> {
            RouteResponse routes = driverClient.getRoutes();
            try{
                co.nvqa.commons.model.driver.Route routeDetails = routes.getRoutes().stream().findAny().filter(e-> e.getId() == routeId).get();
                put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, routeDetails.getWaypoints());
                Waypoint waypoint = routeDetails.getWaypoints().stream().findAny().filter( e -> e.getId() == waypointId).get();
                put(KEY_DRIVER_WAYPOINT_DETAILS, waypoint);
            } catch (Exception ex){
                throw new AssertionError("Waypoint Details are not available in list routes");
            }
        }, "driver gets waypoint details");
    }

    private void createPhysicalItems(String trackingId, String action){
        callWithRetry( () -> {
            Order order = OrderDetailHelper.getOrderDetails(trackingId);
            co.nvqa.commons.model.driver.Order job = new co.nvqa.commons.model.driver.Order();
            job.setAllowReschedule(false);
            job.setDeliveryType(order.getDeliveryType());
            job.setTrackingId(trackingId);
            job.setId(order.getId());
            job.setType(order.getType());
            job.setInstruction(order.getInstruction());
            job.setParcelSize(order.getParcelSize());
            job.setStatus(order.getStatus());
            job.setAction(action);
            job.setParcelWeight(order.getParcelWeight());
            putInList(KEY_LIST_OF_CREATED_JOB_ORDERS, job);
        },"create job orders");
    }
}
