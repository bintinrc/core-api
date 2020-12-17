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
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
  private static final String KEY_ROUTE_MONITORING_RESULT = "KEY_ROUTE_MONITORING_RESULT";
  private static final String KEY_TOTAL_EXPECTED_WAYPOINT = "total-expected-waypoints";
  private static final String KEY_TOTAL_EXPECTED_PENDING_PRIORITY = "total-expected-pending-priority-parcels";
  private static final String KEY_TOTAL_EXPECTED_INVALID_FAILED = "total-expected-invalid-failed";
  private static final String KEY_TOTAL_EXPECTED_VALID_FAILED = "total-expected-valid-failed";
  private static final String KEY_TOTAL_EXPECTED_EARLY = "total-expected-early";
  private static final String KEY_LIST_RESERVATION_REQUEST_DETAILS = "key-list-of-reservation-details";
  private static final String WAYPOINT_TYPE_TRANSACTION = "TRANSACTION";
  private static final String WAYPOINT_TYPE_RESERVATION = "RESERVATION";

  @Override
  public void init() {

  }

  @Given("^Operator Filter Route Monitoring Data for Today's Date$")
  public void operatorFilterRouteMinitoring() {
    List<Long> hubIds = get(KEY_LIST_OF_HUB_IDS);
    List<Long> zoneIds = get(KEY_LIST_OF_ZONE_IDS);
    String date = DateUtil.displayDate(DateUtil.getDate());
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      List<RouteMonitoringResponse> routeMonitoringDetails = getRouteMonitoringClient()
          .getRouteMonitoringDetails(date, hubIds, zoneIds, 1000);
      RouteMonitoringResponse result = routeMonitoringDetails.stream()
          .filter(e -> e.getRouteId().equals(routeId))
          .findAny().orElseThrow(
              () -> new NvTestRuntimeException("Route Monitoring Data not found " + routeId));
      put(KEY_ROUTE_MONITORING_RESULT, result);
    }, "get route monitoring data");

  }

  @Given("^Operator verifies Route Monitoring Data Has Correct Details for \"([^\"]*)\" Case$")
  public void operatorChecksTotalParcelsCount(String waypointType, Map<String, Integer> arg1) {
    callWithRetry(() -> {
      operatorFilterRouteMinitoring();
      List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
      List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
      List<Long> pullOutOrderTids = get(RoutingSteps.KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID);
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
      assertEquals(String.format("total parcels for route id %d", routeId), expectedTotalParcels,
          actualTotalParcels);
      int expectedTotalWaypoints = arg1.get(KEY_TOTAL_EXPECTED_WAYPOINT);
      put(KEY_TOTAL_EXPECTED_WAYPOINT, expectedTotalWaypoints);
      int actualTotalWaypoints = result.getTotalWaypoints();
      assertEquals(String.format("total waypoints for route id %d", routeId),
          expectedTotalWaypoints, actualTotalWaypoints);
      assertEquals(String.format("total pending waypoints for route id %d", routeId),
          expectedTotalWaypoints, actualTotalWaypoints);
      checkPendingDetails(routeId, result, arg1);
      if (waypointType.equalsIgnoreCase(WAYPOINT_TYPE_PENDING)) {
        assertNull("last seen", result.getLastSeen());
      }
    }, "check pending case", 30);
  }

  @When("^Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints$")
  public void checkInvailedFailedDeliveries(Map<String, Integer> arg1) {
    callWithRetry(() -> {
      operatorFilterRouteMinitoring();
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
      assertEquals(String.format("total parcels for route id %d", routeId), expectedTotalParcels,
          actualTotalParcels);
      int expectedTotalWaypoints = arg1.get(KEY_TOTAL_EXPECTED_WAYPOINT);
      put(KEY_TOTAL_EXPECTED_WAYPOINT, expectedTotalWaypoints);
      int actualTotalWaypoints = result.getTotalWaypoints();
      int expectedTotalInvalidFailed = arg1.get(KEY_TOTAL_EXPECTED_INVALID_FAILED);
      int expectedTotalEarlyWaypoints = arg1.get(KEY_TOTAL_EXPECTED_EARLY);
      assertEquals(String.format("total invalid failed waypoints for route id %d", routeId),
          expectedTotalInvalidFailed, result.getNumInvalidFailed());
      assertEquals(String.format("total waypoints for route id %d", routeId),
          expectedTotalWaypoints, actualTotalWaypoints);
      assertEquals(String.format("total pending waypoints for route id %d", routeId),
          expectedTotalWaypoints, actualTotalWaypoints);
      assertEquals(String.format("total success waypoints for route id %d", routeId), 0,
          result.getNumSuccess());
      assertEquals(String.format("total valid failed waypoints for route id %d", routeId), 0,
          result.getNumValidFailed());
      assertEquals(String.format("total early waypoints for route id %d", routeId),
          expectedTotalEarlyWaypoints, result.getNumEarlyWp());
      assertEquals(String.format("total late waypoints for route id %d", routeId), 0,
          result.getNumLateWp());
      assertEquals(String.format("total impending waypoints for route id %d", routeId), 0,
          result.getNumImpending());
      assertEquals(String.format("total late and pending waypoints for route id %d", routeId), 0,
          result.getNumLateAndPending());
      assertEquals("total pending priority parcels", 0, result.getPendingPriorityParcels());
      assertEquals(String.format("completion precentage", routeId), 0.0,
          result.getCompletionPercentage());
    }, "check invalid failed case", 30);
  }


  @Given("^Operator verifies Route Monitoring Data for Empty Route has correct details$")
  public void operatorChecksEmptyRouteData(Map<String, Integer> arg) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      operatorFilterRouteMinitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      checkRouteDetails(result);
      assertEquals(String.format("total parcels for route id %d", routeId), 0,
          result.getTotalParcels());
      assertEquals(String.format("total waypoints for route id %d", routeId), 0,
          result.getTotalWaypoints());
      assertEquals(String.format("total pending waypoints for route id %d", routeId), 0,
          result.getNumPending());
      checkPendingDetails(routeId, result, arg);
      assertNull("last seen", result.getLastSeen());
    }, "check empty route", 30);
  }

  @When("^Operator get pending priority parcel details for \"([^\"]*)\"$")
  public void operatorGetPendingPriorityParcelDetails(String type) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(OrderActionSteps.KEY_LIST_OF_PRIOR_TRACKING_IDS);
    put(WAYPOINT_TYPE_TRANSACTION, type);
    callWithRetry(() -> {
      List<Waypoint> waypoints = getRouteMonitoringClient()
          .getPendingPriorityParcelDetails(routeId, type).getParcels();
      trackingIds.forEach(e -> {
        boolean found = waypoints.stream().anyMatch(o -> o.getTrackingId().equalsIgnoreCase(e));
        assertTrue("tracking id found", found);
      });
      put(KEY_ROUTE_MONITORING_RESULT, waypoints);
    }, "get pending priority details", 30);
  }

  @When("^Operator get \"([^\"]*)\" parcel details$")
  public void operatorGetInvalidFailedParcelDetails(String type) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(OrderCreateSteps.KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
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
        assertTrue("tracking id found", found);
      });
      put(KEY_ROUTE_MONITORING_RESULT, waypoints);
    }, String.format("get %s details", type), 30);
  }

  @When("^Operator get invalid failed reservation details$")
  public void operatorGetInvalidFailedReservationDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<Pickup> pickups = get(ReservationSteps.KEY_LIST_OF_CREATED_RESERVATIONS);
    callWithRetry(() -> {
      List<Waypoint> waypoints = getRouteMonitoringClient().getInvalidFailedReservations(routeId)
          .getPickupAppointments();
      pickups.forEach(e -> {
        boolean found = waypoints.stream().anyMatch(o -> e.getId().equals(o.getId()));
        assertTrue(String.format("reservation id %d found", e.getId()), found);
      });
      put(KEY_ROUTE_MONITORING_RESULT, waypoints);
    }, "get invalid failed reservation details", 30);
  }

  @When("^Operator verifies invalid failed reservations details$")
  public void operatorVerifieInvalidFailedReservationDetails() {
    List<Pickup> pickups = get(ReservationSteps.KEY_LIST_OF_CREATED_RESERVATIONS);
    List<OrderRequestV4> orderDetails = get(OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    Timeslot timeslot = orderDetails.get(0).getParcelJob().getPickupTimeslot();
    callWithRetry(() -> {
      operatorGetInvalidFailedReservationDetails();
      List<Waypoint> waypoints = get(KEY_ROUTE_MONITORING_RESULT);
      assertEquals("invalid failed reservation count", pickups.size(), waypoints.size());
      pickups.forEach(e -> {
        Waypoint waypoint = waypoints.stream()
            .filter(o -> o.getId().equals(e.getId()))
            .findAny()
            .orElseThrow(
                () -> new NvTestRuntimeException("reservation details not found: " + e.getId()));

        assertEquals("reservation id", e.getId(), waypoint.getId());
        assertEquals("name", e.getName().toLowerCase(), waypoint.getName().toLowerCase());
        assertEquals("contact", e.getContact(), waypoint.getContact());

        assertEquals("address", createExpectedReservationAddress(e),
            waypoint.getAddress().toLowerCase());
        assertEquals("time window",
            getFormattedTimeslot(timeslot.getStartTime(), timeslot.getEndTime()),
            waypoint.getTimeWindow().toLowerCase());
      });
    }, "get invalid failed reservation details", 30);
  }


  @When("^Operator verifies \"([^\"]*)\" parcel details$")
  public void operatorVerifieInvalidFailedParcelDetails(String type) {
    List<OrderRequestV4> transactionDetails = get(
        OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    Map<String, OrderRequestV4> requestMap = get(OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_REQUEST);
    callWithRetry(() -> {
      operatorGetInvalidFailedParcelDetails(type);
      List<Waypoint> waypoints = get(KEY_ROUTE_MONITORING_RESULT);
      assertEquals(String.format("%s count", type), transactionDetails.size(), waypoints.size());
      transactionDetails.forEach(e -> {
        OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
        long orderId = getOrderClient().searchOrderByTrackingId(e.getTrackingNumber()).getId();
        Waypoint waypoint = waypoints.stream()
            .filter(o -> o.getTrackingId().contains(e.getTrackingNumber()))
            .findAny()
            .orElseThrow(
                () -> new NvTestRuntimeException("waypoint not found: " + e.getTrackingNumber()));

        assertTrue("tracking id", waypoint.getTrackingId().contains(e.getTrackingNumber()));
        assertEquals("order id", orderId, waypoint.getOrderId());
        List<Long> tagIds = get(OrderActionSteps.KEY_LIST_OF_ORDER_TAG_IDS);
        if (tagIds != null) {
          assertEquals("tags size", tagIds.size(), waypoint.getTags().size());
          assertEquals("tags contains PRIOR", "PRIOR", waypoint.getTags().get(0));
        } else {
          assertNull("tags", waypoint.getTags());
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
        assertEquals("name", userDetail.getName().toLowerCase(), waypoint.getName().toLowerCase());
        assertEquals("contact", userDetail.getPhoneNumber(), waypoint.getContact());

        assertEquals("address", createExpectedPendingAddress(address),
            waypoint.getAddress().toLowerCase());
        assertEquals("time window", getFormattedTimeslot(startTime, endTime),
            waypoint.getTimeWindow().toLowerCase());
      });
    }, String.format("get %s parcel details", type), 3);
  }

  @When("^Operator verifies pending priority parcel details$")
  public void operatorVerifiesPendingPriorityParcelDetails() {
    List<OrderRequestV4> transactionDetails = getListOfPendingPriorityDetails();
    Map<String, OrderRequestV4> requestMap = get(OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_REQUEST);
    String type = get(WAYPOINT_TYPE_TRANSACTION);
    callWithRetry(() -> {
      operatorGetPendingPriorityParcelDetails(type);
      List<Waypoint> waypoints = get(KEY_ROUTE_MONITORING_RESULT);
      assertEquals("pending priority parcel count", transactionDetails.size(), waypoints.size());

      transactionDetails.forEach(e -> {
        OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
        Map<String, String> address;
        long orderId = getOrderClient().searchOrderByTrackingId(e.getTrackingNumber()).getId();
        Waypoint waypoint = waypoints.stream().filter(o -> o.getTrackingId()
            .contains(e.getTrackingNumber())).findAny()
            .orElseThrow(
                () -> new NvTestRuntimeException("pending priority parcels details not found"));

        assertTrue("tracking id", waypoint.getTrackingId().contains(e.getTrackingNumber()));
        assertEquals("order id", orderId, waypoint.getOrderId());

        List<Long> tagIds = get(OrderActionSteps.KEY_LIST_OF_ORDER_TAG_IDS);
        assertEquals("tags size", tagIds.size(), waypoint.getTags().size());
        assertEquals("tags contains PRIOR", "PRIOR", waypoint.getTags().get(0));

        String startTime;
        String endTime;
        if (e.getServiceType().equalsIgnoreCase("RETURN")) {
          assertEquals("name", e.getFrom().getName().toLowerCase(),
              waypoint.getName().toLowerCase());
          assertEquals("contact", e.getFrom().getPhoneNumber(), waypoint.getContact());
          address = temp.getFrom().getAddress();
          startTime = e.getParcelJob().getPickupTimeslot().getStartTime();
          endTime = e.getParcelJob().getPickupTimeslot().getEndTime();
        } else {
          assertEquals("name", e.getTo().getName().toLowerCase(), waypoint.getName().toLowerCase());
          assertEquals("contact", e.getTo().getPhoneNumber(), waypoint.getContact());
          address = temp.getTo().getAddress();
          startTime = e.getParcelJob().getDeliveryTimeslot().getStartTime();
          endTime = e.getParcelJob().getDeliveryTimeslot().getEndTime();
        }
        assertEquals("address", createExpectedPendingAddress(address),
            waypoint.getAddress().toLowerCase());
        assertEquals("time window", getFormattedTimeslot(startTime, endTime),
            waypoint.getTimeWindow().toLowerCase());
      });

    }, "get pending priority details", 30);
  }

  @When("^Operator get empty pending priority parcel details for \"([^\"]*)\"$")
  public void operatorGetEmptyPendingPriorityParcelDetails(String type) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient()
          .getPendingPriorityParcelDetails(routeId, type);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      assertTrue("parcel details is empty", parcels.isEmpty());
      assertTrue("pickup appointment details is empty", rsvn.isEmpty());
    }, "get empty pending priority details", 30);
  }

  @When("^Operator get empty invalid failed deliveries parcel details$")
  public void operatorGetEmptyInvalidFailedDeliveriesParcelDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient()
          .getInvalidFailedDeliveries(routeId);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      assertTrue("parcel details is empty", parcels.isEmpty());
      assertTrue("pickup appointment details is empty", rsvn.isEmpty());
    }, "get invalid failed deliveries details", 30);
  }

  @When("^Operator get empty invalid failed pickup parcel details$")
  public void operatorGetEmptyInvalidFailedPickupParcelDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient()
          .getInvalidFailedPickups(routeId);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      assertTrue("parcel details is empty", parcels.isEmpty());
      assertTrue("pickup appointment details is empty", rsvn.isEmpty());
    }, "get invalid failed pickup details", 30);
  }

  @When("^Operator get empty invalid failed reservation details$")
  public void operatorGetEmptyInvalidFaileReservationDetails() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      RouteMonitoringResponse response = getRouteMonitoringClient()
          .getInvalidFailedReservations(routeId);
      List<Waypoint> rsvn = response.getPickupAppointments();
      List<Waypoint> parcels = response.getParcels();
      assertTrue("pickup appointment details is empty", rsvn.isEmpty());
      assertTrue("parcel details is empty", parcels.isEmpty());
    }, "get invalid failed reservation details", 30);
  }

  @Then("^Operator verifies waypoint details for \"([^\"]*)\" waypoint$")
  public void checkWaypointDetails(String waypointCase) {
    List<OrderRequestV4> transactionDetails = getListOfTransactionDetails();
    List<OrderRequestV4> reservationDetails = get(KEY_LIST_RESERVATION_REQUEST_DETAILS);
    Map<String, OrderRequestV4> requestMap = get(OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_REQUEST);
    callWithRetry(() -> {
      operatorFilterRouteMinitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      List<Waypoint> waypoints = result.getWaypoints();
      int expectedTotalWaypoints = get(KEY_TOTAL_EXPECTED_WAYPOINT);
      assertEquals("number of waypoints inside", expectedTotalWaypoints,
          result.getWaypoints().size());
      if (!transactionDetails.isEmpty()) {
        transactionDetails.forEach(e -> {
          OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
          Map<String, String> address;
          Waypoint waypoint = waypoints.stream()
              .filter(o -> o.getType().equalsIgnoreCase(WAYPOINT_TYPE_TRANSACTION))
              .filter(o -> o.getTrackingId().contains(e.getTrackingNumber())).findAny()
              .orElseThrow(() -> new NvTestRuntimeException("parcels details not found"));
          assertEquals("type", WAYPOINT_TYPE_TRANSACTION.toLowerCase(),
              waypoint.getType().toLowerCase());
          assertTrue("tracking id", waypoint.getTrackingId().contains(e.getTrackingNumber()));
          String startTime;
          String endTime;
          if (waypointCase.equalsIgnoreCase(WAYPOINT_TYPE_PENDING)) {
            assertEquals("status", "Routed", waypoint.getStatus());
            assertNull("service end time", waypoint.getServiceEndTime());
          } else {
            assertEquals("status", "Fail", waypoint.getStatus());
          }

          if (e.getServiceType().equalsIgnoreCase("RETURN")) {
            assertEquals("name", e.getFrom().getName().toLowerCase(),
                waypoint.getName().toLowerCase());
            assertEquals("contact", e.getFrom().getPhoneNumber(), waypoint.getContact());
            assertEquals("email", e.getFrom().getEmail().toLowerCase(),
                waypoint.getEmail().toLowerCase());
            address = temp.getFrom().getAddress();
            assertEquals("pickup status", "return", waypoint.getPickupStatus().toLowerCase());
            startTime = e.getParcelJob().getPickupTimeslot().getStartTime();
            endTime = e.getParcelJob().getPickupTimeslot().getEndTime();
          } else {
            assertEquals("name", e.getTo().getName().toLowerCase(),
                waypoint.getName().toLowerCase());
            assertEquals("contact", e.getTo().getPhoneNumber(), waypoint.getContact());
            assertEquals("email", e.getTo().getEmail().toLowerCase(),
                waypoint.getEmail().toLowerCase());
            address = temp.getTo().getAddress();
            assertNull("pickup status", waypoint.getPickupStatus());
            startTime = e.getParcelJob().getDeliveryTimeslot().getStartTime();
            endTime = e.getParcelJob().getDeliveryTimeslot().getEndTime();
          }
          assertEquals("address", createExpectedPendingAddress(address),
              waypoint.getAddress().toLowerCase());
          assertEquals("time window", getFormattedTimeslot(startTime, endTime),
              waypoint.getTimeWindow().toLowerCase());
          if (waypointCase.equalsIgnoreCase(WAYPOINT_TYPE_INVALID_FAILED)) {
            assertEquals("waypoint status", WAYPOINT_TYPE_INVALID_FAILED,
                waypoint.getWaypointStatus().toLowerCase());
            assertEquals("time status", TIMESLOT_TYPE_EARLY,
                waypoint.getTimeStatus().toLowerCase());
          } else {
            assertEquals("waypoint status", "pending", waypoint.getWaypointStatus().toLowerCase());
            assertNull("driver last seen", waypoint.getDriverLastSeen());
            assertNull("time status", waypoint.getTimeStatus());
          }

        });
      }
      if (reservationDetails != null) {
        reservationDetails.forEach(e -> {
          OrderRequestV4 temp = requestMap.get(e.getTrackingNumber());
          Map<String, String> address;
          Waypoint waypoint = waypoints.stream()
              .filter(o -> o.getType().equalsIgnoreCase(WAYPOINT_TYPE_RESERVATION))
              .filter(o -> o.getName().equalsIgnoreCase(e.getFrom().getName()))
              .findAny().orElseThrow(() -> new NvTestRuntimeException("parcels details not found"));

          assertEquals("type", WAYPOINT_TYPE_RESERVATION.toLowerCase(),
              waypoint.getType().toLowerCase());
          assertNull("tracking id", waypoint.getTrackingId());

          String startTime = e.getParcelJob().getPickupTimeslot().getStartTime();
          String endTime = e.getParcelJob().getPickupTimeslot().getEndTime();
          assertEquals("time window", getFormattedTimeslot(startTime, endTime),
              waypoint.getTimeWindow().toLowerCase());
          assertEquals("status", "Routed", waypoint.getStatus());
          assertNull("service end time", waypoint.getServiceEndTime());

          assertEquals("name", e.getFrom().getName().toLowerCase(),
              waypoint.getName().toLowerCase());
          assertEquals("contact", e.getFrom().getPhoneNumber(), waypoint.getContact());
          assertEquals("email", e.getFrom().getEmail().toLowerCase(),
              waypoint.getEmail().toLowerCase());

          address = temp.getFrom().getAddress();
          assertEquals("address", createExpectedPendingAddress(address),
              waypoint.getAddress().toLowerCase());
          assertNull("pickup status", waypoint.getPickupStatus());
          assertEquals("waypoint status", WAYPOINT_TYPE_RESERVATION.toLowerCase(),
              waypoint.getWaypointStatus().toLowerCase());

          assertNull("time status", waypoint.getTimeStatus());
          assertNull("driver last seen", waypoint.getDriverLastSeen());
        });
      }
    }, "check pending waypoint details", 30);
  }

  @When("^Operator verifies total pending priority parcels and other details$")
  public void checkPendingPriorityParcels(Map<String, Integer> source) {
    int totalExpectedCount = source.get(KEY_TOTAL_EXPECTED_PENDING_PRIORITY);
    callWithRetry(() -> {
      operatorFilterRouteMinitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      assertEquals("total pending priority parcels", totalExpectedCount,
          result.getPendingPriorityParcels());
      operatorChecksTotalParcelsCount(WAYPOINT_TYPE_PENDING, source);
    }, "check total pending priority parcels", 30);
  }

  @When("^Operator verifies total pending priority parcels is now 0$")
  public void excludeAttemptedPendingPriorityParcels() {
    callWithRetry(() -> {
      operatorFilterRouteMinitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      assertEquals("total pending priority parcels", 0, result.getPendingPriorityParcels());
    }, "check total pending priority parcels", 30);
  }

  @When("^Operator verifies total invalid failed is 0 and other details$")
  public void totalEmptyInvalidFailed(Map<String, Integer> waypointCounts) {
    callWithRetry(() -> {
      operatorFilterRouteMinitoring();
      RouteMonitoringResponse result = get(KEY_ROUTE_MONITORING_RESULT);
      assertEquals("total invalid failed", 0, result.getNumInvalidFailed());
      operatorChecksTotalParcelsCount(WAYPOINT_TYPE_INVALID_FAILED, waypointCounts);
    }, "check total invalid failed", 30);
  }

  private List<OrderRequestV4> getListOfTransactionDetails() {
    List<OrderRequestV4> requestedOrderDetails = get(
        OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    List<String> reservationTrackingIds = get(
        ReservationSteps.KEY_LIST_OF_RESERVATION_TRACKING_IDS);
    List<String> pullOutTrackingIds = get(RoutingSteps.KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID);
    if (reservationTrackingIds != null) {
      reservationTrackingIds.forEach(e -> putInList(KEY_LIST_RESERVATION_REQUEST_DETAILS,
          requestedOrderDetails.stream().filter(o -> o.getTrackingNumber().equalsIgnoreCase(e))
              .findAny().get()));
      List<OrderRequestV4> reservationDetails = get(KEY_LIST_RESERVATION_REQUEST_DETAILS);
      //to exclude reservation tracking ids (if any) as transaction tracking ids
      reservationDetails.forEach(e -> requestedOrderDetails.remove(e));
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
        OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    List<String> priorTrackingIds = get(OrderActionSteps.KEY_LIST_OF_PRIOR_TRACKING_IDS);
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
    assertEquals("driver name", TestConstants.ROUTE_MONITORING_DRIVER_NAME.toLowerCase(),
        result.getDriverName().toLowerCase());
    assertEquals("hub name", TestConstants.SORTING_HUB_NAME.toLowerCase(),
        result.getHubName().toLowerCase());
    assertEquals("zone name", TestConstants.ZONE_NAME.toLowerCase(),
        result.getZoneName().toLowerCase());
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
    assertEquals(String.format("total success waypoints for route id %d", routeId), 0,
        result.getNumSuccess());
    assertEquals(String.format("total valid failed waypoints for route id %d", routeId),
        totalExpectedValidFailed, result.getNumValidFailed());
    assertEquals(String.format("total invalid failed waypoints for route id %d", routeId), 0,
        result.getNumInvalidFailed());
    assertEquals(String.format("total early waypoints for route id %d", routeId),
        totalExpectedEarlyWaypoint, result.getNumEarlyWp());
    assertEquals(String.format("total late waypoints for route id %d", routeId), 0,
        result.getNumLateWp());
    assertEquals(String.format("total impending waypoints for route id %d", routeId), 0,
        result.getNumImpending());
    assertEquals(String.format("total late and pending waypoints for route id %d", routeId), 0,
        result.getNumLateAndPending());
    assertEquals(String.format("completion precentage", routeId), 0.0,
        result.getCompletionPercentage());
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
