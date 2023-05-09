package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.model.other.CoreExceptionResponse;
import co.nvqa.common.core.model.reservation.BulkRouteReservationResponse;
import co.nvqa.common.core.utils.CoreScenarioStorageKeys;
import co.nvqa.common.model.DataEntity;
import co.nvqa.commons.constants.HttpConstants;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route.AddParcelToRouteRequest;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.assertj.core.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Binti Cahayati on 2020-07-01
 */
@ScenarioScoped
public class RoutingSteps extends BaseSteps {

  private static final Logger LOGGER = LoggerFactory.getLogger(RoutingSteps.class);

  @Override
  public void init() {

  }

  @When("Operator create an empty route")
  public void operatorCreateEmptyRoute(Map<String, String> arg1) {
    final String json = toJsonCamelCase(arg1);
    final Route route = fromJsonSnakeCase(json, Route.class);
    put(KEY_NINJA_DRIVER_ID, route.getDriverId());
    route.setComments("Created for Core API testing, created at: "
        + DateUtil.getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
    route.setTags(Arrays.asList(1, 4));
    route.setDate(DateUtil.generateUTCTodayDate());
    callWithRetry(() -> {
      Route result = getRouteClient().createRoute(route);
      Assertions.assertThat(route).as("created route is not null").isNotNull();
      put(KEY_CREATED_ROUTE, result);
      putInList(KEY_LIST_OF_CREATED_ROUTE_ID, result.getId());
      putInList(KEY_LIST_OF_HUB_IDS, route.getHubId());
      putInList(KEY_LIST_OF_ZONE_IDS, route.getZoneId());
      put(KEY_CREATED_ROUTE_ID, result.getId());
    }, "create empty route");
  }

  @When("Operator create an empty route with past date")
  public void operatorCreateEmptyRoutePastDate(Map<String, String> arg1) {
    final String json = toJsonCamelCase(arg1);
    final Route route = fromJsonSnakeCase(json, Route.class);
    route.setComments("Created for Core API testing");
    route.setTags(List.of(1, 4));
    route.setDate(DateUtil.generateUTCYesterdayDate());
    callWithRetry(() -> {
      final Route result = getRouteClient().createRoute(route);
      Assertions.assertThat(route).as("created route is not null").isNotNull();
      put(KEY_CREATED_ROUTE, result);
      putInList(KEY_LIST_OF_CREATED_ROUTE_ID, result.getId());
      putInList(KEY_LIST_OF_HUB_IDS, route.getHubId());
      putInList(KEY_LIST_OF_ZONE_IDS, route.getZoneId());
      put(KEY_CREATED_ROUTE_ID, result.getId());
    }, "create empty route");
  }

  @When("Operator add order to driver {string} route")
  public void operatorAddOrderToRoute(String type) {
    callWithRetry(() -> {
      final long routeId = get(KEY_CREATED_ROUTE_ID);
      final long orderId = get(KEY_CREATED_ORDER_ID);
      final AddParcelToRouteRequest request = new AddParcelToRouteRequest();
      request.setRouteId(routeId);
      request.setType(type);
      getRouteClient().addParcelToRoute(orderId, request);
      put(KEY_ROUTE_EVENT_SOURCE, "ADD_BY_ORDER");
      LOGGER.info("order id {} added to {} route id {}", orderId, type, routeId);
    }, "add parcel to route");
  }

  @When("Operator add order by tracking id to driver {string} route")
  public void operatorAddOrderByTrackingIdToRoute(String type) {
    callWithRetry(() -> {
      final long routeId = get(KEY_CREATED_ROUTE_ID);
      final String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      final AddParcelToRouteRequest request = new AddParcelToRouteRequest();
      request.setRouteId(routeId);
      request.setType(type);
      request.setTrackingId(trackingId);
      getRouteClient().addParcelToRouteByTrackingId(request);
      put(KEY_ROUTE_EVENT_SOURCE, "ADD_BY_TRACKING_OR_STAMP");
      LOGGER.info("order {} added to {} route id {}", trackingId, type, routeId);
    }, "add parcel to route");
  }

  @When("Operator add all orders to driver {string} route")
  public void operatorAddMultipleOrdersToRoute(String type) {
    final List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    orderIds.stream().distinct().forEach(e -> {
      put(KEY_CREATED_ORDER_ID, e);
      operatorAddOrderToRoute(type);
    });
  }

  @When("Operator delete driver route")
  public void operatorDeleteRoute() {
    callWithRetry(() -> {
      long routeId = get(KEY_CREATED_ROUTE_ID);
      getRouteClient().deleteRoute(routeId);
      LOGGER.info("route {} is successfully deleted", routeId);
    }, "delete driver route");
  }

  @When("Operator delete multiple driver routes")
  public void operatorDeleteMultipleRoute() {
    callWithRetry(() -> {
      List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);
      getRouteClient().deleteMultipleRoutes(routeIds);
      LOGGER.info("route {} is successfully deleted", Arrays.toString(routeIds.toArray()));
    }, "delete multiple routes");
  }

  @When("Operator delete driver route with status code {int}")
  public void operatorDeleteRouteUnSuccessFully(int statusCode) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      Response response = getRouteClient().deleteRouteAndGetRawResponse(routeId);
      Assertions.assertThat(response.getStatusCode()).as("response code").isEqualTo(statusCode);
      if (statusCode == HttpConstants.RESPONSE_200_SUCCESS) {
        Assertions.assertThat(response.getBody().asString()).as("response body ")
            .isEqualTo(f("[%d]", routeId));
      }
      put(KEY_DELETE_ROUTE_RESPONSE, response);
      put(KEY_ROUTE_EVENT_SOURCE, "ZONAL_ROUTING_REMOVE");
    }, "delete driver route");
  }

  @When("Operator verify delete route response with proper error message : {string}")
  public void verifyBadDeleteRoute(String message) {
    Response r = get(KEY_DELETE_ROUTE_RESPONSE);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    if (pickup != null) {
      Assertions.assertThat(r.getBody().asString()).as("response message is correct")
          .containsIgnoringCase(
              String.format("Reservation %d for Shipper %d has status %s. Cannot delete route.",
                  pickup.getReservationId(), pickup.getShipperId(),
                  pickup.getStatus().toUpperCase()));
    } else {
      final Order order = get(KEY_CREATED_ORDER);
      String type;
      if (order.getType().equalsIgnoreCase("Return")) {
        type = "Pickup";
      } else {
        type = "Delivery";
      }
      Assertions.assertThat(r.getBody().asString()).as("response message contains the message")
          .containsIgnoringCase(
              String.format("%s for Order %d has already been attempted. Cannot delete route.",
                  type, order.getId()));
    }
  }

  @When("Operator verify route response with proper error message below:")
  public void verifyBadUnarchivedRoute(Map<String, String> mapOfData) {
    Map<String, String> expectedData = resolveKeyValues(mapOfData);
    Response r = get(CoreScenarioStorageKeys.KEY_ROUTE_RESPONSE);
    Assertions.assertThat(r.getBody().asString()).as("error Message")
        .contains(f(expectedData.get("message"), expectedData.get("routeId")));
  }

  @When("Operator pull order out of {string} route")
  public void operatorPullOutOfRoute(String type) {
    callWithRetry(() -> {
      final String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      final Order order = OrderDetailHelper.getOrderDetails(trackingId);
      getRouteClient().pullOutWaypointFromRoute(order.getId(), type.toUpperCase());
      putInList(KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID, trackingId);
    }, "pull out of route");
  }

  @When("API Core - Operator verifies response of bulk add reservation to route")
  public void verifyBulkRouteRsvnResponse(Map<String, String> data) {
    Map<String, String> resolvedDataTable = resolveKeyValues(data);
    BulkRouteReservationResponse actualResponse = get(CoreScenarioStorageKeys.KEY_ROUTE_RESPONSE);

    List<CoreExceptionResponse> actualSuccessfulJobs = actualResponse.getSuccessfulJobs();
    List<CoreExceptionResponse> expectedSuccessfulJobs = fromJsonToList(
        resolvedDataTable.get("successfulJobs"), CoreExceptionResponse.class);
    Assertions.assertThat(actualSuccessfulJobs.size())
        .withFailMessage("successful_jobs response size doesnt match")
        .isEqualTo(expectedSuccessfulJobs.size());
    if (!expectedSuccessfulJobs.isEmpty()) {
      expectedSuccessfulJobs.forEach(
          o -> DataEntity.assertListContains(actualSuccessfulJobs, o, "successful_jobs list"));
    }

    List<CoreExceptionResponse> actualFailedJobs = actualResponse.getFailedJobs();
    List<CoreExceptionResponse> expectedFailedJobs = fromJsonToList(
        resolvedDataTable.get("failedJobs"), CoreExceptionResponse.class);
    Assertions.assertThat(actualFailedJobs.size())
        .withFailMessage("failed_jobs response size doesnt match")
        .isEqualTo(expectedFailedJobs.size());
    if (!expectedFailedJobs.isEmpty()) {
      expectedFailedJobs.forEach(
          o -> DataEntity.assertListContains(actualFailedJobs, o, "failed_jobs list"));
    }
  }
}
