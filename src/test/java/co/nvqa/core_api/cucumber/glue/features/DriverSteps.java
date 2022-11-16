package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.driver.DriverClient;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.model.core.batch_update_pod.ProofDetails;
import co.nvqa.commons.model.core.route.FailedOrder;
import co.nvqa.commons.model.core.route.ParcelRouteTransferRequest;
import co.nvqa.commons.model.core.route.ParcelRouteTransferResponse;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.model.driver.*;
import co.nvqa.commons.model.driver.scan.DeliveryRequestV5;
import co.nvqa.commons.model.driver.scan.VanInboundScanRequest;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.support.DriverHelper;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.cucumber.guice.ScenarioScoped;

import io.restassured.response.Response;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.assertj.core.api.Assertions;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class DriverSteps extends BaseSteps {

  public static final String KEY_LIST_OF_CREATED_JOB_ORDERS = "key-list-of-created-job-orders";
  public static final String KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS = "key-list-of-driver-waypoint-details";
  private static final String KEY_DRIVER_WAYPOINT_DETAILS = "key-driver-waypoint-details";
  private static final String KEY_LIST_OF_DRIVER_JOBS = "key-driver-jobs";
  private static final String KEY_DRIVER_SUBMIT_POD_REQUEST = "KEY_DRIVER_SUBMIT_POD_REQUEST";
  private static final String WAYPOINT_TYPE_RESERVATION = "RESERVATION";
  private static final String KEY_BOOLEAN_DRIVER_FAILED_VALID = "key-boolean-driver-failed-valid";
  private DriverClient driverClient;

  @Override
  public void init() {

  }

  @Given("Driver id {string} authenticated to login with username {string} and password {string}")
  public void driverLogin(String driverId, String username, String password) {
    callWithRetry(() -> {
      driverClient = new DriverClient(TestConstants.API_BASE_URL);
      driverClient.authenticate(new DriverLoginRequest(username, password));
      put(KEY_NINJA_DRIVER_ID, Long.valueOf(driverId));
    }, "driver login");
  }

  @Given("Deleted route is not shown on his list routes")
  public void driverRouteNotShown() {
    final List<Long> routes = get(KEY_LIST_OF_CREATED_ROUTE_ID);
    final Long driverId = get(KEY_NINJA_DRIVER_ID);
    callWithRetry(() -> {
      RouteResponse routeResponse = driverClient.getRoutes(driverId);
      List<co.nvqa.commons.model.driver.Route> result = routeResponse.getRoutes();
      routes.forEach(e -> {
        boolean found = result.stream().anyMatch(o -> o.getId().equals(e));
        assertFalse("route is shown in driver list routes", found);
      });
    }, "get list driver routes");
  }

  @Given("Archived route is not shown on his list routes")
  public void archivedDriverRouteNotShown() {
    driverRouteNotShown();
  }

  @Given("Driver Starts the route")
  public void driverStartRoute() {
    Route route = get(KEY_CREATED_ROUTE);
    long routeId = route.getId();
    callWithRetry(() -> driverClient.startRoute(routeId), "driver starts route");
  }

  @Given("Driver Van Inbound Parcel at hub id {string}")
  public void driverVanInboundParcel(String hubId) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    long waypointId = get(KEY_WAYPOINT_ID);
    callWithRetry(() -> driverClient.scan(String.valueOf(routeId),
        VanInboundScanRequest.createSimpleRequest(Long.valueOf(hubId), trackingId, waypointId)),
        "driver van inbound parcel");
  }

  @Given("Driver {string} Parcel {string}")
  public void driverDeliverParcels(String action, String type) {
    callWithRetry(() -> {
      getWaypointId(type);
      driverGetWaypointDetails();
      createDriverJobs(action.toUpperCase());
      List<JobV5> jobs = get(KEY_LIST_OF_DRIVER_JOBS);
      long routeId = get(KEY_CREATED_ROUTE_ID);
      long waypointId = get(KEY_WAYPOINT_ID);
      co.nvqa.commons.model.core.Order order = get(KEY_CREATED_ORDER);

      DeliveryRequestV5 request = DriverHelper.createDefaultDeliveryRequestV5(waypointId, jobs);
      put(KEY_DRIVER_SUBMIT_POD_REQUEST, request);
      if (order != null) {
        request.setContact(order.getToContact());
        request.setName(order.getToName());
        ProofDetails proofDetails = new ProofDetails();
        proofDetails.setContact(request.getContact());
        proofDetails.setName(request.getName());
        putInMap(BatchUpdatePodsSteps.KEY_MAP_PROOF_WEBHOOK_DETAILS, order.getTrackingId(),
            proofDetails);
      }
      driverClient.deliverV5(routeId, waypointId, request);
      if (action.equalsIgnoreCase(Job.ACTION_FAIL)) {
        int attempCount = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT, 0);
        put(KEY_DRIVER_FAIL_ATTEMPT_COUNT, ++attempCount);
      }
    }, "driver attempts waypoint");
  }

  //to success/fail previously rescheduled failed delivery/pickup
  @Given("Driver {string} Parcel previous {string}")
  public void driverDeliverPreviousFailedParcels(String action, String type) {
    co.nvqa.commons.model.core.Order order = get(KEY_CREATED_ORDER);
    callWithRetry(() -> {
      createDriverJobs(action.toUpperCase());
      List<JobV5> jobs = get(KEY_LIST_OF_DRIVER_JOBS);
      DeliveryRequestV5 prevRequest = get(KEY_DRIVER_SUBMIT_POD_REQUEST);
      long routeId = get(KEY_CREATED_ROUTE_ID);
      long waypointId = prevRequest.getWaypointId();
      DeliveryRequestV5 request = DriverHelper.createDefaultDeliveryRequestV5(waypointId, jobs);
      request.setName(order.getToName());
      put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "TRANSACTION_UNROUTE");
      driverClient.deliverV5(routeId, waypointId, request);
    }, "driver attempts waypoint");
  }

  @Given("Driver Fails Parcel {string} with Valid Reason")
  public void driverFailedWithValidReason(String type) {
    put(KEY_BOOLEAN_DRIVER_FAILED_VALID, true);
    driverDeliverParcels("FAIL", type);
  }

  @Then("Driver {string} {string} for All Orders")
  public void driverDeliverParcelsMultipleOrders(String action, String type) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      driverDeliverParcels(action, type);
    });
  }

  @Given("Driver {string} Reservation Pickup")
  public void driverPickupReservation(String action) {
    driverDeliverParcels(action.toUpperCase(), WAYPOINT_TYPE_RESERVATION);
  }

  @When("Driver Transfer Parcel to Another Driver")
  public void driverTransferRoute(Map<String, String> source) {
    ParcelRouteTransferRequest request = createParcelRouteTransferRequest(source);
    callWithRetry(() -> {
          ParcelRouteTransferResponse response = getRouteClient().parcelRouteTransfer(request);
          put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, response);
          put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "ROUTE_TRANSFER");
        },
        "driver parcel route transfer");
  }

  @When("Driver Transfer Parcel to Route with past date")
  public void driverTransferRoutePastDate(Map<String, String> source) {
    ParcelRouteTransferRequest request = createParcelRouteTransferRequest(source);
    callWithRetry(() -> {
          Response response = getRouteClient().parcelRouteTransferAndGetRawResponse(request);
          put(OrderActionSteps.KEY_API_RAW_RESPONSE, response);
          put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, response);
          put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "ROUTE_TRANSFER");
        },
        "driver parcel route transfer");
  }

  @Then("Verify Parcel Route Transfer Response")
  public void verifyRouteTransferReponse() {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    ParcelRouteTransferResponse response = get(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS);
    co.nvqa.commons.model.driver.Route route = response.getRoutes().get(0);
    put(KEY_CREATED_ROUTE_ID, route.getId());
    putInList(KEY_LIST_OF_CREATED_ROUTE_ID, route.getId());
    List<Waypoint> waypoints = route.getWaypoints();
    trackingIds.forEach(e -> {
      Waypoint waypoint = waypoints.stream()
          .filter(o -> !o.getJobs().isEmpty())
          .filter(o -> o.getJobs().get(0).getOrders().get(0).getTrackingId().equalsIgnoreCase(e))
          .findAny().orElseThrow(() -> new NvTestRuntimeException(
              "Tracking Id is not available in response"));
      assertTrue(String.format("tracking id %s found", e),
          waypoint.getJobs().get(0).getOrders().get(0).getTrackingId().equals(e));
    });
  }

  @Then("Verify Parcel Route Transfer Failed Orders with message : {string}")
  public void verifyRouteTransferReponseFailed(String message) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    ParcelRouteTransferResponse response = get(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS);
    List<FailedOrder> failedOrders = response.getFailedOrders();
    assertTrue("contains all failed orders", failedOrders.size() == trackingIds.size());
    trackingIds.forEach(e -> {
      FailedOrder failedOrder = failedOrders.stream()
          .filter(o -> o.getTrackingIds().get(0).equalsIgnoreCase(e))
          .findAny().orElseThrow(() -> new NvTestRuntimeException(
              String.format("tracking id %s not found", e)));
      assertEquals("tracking id size", 1, failedOrder.getTrackingIds().size());
      assertEquals("tracking id", e, failedOrder.getTrackingIds().get(0));
      assertEquals("reason", message, failedOrder.getReason());
    });
  }

  private void driverGetWaypointDetails() {
    Route route = get(KEY_CREATED_ROUTE);
    final Long routeId = route.getId();
    final Long waypointId = get(KEY_WAYPOINT_ID);
    final Long driverId = get(KEY_NINJA_DRIVER_ID);

    callWithRetry(() -> {
      List<co.nvqa.commons.model.driver.Route> routes = driverClient.getRoutes(driverId)
          .getRoutes();
      routes.stream().filter(e -> e.getId().equals(routeId))
          .forEach(e -> put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, e));
      co.nvqa.commons.model.driver.Route routeDetails = get(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS);
      routeDetails.getWaypoints().stream().filter(e -> e.getId().equals(waypointId))
          .forEach(e -> put(KEY_DRIVER_WAYPOINT_DETAILS, e));
      Waypoint waypoint = get(KEY_DRIVER_WAYPOINT_DETAILS);
      Assertions.assertThat(waypoint.getJobs() != null && !waypoint.getJobs().isEmpty())
          .as("jobs is not empty").isTrue();
    }, "driver gets waypoint details");
  }

  private void createPhysicalItems(co.nvqa.commons.model.driver.Order order, String action,
      String jobType) {
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
    job.setShipperId(order.getShipperId());
    job.setRts(order.getRts());
    if (action.equalsIgnoreCase(Job.ACTION_FAIL)) {
      boolean idValidFailed = get(KEY_BOOLEAN_DRIVER_FAILED_VALID, false);
      if (idValidFailed) {
        setOrderValidFailureReason(jobType, job);
      } else {
        setOrderFailureReason(jobType, job);
      }
    }
    List<Order> orderList = Collections.singletonList(job);
    put(KEY_LIST_OF_CREATED_JOB_ORDERS, orderList);
  }

  private void createDriverJobs(String action) {
    Waypoint waypoint = get(KEY_DRIVER_WAYPOINT_DETAILS);
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    List<Job> jobs = waypoint.getJobs();
    jobs.forEach(e -> {
      List<co.nvqa.commons.model.driver.Order> parcels = e.getParcels();
      parcels.stream().filter(o -> o.getTrackingId().equalsIgnoreCase(trackingId))
          .forEach(o -> put("parcel", o));
      Order parcel = get(("parcel"));
      createPhysicalItems(parcel, action, e.getMode());
      List<Order> orders = get(KEY_LIST_OF_CREATED_JOB_ORDERS);
      JobV5 job = createDefaultDriverJobs(e, action);
      job.setPhysicalItems(orders);
      List<JobV5> jobList = Collections.singletonList(job);
      put(KEY_LIST_OF_DRIVER_JOBS, jobList);
    });
  }

  private JobV5 createDefaultDriverJobs(Job job, String action) {
    JobV5 request = new JobV5();
    request.setAction(action);
    request.setId(job.getId());
    request.setStatus(job.getStatus());
    request.setMode(job.getMode());
    request.setType(job.getType());
    return request;
  }

  private void getWaypointId(String transactionType) {
    if (transactionType.equalsIgnoreCase(WAYPOINT_TYPE_RESERVATION)) {
      NvLogger.info("reservation waypoint, no need get from order waypoint");
      return;
    }
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    co.nvqa.commons.model.core.Order order = OrderDetailHelper.getOrderDetails(trackingId);
    Transaction transaction = OrderDetailHelper
        .getTransaction(order, transactionType, Transaction.STATUS_PENDING);
    put(KEY_WAYPOINT_ID, transaction.getWaypointId());
  }

  private void setOrderFailureReason(String jobType, Order order) {
    if (jobType.equalsIgnoreCase(Job.TYPE_DELIVERY)) {
      order.setFailureReason(TestConstants.DELIVERY_FAILURE_REASON);
      order.setFailureReasonId(TestConstants.DELIVERY_FAILURE_REASON_ID);
      order.setFailureReasonCodeId(TestConstants.DELIVERY_FAILURE_REASON_CODE_ID);
    } else {
      order.setFailureReason(TestConstants.PICKUP_FAILURE_REASON);
      order.setFailureReasonId(TestConstants.PICKUP_FAILURE_REASON_ID);
      order.setFailureReasonCodeId(TestConstants.PICKUP_FAILURE_REASON_CODE_ID);
    }
    put(KEY_FAILURE_REASON_ID, order.getFailureReasonId());
    put(KEY_FAILURE_REASON_CODE_ID, order.getFailureReasonCodeId());
  }

  private void setOrderValidFailureReason(String jobType, Order order) {
    if (jobType.equalsIgnoreCase(Job.TYPE_DELIVERY)) {
      order.setFailureReason(TestConstants.DELIVERY_VALID_FAILURE_REASON);
      order.setFailureReasonId(TestConstants.DELIVERY_VALID_FAILURE_REASON_ID);
      order.setFailureReasonCodeId(TestConstants.DELIVERY_VALID_FAILURE_REASON_CODE_ID);
    } else {
      order.setFailureReason(TestConstants.PICKUP_VALID_FAILURE_REASON);
      order.setFailureReasonId(TestConstants.PICKUP_VALID_FAILURE_REASON_ID);
      order.setFailureReasonCodeId(TestConstants.PICKUP_VALID_FAILURE_REASON_CODE_ID);
    }
    put(KEY_FAILURE_REASON_ID, order.getFailureReasonId());
    put(KEY_FAILURE_REASON_CODE_ID, order.getFailureReasonCodeId());
  }

  private ParcelRouteTransferRequest createParcelRouteTransferRequest(Map<String, String> source) {
    String json = toJsonCamelCase(source);
    ParcelRouteTransferRequest request = fromJsonSnakeCase(json, ParcelRouteTransferRequest.class);
    if (!source.containsKey("to_create_route")) {
      long routeId = get(KEY_CREATED_ROUTE_ID);
      request.setRouteId(routeId);
    }
    request.setRouteDate(DateUtil.getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    if (source.containsKey("to_exclude_routed_order")) {
      trackingIds.remove(0);
    }
    List<co.nvqa.commons.model.core.route.Parcel> orders = new ArrayList<>();
    trackingIds.forEach(e -> {
      co.nvqa.commons.model.core.route.Parcel parcel = new co.nvqa.commons.model.core.route.Parcel();
      parcel.setTrackingId(e);
      parcel.setHubId(request.getToDriverHubId());
      parcel.setInboundType("VAN_FROM_NINJAVAN");
      orders.add(parcel);
    });
    request.setOrders(orders);
    return request;
  }
}
