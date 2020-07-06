package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.model.core.route.AddParcelToRouteRequest;
import co.nvqa.commons.model.core.route.ArchiveRouteResponse;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import cucumber.api.java.en.When;
import cucumber.runtime.java.guice.ScenarioScoped;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.Assert;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-01
 */
@ScenarioScoped
public class RoutingSteps extends BaseSteps {

    private static final String DOMAIN = "ROUTING-STEP";

    @Override
    public void init(){

    }

    @When("^Operator create an empty route$")
    public void operatorCreateEmptyRoute(Map<String, String> arg1){
        String json = toJsonCamelCase(arg1);
        Route route = fromJsonSnakeCase(json, Route.class);
        route.setComments("Created for Core API testing, created at: " + DateUtil.getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
        route.setTags(Arrays.asList(1,4));
        route.setDate(DateUtil.getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
        Route result = getRouteClient().createRoute(route);

        NvLogger.success(DOMAIN, "route created with id: " + result.getId());
        put(KEY_CREATED_ROUTE, result);
        putInList(KEY_LIST_OF_CREATED_ROUTE_ID, result.getId());
        put(KEY_CREATED_ROUTE_ID, result.getId());
    }

    @When("^Operator add order to driver \"([^\"]*)\" route$")
    public void operatorCreateEmptyRoute(String type){
        String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
        long routeId = get(KEY_CREATED_ROUTE_ID);
        AddParcelToRouteRequest request = new AddParcelToRouteRequest();
        request.setRouteId(routeId);
        request.setTrackingId(trackingId);
        request.setType(type);
        getRouteClient().addParcelToRoute(routeId, request);
        NvLogger.success(DOMAIN, String.format("order %s added to %s route id %d", trackingId, type, routeId));
    }

    @When("^Operator delete driver route$")
    public void operatorDeleteRoute(){
        long routeId = get(KEY_CREATED_ROUTE_ID);
        getRouteClient().deleteRoute(routeId);
        NvLogger.success(DOMAIN, String.format("route %d is successfully deleted", routeId));
    }

    @When("^Operator delete multiple driver routes$")
    public void operatorDeleteMultipleRoute(){
        List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);
        getRouteClient().deleteMultipleRoutes(routeIds);
        NvLogger.success(DOMAIN, String.format("route %s is successfully deleted", Arrays.toString(routeIds.toArray())));
    }

    @When("^Operator delete driver route with status code \"([^\"]*)\"$")
    public void operatorDeleteRouteUnSuccessFully(int statusCode){
        long routeId = get(KEY_CREATED_ROUTE_ID);
        Response response = getRouteClient().deleteRouteAndGetRawResponse(routeId);
        response.then().assertThat().contentType(ContentType.JSON);
        response.then().assertThat().statusCode(statusCode);
        NvLogger.success(DOMAIN, String.format("route %d is not allowed to be deleted", routeId));
    }

    @When("^Operator archives driver route$")
    public void operatorArchiveRoute(){
        long routeId = get(KEY_CREATED_ROUTE_ID);
        callWithRetry(()-> {
            ArchiveRouteResponse response = getRouteClient().archiveRoute(routeId);
            boolean found = response.getArchivedRouteIds().stream().anyMatch(e -> e.equals(routeId));
            Assert.assertTrue("archived route found", found);
        }, "archive driver route");

        NvLogger.success(DOMAIN, String.format("route %d is successfully archived", routeId));
    }

    @When("^Operator archives multiple driver routes$")
    public void operatorArchiveMultipleRoutes(){
        List<Long> routes = get(KEY_LIST_OF_CREATED_ROUTE_ID);
        long[] request = routes.stream().mapToLong( e->e).toArray();
        callWithRetry(()-> {
            ArchiveRouteResponse response = getRouteClient().archiveRoutes(request);
            boolean found = response.getArchivedRouteIds().containsAll(routes);
            Assert.assertTrue("archived route found", found);
        }, "archive driver route");

        NvLogger.successf("multiple route ids %s are archived", Arrays.toString(routes.toArray()));
    }

    @When("^Operator archives invalid driver route$")
    public void operatorArchiveRouteInvalid(){
        long routeId = get(KEY_CREATED_ROUTE_ID, 0L);
        callWithRetry(()-> {
            ArchiveRouteResponse response = getRouteClient().archiveRoute(routeId);
            boolean found = response.getUnarchivedRouteIds().stream().anyMatch(e -> e.equals(routeId));
            Assert.assertTrue("unarchived route found", found);
        }, "archive driver route");

        NvLogger.success(DOMAIN, String.format("route %d is unarchived", routeId));
    }

    @When("^Operator archives driver the same archived route$")
    public void operatorArchiveSameRoute(){
        operatorArchiveRoute();
    }

    @When("^Operator merge transaction waypoints$")
    public void operatorMergeRoute(){
        long routeId = get(KEY_CREATED_ROUTE_ID);
        callWithRetry(()-> {
            getRouteClient().mergeTransactions(routeId);
        }, "merge transaction waypoints");
    }
}
