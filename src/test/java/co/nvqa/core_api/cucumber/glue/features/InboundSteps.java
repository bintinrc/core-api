package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.GlobalInboundRequest;
import co.nvqa.commons.model.core.GlobalInboundResponse;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.java.en.Then;
import io.cucumber.guice.ScenarioScoped;

import java.util.List;

/**
 * @author Binti Cahayati on 2020-07-04
 */
@ScenarioScoped
public class InboundSteps extends BaseSteps {

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
}
