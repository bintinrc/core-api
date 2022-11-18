package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commonauth.utils.TokenUtils;
import co.nvqa.commons.client.order_create.OrderCreateClientV4;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderCreateHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-01
 */
@ScenarioScoped
public class OrderCreateSteps extends BaseSteps {

  private static final String DOMAIN = "ORDER-CREATION-STEPS";
  private OrderCreateClientV4 orderCreateClientV4;

  @Override
  public void init() {

  }

  @Given("Shipper authenticates using client id {string} and client secret {string}")
  public void shipperAuthenticate(String clientId, String clientSecret) {
    callWithRetry(() -> {
      String token = TokenUtils.getShipperToken(clientId, clientSecret);
      orderCreateClientV4 = new OrderCreateClientV4(TestConstants.API_BASE_URL,
          token);
      put(KEY_SHIPPER_V4_ACCESS_TOKEN, token);
    }, "shipper API authenticated");
  }

  @Given("^Shipper create order with parameters below$")
  public void shipperCreateOrder(Map<String, String> source) {
    OrderRequestV4 request = OrderCreateHelper.generateOrderV4(source);
    callWithRetry(() -> {
      OrderRequestV4 result = orderCreateClientV4.createOrder(request, "4.1");
      NvLogger.success(DOMAIN, "order created tracking id: " + result.getTrackingNumber());
      put(KEY_CREATED_ORDER_TRACKING_ID, result.getTrackingNumber());
      putInList(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID, result.getTrackingNumber());
      put(KEY_ORDER_CREATE_REQUEST, request);
      putInList(KEY_LIST_OF_ORDER_CREATE_RESPONSE, result);
      putInMap(KEY_LIST_OF_ORDER_CREATE_REQUEST, result.getTrackingNumber(), request);
      String pickupAddress =
          request.getFrom().getAddress().get("address1") + " " + request.getFrom().getAddress()
              .get("address2");
      put(KEY_PICKUP_ADDRESS_STRING, pickupAddress);
      //custom dp order add to holding route
      if (source.get("dp-holding-route-id") != null) {
        long routeId = Long.parseLong(source.get("dp-holding-route-id"));
        put(KEY_CREATED_ROUTE_ID, routeId);
        putInList(KEY_LIST_OF_CREATED_ROUTE_ID, routeId);
        put(KEY_ROUTE_EVENT_SOURCE, "ADD_BY_ORDER_DP");
        put(KEY_ROUTE_SOURCE_BY_INBOUND, "ADD_BY_ORDER_DP");
      }
      //custom weight for weight = 0 or null
      Double weight = request.getParcelJob().getDimensions().getWeight();
      if (weight == null || weight <= 0) {
        weight = 0.1;
      }
      put(KEY_EXPECTED_OLD_WEIGHT, weight);
      putInList(KEY_LIST_OF_PICKUP_ADDRESS_STRING, pickupAddress);
    }, "shipper create order");
  }

  @Given("^Shipper creates a reservation tied to Normal orders$")
  public void shipperReservationTiedToNormalOrder(Map<String, String> source) {
    shipperCreateOrder(source);
    shipperCreateAnotherOrderWithSameParams();
  }

  @Given("Shipper creates a reservation")
  public void shipperCreateSingleReservation(Map<String, String> source) {
    shipperCreateOrder(source);
  }

  @Given("^Shipper creates multiple (\\d+) reservations$")
  public void shipperCreateMultipleReservation(int numberOfRsvn, Map<String, String> source) {
    shipperCreateMultiplesOrders(numberOfRsvn, source);
  }


  @Given("^Shipper creates multiple \"([^\"]*)\" orders$")
  public void shipperCreateMultipleReturnOrders(String type, Map<String, String> source) {
    shipperCreateMultiplesOrders(2, source);
  }

  @Given("^Shipper create another order with the same parameters as before$")
  public void shipperCreateAnotherOrderWithSameParams() {
    OrderRequestV4 request = get(KEY_ORDER_CREATE_REQUEST);
    request.setRequestedTrackingNumber("");
    callWithRetry(() -> {
      OrderRequestV4 result = orderCreateClientV4.createOrder(request, "4.1");
      NvLogger.success(DOMAIN, "order created tracking id: " + result.getTrackingNumber());
      put(KEY_CREATED_ORDER_TRACKING_ID, result.getTrackingNumber());
      putInList(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID, result.getTrackingNumber());
      putInList(KEY_LIST_OF_ORDER_CREATE_RESPONSE, result);
      putInMap(KEY_LIST_OF_ORDER_CREATE_REQUEST, result.getTrackingNumber(), request);
    }, "shipper create another order");
  }

  @Given("^Shipper creates multiple orders : (\\d+) orders$")
  public void shipperCreateMultiplesOrders(int numberOfOrders, Map<String, String> source) {
    for (int i = 0; i < numberOfOrders; i++) {
      shipperCreateOrder(source);
    }
  }

  @Given("^Shipper creates multiple orders : (\\d+) orders with the same params$")
  public void shipperCreateMultiplesOrdersWithSameParams(int numberOfOrders,
      Map<String, String> source) {
    shipperCreateOrder(source);
    for (int i = 0; i < numberOfOrders - 1; i++) {
      shipperCreateAnotherOrderWithSameParams();
    }
  }
}
