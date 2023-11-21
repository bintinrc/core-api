package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.common.core.model.order.Order;
import co.nvqa.common.core.model.order.Order.Transaction;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Then;
import java.util.List;

/**
 * @author Binti Cahayati on 2020-07-13
 */
@ScenarioScoped
public class OrderDetailHelper extends BaseSteps {

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
    Order order = getOrderDetails(trackingId);
    put(KEY_CREATED_ORDER, order);
    Transaction transaction = getTransaction(order, transactionType, Transaction.STATUS_PENDING);
    put(KEY_WAYPOINT_ID, transaction.getWaypointId());
    put(KEY_TRANSACTION_ID, transaction.getId());
    putInList(KEY_LIST_OF_WAYPOINT_IDS, transaction.getWaypointId());
  }
}
