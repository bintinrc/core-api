package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route_monitoring.RouteMonitoringResponse;
import co.nvqa.commons.model.core.route_monitoring.Waypoint;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.model.order_create.v4.Timeslot;
import co.nvqa.commons.model.order_create.v4.UserDetail;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.assertj.core.api.Assertions;

/**
 * @author Binti Cahayati on 2020-07-06
 */
@ScenarioScoped
public class RouteMonitoringSteps extends BaseSteps {

  public static final String TIMESLOT_TYPE_EARLY = "early";
  public static final String TIMESLOT_TYPE_LATE = "late";
  public static final String TIMESLOT_TYPE_IMPENDING = "impending";
  private static final String WAYPOINT_TYPE_INVALID_FAILED = "invalid-failed";
  private static final String WAYPOINT_TYPE_PENDING = "pending";
  private static final String WAYPOINT_TYPE_INVALID_FAILED_DELIVERIES = "invalid failed deliveries";
  private static final String WAYPOINT_TYPE_INVALID_FAILED_PICKUPS = "invalid failed pickups";
  private static final String WAYPOINT_TYPE_TRANSACTION = "TRANSACTION";
  private static final String WAYPOINT_TYPE_RESERVATION = "RESERVATION";

  @Override
  public void init() {
  }

  @Given("Operator Filter Route Monitoring Data for Today's Date")
  public void operatorFilterRouteMonitoring() {
    List<Long> hubIds = get(KEY_LIST_OF_HUB_IDS);
    List<Long> zoneIds = get(KEY_LIST_OF_ZONE_IDS);
    String date = DateUtil.displayDate(DateUtil.getDate());
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      List<RouteMonitoringResponse> routeMonitoringDetails = getRouteMonitoringClient().getRouteMonitoringDetails(
          date, hubIds, zoneIds, 1000);
      RouteMonitoringResponse result = routeMonitoringDetails.stream()
          .filter(e -> e.getRouteId().equals(routeId)).findAny().orElseThrow(
              () -> new NvTestRuntimeException("Route Monitoring Data not found " + routeId));
      put(KEY_ROUTE_MONITORING_RESULT, result);
    }, "get route monitoring data", 10);

  }

  @Given("Operator verifies Route Monitoring Data Has Correct Details for {string} Case")
  public void operatorChecksTotalParcelsCount(String waypointType, Map<String, Integer> arg1) {
    callWithRetry(() -> {
      operatorFilterRouteMonitoring();
      List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
      List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
      List<Long> pullOutOrderTids = get(KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID);
      long routeId = get(KEY_CREATED_ROUTE_ID);
      int reservationCounts = 0;
      if (pickups != null) {
        reservationCounts = pickups.size();
      }
      int pullOutOfRouteOrderCount = 0;
      if (pullOutOrderTids != null) {
        pullOutOfRouteOrderCount = pullOutOrderTids.size();
      }
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      checkRouteDetails(result);
      int expectedTotalParcels = trackingIds.size() - reservationCounts - pullOutOfRouteOrderCount;
      int actualTotalParcels = result.getTotalParcels();
      Assertions.assertThat(actualTotalParcels)
          .as(String.format("total parcels for route id %d", routeId))
          .isEqualTo(expectedTotalParcels);
      int expectedTotalWaypoints = arg1.get(KEY_TOTAL_EXPECTED_WAYPOINT);
      put(KEY_TOTAL_EXPECTED_WAYPOINT, expectedTotalWaypoints);
      int actualTotalWaypoints = result.getTotalWaypoints();
      Assertions.assertThat(actualTotalWaypoints)
          .as(String.format("total waypoints for route id %d", routeId))
          .isEqualTo(expectedTotalWaypoints);
      Assertions.assertThat(actualTotalWaypoints)
          .as(String.format("total pending waypoints for route id %d", routeId))
          .isEqualTo(expectedTotalWaypoints);
      checkPendingDetails(routeId, result, arg1);
      if (waypointType.equalsIgnoreCase(WAYPOINT_TYPE_PENDING)) {
        Assertions.assertThat(result.getLastSeen()).as("Driver last seen is null").isNull();
      }
    }, "check pending case", 30);
  }

  @When("Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints")
  public void checkInvalidFailedDeliveries(Map<String, Integer> dataTable) {
    callWithRetry(() -> {
      operatorFilterRouteMonitoring();
      List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
      List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
      long routeId = get(KEY_CREATED_ROUTE_ID);
      int reservationCounts = 0;
      if (pickups != null) {
        reservationCounts = pickups.size();
      }

      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      checkRouteDetails(result);
      int expectedTotalParcels = trackingIds.size() - reservationCounts;
      int actualTotalParcels = result.getTotalParcels();
      Assertions.assertThat(actualTotalParcels)
          .as(String.format("total parcels for route id %d", routeId))
          .isEqualTo(expectedTotalParcels);
      int expectedTotalWaypoints = dataTable.get(KEY_TOTAL_EXPECTED_WAYPOINT);
      put(KEY_TOTAL_EXPECTED_WAYPOINT, expectedTotalWaypoints);
      int actualTotalWaypoints = result.getTotalWaypoints();
      int expectedTotalInvalidFailed = dataTable.get(KEY_TOTAL_EXPECTED_INVALID_FAILED);
      int expectedTotalEarlyWaypoints = dataTable.get(KEY_TOTAL_EXPECTED_EARLY);
      Assertions.assertThat(result.getNumInvalidFailed())
          .as(String.format("total invalid failed waypoints for route id %d", routeId))
          .isEqualTo(expectedTotalInvalidFailed);
      Assertions.assertThat(actualTotalWaypoints)
          .as(String.format("total waypoints for route id %d", routeId))
          .isEqualTo(expectedTotalWaypoints);
      Assertions.assertThat(actualTotalWaypoints)
          .as(String.format("total pending waypoints for route id %d", routeId))
          .isEqualTo(expectedTotalWaypoints);
      Assertions.assertThat(result.getNumSuccess())
          .as(String.format("total success waypoints for route id %d", routeId)).isEqualTo(0);
      Assertions.assertThat(result.getNumValidFailed())
          .as(String.format("total valid failed waypoints for route id %d", routeId)).isEqualTo(0);
      Assertions.assertThat(result.getNumEarlyWp())
          .as(String.format("total early waypoints for route id %d", routeId))
          .isEqualTo(expectedTotalEarlyWaypoints);
      Assertions.assertThat(result.getNumLateWp())
          .as(String.format("total late waypoints for route id %d", routeId)).isEqualTo(0);
      Assertions.assertThat(result.getNumImpending())
          .as(String.format("total impending waypoints for route id %d", routeId)).isEqualTo(0);
      Assertions.assertThat(result.getNumLateAndPending())
          .as(String.format("total late and pending waypoints for route id %d", routeId))
          .isEqualTo(0);
      Assertions.assertThat(result.getPendingPriorityParcels()).as("total pending priority parcels")
          .isEqualTo(0);
      Assertions.assertThat(result.getCompletionPercentage())
          .as(String.format("completion percentage %d", routeId)).isEqualTo(0.0);
    }, "check invalid failed case", 30);
  }


  @Given("Operator verifies Route Monitoring Data for Empty Route has correct details")
  public void operatorChecksEmptyRouteData(Map<String, Integer> dataTable) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      operatorFilterRouteMonitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      checkRouteDetails(result);
      Assertions.assertThat(result.getTotalParcels())
          .as(String.format("total parcels for route id %d", routeId)).isEqualTo(0);
      Assertions.assertThat(result.getTotalWaypoints())
          .as(String.format("total waypoints for route id %d", routeId)).isEqualTo(0);
      Assertions.assertThat(result.getNumPending())
          .as(String.format("total pending waypoints for route id %d", routeId)).isEqualTo(0);
      checkPendingDetails(routeId, result, dataTable);
      Assertions.assertThat(result.getLastSeen()).as("Last seen is null").isNull();

    }, "check empty route", 30);
  }

  @When("Operator get pending priority parcel details for {string}")
  public void operatorGetPendingPriorityParcelDetails(String type) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_PRIOR_TRACKING_IDS);
    put(WAYPOINT_TYPE_TRANSACTION, type);
    callWithRetry(() -> {
      List<Waypoint> waypoints = getRouteMonitoringClient().getPendingPriorityParcelDetails(routeId,
          type).getParcels();
      trackingIds.forEach(e -> {
        boolean found = waypoints.stream().anyMatch(o -> o.getTrackingId().equalsIgnoreCase(e));
        Assertions.assertThat(found).as("tracking id found").isTrue();
      });
      put(KEY_ROUTE_MONITORING_RESULT, waypoints);
    }, "get pending priority details", 30);
  }

  @When("Operator get {string} parcel details")
  public void operatorGetInvalidFailedParcelDetails(String type) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      List<Waypoint> waypoints;
      if (type.equalsIgnoreCase(WAYPOINT_TYPE_INVALID_FAILED_DELIVERIES)) {
        put(WAYPOINT_TYPE_TRANSACTION, "dd");
        waypoints = getRouteMonitoringClient().getInvalidFailedDeliveries(routeId).getParcels();
      } else {
        put(WAYPOINT_TYPE_TRANSACTION, "pp");
        waypoints = getRouteMonitoringClient().getInvalidFailedPickups(routeId).getParcels();
      }

      trackingIds.forEach(e -> {
        boolean found = waypoints.stream().anyMatch(o -> o.getTrackingId().equalsIgnoreCase(e));
        Assertions.assertThat(found).as("tracking id found").isTrue();
      });
      put(KEY_ROUTE_MONITORING_RESULT, waypoints);
    }, String.format("get %s details", type), 30);
  }

  @When("Operator get invalid failed reservation details")
  public void operatorGetInvalidFailedReservationDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
    callWithRetry(() -> {
      List<Waypoint> waypoints = getRouteMonitoringClient().getInvalidFailedReservations(routeId)
          .getPickupAppointments();
      pickups.forEach(e -> {
        boolean found = waypoints.stream().anyMatch(o -> e.getReservationId().equals(o.getId()));
        Assertions.assertThat(found).as(f("reservation id %d found", e.getReservationId()))
            .isTrue();
      });
      put(KEY_ROUTE_MONITORING_RESULT, waypoints);
    }, "get invalid failed reservation details", 30);
  }

  @When("Operator verifies invalid failed reservations details")
  public void operatorVerifyInvalidFailedReservationDetails() {
    List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
    List<OrderRequestV4> orderDetails = get(KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    Timeslot timeslot = orderDetails.get(0).getParcelJob().getPickupTimeslot();
    callWithRetry(() -> {
      operatorGetInvalidFailedReservationDetails();
      List<Waypoint> waypoints = get(KEY_ROUTE_MONITORING_RESULT);
      Assertions.assertThat(waypoints.size()).as("invalid failed reservation count")
          .isEqualTo(pickups.size());

      pickups.forEach(e -> {
        Waypoint waypoint = waypoints.stream().filter(o -> o.getId().equals(e.getReservationId()))
            .findAny().orElseThrow(() -> new NvTestRuntimeException(
                "reservation details not found: " + e.getReservationId()));
        Assertions.assertThat(waypoint.getId()).as("reservation id")
            .isEqualTo(e.getReservationId());
        Assertions.assertThat(waypoint.getName().toLowerCase()).as("name")
            .isEqualTo(e.getName().toLowerCase());
        Assertions.assertThat(waypoint.getContact()).as("contact").isEqualTo(e.getContact());
        Assertions.assertThat(waypoint.getAddress().toLowerCase()).as("address")
            .isEqualTo(createExpectedReservationAddress(e));
        Assertions.assertThat(waypoint.getTimeWindow().toLowerCase()).as("time window")
            .isEqualTo(getFormattedTimeslot(timeslot.getStartTime(), timeslot.getEndTime()));
      });
    }, "get invalid failed reservation details", 30);
  }


  @When("Operator verifies {string} parcel details")
  public void operatorVerifyInvalidFailedParcelDetails(String type) {
    List<OrderRequestV4> transactionDetails = get(
        KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    Map<String, OrderRequestV4> requestMap = get(KEY_LIST_OF_ORDER_CREATE_REQUEST);
    callWithRetry(() -> {
      operatorGetInvalidFailedParcelDetails(type);
      List<Waypoint> waypoints = get(KEY_ROUTE_MONITORING_RESULT);
      Assertions.assertThat(waypoints.size()).as(String.format("%s count", type))
          .isEqualTo(transactionDetails.size());
      transactionDetails.forEach(e -> {
        OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
        long orderId = getOrderClient().searchOrderByTrackingId(e.getTrackingNumber()).getId();
        Waypoint waypoint = waypoints.stream()
            .filter(o -> o.getTrackingId().contains(e.getTrackingNumber())).findAny().orElseThrow(
                () -> new NvTestRuntimeException("waypoint not found: " + e.getTrackingNumber()));

        Assertions.assertThat(waypoint.getTrackingId()).as("contain tracking id")
            .contains(e.getTrackingNumber());
        Assertions.assertThat(waypoint.getOrderId()).as("order id is equal").isEqualTo(orderId);
        List<Long> tagIds = get(KEY_LIST_OF_ORDER_TAG_IDS);
        if (tagIds != null) {
          Assertions.assertThat(waypoint.getTags().size()).as("tags size is correct")
              .isEqualTo(tagIds.size());
          Assertions.assertThat(waypoint.getTags().get(0)).as("tags contains PRIOR")
              .isEqualTo("PRIOR");
        } else {
          Assertions.assertThat(waypoint.getTags()).as("Tags is null").isNull();
        }
        UserDetail userDetail;
        Map<String, String> address;
        String startTime;
        String endTime;
        if (type.equalsIgnoreCase(WAYPOINT_TYPE_INVALID_FAILED_DELIVERIES)) {
          userDetail = e.getTo();
          address = temp.getTo().getAddress();
          startTime = e.getParcelJob().getDeliveryTimeslot().getStartTime();
          endTime = e.getParcelJob().getDeliveryTimeslot().getEndTime();
        } else {
          userDetail = e.getFrom();
          address = temp.getFrom().getAddress();
          startTime = e.getParcelJob().getPickupTimeslot().getStartTime();
          endTime = e.getParcelJob().getPickupTimeslot().getEndTime();
        }
        Assertions.assertThat(waypoint.getName()).as("name is correct")
            .isEqualToIgnoringCase(userDetail.getName());
        Assertions.assertThat(waypoint.getContact()).as("contact is correct")
            .isEqualTo(userDetail.getPhoneNumber());

        Assertions.assertThat(waypoint.getAddress().toLowerCase()).as("address")
            .isEqualTo(createExpectedPendingAddress(address));
        Assertions.assertThat(waypoint.getTimeWindow().toLowerCase()).as("time window")
            .isEqualTo(getFormattedTimeslot(startTime, endTime));
      });
    }, String.format("get %s parcel details", type), 3);
  }

  @When("Operator verifies pending priority parcel details")
  public void operatorVerifiesPendingPriorityParcelDetails() {
    List<OrderRequestV4> transactionDetails = getListOfPendingPriorityDetails();
    Map<String, OrderRequestV4> requestMap = get(KEY_LIST_OF_ORDER_CREATE_REQUEST);
    String type = get(WAYPOINT_TYPE_TRANSACTION);
    callWithRetry(() -> {
      operatorGetPendingPriorityParcelDetails(type);
      List<Waypoint> waypoints = get(KEY_ROUTE_MONITORING_RESULT);
      Assertions.assertThat(waypoints.size()).as("pending priority parcel count")
          .isEqualTo(transactionDetails.size());

      transactionDetails.forEach(e -> {
        OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
        Map<String, String> address;
        long orderId = getOrderClient().searchOrderByTrackingId(e.getTrackingNumber()).getId();
        Waypoint waypoint = waypoints.stream()
            .filter(o -> o.getTrackingId().contains(e.getTrackingNumber())).findAny().orElseThrow(
                () -> new NvTestRuntimeException("pending priority parcels details not found"));

        Assertions.assertThat(waypoint.getTrackingId()).as("tracking id is correct")
            .contains(e.getTrackingNumber());
        Assertions.assertThat(waypoint.getOrderId()).as("order id is correct").isEqualTo(orderId);

        List<Long> tagIds = get(KEY_LIST_OF_ORDER_TAG_IDS);
        Assertions.assertThat(waypoint.getTags().size()).as("tags size").isEqualTo(tagIds.size());
        Assertions.assertThat(waypoint.getTags().get(0)).as("tags contains PRIOR")
            .isEqualTo("PRIOR");

        String startTime;
        String endTime;
        if (e.getServiceType().equalsIgnoreCase("RETURN")) {
          Assertions.assertThat(waypoint.getName().toLowerCase()).as("name")
              .isEqualTo(e.getFrom().getName().toLowerCase());
          Assertions.assertThat(waypoint.getContact()).as("contact")
              .isEqualTo(e.getFrom().getPhoneNumber());
          address = temp.getFrom().getAddress();
          startTime = e.getParcelJob().getPickupTimeslot().getStartTime();
          endTime = e.getParcelJob().getPickupTimeslot().getEndTime();
        } else {
          Assertions.assertThat(waypoint.getName().toLowerCase()).as("name")
              .isEqualTo(e.getTo().getName().toLowerCase());
          Assertions.assertThat(waypoint.getContact()).as("contact")
              .isEqualTo(e.getTo().getPhoneNumber());
          address = temp.getTo().getAddress();
          startTime = e.getParcelJob().getDeliveryTimeslot().getStartTime();
          endTime = e.getParcelJob().getDeliveryTimeslot().getEndTime();
        }
        Assertions.assertThat(waypoint.getAddress().toLowerCase()).as("address")
            .isEqualTo(createExpectedPendingAddress(address));
        Assertions.assertThat(waypoint.getTimeWindow()).as("time window")
            .isEqualToIgnoringCase(getFormattedTimeslot(startTime, endTime));
      });

    }, "get pending priority details", 30);
  }

  @When("Operator get empty pending priority parcel details for {string}")
  public void operatorGetEmptyPendingPriorityParcelDetails(String type) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient().getPendingPriorityParcelDetails(
          routeId, type);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      Assertions.assertThat(parcels.isEmpty()).as("parcel details is empty").isTrue();
      Assertions.assertThat(rsvn.isEmpty()).as("pickup appointment details is empty").isTrue();
    }, "get empty pending priority details", 30);
  }

  @When("Operator get empty invalid failed deliveries parcel details")
  public void operatorGetEmptyInvalidFailedDeliveriesParcelDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient().getInvalidFailedDeliveries(
          routeId);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      Assertions.assertThat(parcels).as("parcel details is empty").isEmpty();
      Assertions.assertThat(rsvn).as("pickup appointment details is empty").isEmpty();
    }, "get invalid failed deliveries details", 30);
  }

  @When("Operator get empty invalid failed pickup parcel details")
  public void operatorGetEmptyInvalidFailedPickupParcelDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient().getInvalidFailedPickups(
          routeId);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      Assertions.assertThat(parcels).as("parcel details is empty").isEmpty();
      Assertions.assertThat(rsvn).as("pickup appointment details is empty").isEmpty();
    }, "get invalid failed pickup details", 30);
  }

  @When("Operator get empty invalid failed reservation details")
  public void operatorGetEmptyInvalidFailedReservationDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient().getInvalidFailedReservations(
          routeId);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      Assertions.assertThat(rsvn).as("pickup appointment details is empty").isEmpty();
      Assertions.assertThat(parcels).as("parcel details is empty").isEmpty();
    }, "get invalid failed reservation details", 30);
  }

  @Then("Operator verifies waypoint details for {string} waypoint")
  public void checkWaypointDetails(String waypointCase) {
    List<OrderRequestV4> transactionDetails = getListOfTransactionDetails();
    List<OrderRequestV4> reservationDetails = get(KEY_LIST_RESERVATION_REQUEST_DETAILS);
    Map<String, OrderRequestV4> requestMap = get(KEY_LIST_OF_ORDER_CREATE_REQUEST);
    callWithRetry(() -> {
      operatorFilterRouteMonitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      List<Waypoint> waypoints = result.getWaypoints();
      int expectedTotalWaypoints = get(KEY_TOTAL_EXPECTED_WAYPOINT);
      Assertions.assertThat(result.getWaypoints().size()).as("number of waypoints inside")
          .isEqualTo(expectedTotalWaypoints);
      if (!transactionDetails.isEmpty()) {
        transactionDetails.forEach(e -> {
          OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
          Map<String, String> address;
          Waypoint waypoint = waypoints.stream()
              .filter(o -> o.getType().equalsIgnoreCase(WAYPOINT_TYPE_TRANSACTION))
              .filter(o -> o.getTrackingId().contains(e.getTrackingNumber())).findAny()
              .orElseThrow(() -> new NvTestRuntimeException("parcels details not found"));
          Assertions.assertThat(waypoint.getType()).as("type")
              .isEqualToIgnoringCase(WAYPOINT_TYPE_TRANSACTION);
          Assertions.assertThat(waypoint.getTrackingId()).as("tracking id")
              .contains(e.getTrackingNumber());
          String startTime;
          String endTime;
          if (waypointCase.equalsIgnoreCase(WAYPOINT_TYPE_PENDING)) {
            Assertions.assertThat(waypoint.getStatus()).as("status").isEqualTo("Routed");
            Assertions.assertThat(waypoint.getServiceEndTime()).as("Service end time is null")
                .isNull();
          } else {
            Assertions.assertThat(waypoint.getStatus()).as("status").isEqualTo("Fail");
          }

          if (e.getServiceType().equalsIgnoreCase("RETURN")) {
            Assertions.assertThat(waypoint.getName()).as("name is correct")
                .isEqualToIgnoringCase(e.getFrom().getName());
            Assertions.assertThat(waypoint.getContact()).as("contact is correct")
                .isEqualTo(e.getFrom().getPhoneNumber());
            Assertions.assertThat(waypoint.getEmail()).as("email is correct")
                .isEqualToIgnoringCase(e.getFrom().getEmail());
            address = temp.getFrom().getAddress();
            Assertions.assertThat(waypoint.getPickupStatus()).as("pickup status is correct")
                .isEqualToIgnoringCase("return");
            startTime = e.getParcelJob().getPickupTimeslot().getStartTime();
            endTime = e.getParcelJob().getPickupTimeslot().getEndTime();
          } else {
            Assertions.assertThat(waypoint.getName()).as("name is correct")
                .isEqualToIgnoringCase(e.getTo().getName());
            Assertions.assertThat(waypoint.getContact()).as("contact is correct")
                .isEqualTo(e.getTo().getPhoneNumber());
            Assertions.assertThat(waypoint.getEmail()).as("email is correct")
                .isEqualToIgnoringCase(e.getTo().getEmail());
            address = temp.getTo().getAddress();
            Assertions.assertThat(waypoint.getPickupStatus()).as("Pickup status is null").isNull();
            startTime = e.getParcelJob().getDeliveryTimeslot().getStartTime();
            endTime = e.getParcelJob().getDeliveryTimeslot().getEndTime();
          }
          Assertions.assertThat(waypoint.getAddress()).as("address is correct")
              .isEqualToIgnoringCase(createExpectedPendingAddress(address));
          Assertions.assertThat(waypoint.getTimeWindow()).as("time window is correct")
              .isEqualToIgnoringCase(getFormattedTimeslot(startTime, endTime));
          if (waypointCase.equalsIgnoreCase(WAYPOINT_TYPE_INVALID_FAILED)) {
            Assertions.assertThat(waypoint.getWaypointStatus()).as("waypoint status is correct")
                .isEqualToIgnoringCase(WAYPOINT_TYPE_INVALID_FAILED);
            Assertions.assertThat(waypoint.getTimeStatus()).as("time status is correct")
                .isEqualToIgnoringCase(TIMESLOT_TYPE_EARLY);
          } else {
            Assertions.assertThat(waypoint.getWaypointStatus()).as("waypoint status")
                .isEqualToIgnoringCase("pending");
            Assertions.assertThat(waypoint.getDriverLastSeen()).as("Driver last seen is null")
                .isNull();
            Assertions.assertThat(waypoint.getTimeStatus()).as("Driver time status is null")
                .isNull();
          }

        });
      }
      if (reservationDetails != null) {
        reservationDetails.forEach(e -> {
          OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
          Map<String, String> address;
          Waypoint waypoint = waypoints.stream()
              .filter(o -> o.getType().equalsIgnoreCase(WAYPOINT_TYPE_RESERVATION))
              .filter(o -> o.getName().equalsIgnoreCase(e.getFrom().getName())).findAny()
              .orElseThrow(() -> new NvTestRuntimeException("parcels details not found"));

          Assertions.assertThat(waypoint.getType()).as("type is reservation")
              .isEqualToIgnoringCase(WAYPOINT_TYPE_RESERVATION);
          Assertions.assertThat(waypoint.getTrackingId()).as("Tracking id is null").isNull();

          String startTime = e.getParcelJob().getPickupTimeslot().getStartTime();
          String endTime = e.getParcelJob().getPickupTimeslot().getEndTime();
          Assertions.assertThat(waypoint.getTimeWindow()).as("time window")
              .isEqualToIgnoringCase(getFormattedTimeslot(startTime, endTime));
          Assertions.assertThat(waypoint.getStatus()).as("status").isEqualTo("Routed");
          Assertions.assertThat(waypoint.getServiceEndTime()).as("Service end time is null")
              .isNull();

          Assertions.assertThat(waypoint.getName()).as("name")
              .isEqualToIgnoringCase(e.getFrom().getName());
          Assertions.assertThat(waypoint.getContact()).as("contact")
              .isEqualTo(e.getFrom().getPhoneNumber());
          Assertions.assertThat(waypoint.getEmail()).as("email")
              .isEqualToIgnoringCase(e.getFrom().getEmail());

          address = temp.getFrom().getAddress();
          Assertions.assertThat(waypoint.getAddress()).as("address")
              .isEqualToIgnoringCase(createExpectedPendingAddress(address));
          Assertions.assertThat(waypoint.getPickupStatus()).as("Pickup status is null").isNull();
          Assertions.assertThat(waypoint.getWaypointStatus()).as("waypoint status")
              .isEqualToIgnoringCase(WAYPOINT_TYPE_RESERVATION);
          Assertions.assertThat(waypoint.getTimeStatus()).as("time status is null").isNull();
          Assertions.assertThat(waypoint.getDriverLastSeen()).as("Driver last seen is null")
              .isNull();

        });
      }
    }, "check pending waypoint details", 30);
  }

  @When("Operator verifies total pending priority parcels and other details")
  public void checkPendingPriorityParcels(Map<String, Integer> dataTable) {
    int totalExpectedCount = dataTable.get(KEY_TOTAL_EXPECTED_PENDING_PRIORITY);
    callWithRetry(() -> {
      operatorFilterRouteMonitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      Assertions.assertThat(result.getPendingPriorityParcels()).as("total pending priority parcels")
          .isEqualTo(totalExpectedCount);
      operatorChecksTotalParcelsCount(WAYPOINT_TYPE_PENDING, dataTable);
    }, "check total pending priority parcels", 30);
  }

  @When("Operator verifies total pending priority parcels is now 0")
  public void excludeAttemptedPendingPriorityParcels() {
    callWithRetry(() -> {
      operatorFilterRouteMonitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      Assertions.assertThat(result.getPendingPriorityParcels()).as("total pending priority parcels")
          .isEqualTo(0);
    }, "check total pending priority parcels", 30);
  }

  @When("Operator verifies total invalid failed is 0 and other details")
  public void totalEmptyInvalidFailed(Map<String, Integer> waypointCounts) {
    callWithRetry(() -> {
      operatorFilterRouteMonitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      Assertions.assertThat(result.getNumInvalidFailed()).as("total invalid failed").isEqualTo(0);
      operatorChecksTotalParcelsCount(WAYPOINT_TYPE_INVALID_FAILED, waypointCounts);
    }, "check total invalid failed", 30);
  }

  private List<OrderRequestV4> getListOfTransactionDetails() {
    List<OrderRequestV4> requestedOrderDetails = get(
        KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    List<String> reservationTrackingIds = get(
        KEY_LIST_OF_RESERVATION_TRACKING_IDS);
    List<String> pullOutTrackingIds = get(KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID);
    if (reservationTrackingIds != null) {
      reservationTrackingIds.forEach(e -> putInList(KEY_LIST_RESERVATION_REQUEST_DETAILS,
          requestedOrderDetails.stream().filter(o -> o.getTrackingNumber().equalsIgnoreCase(e))
              .findAny().get()));
      List<OrderRequestV4> reservationDetails = get(KEY_LIST_RESERVATION_REQUEST_DETAILS);
      //to exclude reservation tracking ids (if any) as transaction tracking ids
      reservationDetails.forEach(requestedOrderDetails::remove);
    }
    if (pullOutTrackingIds != null) {
      pullOutTrackingIds.forEach(e -> {
        OrderRequestV4 temp = requestedOrderDetails.stream()
            .filter(o -> o.getTrackingNumber().equalsIgnoreCase(e)).findAny().get();
        //to exclude pull out tracking ids (if any) as transaction tracking ids
        requestedOrderDetails.remove(temp);
      });
    }
    return requestedOrderDetails;
  }

  private List<OrderRequestV4> getListOfPendingPriorityDetails() {
    List<OrderRequestV4> requestedOrderDetails = get(
        KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    List<String> priorTrackingIds = get(KEY_LIST_OF_PRIOR_TRACKING_IDS);
    List<OrderRequestV4> result = new ArrayList<>();
    if (priorTrackingIds != null) {
      priorTrackingIds.forEach(e -> {
        OrderRequestV4 temp = requestedOrderDetails.stream()
            .filter(o -> o.getTrackingNumber().equalsIgnoreCase(e)).findAny().get();
        result.add(temp);
      });
    }
    return result;
  }

  private void checkRouteDetails(RouteMonitoringResponse result) {
    Assertions.assertThat(result.getDriverName()).as("driver name")
        .isEqualToIgnoringCase(TestConstants.ROUTE_MONITORING_DRIVER_NAME);
    Assertions.assertThat(result.getHubName()).as("hub name")
        .isEqualToIgnoringCase(TestConstants.SORTING_HUB_NAME);
    Assertions.assertThat(result.getZoneName()).as("zone name")
        .isEqualToIgnoringCase(TestConstants.ZONE_NAME);
  }

  private void checkPendingDetails(long routeId, RouteMonitoringResponse result,
      Map<String, Integer> arg) {
    int totalExpectedValidFailed = 0;
    if (arg.get(KEY_TOTAL_EXPECTED_VALID_FAILED) != null) {
      totalExpectedValidFailed = arg.get(KEY_TOTAL_EXPECTED_VALID_FAILED);
    }
    int totalExpectedEarlyWaypoint = 0;
    if (arg.get(KEY_TOTAL_EXPECTED_EARLY) != null) {
      totalExpectedEarlyWaypoint = arg.get(KEY_TOTAL_EXPECTED_EARLY);
    }
    Assertions.assertThat(result.getNumSuccess())
        .as(String.format("total success waypoints for route id %d", routeId)).isEqualTo(0);
    Assertions.assertThat(result.getNumValidFailed())
        .as(String.format("total valid failed waypoints for route id %d", routeId))
        .isEqualTo(totalExpectedValidFailed);
    Assertions.assertThat(result.getNumInvalidFailed())
        .as(String.format("total invalid failed waypoints for route id %d", routeId)).isEqualTo(0);
    Assertions.assertThat(result.getNumEarlyWp())
        .as(String.format("total early waypoints for route id %d", routeId))
        .isEqualTo(totalExpectedEarlyWaypoint);
    Assertions.assertThat(result.getNumLateWp())
        .as(String.format("total late waypoints for route id %d", routeId)).isEqualTo(0);
    Assertions.assertThat(result.getNumImpending())
        .as(String.format("total impending waypoints for route id %d", routeId)).isEqualTo(0);
    Assertions.assertThat(result.getNumLateAndPending())
        .as(String.format("total late and pending waypoints for route id %d", routeId))
        .isEqualTo(0);
    Assertions.assertThat(result.getCompletionPercentage())
        .as(String.format("completion percentage %d", routeId)).isEqualTo(0.0);
  }

  private String createExpectedPendingAddress(Map<String, String> address) {
    return (address.get("address1") + " " + address.get("address2") + " " + address.get("postcode")
        + " " + address.get("country")).toLowerCase();
  }

  private String createExpectedReservationAddress(Pickup pickup) {
    return (pickup.getAddress1() + " " + pickup.getAddress2() + " " + pickup.getPostcode() + " "
        + pickup.getCountry()).toLowerCase();
  }

  private String getFormattedTimeslot(String startTime, String endTime) {
    Timeslot.ValidTimeSlot timeSlot = Timeslot.ValidTimeSlot.fromString(startTime, endTime);
    switch (timeSlot) {
      case TIME_SLOT_1:
        return "9am - 12pm";
      case TIME_SLOT_2:
        return "12pm - 3pm";
      case TIME_SLOT_3:
        return "3pm - 6pm";
      case TIME_SLOT_4:
        return "6pm - 10pm";
      case TIME_SLOT_5:
        return "9am - 6pm";
      default:
        return "9am - 10pm";
    }
  }
}
