package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.model.batch_update_pods.ProofDetails;
import co.nvqa.common.core.model.order.Order;
import co.nvqa.common.core.model.route.ParcelRouteTransferResponse;
import co.nvqa.common.core.model.route.ParcelRouteTransferResponse.FailedOrder;
import co.nvqa.common.driver.client.DriverClient;
import co.nvqa.common.driver.model.rest.GetRouteResponse;
import co.nvqa.common.driver.model.rest.GetRouteResponse.Parcel;
import co.nvqa.common.driver.model.rest.SubmitPodRequest;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.JobAction;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.JobMode;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.JobType;
import co.nvqa.common.driver.model.rest.SubmitPodRequest.PhysicalItem;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import co.nvqa.core_api.exception.NvTestCoreFailedOrdersNotFoundException;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import javax.inject.Inject;
import lombok.Getter;
import org.apache.commons.lang3.StringUtils;
import org.assertj.core.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static co.nvqa.common.core.utils.CoreScenarioStorageKeys.KEY_ROUTE_LIST_ROUTE_TRANSFER_RESPONSE;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class DriverSteps extends BaseSteps {

  private static final Logger LOGGER = LoggerFactory.getLogger(DriverSteps.class);
  private static final String ACTION_FAIL = "FAIL";
  private static final String TYPE_DELIVERY = "DELIVERY";
  private static final String STATUS_PENDING = "pending";

  @Inject
  @Getter
  private DriverClient driverClient;

  @Override
  public void init() {

  }

  @Given("Deleted route is not shown on his list routes")
  public void driverRouteNotShown(Map<String, String> data) {
    Map<String, String> resolvedData = resolveKeyValues(data);
    final long routeId = Long.parseLong(resolvedData.get("routeId"));
    final long driverId = Long.parseLong(resolvedData.get("driverId"));
    doWithRetry(() -> {
      List<GetRouteResponse.Route> result = getDriverClient().getRoutes(driverId, "2.1",
              Optional.of(routeId)).getData()
          .getRoutes();
      boolean found = result.stream().anyMatch(o -> o.getId() == routeId);
      Assertions.assertThat(found).as("route is not shown in driver list routes").isFalse();
    }, "get list driver routes");
  }

  @Given("Archived route is not shown on his list routes")
  public void archivedDriverRouteNotShown(Map<String, String> data) {
    driverRouteNotShown(data);
  }

  @Given("Driver submit pod to {string} waypoint")
  public void driverDeliverParcels(String action, Map<String, String> data) {
    Map<String, String> resolvedData = resolveKeyValues(data);
    final long routeId = Long.parseLong(resolvedData.get("routeId"));
    final long waypointId = Long.parseLong(resolvedData.get("waypointId"));
    final long driverId = Long.parseLong(resolvedData.get("driverId"));
    doWithRetry(() -> {
      driverGetWaypointDetails(routeId, waypointId, driverId);
      createDriverJobs(action.toUpperCase());
      List<SubmitPodRequest.Job> jobs = get(KEY_LIST_OF_DRIVER_JOBS);
      Order order = get(KEY_CREATED_ORDER);

      SubmitPodRequest request = createDefaultDriverSubmitPodRequest(waypointId, jobs);
      if (order != null) {
        request.setContact(order.getToContact());
        request.setName(order.getToName());
        ProofDetails proofDetails = new ProofDetails();
        proofDetails.setContact(request.getContact());
        proofDetails.setName(request.getName());
        putInMap(KEY_MAP_PROOF_WEBHOOK_DETAILS, order.getTrackingId(),
            proofDetails);
      }
      getDriverClient().submitPod(routeId, waypointId, request);
      if (action.equalsIgnoreCase(ACTION_FAIL)) {
        int attemptCount = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT, 0);
        put(KEY_DRIVER_FAIL_ATTEMPT_COUNT, ++attemptCount);
      }
    }, "driver attempts waypoint");
  }

  @When("Driver Transfer Parcel to Route with route past date {string}")
  @When("Driver Transfer Parcel to Archived route {string}")
  public void driverTransferRoutePastDate(String routeId, List<String> trackingIds) {
    List<String> resolvedTrackingIds = resolveValues(trackingIds);
    final long id = Long.parseLong(resolveValue(routeId));

    doWithRetry(() -> {
      Response response = getRouteClient().parcelRouteTransferAndGetRawResponse(id,
          resolvedTrackingIds);
      put(KEY_API_RAW_RESPONSE, response);
      put(KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS, response);
    }, "driver parcel route transfer");
  }

  @Then("Verify Parcel Route Transfer Failed Orders with message : {string}")
  public void verifyRouteTransferResponseFailed(String message, List<String> failedTrackingIds) {
    List<String> trackingIds = resolveValues(failedTrackingIds);
    ParcelRouteTransferResponse response = get(KEY_ROUTE_LIST_ROUTE_TRANSFER_RESPONSE);
    List<FailedOrder> failedOrders = response.getData().getFailure();
    Assertions.assertThat(failedOrders.size() == trackingIds.size())
        .as("contains all failed orders").isTrue();
    trackingIds.forEach(e -> {
      FailedOrder failedOrder = failedOrders.stream()
          .filter(o -> o.getTrackingId().equalsIgnoreCase(e)).findAny().orElseThrow(
              () -> new NvTestCoreFailedOrdersNotFoundException(
                  String.format("tracking id %s not found", e)));
      Assertions.assertThat(failedOrder.getTrackingId()).as(f("tracking id is: %s", e))
          .isEqualTo(e);
      Assertions.assertThat(failedOrder.getReason()).as(f("reason is: %s", message))
          .isEqualTo(message);
    });
  }

  private void driverGetWaypointDetails(long routeId, long waypointId, long driverId) {
    doWithRetry(() -> {
      List<GetRouteResponse.Route> routes = driverClient.getRoutes(driverId, "2.1",
              Optional.of(routeId))
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

  private void createPhysicalItems(Parcel order, String action,
      String jobType) {
    PhysicalItem job = new PhysicalItem();
    job.setAllowReschedule(false);
    job.setTrackingId(order.getTrackingId());
    job.setId(order.getId());
    job.setParcelSize(order.getParcelSize());
    job.setStatus(order.getStatus());
    job.setAction(JobAction.valueOf(StringUtils.upperCase(action)));
    job.setParcelWeight(order.getParcelWeight());
    job.setShipperId(order.getShipperId());
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
      Parcel parcel = get(("parcel"));
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

  private void setOrderFailureReason(String jobType, PhysicalItem order) {
    if (jobType.equalsIgnoreCase(TYPE_DELIVERY)) {
      order.setFailureReasonId(Long.valueOf(TestConstants.DELIVERY_FAILURE_REASON_ID));
    } else {
      order.setFailureReasonId(Long.valueOf(TestConstants.PICKUP_FAILURE_REASON_ID));
    }
    put(KEY_FAILURE_REASON_ID, order.getFailureReasonId());
  }

  private void setOrderValidFailureReason(String jobType, PhysicalItem order) {
    if (jobType.equalsIgnoreCase(TYPE_DELIVERY)) {
      order.setFailureReasonId(Long.valueOf(TestConstants.DELIVERY_VALID_FAILURE_REASON_ID));
    } else {
      order.setFailureReasonId(Long.valueOf(TestConstants.PICKUP_VALID_FAILURE_REASON_ID));
    }
    put(KEY_FAILURE_REASON_ID, order.getFailureReasonId());
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
