package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Dimension;
import co.nvqa.commons.model.core.GlobalInboundRequest;
import co.nvqa.commons.model.core.GlobalInboundResponse;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.guice.ScenarioScoped;

import java.util.List;
import java.util.Map;
import java.util.stream.DoubleStream;
import org.assertj.core.api.Assertions;

/**
 * @author Binti Cahayati on 2020-07-04
 */
@ScenarioScoped
public class InboundSteps extends BaseSteps {

  private static final String KEY_INBOUND_DIMENSION_REQUEST = "KEY_INBOUND_DIMENSION_REQUEST";

  @Override
  public void init() {
  }

  @Then("^Operator perform global inbound for created order at hub \"([^\"]*)\"$")
  public void globalInbound(long hubId) {
    callWithRetry(() -> {
      String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      GlobalInboundResponse response = getInboundClient().globalInbound(
          new GlobalInboundRequest(trackingId, GlobalInboundRequest.TYPE_SORTING_HUB, hubId));
      assertEquals("status", "SUCCESSFUL_INBOUND", response.getStatus());
    }, "operator global inbound");
  }

  @Then("^Operator inbounds all orders at hub \"([^\"]*)\"$")
  public void globalInboundMultipleOrders(long hubId) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      globalInbound(hubId);
    });
  }

  @Given("Operator global inbound at hub {string} with changes in dimensions")
  public void globalInbound(String hubId, Map<String, Double> dimensions) {
    callWithRetry(() -> {
      String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      GlobalInboundRequest request = new GlobalInboundRequest(trackingId,
          GlobalInboundRequest.TYPE_SORTING_HUB, Long.valueOf(hubId));
      final String json = toJsonSnakeCase(dimensions);
      final Dimension dimension = fromJsonSnakeCase(json, Dimension.class);
      request.setDimensions(dimension);
      put(KEY_INBOUND_DIMENSION_REQUEST, dimension);
      GlobalInboundResponse response = getInboundClient().globalInbound(request);
      assertEquals("status", "SUCCESSFUL_INBOUND", response.getStatus());
    }, "operator global inbound with changes in dimensions");
  }

  @Given("Operator verifies orders.weight is updated to highest weight correctly")
  public void operatorVerifiesUpdatedWeight() {
    final Dimension dimension = get(KEY_INBOUND_DIMENSION_REQUEST);
    final OrderRequestV4 order = get(KEY_ORDER_CREATE_REQUEST);
    final Double actualWeight = get(KEY_UPDATED_ORDER_WEIGHT);
    double volumetricWeight =
        (dimension.getLength() * dimension.getWidth() * dimension.getHeight()) / 6000;
    double shipperAdjustedWeight =
        (Math.floor(order.getParcelJob().getDimensions().getWeight() / 100)) / 10;
    double measuredWeight = dimension.getWeight();
    double expectedWeight = DoubleStream.of(shipperAdjustedWeight, measuredWeight, volumetricWeight)
        .max()
        .getAsDouble();

    Assertions.assertThat(actualWeight).as("orders.weight equal highest weight")
        .isEqualTo(expectedWeight);
  }
}
