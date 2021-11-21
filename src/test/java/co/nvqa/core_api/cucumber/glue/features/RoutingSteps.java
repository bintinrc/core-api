package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.constants.HttpConstants;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.route.AddParcelToRouteRequest;
import co.nvqa.commons.model.core.route.ArchiveRouteResponse;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import io.cucumber.java.After;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.cucumber.guice.ScenarioScoped;
import io.restassured.response.Response;

import java.time.ZoneId;
import java.time.ZonedDateTime;
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

  public static final String KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID = "key-list-pull-out-of-route-tracking-id";
  private static final String KEY_UNARCHIVE_ROUTE_RESPONSE = "key-unarchive-route-response";
  private static final String KEY_ARCHIVE_ROUTE_RESPONSE = "key-archive-route-response";
  private static final String KEY_DELETE_ROUTE_RESPONSE = "key-delete-route-response";
  public static final String KEY_ROUTE_EVENT_SOURCE = "key-route-event-source";

  @Override
  public void init() {

  }

  @When("^Operator create an empty route$")
  public void operatorCreateEmptyRoute(Map<String, String> arg1) {
    final String json = toJsonCamelCase(arg1);
    final Route route = fromJsonSnakeCase(json, Route.class);
    route.setComments("Created for Core API testing, created at: " + DateUtil
        .getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
    route.setTags(Arrays.asList(1, 4));
    route.setDate(generateUTCTodayDate());
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
    route.setTags(Arrays.asList(1, 4));
    route.setDate(generateUTCYesterdayDate());
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

  @Given("^Operator new add parcel to DP holding route$")
  public void operatorAddToDpHoldingRoute() {
    Long orderId = get(KEY_CREATED_ORDER_ID);
    Long routeId = get(KEY_CREATED_ROUTE_ID);
    getRouteClient().addToRouteDp(orderId, routeId);
    put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "ADD_BY_ORDER_DP");
  }

  @When("Operator add all orders to driver {string} route")
  public void
  operatorAddMultipleOrdersToRoute(String type) {
    final List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    orderIds.stream().distinct().forEach(e -> {
      put(KEY_CREATED_ORDER_ID,e );
      operatorAddOrderToRoute(type);
    });
  }

  @When("^Operator delete driver route$")
  public void operatorDeleteRoute() {
    callWithRetry(() -> {
      long routeId = get(KEY_CREATED_ROUTE_ID);
      getRouteClient().deleteRoute(routeId);
      LOGGER.info("route {} is successfully deleted", routeId);
    }, "delete driver route");
  }

  @When("^Operator delete multiple driver routes$")
  public void operatorDeleteMultipleRoute() {
    callWithRetry(() -> {
      List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);
      getRouteClient().deleteMultipleRoutes(routeIds);
      LOGGER.info("route {} is successfully deleted", Arrays.toString(routeIds.toArray()));
    }, "delete multiple routes");
  }

  @When("^Operator delete driver route with status code \"([^\"]*)\"$")
  public void operatorDeleteRouteUnSuccessFully(int statusCode) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      Response response = getRouteClient().deleteRouteAndGetRawResponse(routeId);
      assertEquals("response code", statusCode, response.getStatusCode());
      if (statusCode == HttpConstants.RESPONSE_200_SUCCESS) {
        assertEquals("response body", f("[%d]", routeId), response.getBody().asString());
      }
      put(KEY_DELETE_ROUTE_RESPONSE, response);
      put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "ZONAL_ROUTING_REMOVE");
    }, "delete driver route");
  }

  @When("Operator verify delete route response with proper error message : {}")
  public void verifyBadDeleteRoute(String message) {
    Response r = get(KEY_DELETE_ROUTE_RESPONSE);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    if (pickup != null) {
      Assertions.assertThat(r.getBody().asString()).as("response message is correct").containsIgnoringCase(String
          .format("Reservation %d for Shipper %d has status %s. Cannot delete route.",
              pickup.getId(), pickup.getShipperId(), pickup.getStatus().toUpperCase()));
    } else {
      final Order order = get(KEY_CREATED_ORDER);
      String type;
      if (order.getType().equalsIgnoreCase("Return")) {
        type = "Pickup";
      } else {
        type = "Delivery";
      }
      Assertions.assertThat(r.getBody().asString()).as("response message contains the message")
          .containsIgnoringCase(String
              .format("%s for Order %d has already been attempted. Cannot delete route.", type,
                  order.getId()));
    }
  }

  @When("Operator archives driver route")
  public void operatorArchiveRoute() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      getRouteClient().archiveRouteV2(routeId);
    }, "archive driver route");

    LOGGER.info("route {} is successfully archived", routeId);
  }

  @When("^Operator unarchives driver route with status code (\\d+)$")
  public void operatorUnArchiveRouteV2(int statusCode) {
    long routeId = get(KEY_CREATED_ROUTE_ID, 89L);
    callWithRetry(() -> {
      Response r = getRouteClient().unarchiveRouteV2AndGetRawResponse(routeId);
      assertEquals("status code", statusCode, r.getStatusCode());
      if (statusCode == HttpConstants.RESPONSE_200_SUCCESS) {
        assertTrue("response message",
            r.getBody().asString().equalsIgnoreCase("{\"new_route_status\":\"IN_PROGRESS\"}"));
      }
      put(KEY_UNARCHIVE_ROUTE_RESPONSE, r);
    }, "unarchive driver route v2");
  }

  @When("^Operator verify unarchive route response with proper error message : Route \"([^\"]*)\"$")
  public void verifyBadUnarchivedRoute(String message) {
    long routeId = get(KEY_CREATED_ROUTE_ID, 89L);
    Response r = get(KEY_UNARCHIVE_ROUTE_RESPONSE);
    assertTrue("response message",
        r.getBody().asString().contains(String.format("Route with id=%d %s", routeId, message)));
  }

  @When("^Operator archives multiple driver routes$")
  public void operatorArchiveMultipleRoutes() {
    List<Long> routes = get(KEY_LIST_OF_CREATED_ROUTE_ID);
    long[] request = routes.stream().mapToLong(e -> e).toArray();
    callWithRetry(() -> {
      ArchiveRouteResponse response = getRouteClient().archiveRoutes(request);
      boolean found = response.getArchivedRouteIds().containsAll(routes);
      Assertions.assertThat(found).as("archived route is found").isTrue();
    }, "archive driver route");

    LOGGER.info("multiple route ids {} are archived", Arrays.toString(routes.toArray()));
  }

  @When("^Operator archives invalid driver route$")
  public void operatorArchiveRouteInvalid() {
    long routeId = get(KEY_CREATED_ROUTE_ID, 0L);
    callWithRetry(() -> {
      ArchiveRouteResponse response = getRouteClient().archiveRoute(routeId);
      boolean found = response.getUnarchivedRouteIds().stream().anyMatch(e -> e.equals(routeId));
      Assertions.assertThat(found).as("archived route is found").isTrue();
    }, "archive driver route");

    LOGGER.info("route {} is unarchived", routeId);
  }

  @When("^Operator archives driver the same archived route$")
  public void operatorArchiveSameRoute() {
    operatorArchiveRoute();
  }

  @When("^Operator merge transaction waypoints$")
  public void operatorMergeRoute() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    callWithRetry(() -> {
      getRouteClient().mergeTransactions(routeId);
    }, "merge transaction waypoints");
  }

  @When("^Operator pull order out of \"([^\"]*)\" route$")
  public void operatorPullOutOfRoute(String type) {
    callWithRetry(() -> {
      final String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      final Order order = OrderDetailHelper.getOrderDetails(trackingId);
      getRouteClient().pullOutWaypointFromRoute(order.getId(), type.toUpperCase());
      putInList(KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID, trackingId);
    }, "pull out of route");
  }

  @When("^Operator pull DP order out of route$")
  public void operatorPullOutDpOrderOfRoute() {
    callWithRetry(() -> {
      final String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
      final Order order = OrderDetailHelper.getOrderDetails(trackingId);
      getRouteClient().pullOutDpOrderFromRoute(order.getId());
      put(RoutingSteps.KEY_ROUTE_EVENT_SOURCE, "REMOVE_BY_ORDER_DP");
    }, "pull out of route");
  }

  @When("^Operator archives driver route with status code (\\d+)$")
  public void operatorArchiveRouteV2(int statusCode) {
    long routeId = get(KEY_CREATED_ROUTE_ID, 1234L);
    callWithRetry(() -> {
      Response response = getRouteClient().archiveRouteV2AndGetRawResponse(routeId);
      assertEquals("archive route response", statusCode, response.getStatusCode());
      put(KEY_ARCHIVE_ROUTE_RESPONSE, response);
    }, "archive driver route V2");
  }

  @When("Operator verify archive route response with proper error message : Route {string}")
  public void operatorVerifyArchiveV2Route(String message) {
    callWithRetry(() -> {
      long routeId = get(KEY_CREATED_ROUTE_ID, 1234L);
      Response response = get(KEY_ARCHIVE_ROUTE_RESPONSE);
      assertTrue("response message", response.getBody().asString()
          .contains(String.format("Route with id=%d %s", routeId, message)));

    }, "verify archive driver route v2");
  }

  private String generateUTCTodayDate() {
    ZonedDateTime startDateTime = DateUtil.getStartOfDay(DateUtil.getDate());
    return DateUtil
        .displayDateTime(startDateTime.withZoneSameInstant(ZoneId.of("UTC")));
  }

  private String generateUTCYesterdayDate() {
    ZonedDateTime startDateTime = DateUtil.getStartOfDay(DateUtil.getDate()).minusDays(1);
    return DateUtil
        .displayDateTime(startDateTime.withZoneSameInstant(ZoneId.of("UTC")));
  }

  @After("@ArchiveDriverRoutes")
  public void cleanCreatedRoute() {
    final List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);

    try {
      if (routeIds != null) {
        routeIds.forEach(e -> getRouteClient().archiveRouteV2(e));
      }
    } catch (Throwable t) {
      LOGGER.warn("Failed to archive route(s)");
    }
  }
}
