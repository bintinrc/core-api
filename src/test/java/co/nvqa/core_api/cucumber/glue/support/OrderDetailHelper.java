package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.common.core.model.order.Order;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Then;
import java.util.List;

/**
 * @author Binti Cahayati on 2020-07-13
 */
@ScenarioScoped
public class OrderDetailHelper extends BaseSteps {

  public static Order searchOrder(String trackingIdOrStampId) {
    return getOrderSearchClient().searchOrderByTrackingId(trackingIdOrStampId);
  }

  public static Order getOrderDetails(String trackingId) {
    long orderId = searchOrder(trackingId).getId();
    Order order = getOrderClient().getOrder(orderId);
    return order;
  }

  public static Order.Transaction getTransaction(Order order, String type, String status) {
    List<Order.Transaction> transactions = order.getTransactions();
    Order.Transaction result;
    result = transactions.stream()
        .filter(e -> e.getType().equalsIgnoreCase(type))
        .filter(e -> e.getStatus().equalsIgnoreCase(status))
        .findAny().orElseThrow(() -> new NvTestRuntimeException("transaction details not found"));
    return result;
  }

  @Override
  public void init() {

  }

  @Then("Operator get {string} transaction waypoint Ids for all orders")
  public void getWaypointIdAllOrders(String transactionType) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      getTransactionWaypointId(transactionType);
    });
  }

  private void getTransactionWaypointId(String transactionType) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    co.nvqa.commons.model.core.Order order = OrderDetailHelper.getOrderDetails(trackingId);
    put(KEY_CREATED_ORDER, order);
    Transaction transaction = OrderDetailHelper
        .getTransaction(order, transactionType, Transaction.STATUS_PENDING);
    put(KEY_WAYPOINT_ID, transaction.getWaypointId());
    put(KEY_TRANSACTION_ID, transaction.getId());
    putInList(KEY_LIST_OF_WAYPOINT_IDS, transaction.getWaypointId());
  }
}
