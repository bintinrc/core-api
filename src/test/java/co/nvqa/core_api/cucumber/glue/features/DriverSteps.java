package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.model.batch_update_pods.ProofDetails;
import co.nvqa.common.core.model.order.Order;
import co.nvqa.common.core.model.order.Order.Transaction;
import co.nvqa.common.driver.client.DriverClient;
import co.nvqa.common.driver.model.rest.GetRouteResponse;
import co.nvqa.common.driver.model.rest.GetRouteResponse.Parcel;
import co.nvqa.common.driver.model.rest.SubmitPodRequest;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.JobAction;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.JobMode;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.JobType;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.PhysicalItem;
import co.nvqa.commons.model.core.route.FailedOrder;
import co.nvqa.commons.model.core.route.ParcelRouteTransferRequest;
import co.nvqa.commons.model.core.route.ParcelRouteTransferResponse;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.model.driver.Waypoint;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.apache.commons.lang3.StringUtils;
import org.assertj.core.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class DriverSteps extends BaseSteps {

  private static final Logger LOGGER = LoggerFactory.getLogger(DriverSteps.class);
  private static final String ACTION_FAIL = "FAIL";
  private static final String TYPE_DELIVERY = "DELIVERY";
  private static final String STATUS_PENDING = "pending";

  private DriverClient driverClient;

  @Override
  public void init() {

  }

  @Given("Driver id {string} authenticated to login with username {string} and password {string}")
  public void driverLogin(String driverId, String username, String password) {
    callWithRetry(() -> {
      driverClient = new DriverClient();
      driverClient.authenticate(username, password);
      put(KEY_NINJA_DRIVER_ID, Long.valueOf(driverId));
    }, "driver login");
  }

  @Given("Deleted route is not shown on his list routes")
  public void driverRouteNotShown() {
    final List<Long> routes = get(KEY_LIST_OF_CREATED_ROUTE_ID);
    final Long driverId = get(KEY_NINJA_DRIVER_ID);
    callWithRetry(() -> {
      List<GetRouteResponse.Route> result = driverClient.getRoutes(driverId, "2.1").getData()
          .getRoutes();
      routes.forEach(e -> {
        boolean found = result.stream().anyMatch(o -> o.getId() == e);
        Assertions.assertThat(found).as("route is not shown in driver list routes").isFalse();
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

  // TODO to remove after step replaced with one from common-driver
  @Given("Driver Van Inbound Parcel at hub id {string}")
  public void driverVanInboundParcel(String hubId) {
//    long routeId = get(KEY_CREATED_ROUTE_ID);
//    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
//    long waypointId = get(KEY_WAYPOINT_ID);
//    callWithRetry(() -> driverClient.scan(String.valueOf(routeId),
//        VanInboundScanRequest.createSimpleRequest(Long.valueOf(hubId), trackingId, waypointId)),
//        "driver van inbound parcel");
  }

  @Given("Driver {string} Parcel {string}")
  public void driverDeliverParcels(String action, String type) {
    callWithRetry(() -> {
      getWaypointId(type);
      driverGetWaypointDetails();
      createDriverJobs(action.toUpperCase());
      List<SubmitPodRequest.Job> jobs = get(KEY_LIST_OF_DRIVER_JOBS);
      Long routeId = get(KEY_CREATED_ROUTE_ID);
      Long waypointId = get(KEY_WAYPOINT_ID);
      Order order = get(KEY_CREATED_ORDER);

      SubmitPodRequest request = createDefaultDriverSubmitPodRequest(waypointId, jobs);
      put(KEY_DRIVER_SUBMIT_POD_REQUEST, request);
      if (order != null) {
        request.setContact(order.getToContact());
        request.setName(order.getToName());
        ProofDetails proofDetails = new ProofDetails();
        proofDetails.setContact(request.getContact());
        proofDetails.setName(request.getName());
        putInMap(KEY_MAP_PROOF_WEBHOOK_DETAILS, order.getTrackingId(),
            proofDetails);
      }
      driverClient.submitPod(routeId, waypointId, request);
      if (action.equalsIgnoreCase(ACTION_FAIL)) {
        int attemptCount = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT, 0);
        put(KEY_DRIVER_FAIL_ATTEMPT_COUNT, ++attemptCount);
      }
    }, "driver attempts waypoint");
  }

  //to success/fail previously rescheduled failed delivery/pickup
  @Given("Driver {string} Parcel previous {string}")
  public void driverDeliverPreviousFailedParcels(String action, String type) {
    Order order = get(KEY_CREATED_ORDER);
    callWithRetry(() -> {
      createDriverJobs(action.toUpperCase());
      List<SubmitPodRequest.Job> jobs = get(KEY_LIST_OF_DRIVER_JOBS);
      SubmitPodRequest prevRequest = get(KEY_DRIVER_SUBMIT_POD_REQUEST);
      Long routeId = get(KEY_CREATED_ROUTE_ID);
      Long waypointId = prevRequest.getWaypointId();
      SubmitPodRequest request = createDefaultDriverSubmitPodRequest(waypointId, jobs);
      request.setName(order.getToName());
      put(KEY_ROUTE_EVENT_SOURCE, "TRANSACTION_UNROUTE");
      driverClient.submitPod(routeId, waypointId, request);
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
      put(KEY_ROUTE_EVENT_SOURCE, "ROUTE_TRANSFER");
    }, "driver parcel route transfer");
  }

  @When("Driver Transfer Parcel to Route with past date")
  public void driverTransferRoutePastDate(Map<String, String> source) {
    ParcelRouteTransferRequest request = createParcelRouteTransferRequest(source);
    callWithRetry(() -> {
      Response response = getRouteClient().parcelRouteTransferAndGetRawResponse(request);
      put(KEY_API_RAW_RESPONSE, response);
      put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, response);
      put(KEY_ROUTE_EVENT_SOURCE, "ROUTE_TRANSFER");
    }, "driver parcel route transfer");
  }

  @Then("Verify Parcel Route Transfer Response")
  public void verifyRouteTransferResponse() {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    ParcelRouteTransferResponse response = get(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS);
    co.nvqa.commons.model.driver.Route route = response.getRoutes().get(0);
    put(KEY_CREATED_ROUTE_ID, route.getId());
    putInList(KEY_LIST_OF_CREATED_ROUTE_ID, route.getId());
    List<Waypoint> waypoints = route.getWaypoints();
    trackingIds.forEach(e -> {
      Waypoint waypoint = waypoints.stream().filter(o -> !o.getJobs().isEmpty())
          .filter(o -> o.getJobs().get(0).getOrders().get(0).getTrackingId().equalsIgnoreCase(e))
          .findAny().orElseThrow(
              () -> new NvTestRuntimeException("Tracking Id is not available in response"));
      Assertions.assertThat(waypoint.getJobs().get(0).getOrders().get(0).getTrackingId())
          .as(String.format("tracking id %s found", e)).isEqualTo(e);
    });
  }

  @Then("Verify Parcel Route Transfer Failed Orders with message : {string}")
  public void verifyRouteTransferResponseFailed(String message) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    ParcelRouteTransferResponse response = get(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS);
    List<FailedOrder> failedOrders = response.getFailedOrders();
    Assertions.assertThat(failedOrders.size() == trackingIds.size())
        .as("contains all failed orders").isTrue();
    trackingIds.forEach(e -> {
      FailedOrder failedOrder = failedOrders.stream()
          .filter(o -> o.getTrackingIds().get(0).equalsIgnoreCase(e)).findAny().orElseThrow(
              () -> new NvTestRuntimeException(String.format("tracking id %s not found", e)));
      Assertions.assertThat(failedOrder.getTrackingIds().size()).as("tracking id size is 1")
          .isEqualTo(1);
      Assertions.assertThat(failedOrder.getTrackingIds().get(0)).as(f("tracking id is: %s", e))
          .isEqualTo(e);
      Assertions.assertThat(failedOrder.getReason()).as(f("reason is: %s", message))
          .isEqualTo(message);
    });
  }

  private void driverGetWaypointDetails() {
    Route route = get(KEY_CREATED_ROUTE);
    final Long routeId = route.getId();
    final Long waypointId = get(KEY_WAYPOINT_ID);
    final Long driverId = get(KEY_NINJA_DRIVER_ID);

    callWithRetry(() -> {
      List<GetRouteResponse.Route> routes = driverClient.getRoutes(driverId, "2.1")
          .getData().getRoutes();
      routes.stream().filter(e -> e.getId() == (routeId))
          .forEach(e -> put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, e));
      GetRouteResponse.Route routeDetails = get(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS);
      routeDetails.getWaypoints().stream().filter(e -> e.getId() == waypointId)
          .forEach(e -> put(KEY_DRIVER_WAYPOINT_DETAILS, e));
      GetRouteResponse.Waypoint waypoint = get(KEY_DRIVER_WAYPOINT_DETAILS);
      Assertions.assertThat(waypoint.getJobs() != null && !waypoint.getJobs().isEmpty())
          .as("jobs is not empty").isTrue();
    }, "driver gets waypoint details");
  }

  private void createPhysicalItems(PhysicalItem order, String action,
      String jobType) {
    PhysicalItem job = new PhysicalItem();
    job.setAllowReschedule(false);
//    TODO check again
//    job.setDeliveryType(order.getDeliveryType());
    job.setTrackingId(order.getTrackingId());
    job.setId(order.getId());
//    job.setType(order.getType());
//    job.setInstruction(order.getInstruction());
    job.setParcelSize(order.getParcelSize());
    job.setStatus(order.getStatus());
    job.setAction(JobAction.valueOf(StringUtils.upperCase(action)));
    job.setParcelWeight(order.getParcelWeight());
    job.setShipperId(order.getShipperId());
    job.setRts(order.getRts());
    if (action.equalsIgnoreCase(ACTION_FAIL)) {
      boolean idValidFailed = get(KEY_BOOLEAN_DRIVER_FAILED_VALID, false);
      if (idValidFailed) {
        setOrderValidFailureReason(jobType, job);
      } else {
        setOrderFailureReason(jobType, job);
      }
    }
    List<PhysicalItem> orderList = Collections.singletonList(job);
    put(KEY_LIST_OF_CREATED_JOB_ORDERS, orderList);
  }

  private void createDriverJobs(String action) {
    GetRouteResponse.Waypoint waypoint = get(KEY_DRIVER_WAYPOINT_DETAILS);
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    List<GetRouteResponse.Job> jobs = waypoint.getJobs();
    jobs.forEach(e -> {
      List<Parcel> parcels = e.getParcels();
      parcels.stream().filter(o -> o.getTrackingId().equalsIgnoreCase(trackingId))
          .forEach(o -> put("parcel", o));
      PhysicalItem parcel = get(("parcel"));
      createPhysicalItems(parcel, action, e.getMode());
      List<PhysicalItem> orders = get(KEY_LIST_OF_CREATED_JOB_ORDERS);
      SubmitPodRequest.Job job = createDefaultDriverJobs(e, action);
      job.setPhysicalItems(orders);
      List<SubmitPodRequest.Job> jobList = Collections.singletonList(job);
      put(KEY_LIST_OF_DRIVER_JOBS, jobList);
    });
  }

  private SubmitPodRequest.Job createDefaultDriverJobs(GetRouteResponse.Job job, String action) {
    SubmitPodRequest.Job request = new SubmitPodRequest.Job();
    request.setAction(JobAction.valueOf(StringUtils.upperCase(action)));
    request.setId(job.getId());
    request.setStatus(job.getStatus());
    request.setMode(JobMode.valueOf(StringUtils.upperCase(job.getMode())));
    request.setType(JobType.valueOf(StringUtils.upperCase(job.getType())));
    return request;
  }

  private void getWaypointId(String transactionType) {
    if (transactionType.equalsIgnoreCase(WAYPOINT_TYPE_RESERVATION)) {
      LOGGER.info("reservation waypoint, no need get from order waypoint");
      return;
    }
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Order order = OrderDetailHelper.getOrderDetails(trackingId);
    Transaction transaction = OrderDetailHelper
        .getTransaction(order, transactionType, STATUS_PENDING);
    put(KEY_WAYPOINT_ID, transaction.getWaypointId());
  }

  private void setOrderFailureReason(String jobType, PhysicalItem order) {
    if (jobType.equalsIgnoreCase(TYPE_DELIVERY)) {
//      TODO check again
//      order.setFailureReason(TestConstants.DELIVERY_FAILURE_REASON);
      order.setFailureReasonId(Long.valueOf(TestConstants.DELIVERY_FAILURE_REASON_ID));
//      order.setFailureReasonCodeId(TestConstants.DELIVERY_FAILURE_REASON_CODE_ID);
    } else {
//      order.setFailureReason(TestConstants.PICKUP_FAILURE_REASON);
      order.setFailureReasonId(Long.valueOf(TestConstants.PICKUP_FAILURE_REASON_ID));
//      order.setFailureReasonCodeId(TestConstants.PICKUP_FAILURE_REASON_CODE_ID);
    }
    put(KEY_FAILURE_REASON_ID, order.getFailureReasonId());
//    put(KEY_FAILURE_REASON_CODE_ID, order.getFailureReasonCodeId());
  }

  private void setOrderValidFailureReason(String jobType, PhysicalItem order) {
    if (jobType.equalsIgnoreCase(TYPE_DELIVERY)) {
      //      TODO check again
//      order.setFailureReason(TestConstants.DELIVERY_VALID_FAILURE_REASON);
      order.setFailureReasonId(Long.valueOf(TestConstants.DELIVERY_VALID_FAILURE_REASON_ID));
//      order.setFailureReasonCodeId(TestConstants.DELIVERY_VALID_FAILURE_REASON_CODE_ID);
    } else {
//      order.setFailureReason(TestConstants.PICKUP_VALID_FAILURE_REASON);
      order.setFailureReasonId(Long.valueOf(TestConstants.PICKUP_VALID_FAILURE_REASON_ID));
//      order.setFailureReasonCodeId(TestConstants.PICKUP_VALID_FAILURE_REASON_CODE_ID);
    }
    put(KEY_FAILURE_REASON_ID, order.getFailureReasonId());
//    put(KEY_FAILURE_REASON_CODE_ID, order.getFailureReasonCodeId());
  }

  private ParcelRouteTransferRequest createParcelRouteTransferRequest(Map<String, String> source) {
    String json = toJsonCamelCase(source);
    ParcelRouteTransferRequest request = fromJsonSnakeCase(json, ParcelRouteTransferRequest.class);
    if (!source.containsKey("to_create_route")) {
      Long routeId = get(KEY_CREATED_ROUTE_ID);
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

  private SubmitPodRequest createDefaultDriverSubmitPodRequest(long waypointId,
      List<SubmitPodRequest.Job> jobs) {

    SubmitPodRequest request = new SubmitPodRequest();
    request.setCommitDate(Instant.now().toEpochMilli());
    request.setWaypointId(waypointId);
    request.setJobs(jobs);
    request.setDeliveredQuantity(jobs.size());
    request.setIcNumber("");
    request.setImei("000000000000000");
    request.setLatitude(1.28483758);
    request.setLongitude(103.80875857);
    request.setPickupQuantity(0);
    request.setSignatureImage(SubmitPodRequest.DEFAULT_SUBMIT_POD_IMAGE);
    request.setSignatureNotes("-");
    return request;
  }
}
