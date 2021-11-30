package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.CancelOrder;
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

  @Given("^API Operator cancel order with DELETE /2.0/orders/:uuid$")
  public void apiOperatorCancelOrderV2() {
    String asyncHandle = get(KEY_CREATED_ORDER_ASYNC_ID);
    getOrderClient().cancelOrderV2(asyncHandle);
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(KEY_CANCELLATION_REASON, "Cancellation reason : API CANCELLATION REQUEST");
  }

  @Given("^API Operator cancel order with DELETE /2.2/orders/:trackingNumber$")
  public void apiOperatorCancelOrderV3() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    getShipperOrderClient(shipperToken).cancelOrderV3(trackingId);
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(KEY_CANCELLATION_REASON, "Cancellation reason : API CANCELLATION REQUEST");
  }

  @Given("^API Operator cancel order with DELETE /orders/cancel by TID$")
  public void apiOperatorCancelOrderV4byTid(Map<String, String> source) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    String reason = source.get("reason");
    CancelOrder request = new CancelOrder();
    request.setComments(reason);
    request.setTrackingId(trackingId);
    CancelOrder response = getShipperOrderClient(shipperToken).cancelOrderV4(request);
    assertEquals("cancelled orders size", 1, response.getCancelledOrders().size());
    assertEquals("cancelled Orders tracking id equals", trackingId,
        response.getCancelledOrders().get(0).getTrackingId());
    assertEquals("un-cancelled orders size", 0, response.getUnCancelledOrders().size());
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(KEY_CANCELLATION_REASON, f("Cancellation reason : %s", reason));
  }

  @Given("^API Operator cancel order with DELETE /orders/cancel by UUID$")
  public void apiOperatorCancelOrderV4byUuid(Map<String, String> source) {
    String asyncHandle = get(KEY_CREATED_ORDER_ASYNC_ID);
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    String reason = source.get("reason");
    CancelOrder request = new CancelOrder();
    request.setComments(reason);
    request.setUuid(asyncHandle);
    CancelOrder response = getShipperOrderClient(shipperToken).cancelOrderV4(request);
    assertEquals("cancelled orders size", 1, response.getCancelledOrders().size());
    assertEquals("cancelled Orders tracking id equals", trackingId,
        response.getCancelledOrders().get(0).getTrackingId());
    assertEquals("un-cancelled orders size", 0, response.getUnCancelledOrders().size());
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

  @When("^Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid$")
  public void operatorCancelInvalidV2() {
    String asyncHandle = get(KEY_CREATED_ORDER_ASYNC_ID);
    Response r = getOrderClient().cancelOrderV2AndGetRawResponse(asyncHandle);
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(OrderActionSteps.KEY_API_RAW_RESPONSE, r);
  }

  @When("^Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber$")
  public void operatorCancelInvalidV3() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    Response r = getShipperOrderClient(shipperToken).cancelOrderV3AndGetRawResponse(trackingId);
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(OrderActionSteps.KEY_API_RAW_RESPONSE, r);
  }

  @Given("^Operator failed to cancel order with DELETE /orders/cancel by TID$")
  public void invalidCancelOrderV4byTid() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    CancelOrder request = new CancelOrder();
    request.setComments("invalid cancel order status");
    request.setTrackingId(trackingId);
    CancelOrder response = getShipperOrderClient(shipperToken).cancelOrderV4(request);
    assertEquals("cancelled orders size", 0, response.getCancelledOrders().size());
    assertEquals("un-cancelled orders size", 1, response.getUnCancelledOrders().size());
    assertEquals("un-cancelled Orders tracking id equals", trackingId,
        response.getUnCancelledOrders().get(0).getTrackingId());
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(KEY_CANCELLATION_REASON, f("Cancellation reason : %s", "invalid cancel order status"));
  }

  @Given("^Operator failed to cancel order with DELETE /orders/cancel by UUID$")
  public void invalidCancelOrderV4byUuid() {
    String asyncHandle = get(KEY_CREATED_ORDER_ASYNC_ID);
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    String shipperToken = get(KEY_SHIPPER_V4_ACCESS_TOKEN);
    CancelOrder request = new CancelOrder();
    request.setComments("invalid cancel order status");
    request.setUuid(asyncHandle);
    CancelOrder response = getShipperOrderClient(shipperToken).cancelOrderV4(request);
    assertEquals("cancelled orders size", 0, response.getCancelledOrders().size());
    assertEquals("un-cancelled orders size", 1, response.getUnCancelledOrders().size());
    assertEquals("un-cancelled Orders tracking id equals", trackingId,
        response.getUnCancelledOrders().get(0).getTrackingId());
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_CANCEL");
    put(KEY_CANCELLATION_REASON, f("Cancellation reason : %s", "invalid cancel order status"));
  }
}
