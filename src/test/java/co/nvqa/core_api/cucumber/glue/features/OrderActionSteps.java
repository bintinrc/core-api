package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.constants.HttpConstants;
import co.nvqa.commons.model.core.Dimension;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Rts;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.model.core.event.Event;
import co.nvqa.commons.model.core.event.EventDetail;
import co.nvqa.commons.model.other.ExceptionResponse;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.apache.commons.lang3.StringUtils;
import org.assertj.core.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class OrderActionSteps extends BaseSteps {

  private static final Logger LOGGER = LoggerFactory.getLogger(OrderActionSteps.class);

  private static final String DOMAIN = "ORDER-ACTION-STEP";
  private static final String ACTION_SUCCESS = "success";
  private static final String ACTION_FAIL = "fail";
  public static final String KEY_LIST_OF_ORDER_TAG_IDS = "key-order-tag-ids";
  public static final String KEY_LIST_OF_PRIOR_TRACKING_IDS = "key-list-prior-tracking-ids";
  public static final String KEY_API_RAW_RESPONSE = "key-api-raw-response";

  @Override
  public void init() {

  }

  @Then("^Operator search for created order$")
  public void operatorSearchOrderByTrackingId() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      LOGGER.info(
          f("retrieve created order details from core orders for tracking id %s", trackingId));
      Order order = getOrderDetails(trackingId);
      put(KEY_CREATED_ORDER, order);
      putInList(KEY_LIST_OF_CREATED_ORDER, order);
      assertNotNull("retrieved order", order);
      put(KEY_CREATED_ORDER_ID, order.getId());
      putInList(KEY_LIST_OF_CREATED_ORDER_ID, order.getId());
      assertNotNull("order id", order.getId());
      LOGGER.info(f("order id = %d is successfully retrieved from core", order.getId()));
    }, "retrieve order details from core");
  }

  @Then("^Operator search for all created orders$")
  public void operatorSearchAllOrdersByTrackingIds() {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorSearchOrderByTrackingId();
    });
  }

  @Then("^Operator search for \"([^\"]*)\" transaction with status \"([^\"]*)\"$")
  public void operatorSearchTransaction(String type, String status) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      Order order = getOrderDetails(trackingId);
      put(KEY_CREATED_ORDER, order);
      put(KEY_CREATED_ORDER_ID, order.getId());
      putInList(KEY_LIST_OF_CREATED_ORDER_ID, order.getId());
      Transaction transaction = getTransaction(order, type, status);
      assertNotNull("retrieved transaction", transaction);
      LOGGER.info(f("retrieved transaction for id %d", transaction.getId()));
      put(KEY_TRANSACTION_DETAILS, transaction);
      put(KEY_TRANSACTION_ID, transaction.getId());
      putInList(KEY_LIST_OF_TRANSACTION_IDS, transaction.getId());
      putInList(KEY_LIST_OF_WAYPOINT_IDS, transaction.getWaypointId());
      put(KEY_WAYPOINT_ID, transaction.getWaypointId());
      putInMap(KEY_MAP_OF_WAYPOINT_IDS_ORDER, transaction.getWaypointId(), trackingId);
      //to get newly create route id from parcel route transfer
      String routeSource = get(RoutingSteps.KEY_ROUTE_EVENT_SOURCE);
      if (get(DriverSteps.KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS) != null && routeSource
          .equalsIgnoreCase("ROUTE_TRANSFER")) {
        put(KEY_CREATED_ROUTE_ID, transaction.getRouteId());
        putInList(KEY_LIST_OF_CREATED_ROUTE_ID, transaction.getRouteId());
      }
      if (type.equalsIgnoreCase("DELIVERY")) {
        put(KEY_DELIVERY_WAYPOINT_ID, transaction.getWaypointId());
      }
    }, "retrieve transaction details from core");
  }

  @Then("Operator search for multiple {string} transactions with status {string}")
  public void operatorSearchMultipleTransaction(String type, String status) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorSearchTransaction(type, status);
    });
    List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    put(KEY_LIST_OF_WAYPOINTS_SEQUENCE, waypointIds);
  }

  @Then("^Operator verify all \"([^\"]*)\" transactions status is \"([^\"]*)\"$")
  public void operatorVerifyAllTransactionStatus(String type, String status) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorSearchTransaction(type, status);
      Transaction transaction = get(KEY_TRANSACTION_DETAILS);
      if (status.equalsIgnoreCase("fail")) {
        putInList(KEY_LIST_OF_TRANSACTION_DETAILS, transaction);
      }
      assertEquals(String.format("transaction id %d status", transaction.getId()),
          status.toLowerCase(), transaction.getStatus().toLowerCase());
    });
  }

  @Then("^Operator verify that \"([^\"]*)\" orders \"([^\"]*)\" transactions status is \"([^\"]*)\"$")
  public void operatortVerifiesPartialTransactionStatus(String actionMode, String transactionType,
      String transactionStatus) {
    List<String> trackingIds;
    if (actionMode.equalsIgnoreCase(ACTION_SUCCESS)) {
      trackingIds = get(BatchUpdatePodsSteps.KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    } else {
      trackingIds = get(BatchUpdatePodsSteps.KEY_LIST_OF_PARTIAL_FAIL_TID);
    }
    trackingIds.forEach(e -> {
      put(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID, trackingIds);
      operatorVerifyAllTransactionStatus(transactionType, transactionStatus);
    });
  }

  @Then("^Operator checks that \"([^\"]*)\" event is published$")
  public void operatortVerifiesOrderEvent(String event) {
    long orderId = get(KEY_CREATED_ORDER_ID);
    callWithRetry(() -> {
      List<Event> result = getOrderEvent(event, orderId);

      if (result.isEmpty()) {
        throw new NvTestRuntimeException(
            f("events should not empty, order id: %d, event: %s", orderId, event));
      }
      assertEquals(String.format("%s event is published", event), event.toLowerCase(),
          result.get(0).getType().toLowerCase());
      put(KEY_ORDER_EVENTS, result);
      putAllInList(KEY_LIST_OF_ORDER_EVENTS, result);
      operatortVerifiesOrderEventData(event);
    }, String.format("%s event is published for order id %d", event, orderId));
  }

  @Then("^Operator checks that \"([^\"]*)\" event is NOT published$")
  public void operatortVerifiesOrderEventNotPUblished(String event) {
    long orderId = get(KEY_CREATED_ORDER_ID);
    callWithRetry(() -> {
      List<Event> result = getOrderEvent(event, orderId);
      assertTrue(String.format("%s event is NOT published", event), result.isEmpty());
    }, String.format("%s event is NOT published", event));
  }

  @Then("^Operator verifies that order event \"([^\"]*)\" data has correct details$")
  public void operatortVerifiesOrderEventData(String eventType) {
    List<Event> events = get(KEY_LIST_OF_ORDER_EVENTS);
    List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);
    Long routeId = get(KEY_CREATED_ROUTE_ID);
    long orderId = get(KEY_CREATED_ORDER_ID);
    Event event;
    if (eventType.equalsIgnoreCase(Event.ADD_TO_ROUTE_EVENT) || eventType
        .equalsIgnoreCase(Event.PULL_OUT_OF_ROUTE_EVENT)) {
      String source = get(RoutingSteps.KEY_ROUTE_EVENT_SOURCE);
      event = events.stream()
          .filter(e -> e.getOrderId() == orderId)
          .filter(e -> e.getType().equalsIgnoreCase(eventType))
          .filter(e -> e.getData().getSource().equalsIgnoreCase(source))
          .findAny().orElseThrow(() -> new NvTestRuntimeException(
              "order event not found"));
    } else {
      event = events.stream()
          .filter(e -> e.getOrderId() == orderId)
          .filter(e -> e.getType().equalsIgnoreCase(eventType))
          .findAny().orElseThrow(() -> new NvTestRuntimeException(
              "order event not found"));
    }
    EventDetail data = event.getData();
    switch (eventType) {
      case Event.ROUTE_TRANSFER_SCAN_EVENT:
        if (data.getRouteIdValue().getOldValue() != null) {
          put(KEY_CREATED_ROUTE_ID, routeIds.get(1));
          Assertions.assertThat(data.getRouteIdValue().getNewValue()).as("old route_id")
              .isEqualTo(routeIds.get(1));
          Assertions.assertThat(data.getRouteIdValue().getOldValue()).as("old route_id")
              .isEqualTo(routeIds.get(0));
        } else {
          put(KEY_CREATED_ROUTE_ID, routeIds.get(0));
          Assertions.assertThat(data.getRouteIdValue().getNewValue()).as("new route_id")
              .isEqualTo(routeIds.get(0));
        }
        break;
      case Event.PULL_OUT_OF_ROUTE_EVENT:
        Assertions.assertThat(data.getRouteId()).as("data.route_id")
            .isEqualTo(routeIds.get(0));
        break;
      case Event.CANCEL:
        break;
      default: {
        //ADD_TO_ROUTE, DRIVER_INBOUND_SCAN, DRIVER_PICKUP_SCAN
        if (data.getRouteId() != null) {
          Assertions.assertThat(data.getRouteId()).as("data.route_id")
              .isEqualTo(routeId);
        }
      }
    }
  }

  @Then("^Operator verify that order status-granular status is \"([^\"]*)\"-\"([^\"]*)\"$")
  public void operatortVerifiesOrderStatus(String status, String granularStatus) {
    operatorSearchOrderByTrackingId();
    final Order o = get(KEY_CREATED_ORDER);
    callWithRetry(() -> {
      operatorSearchOrderByTrackingId();
      Order order = get(KEY_CREATED_ORDER);
      assertEquals(String.format("order %s status = %s", order.getTrackingId(), status),
          StringUtils.lowerCase(status), StringUtils.lowerCase(order.getStatus()));
      assertEquals(
          String.format("order %s granular status = %s", order.getTrackingId(), granularStatus),
          StringUtils.lowerCase(granularStatus), StringUtils.lowerCase(order.getGranularStatus()));
    }, f("check order granular status of %s", o.getTrackingId()));
  }

  @Then("^Operator verify that order comment is appended with cancel reason = \"([^\"]*)\"$")
  public void operatortVerifiesOrderComment(String comment) {
    operatorSearchOrderByTrackingId();
    final Order o = get(KEY_CREATED_ORDER);
    callWithRetry(() -> {
      operatorSearchOrderByTrackingId();
      Order order = get(KEY_CREATED_ORDER);
      assertEquals("order comment", StringUtils.lowerCase(comment),
          StringUtils.lowerCase(order.getComments()));
    }, f("check order comment", o.getTrackingId()));
  }

  @Then("^Operator verify that all orders status-granular status is \"([^\"]*)\"-\"([^\"]*)\"$")
  public void operatortVerifiesAllOrderStatus(String status, String granularStatus) {
    List<String> trackingIds = get(OrderCreateSteps.KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatortVerifiesOrderStatus(status, granularStatus);
    });
  }

  //to remove not transferred parcel from being asserted
  @Then("Operator gets only eligible parcel for route transfer")
  public void getEligibleRouteTransfer() {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    trackingIds.remove(0);
    orderIds.remove(0);
    remove(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    remove(KEY_LIST_OF_CREATED_ORDER_ID);
    putAllInList(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID, trackingIds);
    putAllInList(KEY_LIST_OF_CREATED_ORDER_ID, orderIds);
  }

  @Then("^Operator verify that \"([^\"]*)\" orders status-granular status is \"([^\"]*)\"-\"([^\"]*)\"$")
  public void operatortVerifiesPartialOrderStatus(String actionMode, String status,
      String granularStatus) {
    List<String> trackingIds;
    if (actionMode.equalsIgnoreCase(ACTION_SUCCESS)) {
      trackingIds = get(BatchUpdatePodsSteps.KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    } else {
      trackingIds = get(BatchUpdatePodsSteps.KEY_LIST_OF_PARTIAL_FAIL_TID);
    }
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatortVerifiesOrderStatus(status, granularStatus);
    });
  }

  @Then("^Operator checks that for all orders, \"([^\"]*)\" event is published$")
  public void operatortVerifiesOrderEventForEach(String event) {
    List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    orderIds.forEach(e -> {
      put(KEY_CREATED_ORDER_ID, e);
      operatortVerifiesOrderEvent(event);
    });
    LOGGER.info(f("%s event is published for all order ids %s", event,
        Arrays.toString(orderIds.toArray())));
  }

  @When("^Operator force success order$")
  public void operatorForceSuccessOrder() {
    long orderId = get(KEY_CREATED_ORDER_ID);
    callWithRetry(() -> {
      getOrderClient().forceSuccess(orderId);
      LOGGER.info(f("order id %d force successed", orderId));
    }, "force success order");
  }

  @When("^Operator force success all orders$")
  public void operatorForceSuccessAllOrders() {
    List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    orderIds.stream().distinct().forEach(e -> {
      put(KEY_CREATED_ORDER_ID, e);
      operatorForceSuccessOrder();
    });
  }

  @When("^Operator force \"([^\"]*)\" \"([^\"]*)\" waypoint$")
  public void operatorForceFailOrder(String action, String type) {
    operatorSearchTransaction(type, Transaction.STATUS_PENDING);
    long waypointId = get(KEY_WAYPOINT_ID);
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      if (action.equalsIgnoreCase(ACTION_FAIL)) {
        getOrderClient().forceFailWaypoint(routeId, waypointId, TestConstants.FAILURE_REASON_ID);
      } else {
        getOrderClient().forceSuccessWaypoint(routeId, waypointId);
      }
      LOGGER.info(f("waypoint id %d forced %s", waypointId, action));
    }, String.format("admin force finish %s", action));
  }

  @When("Operator admin manifest force success waypoint with cod collected : {string}")
  public void operatorAdminManifestForceSuccessCod(String codCollected) {
    operatorSearchTransaction(Transaction.TYPE_DELIVERY, Transaction.STATUS_PENDING);
    long waypointId = get(KEY_WAYPOINT_ID);
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    callWithRetry(() -> {
      if (Boolean.valueOf(codCollected)) {
        getOrderClient().forceSuccessWaypointWithCodCollected(routeId, waypointId, orderIds);
      } else {
        List<Long> emptyOrderId = new ArrayList<>();
        getOrderClient().forceSuccessWaypointWithCodCollected(routeId, waypointId, emptyOrderId);
      }
      LOGGER.info(f("waypoint id %d forced success with cod", waypointId));
    }, "admin force finish success with cod");
  }

  @When("^Operator tags order with PRIOR tag$")
  public void tagPriorOrder() {
    long tagId = TestConstants.ORDER_TAG_PRIOR_ID;
    operatorTagsOrder(tagId);
  }

  @When("^Operator \"([^\"]*)\" Order COD value with value (\\d+)$")
  public void operatorModifyCod(String type, long amount) {
    long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient().addCodValueAndGetRawResponse(orderId, amount);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("^Operator deletes Order COD value$")
  public void operatorDeleteCod() {
    long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient().deleteCodAndGetRawResponse(orderId);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("^Operator update delivery verfication with value \"([^\"]*)\"$")
  public void operatorUpdateDeliveryVerification(String method) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Response r = getOrderClient()
        .editDeliveryVerificationRequiredAndGetRawResponse(trackingId, method);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator RTS invalid state Order")
  public void operatorRtsInvalidState(Map<String, String> request) {
    final Long orderId = get(KEY_CREATED_ORDER_ID);
    final Rts rtsRequest = fromJsonSnakeCase(request.get("request"), Rts.class);
    rtsRequest.setOrderId(orderId);
    Response r = getOrderClient()
        .setReturnedToSenderAndGetRawResponse(rtsRequest);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator force success invalid state Order")
  public void operatorForceSuccessInvalidState() {
    final Long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient()
        .forceSuccessAndGetRawResponse(orderId, false);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("^Operator validate order for ATL$")
  public void operatorValidateDeliveryVerification() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Response r = getOrderClient()
        .validateDeliveryVerificationAndGetRawResponse(trackingId);
    assertEquals("response code", HttpConstants.RESPONSE_200_SUCCESS, r.statusCode());
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("^Operator verify that response returns \"([^\"]*)\"$")
  public void operatorVerifyResponseValidationDeliveryVerification(String data) {
    Response r = get(KEY_API_RAW_RESPONSE);
    String actualData = r.body().asString();
    String expectedData = "{\"data\":" + data + "}";
    assertEquals("response data", expectedData, actualData);
  }

  @When("^Operator verify response code is (\\d+) with error message details as follow$")
  public void operatorVerifyResponseWithParams(int expectedHttpStatus, Map<String, String> params) {
    callWithRetry(() -> {
      Response response = get(KEY_API_RAW_RESPONSE);
      assertEquals("Http response code", expectedHttpStatus, response.getStatusCode());

      String json = toJsonSnakeCase(params);
      ExceptionResponse expectedError = fromJsonSnakeCase(json, ExceptionResponse.class);
      ExceptionResponse actualError;
      try {
        actualError = fromJsonSnakeCase(response.body().asString(),
            ExceptionResponse.class);
      } catch (Exception e) {
        LOGGER.error("JSON error: " + e.getMessage());
        throw new RuntimeException("response is not valid JSON");
      }
      assertEquals("code", expectedError.getCode(), actualError.getCode());
      assertEquals("messages", params.get("message"),
          actualError.getMessages().get(0));
      assertEquals("application", expectedError.getApplication(), actualError.getApplication());
      assertEquals("description", expectedError.getDescription(), actualError.getDescription());
      assertEquals("data.message", params.get("message"),
          actualError.getData().getMessage());
    }, "verify response");
  }

  @When("^Operator tags order with tag id \"([^\"]*)\"$")
  public void operatorTagsOrder(long tagId) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    List<Long> tagIds = Arrays.asList(tagId);
    callWithRetry(() -> {
      long orderId = searchOrder(trackingId).getId();
      getOrderClient().addOrderLevelTags(orderId, tagIds);
      put(KEY_LIST_OF_ORDER_TAG_IDS, tagIds);
      putInList(KEY_LIST_OF_PRIOR_TRACKING_IDS, trackingId);
    }, f("tag an order: %s", trackingId));
  }

  @When("^Operator tags all orders with PRIOR tag$")
  public void tagMultipleOrders() {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      tagPriorOrder();
    });
  }

  @When("Operator updates order dimensions with following details")
  public void updateOrderDimensions(Map<String, Double> source) {
    final Long orderId = get(KEY_CREATED_ORDER_ID);
    final String json = toJsonSnakeCase(source);
    final Dimension dimension = fromJsonSnakeCase(json, Dimension.class);
    if (dimension.getWeight() == 0) {
      dimension.setWeight(null);
    }
    put(KEY_EXPECTED_NEW_WEIGHT, dimension.getWeight());
    callWithRetry(() -> getOrderClient().updateParcelDimensions(orderId, dimension),
        "update order dimension");
  }

  private Order searchOrder(String trackingIdOrStampId) {
    return getOrderSearchClient().searchOrderByTrackingId(trackingIdOrStampId);
  }

  private Order getOrderDetails(String trackingId) {
    long orderId = searchOrder(trackingId).getId();
    Order order = getOrderClient().getOrder(orderId);
    assertNotNull("order details", order);
    return order;
  }

  private Transaction getTransaction(Order order, String type, String status) {
    List<Transaction> transactions = order.getTransactions();
    Transaction result;
    result = transactions.stream()
        .filter(e -> e.getType().equalsIgnoreCase(type))
        .filter(e -> e.getStatus().equalsIgnoreCase(status))
        .findAny().orElseThrow(() -> new NvTestRuntimeException(
            f("transaction details not found: %s", order.getTrackingId())));
    return result;
  }

  private List<Event> getOrderEvent(String event, long orderId) {
    List<Event> events = getEventClient().getOrderEventsByOrderId(orderId).getData();
    return events.stream()
        .filter(c -> c.getType().equalsIgnoreCase(event)).collect(Collectors.toList());
  }
}
