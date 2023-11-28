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

  @Given("API Operator cancel order with PUT \\/orders\\/:orderId\\/cancel")
  public void apiOperatorCancelCreatedOrder(Map<String, String> source) {
    long orderId = get(KEY_CREATED_ORDER_ID);
    String reason = source.get("reason");
    getOrderClient().cancelOrderV1(orderId, reason);
    put(KEY_CANCELLATION_REASON, f("Cancellation reason : %s", reason));
  }

  @Given("API Operator cancel order with DELETE \\/2.2\\/orders\\/:trackingNumber")
  public void apiOperatorCancelOrderV3() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    getShipperOrderClient(shipperToken).cancelOrderV3(trackingId);
    put(KEY_CANCELLATION_REASON, "Cancellation reason : API CANCELLATION REQUEST");
  }

  @When("Operator failed to cancel invalid status with PUT \\/orders\\/:orderId\\/cancel")
  public void operatorCancelV1() {
    long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient().cancelOrderV1AndGetRawResponse(orderId, "invalid cancel");
    put(KEY_API_RAW_RESPONSE, r);
  }


  @When("Operator failed to cancel invalid status with DELETE \\/2.2\\/orders\\/:trackingNumber")
  public void operatorCancelInvalidV3() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    Response r = getShipperOrderClient(shipperToken).cancelOrderV3AndGetRawResponse(trackingId);
    put(KEY_API_RAW_RESPONSE, r);
  }

}
