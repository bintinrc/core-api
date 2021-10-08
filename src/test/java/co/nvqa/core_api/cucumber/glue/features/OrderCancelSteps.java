package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.util.Map;

/**
 * @author Binti Cahayati on 2021-10-08
 */
@ScenarioScoped
public class OrderCancelSteps extends BaseSteps {

  @Override
  public void init() {

  }

  @Given("^API Operator cancel order with PUT /orders/:orderId/cancel$")
  public void apiOperatorCancelCreatedOrder(Map<String, String> source) {
    long orderId = get(KEY_CREATED_ORDER_ID);
    String reason = source.get("reason");
    getOrderClient().cancelOrderV1(orderId, reason);
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(KEY_CANCELLATION_REASON, f("Cancellation reason : %s", reason));
  }

  @When("^Operator failed to cancel invalid status with PUT /orders/:orderId/cancel$")
  public void operatorCancelV1() {
    long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient().cancelOrderV1AndGetRawResponse(orderId, "invalid cancel");
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(OrderActionSteps.KEY_API_RAW_RESPONSE, r);
  }
}
