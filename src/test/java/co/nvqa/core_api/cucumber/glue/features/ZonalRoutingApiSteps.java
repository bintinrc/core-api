package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.model.route.RouteRequest;
import co.nvqa.common.core.model.route.RouteResponse;
import co.nvqa.common.utils.DateUtil;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.assertj.core.api.Assertions;

public class ZonalRoutingApiSteps extends BaseSteps {

  @Override
  public void init() {

  }

  //    TODO move all these steps to common-core
  @When("Operator create a route and assign waypoint from Zonal Routing API")
  public void operatorCreateRouteZr(Map<String, String> arg1) {
    final String json = toJsonCamelCase(arg1);
    final RouteRequest route = fromJsonSnakeCase(json, RouteRequest.class);
    final List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    route.setTags(Arrays.asList(1, 4));
    route.setDate(DateUtil.generateUTCTodayDate());
    route.setWaypoints(waypointIds);
    doWithRetry(() -> {
      RouteResponse result = getRouteClient().createRoute(
          route);
      Assertions.assertThat(result).as("created route is not null").isNotNull();
      put(KEY_CREATED_ROUTE, result);
      putInList(KEY_LIST_OF_CREATED_ROUTE_ID, result.getId());
      put(KEY_CREATED_ROUTE_ID, result.getId());
      put(KEY_ROUTE_EVENT_SOURCE, "ZONAL_ROUTING_CREATE");
    }, "zonal routing create route");
  }

  //add unrouted waypoints & edit waypoint sequence
  @When("Operator edit route from Zonal Routing API")
  public void operatorEditRouteZr(Map<String, String> arg1) {
    final Long routeId = get(KEY_CREATED_ROUTE_ID);
    final String json = toJsonCamelCase(arg1);
    final RouteRequest route = fromJsonSnakeCase(json, RouteRequest.class);
    final List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    final List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    if (arg1.containsKey("to_edit_sequence")) {
      Collections.shuffle(waypointIds);
    }
    route.setTags(Arrays.asList(1, 4));
    route.setWaypoints(waypointIds);
    route.setId(routeId);
    put(KEY_LIST_OF_WAYPOINTS_SEQUENCE, waypointIds);
    doWithRetry(() -> {
      List<RouteResponse> result = getRouteClient()
          .zonalRoutingEditRoute(Collections.singletonList(route));
      Assertions.assertThat(result.get(0)).as("updated route is not null").isNotNull();
      remove(KEY_LIST_OF_CREATED_ORDER_ID);
      orderIds.remove(0);
      putAllInList(KEY_LIST_OF_CREATED_ORDER_ID, orderIds);
      put(KEY_ROUTE_EVENT_SOURCE, "ZONAL_ROUTING_UPDATE");
    }, "zonal routing edit route");
  }

  //remove waypoints
  @When("Operator edit route by removing waypoints from Zonal Routing API")
  public void operatorEditRouteRemoveZr(Map<String, String> arg1) {
    final long routeId = get(KEY_CREATED_ROUTE_ID);
    final String json = toJsonCamelCase(arg1);
    final RouteRequest route = fromJsonSnakeCase(json, RouteRequest.class);
    final Long waypointId = get(KEY_WAYPOINT_ID);
    final Long transactionId = get(KEY_TRANSACTION_ID);
    final Long orderId = get(KEY_CREATED_ORDER_ID);
    final List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    final List<Long> transactionIds = get(KEY_LIST_OF_TRANSACTION_IDS);
    final List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    route.setTags(Arrays.asList(1, 4));
    route.setWaypoints(Collections.singletonList(waypointId));
    route.setId(routeId);
    doWithRetry(() -> {
      List<RouteResponse> result = getRouteClient()
          .zonalRoutingEditRoute(Collections.singletonList(route));
      Assertions.assertThat(result.get(0)).as("updated route is not null").isNotNull();
      put(KEY_ROUTE_EVENT_SOURCE, "ZONAL_ROUTING_UPDATE");
      //remove all waypoints, transactions, orders from map
      remove(KEY_LIST_OF_WAYPOINT_IDS);
      remove(KEY_LIST_OF_TRANSACTION_IDS);
      remove(KEY_LIST_OF_CREATED_ORDER_ID);
      //include only removed waypoints, transactions, orders
      waypointIds.remove(waypointId);
      transactionIds.remove(transactionId);
      orderIds.remove(orderId);
      //add only removed waypoints, transactions, orders
      putAllInList(KEY_LIST_OF_WAYPOINT_IDS, waypointIds);
      putAllInList(KEY_LIST_OF_TRANSACTION_IDS, transactionIds);
      putAllInList(KEY_LIST_OF_CREATED_ORDER_ID, orderIds);
      putAllInList(KEY_LIST_OF_REMAINING_WAYPOINT_IDS, route.getWaypoints());
      putAllInList(KEY_LIST_OF_REMOVED_WAYPOINT_IDS, waypointIds);
    }, "zonal routing edit route");
  }

  //move routed waypoints to another route
  @When("Operator edit route by moving to another route from Zonal Routing API")
  public void operatorEditRouteMoveToAnotherRouteZr(Map<String, String> arg1) {
    final List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);
    final String json = toJsonCamelCase(arg1);
    final Long waypointId = get(KEY_WAYPOINT_ID);
    final Long transactionId = get(KEY_TRANSACTION_ID);
    final Long orderId = get(KEY_CREATED_ORDER_ID);
    final List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    final List<Long> transactionIds = get(KEY_LIST_OF_TRANSACTION_IDS);
    final List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);

    List<RouteRequest> request = new ArrayList<>();
    //removed from route
    RouteRequest removedRoute = fromJson(json, RouteRequest.class);
    removedRoute.setTags(Arrays.asList(1, 4));
    removedRoute.setWaypoints(Collections.singletonList(waypointId));
    removedRoute.setId(routeIds.get(0));
    request.add(removedRoute);

    //moved to new route
    RouteRequest movedToRoute = fromJson(json, RouteRequest.class);
    movedToRoute.setTags(Arrays.asList(1, 4));
    waypointIds.remove(waypointId);
    movedToRoute.setWaypoints(waypointIds);
    movedToRoute.setId(routeIds.get(1));
    request.add(movedToRoute);

    doWithRetry(() -> {
      List<RouteResponse> result = getRouteClient().zonalRoutingEditRoute(request);
      Assertions.assertThat(result.get(0)).as("removed route is not null").isNotNull();
      Assertions.assertThat(result.get(1)).as("moved to route is not null").isNotNull();
      put(KEY_ROUTE_EVENT_SOURCE, "ZONAL_ROUTING_UPDATE");
      remove(KEY_LIST_OF_WAYPOINT_IDS);
      remove(KEY_LIST_OF_TRANSACTION_IDS);
      remove(KEY_LIST_OF_CREATED_ORDER_ID);
      orderIds.remove(orderId);
      waypointIds.remove(waypointId);
      transactionIds.remove(transactionId);
      putAllInList(KEY_LIST_OF_WAYPOINT_IDS, waypointIds);
      putAllInList(KEY_LIST_OF_TRANSACTION_IDS, transactionIds);
      putAllInList(KEY_LIST_OF_CREATED_ORDER_ID, orderIds);
      put(KEY_LIST_ZONAL_ROUTING_EDIT_ROUTE, request);
    }, "zonal routing edit route move to another route");
  }

  //remove waypoints of merged transactions
  @When("Operator edit route by removing merged waypoints from Zonal Routing API")
  public void operatorEditRouteRemoveMergedWp(Map<String, String> arg1) {
    final long routeId = get(KEY_CREATED_ROUTE_ID);
    final String json = toJsonCamelCase(arg1);
    final RouteRequest route = fromJsonSnakeCase(json, RouteRequest.class);
    final List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    route.setTags(Arrays.asList(1, 4));
    route.setWaypoints(Collections.singletonList(waypointIds.get(0)));
    route.setId(routeId);
    doWithRetry(() -> {
      List<RouteResponse> result = getRouteClient()
          .zonalRoutingEditRoute(Collections.singletonList(route));
      Assertions.assertThat(result.get(0)).as("updated route is not null").isNotNull();
      put(KEY_ROUTE_EVENT_SOURCE, "ZONAL_ROUTING_UPDATE");
    }, "zonal routing edit route");
  }

  @When("Operator gets only eligible routed orders")
  public void operatorGetsEligibleRoutedOrders() {
    List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    List<Long> transactionIds = get(KEY_LIST_OF_TRANSACTION_IDS);
    List<Long> orderIds = get(KEY_LIST_OF_CREATED_ORDER_ID);
    put(KEY_TRANSACTION_ID, transactionIds.get(0));
    put(KEY_WAYPOINT_ID, waypointIds.get(1));
    remove(KEY_LIST_OF_WAYPOINT_IDS);
    remove(KEY_LIST_OF_TRANSACTION_IDS);
    remove(KEY_LIST_OF_CREATED_ORDER_ID);
    waypointIds.remove(1);
    transactionIds.remove(0);
    orderIds.remove(0);
    putAllInList(KEY_LIST_OF_WAYPOINT_IDS, waypointIds);
    putAllInList(KEY_LIST_OF_TRANSACTION_IDS, transactionIds);
    putAllInList(KEY_LIST_OF_CREATED_ORDER_ID, orderIds);
  }

  @When("API Route - Operator edit route from Zonal Routing API with Invalid State")
  public void operatorEditRouteZrInvalidState(Map<String, String> mapOfData) {
    mapOfData = resolveKeyValues(mapOfData);
    String json = toJson(mapOfData);
    RouteRequest route = fromJson(json, RouteRequest.class);
    List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    route.setWaypoints(waypointIds);
    doWithRetry(() -> {
      Response response = getRouteClient()
          .zonalRoutingEditRouteAndGetRawResponse(Collections.singletonList(route));
      put(KEY_API_RAW_RESPONSE, response);
    }, "zonal routing edit route");
  }

  @When("API Route - Operator create route from Zonal Routing API with Invalid State")
  public void operatorCreateRouteZrInvalidState(Map<String, String> mapOfData) {
    mapOfData = resolveKeyValues(mapOfData);
    String json = toJson(mapOfData);
    RouteRequest route = fromJson(json, RouteRequest.class);
    List<Long> waypointIds = get(KEY_LIST_OF_WAYPOINT_IDS);
    route.setWaypoints(waypointIds);
    route.setDate(DateUtil.generateUTCTodayDate());
    doWithRetry(() -> {
      Response response = getRouteClient()
          .createRouteAndGetRawResponse(route);
      put(KEY_API_RAW_RESPONSE, response);
    }, "zonal routing edit route");
  }

}
