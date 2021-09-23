package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.order_create.OrderCreateClientV4;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.AuthHelper;
import co.nvqa.core_api.cucumber.glue.support.OrderCreateHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.java.en.Given;
import io.cucumber.guice.ScenarioScoped;

import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-01
 */
@ScenarioScoped
public class OrderCreateSteps extends BaseSteps {

  public static final String KEY_LIST_OF_ORDER_CREATE_RESPONSE = "key-list-of-order-create-response";
  public static final String KEY_LIST_OF_ORDER_CREATE_REQUEST = "key-list-of-order-create-request";
  public static final String KEY_LIST_OF_PICKUP_ADDRESS_STRING = "key-list-of-pickup-address-string";
  private static final String DOMAIN = "ORDER-CREATION-STEPS";
  private OrderCreateClientV4 orderCreateClientV4;

  @Override
  public void init() {

  }

  @Given("^Shipper authenticates using client id \"([^\"]*)\" and client secret \"([^\"]*)\"$")
  public void shipperAuthenticate(String clientId, String clientSecret) {
    callWithRetry(() -> {
      orderCreateClientV4 = new OrderCreateClientV4(TestConstants.API_BASE_URL,
          AuthHelper.getShipperToken(clientId, clientSecret));
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
        long routeId = Long.valueOf(source.get("dp-holding-route-id"));
        put(KEY_CREATED_ROUTE_ID, routeId);
        putInList(KEY_LIST_OF_CREATED_ROUTE_ID, routeId);
        put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "ADD_BY_ORDER_DP");
      }
      putInList(KEY_LIST_OF_PICKUP_ADDRESS_STRING, pickupAddress);
    }, "shipper create order");
  }

  @Given("^Shipper creates a reservation tied to Normal orders$")
  public void shipperReservationTiedToNormalOrder(Map<String, String> source) {
    shipperCreateOrder(source);
    shipperCreateAnotherOrderWithSameParams();
  }

  @Given("^Shipper creates a reservation$")
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
