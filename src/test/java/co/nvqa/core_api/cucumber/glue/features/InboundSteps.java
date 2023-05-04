package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.utils.CoreScenarioStorageKeys;
import co.nvqa.commonsort.model.GlobalInboundRequest;
import co.nvqa.commonsort.model.GlobalInboundRequest.Dimension;
import co.nvqa.commonsort.model.GlobalInboundResponse;
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

  @Override
  public void init() {
  }

  @Then("Operator perform global inbound at hub {string}")
  public void globalInbound(String hubInboundId) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Long hubId = Long.valueOf(hubInboundId);
    callWithRetry(() -> {
      GlobalInboundRequest request = new GlobalInboundRequest();
      request.setInboundType("SORTING_HUB");
      request.setScan(trackingId);
      request.setHubId(hubId);
      GlobalInboundResponse response = getInboundClient().doGlobalInbound(request);
      Assertions.assertThat(response.getStatus()).as("status is SUCCESSFUL_INBOUND")
          .isEqualTo("SUCCESSFUL_INBOUND");
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

  @Given("Operator global inbound at hub {string} for tid {string} with changes in dimensions")
  public void globalInbound(String hubId, String trackingId, Map<String, String> dimensions) {
    callWithRetry(() -> {
      GlobalInboundRequest request = new GlobalInboundRequest();
      request.setInboundType("SORTING_HUB");
      request.setScan(resolveValue(trackingId));
      request.setHubId(Long.valueOf(hubId));

      final String json = toJsonSnakeCase(dimensions);
      final GlobalInboundRequest.Dimension dimension = fromJsonSnakeCase(json, Dimension.class);
      request.setDimensions(dimension);
      put(CoreScenarioStorageKeys.KEY_SAVED_ORDER_WEIGHT, dimension.getWeight());
      put(KEY_DIMENSION_CHANGES_REQUEST, dimension);
      GlobalInboundResponse response = getInboundClient().doGlobalInbound(request);
      Assertions.assertThat(response.getStatus()).as("status is SUCCESSFUL_INBOUND")
          .isEqualTo("SUCCESSFUL_INBOUND");
    }, "operator global inbound with changes in dimensions");
  }
}
