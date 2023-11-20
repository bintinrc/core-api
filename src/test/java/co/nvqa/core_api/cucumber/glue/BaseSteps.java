package co.nvqa.core_api.cucumber.glue;

import co.nvqa.common.core.client.BatchUpdatePodClient;
import co.nvqa.common.core.client.EventClient;
import co.nvqa.common.core.client.OrderClient;
import co.nvqa.common.core.client.PickupClient;
import co.nvqa.common.core.client.RouteClient;
import co.nvqa.common.core.client.RouteMonitoringClient;
import co.nvqa.common.cucumber.glue.StandardSteps;
import co.nvqa.common.ordercreate.client.OrderSearchClient;
import co.nvqa.common.webhook.client.ShipperClient;
import co.nvqa.commonauth.utils.TokenUtils;
import co.nvqa.commonsort.client.InboundClient;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import co.nvqa.core_api.cucumber.glue.util.CoreApiScenarioStorageKeys;
import javax.inject.Inject;

/**
 * put any common methods here all step class should extend this class
 */
public abstract class BaseSteps extends StandardSteps<ScenarioManager> implements
    CoreApiScenarioStorageKeys {

  @Inject
  private static OrderSearchClient orderSearchClient;
  @Inject
  private static OrderClient orderClient;
  @Inject
  private RouteClient routeClient;
  @Inject
  private EventClient eventClient;
  @Inject
  private PickupClient shipperPickupClient;
  @Inject
  private InboundClient inboundClient;
  private ShipperClient shipperWebhookClient;
  @Inject
  private RouteMonitoringClient routeMonitoringClient;
  @Inject
  private BatchUpdatePodClient batchUpdatePodClient;

  protected static synchronized OrderSearchClient getOrderSearchClient() {
    return orderSearchClient;
  }

  protected static synchronized OrderClient getOrderClient() {
    return orderClient;
  }

  protected static synchronized OrderClient getShipperOrderClient(String shipperToken) {
    return new OrderClient(shipperToken);
  }

  protected synchronized RouteClient getRouteClient() {
    return routeClient;
  }

  protected synchronized RouteMonitoringClient getRouteMonitoringClient() {
    return routeMonitoringClient;
  }

  protected synchronized EventClient getEventClient() {
    return eventClient;
  }

  protected synchronized PickupClient getShipperPickupClient() {
    return shipperPickupClient;
  }

  protected synchronized InboundClient getInboundClient() {
    return inboundClient;
  }

  protected synchronized ShipperClient getShipperWebhookClient() {
    if (shipperWebhookClient == null) {
      shipperWebhookClient = new ShipperClient(
          TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken(), null);
    }
    return shipperWebhookClient;
  }

  protected synchronized BatchUpdatePodClient getBatchUpdatePodClient() {
    return batchUpdatePodClient;
  }
}
