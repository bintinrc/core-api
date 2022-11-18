package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Dimension;
import co.nvqa.commons.model.core.GlobalInboundRequest;
import co.nvqa.commons.model.core.GlobalInboundResponse;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import java.util.List;
import java.util.Map;
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

  @Then("Operator perform global inbound at hub {string}")
  public void globalInbound(String hubInboundId) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Long hubId = Long.valueOf(hubInboundId);
    callWithRetry(() -> {
      GlobalInboundResponse response = getInboundClient().globalInbound(
          new GlobalInboundRequest(trackingId, GlobalInboundRequest.TYPE_SORTING_HUB, hubId));
      Assertions.assertThat(response.getStatus()).as("status").isEqualTo("SUCCESSFUL_INBOUND");
    }, "operator global inbound");
  }

  @Then("Operator inbounds all orders at hub {string}")
  public void globalInboundMultipleOrders(String hubId) {
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
      put(KEY_EXPECTED_NEW_WEIGHT, dimension.getWeight());
      put(KEY_INBOUND_DIMENSION_REQUEST, dimension);
      GlobalInboundResponse response = getInboundClient().globalInbound(request);
      Assertions.assertThat(response.getStatus()).as("status").isEqualTo("SUCCESSFUL_INBOUND");
    }, "operator global inbound with changes in dimensions");
  }
}
