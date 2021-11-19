package co.nvqa.core_api.cucumber.glue;

import co.nvqa.commons.client.core.BatchUpdatePodClient;
import co.nvqa.commons.client.core.EventClient;
import co.nvqa.commons.client.core.InboundClient;
import co.nvqa.commons.client.core.OrderClient;
import co.nvqa.commons.client.core.RouteClient;
import co.nvqa.commons.client.core.RouteMonitoringClient;
import co.nvqa.commons.client.core.ShipperPickupClient;
import co.nvqa.commons.client.order_search.OrderSearchClient;
import co.nvqa.commons.client.reservation.ReservationV2Client;
import co.nvqa.commons.client.shipper.ShipperClient;
import co.nvqa.commons.cucumber.glue.StandardSteps;
import co.nvqa.commons.util.StandardTestUtils;
import co.nvqa.core_api.cucumber.glue.support.AuthHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;

/**
 * put any common methods here all step class should extend this class
 */
public abstract class BaseSteps extends StandardSteps<ScenarioManager> {

  private static final long DEFAULT_FALLBACK_MS = 500;
  private static final int DEFAULT_RETRY = 30;

  private static OrderSearchClient orderSearchClient;
  private static OrderClient orderClient;
  private RouteClient routeClient;
  private EventClient eventClient;
  private ShipperPickupClient shipperPickupClient;
  private ReservationV2Client reservationV2Client;
  private InboundClient inboundClient;
  private ShipperClient shipperClient;
  private RouteMonitoringClient routeMonitoringClient;
  private BatchUpdatePodClient batchUpdatePodClient;

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
      routeClient = new RouteClient(TestConstants.API_BASE_URL, AuthHelper.getOperatorAuthToken());
    }
    return routeClient;
  }

  protected synchronized RouteMonitoringClient getRouteMonitoringClient() {
    if (routeMonitoringClient == null) {
      routeMonitoringClient = new RouteMonitoringClient(TestConstants.API_BASE_URL,
          AuthHelper.getOperatorAuthToken());
    }
    return routeMonitoringClient;
  }

  protected static synchronized OrderSearchClient getOrderSearchClient() {
    if (orderSearchClient == null) {
      orderSearchClient = new OrderSearchClient(TestConstants.API_BASE_URL,
          AuthHelper.getOperatorAuthToken());
    }
    return orderSearchClient;
  }

  protected static synchronized OrderClient getOrderClient() {
    if (orderClient == null) {
      orderClient = new OrderClient(TestConstants.API_BASE_URL, AuthHelper.getOperatorAuthToken());
    }
    return orderClient;
  }

  protected static synchronized OrderClient getShipperOrderClient(String shipperToken) {
    return new OrderClient(TestConstants.API_BASE_URL, shipperToken);
  }

  protected synchronized EventClient getEventClient() {
    if (eventClient == null) {
      eventClient = new EventClient(TestConstants.API_BASE_URL, AuthHelper.getOperatorAuthToken());
    }
    return eventClient;
  }

  protected synchronized ShipperPickupClient getShipperPickupClient() {
    if (shipperPickupClient == null) {
      shipperPickupClient = new ShipperPickupClient(TestConstants.API_BASE_URL,
          AuthHelper.getOperatorAuthToken());
    }
    return shipperPickupClient;
  }

  protected synchronized ReservationV2Client getReservationV2Client() {
    if (reservationV2Client == null) {
      reservationV2Client = new ReservationV2Client(TestConstants.API_BASE_URL,
          AuthHelper.getOperatorAuthToken());
    }
    return reservationV2Client;
  }

  protected synchronized InboundClient getInboundClient() {
    if (inboundClient == null) {
      inboundClient = new InboundClient(TestConstants.API_BASE_URL,
          AuthHelper.getOperatorAuthToken());
    }
    return inboundClient;
  }

  protected synchronized ShipperClient getShipperClient() {
    if (shipperClient == null) {
      shipperClient = new ShipperClient(TestConstants.API_BASE_URL,
          AuthHelper.getOperatorAuthToken());
    }
    return shipperClient;
  }

  protected synchronized BatchUpdatePodClient getBatchUpdatePodClient() {
    if (batchUpdatePodClient == null) {
      batchUpdatePodClient = new BatchUpdatePodClient(TestConstants.API_BASE_URL,
          AuthHelper.getOperatorAuthToken());
    }
    return batchUpdatePodClient;
  }
}
