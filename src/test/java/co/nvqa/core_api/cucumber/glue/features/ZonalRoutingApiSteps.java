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
    }, "zonal routing create route");
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
