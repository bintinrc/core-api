package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.util.List;

/**
 * @author Binti Cahayati on 2020-07-13
 */
@ScenarioScoped
public class OrderDetailHelper extends BaseSteps {

    @Override
    public void init(){

    }

    public static Order searchOrder(String trackingIdOrStampId) {
        return getOrderSearchClient().searchOrderByTrackingId(trackingIdOrStampId);
    }

    public static Order getOrderDetails(String trackingId){
        long orderId = searchOrder(trackingId).getId();
        Order order = getOrderClient().getOrder(orderId);
        return order;
    }

    public static Transaction getTransaction(Order order, String type, String status){
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
}
