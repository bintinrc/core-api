package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.model.pickup.Pickup;
import co.nvqa.common.core.model.pickup.PickupSearchRequest;
import co.nvqa.common.core.model.route.RouteResponse;
import co.nvqa.common.model.address.Address;
import co.nvqa.common.utils.DateUtil;
import co.nvqa.common.utils.JsonUtils;
import co.nvqa.common.utils.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.assertj.core.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class ReservationSteps extends BaseSteps {


  private static final String DOMAIN = "RESERVATION-STEPS";
  private static final String ACTION_FAIL = "fail";
  private static final Logger LOGGER = LoggerFactory.getLogger(ReservationSteps.class);

  @Override
  public void init() {

  }

  @Given("Operator Search for Created Pickup for Shipper {string} with status {string}")
  public void operatorSearchForCreatedPickupForShipperWithStatus(String legacyId, String status) {
    searchPickup(Long.parseLong(legacyId), status);
  }

  @And("Operator search for all reservations for shipper legacy id {long}")
  public void operatorSearchAllReservation(Long legacyId) {
    List<String> addresses = get(KEY_LIST_OF_PICKUP_ADDRESS_STRING);
    addresses.forEach(e -> {
      put(KEY_PICKUP_ADDRESS_STRING, e);
      searchPickup(legacyId, "Pending");
    });
  }

  @And("Operator verify that reservation id {string} status is {string}")
  public void operatorRouteReservation(String reservationId, String status) {
    doWithRetry(() -> {
      PickupSearchRequest request = new PickupSearchRequest();
      request.setReservationIds(
          Collections.singletonList(Long.parseLong(resolveValue(reservationId))));
      List<Pickup> result = getShipperPickupClient().searchPickupsWithFilters(request);
      Assertions.assertThat(result.size()).as("reservation is not empty")
          .isEqualTo(1);
      final Pickup pickup = result.get(0);
      put(KEY_WAYPOINT_ID, pickup.getWaypointId());
      Assertions.assertThat(pickup.getStatus())
          .as(String.format("reservation status id %d", pickup.getReservationId()))
          .isEqualToIgnoringCase(status);
    }, "operator verify reservation status", 2000, 50);
  }

  @When("Operator search for created DP reservation with status {string}")
  public void operatorSearchCreatedDpReservation(String status) {
    Long addressId = TestConstants.DEFAULT_DP_ADDRESS_ID;
    Long shipperId = TestConstants.DEFAULT_DP_SHIPPER_ID;
    Long shipperLegacyId = get(KEY_DP_SHIPPER_LEGACY_ID);
    Address address = getShipperClient().readAddress(shipperId, addressId);
    String pickupAddress = address.getAddress1() + " " + address.getAddress2();
    put(KEY_PICKUP_ADDRESS_STRING, pickupAddress);
    searchPickup(shipperLegacyId, status);
  }

  @And("Operator Route the Reservation Pickup")
  public void operatorRouteReservation() {
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    Long reservationId = pickup.getReservationId();
    RouteResponse route = get(KEY_CREATED_ROUTE);
    Long routeId = route.getId();
    doWithRetry(() -> {
      getReservationV2Client().addReservationToRoute(routeId, reservationId);
      put(KEY_WAYPOINT_ID, pickup.getWaypointId());
    }, "operator route the reservation");
  }

  @And("Operator Route All Reservation Pickups")
  public void operatorRouteAllReservations() {
    List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
    pickups.forEach(e -> {
      put(KEY_CREATED_RESERVATION, e);
      operatorRouteReservation();
    });
  }


  @And("Operator Pull Reservation Out of Route")
  public void operatorPullReservationRoute() {
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    RouteResponse route = get(KEY_CREATED_ROUTE);
    long routeId = route.getId();
    doWithRetry(() -> {
      getReservationV2Client().pullReservationOutOfRoute(reservationId);
    }, "operator pull out reservation route");
  }

  @When("Operator admin manifest force {string} reservation")
  public void operatorForceFinishReservation(String action) {
    Long waypointId = get(KEY_WAYPOINT_ID);
    Long routeId = get(KEY_CREATED_ROUTE_ID);
    doWithRetry(() -> {
      if (action.equalsIgnoreCase(ACTION_FAIL)) {
        getRouteClient().forceFailWaypoint(routeId, waypointId, TestConstants.FAILURE_REASON_ID);
      } else {
        getRouteClient().forceSuccessWaypoint(routeId, waypointId);
      }
      Pickup pickup = get(KEY_CREATED_RESERVATION);
      searchPickup(pickup.getShipperId(), action);
      LOGGER.info(DOMAIN + String.format("waypoint id %d force failed", waypointId));
    }, "admin force finish reservation");
  }

  private void operatorForceFailInvalidReservation() {
    Long waypointId = get(KEY_WAYPOINT_ID);
    Long routeId = get(KEY_CREATED_ROUTE_ID);
    doWithRetry(() -> {
      getRouteClient().forceFailWaypoint(routeId, waypointId,
          TestConstants.RESERVATION_FAILURE_REASON_ID);
      LOGGER.info(DOMAIN + String.format("waypoint id %d force failed", waypointId));
    }, "admin force finish reservation");
  }

  @When("Operator admin manifest force fail reservation with valid reason")
  public void operatorForceFailValidReservation() {
    Long waypointId = get(KEY_WAYPOINT_ID);
    Long routeId = get(KEY_CREATED_ROUTE_ID);
    doWithRetry(() -> {
      getRouteClient().forceFailWaypoint(routeId, waypointId,
          TestConstants.RESERVATION_VALID_FAILURE_REASON_ID);
      LOGGER.info(DOMAIN + String.format("waypoint id %d force failed", waypointId));
    }, "admin force finish reservation");
  }

  @When("Operator admin manifest force fail all reservations with invalid reason")
  public void operatorForceFailInvalidAllReservation() {
    List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    waypointIds.forEach(e -> {
      put(KEY_WAYPOINT_ID, e);
      operatorForceFailInvalidReservation();
    });
  }

  private void searchPickup(Long legacyId, String status) {
    String pickupAddress = get(KEY_PICKUP_ADDRESS_STRING);
    put(KEY_INITIAL_RESERVATION_ADDRESS, pickupAddress);
    ZonedDateTime startDateTime = DateUtil.getStartOfDay(DateUtil.getDate());

    final ZonedDateTime endDateTime = startDateTime.plusDays(3L).minusSeconds(1L);

    final String fromDateTime = DateUtil.displayDateTime(
        startDateTime.withZoneSameInstant(ZoneId.of("UTC")));
    final String toDateTime = DateUtil.displayDateTime(
        endDateTime.withZoneSameInstant(ZoneId.of("UTC")));

    final Map<String, Object> param = new HashMap<>();
    param.put("from_datetime", fromDateTime);
    param.put("to_datetime", toDateTime);
    param.put("max_result", 1000);
    param.put("shipper_ids", Collections.singletonList(legacyId));
    param.put("waypoint_status", Collections.singletonList(status));
    PickupSearchRequest request = JsonUtils.fromMapSnakeCase(param, PickupSearchRequest.class);

    doWithRetry(() -> {
      LOGGER.info("Try to find reservation with address2: {}", pickupAddress);
      pause2s();
      List<Pickup> pickups = getShipperPickupClient().searchPickupsWithFilters(request);
      Pickup pickup = pickups.stream()
          .filter(e -> (e.getAddress1() + " " + e.getAddress2()).equalsIgnoreCase(pickupAddress))
          .findAny().orElseThrow(() -> new NvTestRuntimeException("reservation details not found"));
      LOGGER.info("reservation id {} found", pickup.getReservationId());
      put(KEY_CREATED_RESERVATION, pickup);
      String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      putInList(KEY_LIST_OF_CREATED_RESERVATIONS, pickup);
      putInList(KEY_LIST_OF_RESERVATION_TRACKING_IDS, trackingId);
      put(KEY_WAYPOINT_ID, pickup.getWaypointId());
      putInList(KEY_LIST_OF_WAYPOINT_IDS, pickup.getWaypointId());
    }, f("search reservation with status %s", status));
  }
}
