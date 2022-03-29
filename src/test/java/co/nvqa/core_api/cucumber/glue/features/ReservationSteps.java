package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Address;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.cucumber.guice.ScenarioScoped;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class ReservationSteps extends BaseSteps {

  public static final String KEY_LIST_OF_RESERVATION_TRACKING_IDS = "key-list-of-reservation-tracking-ids";
  private static final String DOMAIN = "RESERVATION-STEPS";
  private static final String ACTION_FAIL = "fail";
  private static final String KEY_INITIAL_RESERVATION_ADDRESS = "key-initial-reservation-address";

  @Override
  public void init() {

  }

  @Given("^Operator Search for Created Pickup for Shipper \"([^\"]*)\" with status \"([^\"]*)\"$")
  public void searchPickup(long legacyId, String status) {
    String pickupAddress = get(KEY_PICKUP_ADDRESS_STRING);
    put(KEY_INITIAL_RESERVATION_ADDRESS, pickupAddress);
    ZonedDateTime startDateTime = DateUtil.getStartOfDay(DateUtil.getDate());

    final ZonedDateTime endDateTime = startDateTime.plusDays(3L)
        .minusSeconds(1L);

    final String fromDateTime = DateUtil
        .displayDateTime(startDateTime.withZoneSameInstant(ZoneId.of("UTC")));
    final String toDateTime = DateUtil
        .displayDateTime(endDateTime.withZoneSameInstant(ZoneId.of("UTC")));

    final Map<String, Object> param = new HashMap<>();
    param.put("from_datetime", fromDateTime);
    param.put("to_datetime", toDateTime);
    param.put("max_result", 1000);
    param.put("shipper_ids", Collections.singletonList(legacyId));
    param.put("waypoint_status", Collections.singletonList(status));

    callWithRetry(() -> {
      NvLogger.infof("Try to find reservation with address2: %s", pickupAddress);
      doStepPause();
      List<Pickup> pickups = getShipperPickupClient().search(param);
      Pickup pickup = pickups.stream().
          filter(e -> (e.getAddress1() + " " + e.getAddress2())
              .equalsIgnoreCase(pickupAddress))
          .findAny().orElseThrow(() -> new NvTestRuntimeException("reservation details not found"));
      NvLogger.successf("reservation id %d found", pickup.getId());
      put(KEY_CREATED_RESERVATION, pickup);
      String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      putInList(KEY_LIST_OF_CREATED_RESERVATIONS, pickup);
      putInList(KEY_LIST_OF_RESERVATION_TRACKING_IDS, trackingId);
      put(KEY_WAYPOINT_ID, pickup.getWaypointId());
      putInList(KEY_LIST_OF_WAYPOINT_IDS, pickup.getWaypointId());
    }, String.format("search reservation with status %s", status), 30);
  }

  @And("^Operator search for all reservations for shipper legacy id \"([^\"]*)\"$")
  public void operatorSearchAllReservation(long legacyId) {
    List<String> addresses = get(OrderCreateSteps.KEY_LIST_OF_PICKUP_ADDRESS_STRING);
    addresses.forEach(e -> {
      put(KEY_PICKUP_ADDRESS_STRING, e);
      searchPickup(legacyId, "PENDING");
    });
  }

  @And("^Operator verify that reservation status is \"([^\"]*)\"$")
  public void operatorRouteReservation(String status) {
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    String pickupAddress = get(KEY_INITIAL_RESERVATION_ADDRESS);
    put(KEY_PICKUP_ADDRESS_STRING, pickupAddress);
    callWithRetry(() -> {
      searchPickup(pickup.getShipperId(), status);
      Pickup result = get(KEY_CREATED_RESERVATION);
      assertEquals(String.format("reservation status id %d", result.getId()), status.toLowerCase(),
          result.getStatus().toLowerCase());
    }, "operator verify reservation status");
  }

  @When("^Operator search for created DP reservation with status \"([^\"]*)\"$")
  public void operatorSearchCreatedDpReservation(String status) {
    long addressId = TestConstants.DEFAULT_DP_ADDRESS_ID;
    long shipperId = TestConstants.DEFAULT_DP_SHIPPER_ID;
    long shipperLegacyId = get(DpSteps.KEY_DP_SHIPPER_LEGACY_ID);
    Address address = getShipperClient().readAddress(shipperId, addressId);
    String pickupAddress = address.getAddress1() + " " + address.getAddress2();
    put(KEY_PICKUP_ADDRESS_STRING, pickupAddress);
    searchPickup(shipperLegacyId, status);
  }

  @And("Operator Route the Reservation Pickup")
  public void operatorRouteReservation() {
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    Route route = get(KEY_CREATED_ROUTE);
    long routeId = route.getId();
    callWithRetry(() -> {
      getReservationV2Client().addReservationToRoute(routeId, reservationId);
      NvLogger.success(DOMAIN,
          String.format("reservation id %d added to route id %d", reservationId, routeId));
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


  @And("^Operator Pull Reservation Out of Route$")
  public void operatorPullReservationRoute() {
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getId();
    Route route = get(KEY_CREATED_ROUTE);
    long routeId = route.getId();
    callWithRetry(() -> {
      getReservationV2Client().pullReservationOutOfRoute(reservationId);
    }, "operator pull out reservation route");
  }

  @When("^Operator admin manifest force \"([^\"]*)\" reservation$")
  public void operatorForceFinishReservation(String action) {
    long waypointId = get(KEY_WAYPOINT_ID);
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      if (action.equalsIgnoreCase(ACTION_FAIL)) {
        getOrderClient().forceFailWaypoint(routeId, waypointId, TestConstants.FAILURE_REASON_ID);
      } else {
        getOrderClient().forceSuccessWaypoint(routeId, waypointId);
      }
      Pickup pickup = get(KEY_CREATED_RESERVATION);
      searchPickup(pickup.getShipperId(), action);
      NvLogger.success(DOMAIN, String.format("waypoint id %d force failed", waypointId));
    }, "admin force finish reservation");
  }

  @When("^Operator admin manifest force fail reservation with invalid reason$")
  public void operatorForceFailInvalidReservation() {
    long waypointId = get(KEY_WAYPOINT_ID);
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      getOrderClient()
          .forceFailWaypoint(routeId, waypointId, TestConstants.RESERVATION_FAILURE_REASON_ID);
      NvLogger.success(DOMAIN, String.format("waypoint id %d force failed", waypointId));
    }, "admin force finish reservation");
  }

  @When("^Operator admin manifest force fail reservation with valid reason$")
  public void operatorForceFailValidReservation() {
    long waypointId = get(KEY_WAYPOINT_ID);
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      getOrderClient().forceFailWaypoint(routeId, waypointId,
          TestConstants.RESERVATION_VALID_FAILURE_REASON_ID);
      NvLogger.success(DOMAIN, String.format("waypoint id %d force failed", waypointId));
    }, "admin force finish reservation");
  }

  @When("^Operator admin manifest force fail all reservations with invalid reason$")
  public void operatorForceFailInvalidAllReservation() {
    List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    waypointIds.forEach(e -> {
      put(KEY_WAYPOINT_ID, e);
      operatorForceFailInvalidReservation();
    });
  }

  @After("@DeleteReservationAndAddress")
  public void deleteReservationAndAddressIfAny() {
    try {
      List<Pickup> pickups = get(KEY_LIST_OF_CREATED_RESERVATIONS);
      if (pickups == null) {
        NvLogger.warn("No Reservations to clear");
        return;
      }
      //clear reservations
      pickups.forEach(e -> {
        getReservationV2Client().deleteReservation(e.getId(), e.getShipperId());
        put(KEY_SHIPPER_OWNER_LEGACY_ID, e.getShipperId());
      });
      // clear addresses
      long shipperLegacyId = get(KEY_SHIPPER_OWNER_LEGACY_ID);
      long shipperGlobalId = getShipperClient().getNewShipperIdByLegacyId(shipperLegacyId).getId();
      long defaultDpAddressId = TestConstants.DEFAULT_DP_ADDRESS_ID;
      List<Address> addresses = getShipperClient().readAllAddresses(shipperGlobalId);
      addresses.stream().filter(e -> e.getId() != defaultDpAddressId)
          .forEach(address -> {
            try {
              NvLogger.infof("try to delete address: %d", address.getId());
              getShipperClient().deleteAddress(shipperGlobalId, address.getId());
              NvLogger.successf("address deleted successfully: %d", address.getId());
            } catch (Exception | AssertionError e) {
              NvLogger.warnf("failed to delete address: %d caused of %s", address.getId(),
                  e.getMessage());
            }
          });
    } catch (Throwable t) {
      NvLogger.warnf("Failed to clear any reservation and/or address due to: %s", t.getMessage());
    }
  }
}
