package co.nvqa.core_api.cucumber.glue;

import co.nvqa.common.core.client.BatchUpdatePodClient;
import co.nvqa.common.core.client.EventClient;
import co.nvqa.common.core.client.OrderClient;
import co.nvqa.common.core.client.PickupClient;
import co.nvqa.common.core.client.RouteClient;
import co.nvqa.common.core.client.RouteMonitoringClient;
import co.nvqa.common.cucumber.glue.StandardSteps;
import co.nvqa.common.ordercreate.client.OrderSearchClient;
import co.nvqa.commonauth.utils.TokenUtils;
import co.nvqa.commonsort.client.InboundClient;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import co.nvqa.core_api.cucumber.glue.util.CoreApiScenarioStorageKeys;

/**
 * put any common methods here all step class should extend this class
 */
public abstract class BaseSteps extends StandardSteps<ScenarioManager> implements
    CoreApiScenarioStorageKeys {

  private static OrderSearchClient orderSearchClient;
  private static OrderClient orderClient;
  private RouteClient routeClient;
  private EventClient eventClient;
  private PickupClient shipperPickupClient;
  private InboundClient inboundClient;
  private co.nvqa.common.webhook.client.ShipperClient shipperWebhookClient;
  private RouteMonitoringClient routeMonitoringClient;
  private BatchUpdatePodClient batchUpdatePodClient;

  protected static synchronized OrderSearchClient getOrderSearchClient() {
    if (orderSearchClient == null) {
      orderSearchClient = new OrderSearchClient();
    }
    return orderSearchClient;
  }

  protected static synchronized OrderClient getOrderClient() {
    if (orderClient == null) {
      orderClient = new OrderClient();
    }
    return orderClient;
  }

  protected static synchronized OrderClient getShipperOrderClient(String shipperToken) {
    return new OrderClient(shipperToken);
  }

  protected synchronized RouteClient getRouteClient() {
    if (routeClient == null) {
      routeClient = new RouteClient();
    }
    return routeClient;
  }

  protected synchronized RouteMonitoringClient getRouteMonitoringClient() {
    if (routeMonitoringClient == null) {
      routeMonitoringClient = new RouteMonitoringClient();
    }
    return routeMonitoringClient;
  }

  protected synchronized EventClient getEventClient() {
    if (eventClient == null) {
      eventClient = new EventClient();
    }
    return eventClient;
  }

  protected synchronized PickupClient getShipperPickupClient() {
    if (shipperPickupClient == null) {
      shipperPickupClient = new PickupClient();
    }
    return shipperPickupClient;
  }

  protected synchronized InboundClient getInboundClient() {
    if (inboundClient == null) {
      inboundClient = new InboundClient();
    }
    return inboundClient;
  }

  protected synchronized co.nvqa.common.webhook.client.ShipperClient getShipperWebhookClient() {
    if (shipperWebhookClient == null) {
      shipperWebhookClient = new co.nvqa.common.webhook.client.ShipperClient(
          TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken(), null);
    }
    return shipperWebhookClient;
  }

  protected synchronized BatchUpdatePodClient getBatchUpdatePodClient() {
    if (batchUpdatePodClient == null) {
      batchUpdatePodClient = new BatchUpdatePodClient();
    }
    return batchUpdatePodClient;
  }
}
