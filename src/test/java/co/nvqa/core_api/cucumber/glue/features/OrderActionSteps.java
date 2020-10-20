package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.model.core.event.Event;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.util.Arrays;
import java.util.List;


/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class OrderActionSteps extends BaseSteps {

    private static final String DOMAIN = "ORDER-ACTION-STEP";
    private static final String ACTION_SUCCESS = "success";
    private static final String ACTION_FAIL = "fail";
    public static final String KEY_LIST_OF_ORDER_TAG_IDS = "key-order-tag-ids";
    public static final String KEY_LIST_OF_PRIOR_TRACKING_IDS = "key-list-prior-tracking-ids";

    @Override
    public void init() {

    }

    @Then("^Operator search for created order$")
    public void operatorSearchOrderByTrackingId() {
        String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
        callWithRetry(() -> {
            NvLogger.infof("retrieve created order details from core orders for tracking id %s", trackingId);
            Order order = getOrderDetails(trackingId);
            put(KEY_CREATED_ORDER, order);
            putInList(KEY_LIST_OF_CREATED_ORDER, order);
            assertNotNull("retrieved order", order);
            put(KEY_CREATED_ORDER_ID, order.getId());
            assertNotNull("order id", order.getId());
            NvLogger.successf("order id = %d is successfully retrieved from core", order.getId());
        }, "retrieve order details from core");
    }

    @Then("^Operator search for \"([^\"]*)\" transaction with status \"([^\"]*)\"$")
    public void operatorSearchTransaction(String type, String status) {
        String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
        callWithRetry(() -> {
            Order order = getOrderDetails(trackingId);
            put(KEY_CREATED_ORDER, order);
            Transaction transaction = getTransaction(order, type, status);
            assertNotNull("retrieved transaction", transaction);
            NvLogger.successf("retrieved transaction for id %d", transaction.getId());
            put(KEY_TRANSACTION_DETAILS, transaction);
            put(KEY_TRANSACTION_ID, transaction.getId());
            putInList(KEY_LIST_OF_TRANSACTION_IDS, transaction.getId());
            putInList(KEY_LIST_OF_WAYPOINT_IDS, transaction.getWaypointId());
            put(KEY_WAYPOINT_ID, transaction.getWaypointId());
        }, "retrieve transaction details from core");
    }

    @Then("^Operator search for multiple \"([^\"]*)\" transactions with status \"([^\"]*)\"$")
    public void operatorSearchMultipleTransaction(String type, String status) {
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach(e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            operatorSearchTransaction(type, status);
        });
    }

    @Then("^Operator verify all \"([^\"]*)\" transactions status is \"([^\"]*)\"$")
    public void operatorVerifyAllTransactionStatus(String type, String status) {
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach(e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            operatorSearchTransaction(type, status);
            Transaction transaction = get(KEY_TRANSACTION_DETAILS);
            assertEquals(String.format("transaction id %d status",transaction.getId()), status.toLowerCase(), transaction.getStatus().toLowerCase());
        });
    }

    @Then("^Operator verify that \"([^\"]*)\" orders \"([^\"]*)\" transactions status is \"([^\"]*)\"$")
    public void operatortVerifiesPartialTransactionStatus(String actionMode, String transactionType, String transactionStatus) {
        List<String> trackingIds;
        if(actionMode.equalsIgnoreCase(ACTION_SUCCESS)){
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
            Event result = getOrderEvent(event, orderId);
            assertEquals(String.format("%s event is published", event), event.toLowerCase(), result.getType().toLowerCase());
        }, String.format("%s event is published for order id %d", event, orderId));
    }

    @Then("^Operator verify that order status-granular status is \"([^\"]*)\"-\"([^\"]*)\"$")
    public void operatortVerifiesOrderStatus(String status, String granularStatus) {
        callWithRetry(() -> {
            operatorSearchOrderByTrackingId();
            Order order = get(KEY_CREATED_ORDER);
            assertEquals(String.format("order %s status = %s", order.getTrackingId(), status), status.toLowerCase(), order.getStatus().toLowerCase());
            assertEquals(String.format("order %s granular status = %s", order.getTrackingId(), granularStatus), granularStatus.toLowerCase(), order.getGranularStatus().toLowerCase());
        }, "check order granular status", 3);
    }

    @Then("^Operator verify that all orders status-granular status is \"([^\"]*)\"-\"([^\"]*)\"$")
    public void operatortVerifiesAllOrderStatus(String status, String granularStatus) {
        List<String> trackingIds = get(OrderCreateSteps.KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach(e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            operatortVerifiesOrderStatus(status, granularStatus);
        });
    }

    @Then("^Operator verify that \"([^\"]*)\" orders status-granular status is \"([^\"]*)\"-\"([^\"]*)\"$")
    public void operatortVerifiesPartialOrderStatus(String actionMode, String status, String granularStatus) {
        List<String> trackingIds;
        if(actionMode.equalsIgnoreCase(ACTION_SUCCESS)){
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
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach(e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            operatorSearchOrderByTrackingId();
            operatortVerifiesOrderEvent(event);
        });
        NvLogger.successf("%s event is published for all orders tracking ids %s", event, Arrays.toString(trackingIds.toArray()));
    }

    @When("^Operator force success order$")
    public void operatorForceSuccessOrder() {
        long orderId = get(KEY_CREATED_ORDER_ID);
        callWithRetry(() -> {
            getOrderClient().forceSuccess(orderId);
            NvLogger.success(DOMAIN, String.format("order id %d force successed", orderId));
        }, "force success order");
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
            NvLogger.success(DOMAIN, String.format("waypoint id %d forced %s", waypointId, action));
        }, String.format("admin force finish %s", action));
    }

    @When("^Operator tags order with PRIOR tag$")
    public void tagPriorOrder() {
        long tagId = TestConstants.ORDER_TAG_PRIOR_ID;
        operatorTagsOrder(tagId);
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
        }, "tag an order");
    }

    @When("^Operator tags all orders with PRIOR tag$")
    public void tagMultipleOrders() {
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach(e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            tagPriorOrder();
        });
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
                .findAny().orElseThrow(() -> new NvTestRuntimeException("transaction details not found"));
        return result;
    }

    private Event getOrderEvent(String event, long orderId) {
        List<Event> events = getEventClient().getOrderEventsByOrderId(orderId).getData();
        Event result;
        result = events.stream()
                .filter(e -> e.getType().equalsIgnoreCase(event))
                .findAny().orElseThrow(() -> new NvTestRuntimeException("order event details not found"));
        return result;
    }
}
