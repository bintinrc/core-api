package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.driver.DriverClient;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.model.driver.*;
import co.nvqa.commons.model.driver.scan.DeliveryRequestV5;
import co.nvqa.commons.support.DriverHelper;
import co.nvqa.commons.util.NvLogger;
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
    private static final String KEY_LIST_OF_DRIVER_JOBS = "key-driver-jobs";
    private static final String WAYPOINT_TYPE_RESERVATION = "RESERVATION";
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
            routes.forEach(e -> {
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
        callWithRetry(() -> driverClient.startRoute(routeId), "driver starts route");
    }

    @Given("^Driver \"([^\"]*)\" Parcel \"([^\"]*)\"$")
    public void driverDeliverParcels(String action, String type){
        getWaypointId(type);
        driverGetWaypointDetails();
        createDriverJobs(action.toUpperCase());
        List<JobV5> jobs = get(KEY_LIST_OF_DRIVER_JOBS);
        long routeId = get (KEY_CREATED_ROUTE_ID);
        long waypointId = get(KEY_WAYPOINT_ID);
        DeliveryRequestV5 request = DriverHelper.createDefaultDeliveryRequestV5(waypointId,jobs);
        callWithRetry( () -> driverClient.deliverV5(routeId, waypointId, request), "driver attempts waypoint");
    }

    @Given("^Driver \"([^\"]*)\" Reservation Pickup$")
    public void driverPickupReservation(String action){
       driverDeliverParcels(action.toUpperCase(), WAYPOINT_TYPE_RESERVATION);
    }

    private void driverGetWaypointDetails(){
        Route route = get(KEY_CREATED_ROUTE);
        long routeId = route.getId();
        long waypointId = get(KEY_WAYPOINT_ID);
        callWithRetry(() -> {
            List<co.nvqa.commons.model.driver.Route> routes = driverClient.getRoutes().getRoutes();
            try{
                co.nvqa.commons.model.driver.Route routeDetails = routes.stream().filter( e -> e.getId() == routeId).findAny().get();
                put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, routeDetails.getWaypoints());
                Waypoint waypoint = routeDetails.getWaypoints().stream().filter( e -> e.getId() == waypointId).findAny().get();
                assertTrue("jobs is not empty", (waypoint.getJobs() !=null && !waypoint.getJobs().isEmpty()));
                put(KEY_DRIVER_WAYPOINT_DETAILS, waypoint);
            } catch (Exception ex){
                throw new AssertionError("Waypoint Details are not available in list routes");
            }
        }, "driver gets waypoint details");
    }

    private void createPhysicalItems(co.nvqa.commons.model.driver.Order order, String action, String jobType){
            co.nvqa.commons.model.driver.Order job = new co.nvqa.commons.model.driver.Order();
            job.setAllowReschedule(false);
            job.setDeliveryType(order.getDeliveryType());
            job.setTrackingId(order.getTrackingId());
            job.setId(order.getId());
            job.setType(order.getType());
            job.setInstruction(order.getInstruction());
            job.setParcelSize(order.getParcelSize());
            job.setStatus(order.getStatus());
            job.setAction(action);
            job.setParcelWeight(order.getParcelWeight());
            if(action.equalsIgnoreCase(Job.ACTION_FAIL)){
                setOrderFailureReason(jobType, job);
            }
            putInList(KEY_LIST_OF_CREATED_JOB_ORDERS, job);
    }

    private void createDriverJobs(String action){
        Waypoint waypoint = get(KEY_DRIVER_WAYPOINT_DETAILS);
        List<Job> jobs = waypoint.getJobs();
        jobs.forEach( e -> {
            List<co.nvqa.commons.model.driver.Order> parcels = e.getParcels();
            parcels.forEach(o -> createPhysicalItems(o, action, e.getMode()));
            List<Order> orders = get(KEY_LIST_OF_CREATED_JOB_ORDERS);
            JobV5 job = createDefaultDriverJobs(e, action);
            job.setPhysicalItems(orders);
            putInList(KEY_LIST_OF_DRIVER_JOBS, job);
        } );
    }

    private JobV5 createDefaultDriverJobs(Job job, String action){
        JobV5 request = new JobV5();
        request.setAction(action);
        request.setId(job.getId());
        request.setStatus(job.getStatus());
        request.setMode(job.getMode());
        request.setType(job.getType());
        return request;
    }

    private void getWaypointId(String transactionType){
        if(transactionType.equalsIgnoreCase(WAYPOINT_TYPE_RESERVATION)){
            NvLogger.info("reservation waypoint, no need get from order waypoint");
            return;
        }
        String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
        co.nvqa.commons.model.core.Order order = OrderDetailHelper.getOrderDetails(trackingId);
        Transaction transaction = OrderDetailHelper.getTransaction(order, transactionType, Transaction.STATUS_PENDING);
        put(KEY_WAYPOINT_ID, transaction.getWaypointId());
    }

    private void setOrderFailureReason(String jobType, Order order){
        if(jobType.equalsIgnoreCase(Job.TYPE_DELIVERY)){
            order.setFailureReason(TestConstants.DELIVERY_FAILURE_REASON);
            order.setFailureReasonId(TestConstants.DELIVERY_FAILURE_REASON_ID);
        } else {
            order.setFailureReason(TestConstants.PICKUP_FAILURE_REASON);
            order.setFailureReasonId(TestConstants.PICKUP_FAILURE_REASON_ID);
        }
    }
}
