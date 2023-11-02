package co.nvqa.core_api.cucumber.glue;

import co.nvqa.common.core.client.BatchUpdatePodClient;
import co.nvqa.common.core.client.OrderClient;
import co.nvqa.common.cucumber.glue.StandardSteps;
import co.nvqa.commonauth.utils.TokenUtils;
import co.nvqa.commons.client.core.EventClient;
import co.nvqa.commons.client.core.RouteClient;
import co.nvqa.commons.client.core.RouteMonitoringClient;
import co.nvqa.commons.client.core.ShipperPickupClient;
import co.nvqa.commons.client.order_search.OrderSearchClient;
import co.nvqa.commons.client.reservation.ReservationV2Client;
import co.nvqa.commons.client.shipper.ShipperClient;
import co.nvqa.commons.util.StandardTestUtils;
import co.nvqa.commonsort.client.InboundClient;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import co.nvqa.core_api.cucumber.glue.util.CoreApiScenarioStorageKeys;

/**
 * put any common methods here all step class should extend this class
 */
public abstract class BaseSteps extends StandardSteps<ScenarioManager> implements
    CoreApiScenarioStorageKeys {

  private static final long DEFAULT_FALLBACK_MS = 500;
  private static final int DEFAULT_RETRY = 10;

  private static OrderSearchClient orderSearchClient;
  private static OrderClient orderClient;
  private static co.nvqa.common.core.client.OrderClient orderClientV2;
  private RouteClient routeClient;
  private EventClient eventClient;
  private ShipperPickupClient shipperPickupClient;
  private ReservationV2Client reservationV2Client;
  private InboundClient inboundClient;
  private ShipperClient shipperClient;
  private co.nvqa.common.webhook.client.ShipperClient shipperWebhookClient;
  private RouteMonitoringClient routeMonitoringClient;
  private BatchUpdatePodClient batchUpdatePodClient;

  protected static synchronized OrderSearchClient getOrderSearchClient() {
    if (orderSearchClient == null) {
      orderSearchClient = new OrderSearchClient(TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken());
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
    return new OrderClient(TestConstants.API_BASE_URL, shipperToken);
  }

  @SuppressWarnings("unchecked")
  protected void callWithRetry(Runnable runnable, String methodName) {
    retryIfAssertionErrorOrRuntimeExceptionOccurred(runnable, methodName, DEFAULT_FALLBACK_MS,
        DEFAULT_RETRY);
  }

  @SuppressWarnings("unchecked")
  protected void callWithRetry(Runnable runnable, String methodName, int maxRetry) {
    retryIfAssertionErrorOrRuntimeExceptionOccurred(runnable, methodName, DEFAULT_FALLBACK_MS,
        maxRetry);
  }

  protected void doStepPause() {
    StandardTestUtils.pause2s();
  }

  protected synchronized RouteClient getRouteClient() {
    if (routeClient == null) {
      routeClient = new RouteClient(TestConstants.API_BASE_URL, TokenUtils.getOperatorAuthToken());
    }
    return routeClient;
  }

  protected synchronized RouteMonitoringClient getRouteMonitoringClient() {
    if (routeMonitoringClient == null) {
      routeMonitoringClient = new RouteMonitoringClient(TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken());
    }
    return routeMonitoringClient;
  }

  protected synchronized EventClient getEventClient() {
    if (eventClient == null) {
      eventClient = new EventClient(TestConstants.API_BASE_URL, TokenUtils.getOperatorAuthToken());
    }
    return eventClient;
  }

  protected synchronized ShipperPickupClient getShipperPickupClient() {
    if (shipperPickupClient == null) {
      shipperPickupClient = new ShipperPickupClient(TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken());
    }
    return shipperPickupClient;
  }

  protected synchronized ReservationV2Client getReservationV2Client() {
    if (reservationV2Client == null) {
      reservationV2Client = new ReservationV2Client(TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken());
    }
    return reservationV2Client;
  }

  protected synchronized InboundClient getInboundClient() {
    if (inboundClient == null) {
      inboundClient = new InboundClient();
    }
    return inboundClient;
  }

  protected synchronized ShipperClient getShipperClient() {
    if (shipperClient == null) {
      shipperClient = new ShipperClient(TestConstants.API_BASE_URL,
          TokenUtils.getOperatorAuthToken());
    }
    return shipperClient;
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
