package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Address;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import cucumber.api.java.After;
import cucumber.api.java.en.And;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class ReservationSteps extends BaseSteps {
    private static final String DOMAIN = "RESERVATION-STEPS";
    private static final String ACTION_FAIL = "fail";

    @Override
    public void init(){

    }

    @Given("Operator Search for Created Pickup for Shipper \"([^\"]*)\" with status \"([^\"]*)\"$")
    public void searchPickup(long legacyId, String status) {
        String pickupAddress = get(KEY_PICKUP_ADDRESS_STRING);
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

        callWithRetry(()->{
            NvLogger.infof("Try to find reservation with address2: %s", pickupAddress);
            doStepPause();
            List<Pickup> pickups = getShipperPickupClient().search(param);
            try {
                Pickup pickup = pickups.stream().filter(e -> e.getAddress2().toLowerCase().contains(pickupAddress.toLowerCase())).findAny().get();
                NvLogger.successf("reservation id %d found", pickup.getId());
                put(KEY_CREATED_RESERVATION, pickup);
                putInList(KEY_LIST_OF_CREATED_RESERVATIONS, pickup);
                put(KEY_WAYPOINT_ID, pickup.getWaypointId());
            } catch (RuntimeException ex) {
                throw new AssertionError(ex);
            }
        },String.format("search reservation with status %s", status));
    }

    @And("Operator Route the Reservation Pickup")
    public void operatorRouteReservation() {
        Pickup pickup = get(KEY_CREATED_RESERVATION);
        long reservationId = pickup.getId();
        Route route = get(KEY_CREATED_ROUTE);
        long routeId = route.getId();
        callWithRetry( () -> {
            getReservationV2Client().addReservationToRoute(routeId, reservationId);
            NvLogger.success(DOMAIN, String.format("reservation id %d added to route id %d", reservationId, routeId));
            put(KEY_WAYPOINT_ID, pickup.getWaypointId());
        },"operator route the reservation");
    }

    @When("^Operator force finish \"([^\"]*)\" reservation$")
    public void operatorForceFinishReservation(String action){
        long waypointId = get(KEY_WAYPOINT_ID);
        long routeId = get(KEY_CREATED_ROUTE_ID);
        callWithRetry( () -> {
            if(action.equalsIgnoreCase(ACTION_FAIL)){
                getOrderClient().forceFailWaypoint(routeId, waypointId, TestConstants.FAILURE_REASON_ID);
            } else {
                getOrderClient().forceSuccessWaypoint(routeId, waypointId);
            }
            NvLogger.success(DOMAIN, String.format("waypoint id %d force failed", waypointId));
        }, "admin force finish reservation");
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
            pickups.forEach( e -> {
                getReservationV2Client().deleteReservation(e.getId(), e.getShipperId());
                put(KEY_SHIPPER_OWNER_LEGACY_ID, e.getShipperId());
            });
            // clear addresses
            long shipperLegacyId = get(KEY_SHIPPER_OWNER_LEGACY_ID);
            long shipperGlobalId = getShipperClient().getNewShipperIdByLegacyId(shipperLegacyId).getId();
            List<Address> addresses = getShipperClient().readAllAddresses(shipperGlobalId);
            addresses.forEach(address -> {
                try {
                    NvLogger.infof("try to delete address: %d", address.getId());
                    getShipperClient().deleteAddress(shipperGlobalId, address.getId());
                    NvLogger.successf("address deleted successfully: %d", address.getId());
                } catch (Exception | AssertionError e) {
                    NvLogger.warnf("failed to delete address: %d caused of %s", address.getId(), e.getMessage());
                }
            });
        } catch (Throwable t) {
            NvLogger.warnf("Failed to clear any reservation and/or address due to: %s", t.getMessage());
        }
    }
}
