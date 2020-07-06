package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.model.core.event.Event;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.runtime.java.guice.ScenarioScoped;
import org.junit.Assert;

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

    @Override
    public void init(){

    }

    @Then("^Operator search for created order$")
    public void operatorSearchOrderByTrackingId(){
        String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
        callWithRetry(() -> {
            NvLogger.infof("retrieve created order details from core orders for tracking id %s", trackingId);
            Order order = getOrderDetails(trackingId);
            put(KEY_CREATED_ORDER, order);
            Assert.assertNotNull("retrieved order is not null", order);
            put(KEY_CREATED_ORDER_ID, order.getId());
            Assert.assertNotNull("order id is not null", order.getId());
            NvLogger.successf("order id = %d is successfully retrieved from core", order.getId());
        }, "retrieve order details from core");
    }

    @Then("^Operator search for \"([^\"]*)\" transaction with status \"([^\"]*)\"$")
    public void operatorSearchTransaction(String type, String status){
        String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
        Order order = getOrderDetails(trackingId);
        put(KEY_CREATED_ORDER, order);
        callWithRetry(() -> {
            Transaction transaction = getTransaction(order, type, status);
            Assert.assertNotNull("retrieved transaction is not null", transaction);
            NvLogger.successf("retrieved transaction for id %d", transaction.getId());
            put(KEY_TRANSACTION_DETAILS, transaction);
            put(KEY_TRANSACTION_ID, transaction.getId());
            putInList(KEY_LIST_OF_TRANSACTION_IDS,transaction.getId());
            putInList(KEY_LIST_OF_WAYPOINT_IDS, transaction.getWaypointId());
            put(KEY_WAYPOINT_ID, transaction.getWaypointId());
        }, "retrieve transaction details from core");
    }

    @Then("^Operator search for multiple \"([^\"]*)\" transactions with status \"([^\"]*)\"$")
    public void operatorSearchMultipleTransaction(String type, String status){
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach( e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            operatorSearchTransaction(type, status);
        });
    }

    @Then("^Operator checks that \"([^\"]*)\" event is published$")
    public void operatortVerifiesOrderEvent(String event){
        long orderId = get(KEY_CREATED_ORDER_ID);
        callWithRetry(() -> {
            Event result = getOrderEvent(event, orderId);
            Assert.assertEquals("%s event is published", event.toLowerCase(), result.getType().toLowerCase());
            NvLogger.successf("%s event is published for order id %d",result.getType(), orderId);
        }, String.format("%s event is published for order id %d",event, orderId));
    }

    @Then("^Operator checks that for all orders, \"([^\"]*)\" event is published$")
    public void operatortVerifiesOrderEventForEach(String event){
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach( e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            operatorSearchOrderByTrackingId();
            operatortVerifiesOrderEvent(event);
        });
        NvLogger.successf("%s event is published for all orders tracking ids %s", event, Arrays.toString(trackingIds.toArray()));
    }

    @When("^Operator force success order$")
    public void operatorForceSuccessOrder(){
        long orderId = get(KEY_CREATED_ORDER_ID);
        getOrderClient().forceSuccess(orderId);
        NvLogger.success(DOMAIN, String.format("order id %d force successed", orderId));
    }

    @When("^Operator force \"([^\"]*)\" \"([^\"]*)\" waypoint$")
    public void operatorForceFailOrder(String action, String type){
        operatorSearchTransaction(type, Transaction.STATUS_PENDING);
        long waypointId = get(KEY_WAYPOINT_ID);
        long routeId = get(KEY_CREATED_ROUTE_ID);
        if(action.equalsIgnoreCase(ACTION_FAIL)){
            getOrderClient().forceFailWaypoint(routeId, waypointId, TestConstants.FAILURE_REASON_ID);
        } else {
            getOrderClient().forceSuccessWaypoint(routeId, waypointId);
        }
        NvLogger.success(DOMAIN, String.format("waypoint id %d forced %s",waypointId, action));
    }

    private Order searchOrder(String trackingIdOrStampId) {
        return getOrderSearchClient().searchOrderByTrackingId(trackingIdOrStampId);
    }

    private Order getOrderDetails(String trackingId){
        long orderId = searchOrder(trackingId).getId();
        Order order = getOrderClient().getOrder(orderId);
        Assert.assertNotNull("order details is not null",order);
        return order;
    }

    private Transaction getTransaction(Order order, String type, String status){
        List<Transaction> transactions = order.getTransactions();
        Transaction result;
        try {
             result = transactions.stream()
                    .filter(e-> e.getType().equalsIgnoreCase(type))
                    .filter(e-> e.getStatus().equalsIgnoreCase(status))
                    .findAny().get();

        } catch (Exception ex) {
            throw new AssertionError(ex);
        }
        return result;
    }

    private Event getOrderEvent(String event, long orderId){
        List<Event> events = getEventClient().getOrderEventsByOrderId(orderId).getData();
        Event result;
        try {
            result = events.stream().filter(e-> e.getType().equalsIgnoreCase(event)).findAny().get();
        } catch (Exception ex){
            throw new AssertionError(ex);
        }
        return result;
    }
}
