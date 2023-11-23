package co.nvqa.core_api.cucumber.glue;

import co.nvqa.common.core.client.BatchUpdatePodClient;
import co.nvqa.common.core.client.EventClient;
import co.nvqa.common.core.client.OrderClient;
import co.nvqa.common.core.client.PickupClient;
import co.nvqa.common.core.client.RouteClient;
import co.nvqa.common.core.client.RouteMonitoringClient;
import co.nvqa.common.core.model.order.Order;
import co.nvqa.common.core.model.order.Order.Transaction;
import co.nvqa.common.cucumber.glue.StandardSteps;
import co.nvqa.common.ordercreate.client.OrderSearchClient;
import co.nvqa.common.ordercreate.model.OrderSearchRequest;
import co.nvqa.common.ordercreate.model.OrderSearchResponse.OrderSearch;
import co.nvqa.common.utils.NvTestRuntimeException;
import co.nvqa.common.webhook.client.ShipperClient;
import co.nvqa.commonauth.utils.TokenUtils;
import co.nvqa.commonsort.client.InboundClient;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import co.nvqa.core_api.cucumber.glue.util.CoreApiScenarioStorageKeys;
import java.util.Collections;
import java.util.List;
import javax.inject.Inject;
import lombok.Getter;

/**
 * put any common methods here all step class should extend this class
 */
public abstract class BaseSteps extends StandardSteps<ScenarioManager> implements
    CoreApiScenarioStorageKeys {

  @Inject
  @Getter
  private OrderSearchClient orderSearchClient;
  @Inject
  @Getter
  private OrderClient orderClient;
  @Inject
  @Getter
  private RouteClient routeClient;
  @Inject
  @Getter
  private EventClient eventClient;
  @Inject
  @Getter
  private PickupClient shipperPickupClient;
  @Inject
  @Getter
  private InboundClient inboundClient;

  private ShipperClient shipperWebhookClient;
  @Inject
  @Getter
  private RouteMonitoringClient routeMonitoringClient;
  @Inject
  @Getter
  private BatchUpdatePodClient batchUpdatePodClient;

  protected synchronized OrderClient getShipperOrderClient(String shipperToken) {
    return new OrderClient(shipperToken);
  }

  protected synchronized ShipperClient getShipperWebhookClient() {
    if (shipperWebhookClient == null) {
      shipperWebhookClient = new ShipperClient(
          TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken(), null);
    }
    return shipperWebhookClient;
  }


  protected OrderSearch searchOrder(String trackingIdOrStampId) {
    OrderSearchRequest request = new OrderSearchRequest();
    request.addOrReplaceStringFilter("tracking_id", Collections.singletonList(trackingIdOrStampId));
    return orderSearchClient
        .searchOrders(request).getSearchData()
        .get(0).getOrder();
  }

  protected Order getOrderDetails(String trackingId) {
    long orderId = searchOrder(trackingId).getId();
    Order order = getOrderClient().getOrder(orderId);
    return order;
  }

  protected Order.Transaction getTransaction(Order order, String type, String status) {
    List<Transaction> transactions = order.getTransactions();
    Order.Transaction result;
    result = transactions.stream()
        .filter(e -> e.getType().equalsIgnoreCase(type))
        .filter(e -> e.getStatus().equalsIgnoreCase(status))
        .findAny().orElseThrow(() -> new NvTestRuntimeException("transaction details not found"));
    return result;
  }
}
