package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.core.RouteClient;
import co.nvqa.commons.model.core.route.AddParcelToRouteRequest;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.AbstractSteps;
import co.nvqa.core_api.cucumber.glue.support.AuthHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.util.Arrays;
import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-01
 */
@ScenarioScoped
public class RoutingSteps extends AbstractSteps {

    private static final String DOMAIN = "ROUTING-STEP";
    private static final String KEY_CREATED_ROUTE = "key-created-route";

    private RouteClient routeClient;

    @Override
    public void init(){

    }

    @Given("^Routing Operator does authentication$")
    public void routingOperatorAuthenticate() {
        routeClient = new RouteClient(TestConstants.API_BASE_URL, AuthHelper.getOperatorAuthToken());
    }

    @When("^Operator create an empty route$")
    public void operatorCreateEmptyRoute(Map<String, String> arg1){
        String json = toJsonCamelCase(arg1);
        Route route = fromJsonSnakeCase(json, Route.class);
        route.setComments("Created for Core API testing, created at: " + DateUtil.getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
        route.setTags(Arrays.asList(1,4));
        route.setDate(DateUtil.getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
        Route result = routeClient.createRoute(route);

        NvLogger.success(DOMAIN, "route created with id: " + result);
        put(KEY_CREATED_ROUTE, result);
    }

    @When("^Operator add order to driver \"([^\"]*)\" route$")
    public void operatorCreateEmptyRoute(String type){
        String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
        Route route = get(KEY_CREATED_ROUTE);
        long routeId = route.getId();
        AddParcelToRouteRequest request = new AddParcelToRouteRequest();
        request.setRouteId(routeId);
        request.setTrackingId(trackingId);
        request.setType(type);
        routeClient.addParcelToRoute(routeId, request);
        NvLogger.success(DOMAIN, String.format("order %s added to %s route id %d", trackingId, type, routeId));
    }
}
