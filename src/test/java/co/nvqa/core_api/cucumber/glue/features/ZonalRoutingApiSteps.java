package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.model.route.RouteRequest;
import co.nvqa.common.core.model.route.RouteResponse;
import co.nvqa.common.utils.DateUtil;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.assertj.core.api.Assertions;

public class ZonalRoutingApiSteps extends BaseSteps {

  @Override
  public void init() {

  }

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
