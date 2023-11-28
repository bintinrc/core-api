package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.constants.HttpConstants;
import co.nvqa.common.core.client.OrderClient;
import co.nvqa.common.core.model.event.Event;
import co.nvqa.common.core.model.event.EventDetail;
import co.nvqa.common.core.model.order.Order;
import co.nvqa.common.core.model.order.Order.Dimension;
import co.nvqa.common.core.model.order.Order.Transaction;
import co.nvqa.common.core.model.order.RtsOrderRequest;
import co.nvqa.common.core.model.other.CoreExceptionResponse.Error;
import co.nvqa.common.core.utils.CoreScenarioStorageKeys;
import co.nvqa.common.utils.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.After;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import javax.inject.Inject;
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
  private static final String ACTION_SUCCESS = "success";
  private static final String ACTION_FAIL = "fail";

  @Inject
  private OrderClient orderClient;

  @Override
  public void init() {
  }

  @Then("Operator search for created order")
  public void operatorSearchOrderByTrackingId() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    doWithRetry(() -> {
      LOGGER.info(
          f("retrieve created order details from core orders for tracking id %s", trackingId));
      Order order = getOrderDetails(trackingId);
      put(KEY_CREATED_ORDER, order);
      putInList(KEY_LIST_OF_CREATED_ORDER, order);
      Assertions.assertThat(order).as("retrieved order").isNotNull();
      put(KEY_CREATED_ORDER_ID, order.getId());
      putInList(KEY_LIST_OF_CREATED_ORDER_ID, order.getId());
      Assertions.assertThat(order.getId()).as("order id").isNotNull();
      LOGGER.info(f("order id = %d is successfully retrieved from core", order.getId()));
    }, "retrieve order details from core");
  }

  @Then("Operator search for all created orders")
  public void operatorSearchAllOrdersByTrackingIds() {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorSearchOrderByTrackingId();
    });
  }

  @Then("Operator search for {string} transaction with status {string}")
  public void operatorSearchTransaction(String type, String status) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    operatorSearchTransaction(type, status, trackingId);
  }

  @Then("Operator search for {string} transaction with status {string} and tracking id {string}")
  public void operatorSearchTransaction(String type, String status, String tid) {
    String trackingId = resolveValue(tid);
    doWithRetry(() -> {
      Order order = getOrderDetails(trackingId);
      put(KEY_CREATED_ORDER, order);
      put(KEY_CREATED_ORDER_ID, order.getId());
      putInList(KEY_LIST_OF_CREATED_ORDER_ID, order.getId());
      Transaction transaction = getTransaction(order, type, status);
      Assertions.assertThat(transaction).as("retrieved transaction").isNotNull();
      LOGGER.info(f("retrieved transaction for id %d", transaction.getId()));
      put(KEY_TRANSACTION_DETAILS, transaction);
      put(KEY_TRANSACTION_ID, transaction.getId());
      putInList(KEY_LIST_OF_TRANSACTION_IDS, transaction.getId());
      putInList(KEY_LIST_OF_WAYPOINT_IDS, transaction.getWaypointId());
      put(KEY_WAYPOINT_ID, transaction.getWaypointId());
    }, "retrieve transaction details from core");
  }

  @Then("Operator search for multiple {string} transactions with status {string}")
  public void operatorSearchMultipleTransaction(String type, String status) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorSearchTransaction(type, status);
    });
  }

  @Then("Operator verify all {string} transactions status is {string}")
  public void operatorVerifyAllTransactionStatus(String type, String status) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorSearchTransaction(type, status);
      Transaction transaction = get(KEY_TRANSACTION_DETAILS);
      if (status.equalsIgnoreCase("fail")) {
        putInList(KEY_LIST_OF_TRANSACTION_DETAILS, transaction);
      }
      Assertions.assertThat(transaction.getStatus().toLowerCase())
          .as(String.format("transaction id %d status", transaction.getId()))
          .isEqualTo(status.toLowerCase());
    });
  }

  @Then("Operator verify that {string} orders {string} transactions status is {string}")
  public void operatorVerifiesPartialTransactionStatus(String actionMode, String transactionType,
      String transactionStatus) {
    List<String> trackingIds;
    if (actionMode.equalsIgnoreCase(ACTION_SUCCESS)) {
      trackingIds = get(KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    } else {
      trackingIds = get(KEY_LIST_OF_PARTIAL_FAIL_TID);
    }
    trackingIds.forEach(e -> {
      put(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID, trackingIds);
      operatorVerifyAllTransactionStatus(transactionType, transactionStatus);
    });
  }

  @Then("API Event - Operator verify that event is published with the following details:")
  public void operatorVerifiesOrderEventDetails(Map<String, String> mapOfData) {
    Map<String, String> expectedData = resolveKeyValues(mapOfData);
    Long orderId = Long.valueOf(expectedData.get("orderId"));
    String event = expectedData.get("event");
    doWithRetry(() -> {
      List<Event> result = getOrderEvent(event, orderId);
      if (result.isEmpty()) {
        throw new NvTestRuntimeException(
            f("events should not empty, order id: %d, event: %s", orderId,
                event));
      }
      Assertions.assertThat(result.get(0).getType().toLowerCase())
          .as(String.format("%s event is published", event)).isEqualTo(event.toLowerCase());
      putAllInList(KEY_LIST_OF_ORDER_EVENTS, result);
      operatorVerifiesOrderEventData(expectedData);
    }, String.format("%s event is published for order id %d", event, orderId));
  }

  @Then("Operator checks that {string} event is NOT published")
  public void operatorVerifiesOrderEventNotPublished(String event) {
    long orderId = get(KEY_CREATED_ORDER_ID);
    doWithRetry(() -> {
      List<Event> result = getOrderEvent(event, orderId);
      Assertions.assertThat(result.isEmpty()).as(String.format("%s event is NOT published", event))
          .isTrue();
    }, String.format("%s event is NOT published", event));
  }

  private void operatorVerifiesOrderEventData(Map<String, String> mapOfData) {
    List<Event> events = get(KEY_LIST_OF_ORDER_EVENTS);
    List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);
    String eventType = mapOfData.get("event");
    Long orderId = Long.valueOf(mapOfData.get("orderId"));
    Event event;
    if (eventType.equalsIgnoreCase(Event.ADD_TO_ROUTE_EVENT) || eventType.equalsIgnoreCase(
        Event.PULL_OUT_OF_ROUTE_EVENT)) {
      String source = mapOfData.get("routeEventSource");
      event = events.stream().filter(e -> Objects.equals(e.getOrderId(), orderId))
          .filter(e -> e.getType().equalsIgnoreCase(eventType))
          .filter(e -> e.getData().getSource().equalsIgnoreCase(source)).findAny()
          .orElseThrow(() -> new NvTestRuntimeException("order event not found"));
    } else if (eventType.equalsIgnoreCase(Event.UPDATE_STATUS)) {
      String reason = mapOfData.get("updateStatusReason");
      event = events.stream().filter(e -> Objects.equals(e.getOrderId(), orderId))
          .filter(e -> e.getType().equalsIgnoreCase(eventType))
          .filter(e -> e.getData().getReason().equalsIgnoreCase(reason)).findAny()
          .orElseThrow(() -> new NvTestRuntimeException("order event not found"));
    } else {
      event = events.stream().filter(e -> Objects.equals(e.getOrderId(), orderId))
          .filter(e -> e.getType().equalsIgnoreCase(eventType)).findAny()
          .orElseThrow(() -> new NvTestRuntimeException("order event not found"));
    }
    EventDetail data = event.getData();
    switch (eventType) {
      case Event.ROUTE_TRANSFER_SCAN_EVENT:
        if (data.getRouteIdValue().getOldValue() != null) {
          Assertions.assertThat(data.getRouteIdValue().getNewValue()).as("new route_id")
              .isEqualTo(routeIds.get(1));
          Assertions.assertThat(data.getRouteIdValue().getOldValue()).as("old route_id")
              .isEqualTo(routeIds.get(0));
        } else {
          Assertions.assertThat(data.getRouteIdValue().getNewValue()).as("new route_id")
              .isEqualTo(routeIds.get(0));
        }
        break;
      case Event.PULL_OUT_OF_ROUTE_EVENT:
        Long expectedOldRouteId;
        if (routeIds == null) {
          expectedOldRouteId = Long.parseLong(resolveValue(mapOfData.get("oldRouteId")));
        } else {
          expectedOldRouteId = routeIds.get(0);
        }
        Assertions.assertThat(data.getRouteId()).as("data.route_id").isEqualTo(expectedOldRouteId);
        break;
      case Event.CANCEL:
        break;
      case Event.UPDATE_STATUS:
        String reason = mapOfData.get("updateStatusReason");
        Assertions.assertThat(data.getReason()).as("update status reason").isEqualTo(reason);
        break;
      default: {
        //ADD_TO_ROUTE, DRIVER_INBOUND_SCAN, DRIVER_PICKUP_SCAN
        if (data.getRouteId() != null) {
          Long routeId = Long.valueOf(mapOfData.get("routeId"));
          Assertions.assertThat(data.getRouteId()).as("data.route_id").isEqualTo(routeId);
        }
      }
    }

  }

  @Then("Operator verify that order status-granular status is {string}-{string}")
  public void operatorVerifiesOrderStatus(String status, String granularStatus) {
    operatorSearchOrderByTrackingId();
    final Order o = get(KEY_CREATED_ORDER);
    doWithRetry(() -> {
      operatorSearchOrderByTrackingId();
      Order order = get(KEY_CREATED_ORDER);
      Assertions.assertThat(order.getStatus())
          .as(String.format("order %s status = %s", order.getTrackingId(), status))
          .isEqualToIgnoringCase(status);
      Assertions.assertThat(order.getGranularStatus())
          .as(f("order %s granular status = %s", order.getTrackingId(), granularStatus))
          .isEqualToIgnoringCase(granularStatus);
    }, f("check order granular status of %s", o.getTrackingId()));
  }

  @Then("Operator verify that order comment is appended with cancel reason = {string}")
  public void operatorVerifiesOrderComment(String comment) {
    operatorSearchOrderByTrackingId();
    final Order o = get(KEY_CREATED_ORDER);
    doWithRetry(() -> {
      operatorSearchOrderByTrackingId();
      Order order = get(KEY_CREATED_ORDER);
      Assertions.assertThat(StringUtils.lowerCase(order.getComments())).as("order comment")
          .isEqualTo(StringUtils.lowerCase(comment));
    }, f("check order comment", o.getTrackingId()));
  }

  @Then("Operator verify that all orders status-granular status is {string}-{string}")
  public void operatorVerifiesAllOrderStatus(String status, String granularStatus) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorVerifiesOrderStatus(status, granularStatus);
    });
  }

  @Then("Operator verify that order with status-granular status is {string}-{string} and tracking id {string}")
  public void operatorVerifiesAllOrderStatusWithTrackingIds(String status, String granularStatus,
      String tid) {
    String trackingId = resolveValue(tid);

    put(KEY_CREATED_ORDER_TRACKING_ID, trackingId);
    operatorVerifiesOrderStatus(status, granularStatus);
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

  @Then("Operator verify that {string} orders status-granular status is {string}-{string}")
  public void operatorVerifiesPartialOrderStatus(String actionMode, String status,
      String granularStatus) {
    List<String> trackingIds;
    if (actionMode.equalsIgnoreCase(ACTION_SUCCESS)) {
      trackingIds = get(KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    } else {
      trackingIds = get(KEY_LIST_OF_PARTIAL_FAIL_TID);
    }
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      operatorVerifiesOrderStatus(status, granularStatus);
    });
  }

  @When("Operator force success order")
  public void operatorForceSuccessOrder() {
    long orderId = get(KEY_CREATED_ORDER_ID);
    doWithRetry(() -> {
      getOrderClient().forceSuccess(orderId);
      LOGGER.info(f("order id %d force successed", orderId));
    }, "force success order");
  }

  @When("Operator force success all orders")
  public void operatorForceSuccessAllOrders() {
    List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    orderIds.stream().distinct().forEach(e -> {
      put(KEY_CREATED_ORDER_ID, e);
      operatorForceSuccessOrder();
    });
  }

  @When("Operator force {string} {string} waypoint")
  public void operatorForceFailOrder(String action, String type) {
    operatorSearchTransaction(type, Transaction.STATUS_PENDING);
    long waypointId = get(KEY_WAYPOINT_ID);
    long routeId = get(KEY_CREATED_ROUTE_ID);
    doWithRetry(() -> {
      if (action.equalsIgnoreCase(ACTION_FAIL)) {
        getRouteClient().forceFailWaypoint(routeId, waypointId, TestConstants.FAILURE_REASON_ID);
      } else {
        getRouteClient().forceSuccessWaypoint(routeId, waypointId);
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
    doWithRetry(() -> {
      if (Boolean.valueOf(codCollected)) {
        getRouteClient().forceSuccessWaypointWithCodCollected(routeId, waypointId, orderIds);
      } else {
        List<Long> emptyOrderId = new ArrayList<>();
        getRouteClient().forceSuccessWaypointWithCodCollected(routeId, waypointId, emptyOrderId);
      }
      LOGGER.info(f("waypoint id %d forced success with cod", waypointId));
    }, "admin force finish success with cod");
  }

  @When("Operator tags order with PRIOR tag")
  public void tagPriorOrder() {
    long tagId = TestConstants.ORDER_TAG_PRIOR_ID;
    operatorTagsOrder(tagId);
  }

  @When("Operator {string} Order COD value with value {double}")
  public void operatorModifyCod(String type, double amount) {
    long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient().addCodValueAndGetRawResponse(orderId, amount);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator deletes Order COD value")
  public void operatorDeleteCod() {
    long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient().deleteCodAndGetRawResponse(orderId);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator update delivery verfication with value {string}")
  public void operatorUpdateDeliveryVerification(String method) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Response r = getOrderClient().editDeliveryVerificationRequiredAndGetRawResponse(trackingId,
        method);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator RTS invalid state Order")
  public void operatorRtsInvalidState(Map<String, String> request) {
    final Long orderId = get(KEY_CREATED_ORDER_ID);
    final RtsOrderRequest rtsRequest = fromJsonSnakeCase(request.get("request"),
        RtsOrderRequest.class);
    Response r = getOrderClient().setReturnedToSenderAndGetRawResponse(orderId, rtsRequest);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator force success invalid state Order")
  public void operatorForceSuccessInvalidState() {
    final Long orderId = get(KEY_CREATED_ORDER_ID);
    Response r = getOrderClient().forceSuccessAsRawResponse(orderId, false);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator validate order for ATL")
  public void operatorValidateDeliveryVerification() {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Response r = getOrderClient().validateDeliveryVerificationAndGetRawResponse(trackingId);
    Assertions.assertThat(r.statusCode()).as("response code")
        .isEqualTo(HttpConstants.RESPONSE_200_SUCCESS);
    put(KEY_API_RAW_RESPONSE, r);
  }

  @When("Operator verify that response returns {string}")
  public void operatorVerifyResponseValidationDeliveryVerification(String data) {
    Response r = get(KEY_API_RAW_RESPONSE);
    String actualData = r.body().asString();
    String expectedData = "{\"data\":" + data + "}";
    Assertions.assertThat(actualData).as("response data").isEqualTo(expectedData);
  }

  @When("Operator verify response code is {int} with error message details as follow")
  public void operatorVerifyResponseWithParams(int expectedHttpStatus, Map<String, String> params) {
    Map<String, String> expectedData = resolveKeyValues(params);
    doWithRetry(() -> {
      Response response = get(KEY_API_RAW_RESPONSE);
      Assertions.assertThat(response.getStatusCode()).as("Http response code")
          .isEqualTo(expectedHttpStatus);

      String json = toJsonSnakeCase(expectedData);
      Error expectedError = fromJsonSnakeCase(json, Error.class);
      Error actualError;
      try {
        actualError = fromJsonSnakeCase(response.body().asString(), Error.class);
      } catch (Exception e) {
        LOGGER.error("JSON error: " + e.getMessage());
        throw new RuntimeException("response is not valid JSON");
      }
      Assertions.assertThat(actualError.getCode()).as("code").isEqualTo(expectedError.getCode());
      Assertions.assertThat(actualError.getMessages().get(0)).as("messages")
          .isEqualTo(f(expectedData.get("message"), expectedData.get("values")));
      Assertions.assertThat(actualError.getApplication()).as("application")
          .isEqualTo(expectedError.getApplication());
      Assertions.assertThat(actualError.getDescription()).as("description")
          .isEqualTo(expectedError.getDescription());
      Assertions.assertThat(actualError.getData().getMessage()).as("data.message")
          .isEqualTo(f(expectedData.get("message"), expectedData.get("values")));
    }, "verify response");
  }

  @When("Operator verify response code is {int} with error message {string}")
  public void operatorVerifyResponseWithParams(int expectedHttpStatus, String message) {
    String errorMessage = resolveValue(message);
    doWithRetry(() -> {
      Response response = get(KEY_API_RAW_RESPONSE);
      Assertions.assertThat(response.getStatusCode()).as("Http response code")
          .isEqualTo(expectedHttpStatus);
      Assertions.assertThat(response.getBody().asString()).as("messages")
          .isEqualTo(f(errorMessage));
    }, "verify response");
  }

  @When("Operator tags order with tag id {long}")
  public void operatorTagsOrder(Long tagId) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    List<Long> tagIds = List.of(tagId);
    doWithRetry(() -> {
      long orderId = getOrderDetails(trackingId).getId();
      getOrderClient().addOrderLevelTags(orderId, tagIds);
      put(KEY_LIST_OF_ORDER_TAG_IDS, tagIds);
      putInList(KEY_LIST_OF_PRIOR_TRACKING_IDS, trackingId);
    }, f("tag an order: %s", trackingId));
  }

  @When("Operator tags all orders with PRIOR tag")
  public void tagMultipleOrders() {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      tagPriorOrder();
    });
  }

  @When("Operator updates order dimensions with following details for order id {string}")
  public void updateOrderDimensions(String id, Map<String, Double> source) {
    final Long orderId = Long.parseLong(resolveValue(id));
    final String json = toJsonSnakeCase(source);
    final Dimension dimension = fromJsonSnakeCase(json, Dimension.class);
    if (dimension.getWeight() == 0) {
      dimension.setWeight(null);
    }
    put(CoreScenarioStorageKeys.KEY_SAVED_ORDER_WEIGHT, dimension.getWeight());
    put(KEY_DIMENSION_CHANGES_REQUEST, dimension);
    doWithRetry(() -> getOrderClient().updateParcelDimensions(orderId, dimension),
        "update order dimension");
  }

  @After("@ForceSuccessOrders")
  public void cleanOrders() {
    final List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    try {
      if (orderIds != null) {
        orderIds.forEach(e -> getOrderClient().forceSuccess(e));
      }
    } catch (Throwable t) {
      LOGGER.warn("Failed to force success order(s)");
    }
  }


  @Override
  protected Order getOrderDetails(String trackingId) {
    return orderClient.searchOrderByTrackingId(trackingId);
  }

  @Override
  protected Transaction getTransaction(Order order, String type, String status) {
    List<Transaction> transactions = order.getTransactions();
    Transaction result;
    result = transactions.stream().filter(e -> e.getType().equalsIgnoreCase(type))
        .filter(e -> e.getStatus().equalsIgnoreCase(status)).findAny().orElseThrow(
            () -> new NvTestRuntimeException(
                f("transaction details not found: %s", order.getTrackingId())));
    return result;
  }

  private List<Event> getOrderEvent(String event, long orderId) {
    List<Event> events = getEventClient().getOrderEventsByOrderId(orderId).getData();
    return events.stream().filter(c -> c.getType().equalsIgnoreCase(event))
        .collect(Collectors.toList());
  }

}
