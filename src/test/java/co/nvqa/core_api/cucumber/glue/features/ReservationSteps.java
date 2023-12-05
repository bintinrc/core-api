package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.model.pickup.Pickup;
import co.nvqa.common.core.model.pickup.PickupSearchRequest;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.exception.NvTestCoreReservationException;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.And;
import java.util.Collections;
import java.util.List;
import org.assertj.core.api.Assertions;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class ReservationSteps extends BaseSteps {

  @Override
  public void init() {

  }

  @And("Operator verify that reservation id {string} status is {string}")
  public void operatorRouteReservation(String reservationId, String status) {
    doWithRetry(() -> {
      try {
        PickupSearchRequest request = new PickupSearchRequest();
        request.setReservationIds(
            Collections.singletonList(Long.parseLong(resolveValue(reservationId))));
        List<Pickup> result = getShipperPickupClient().searchPickupsWithFilters(request);
        Assertions.assertThat(result).as("reservation is not empty")
            .hasSize(1);
        final Pickup pickup = result.get(0);
        put(KEY_WAYPOINT_ID, pickup.getWaypointId());
        Assertions.assertThat(pickup.getStatus())
            .as(String.format("reservation status id %d", pickup.getReservationId()))
            .isEqualToIgnoringCase(status);
      } catch (Exception e) {
        throw new NvTestCoreReservationException("Reservation status not updated due to Kafka ", e);
      }
    }, "operator verify reservation status");
  }
}
