package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.constants.HttpConstants;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.route.AddParcelToRouteRequest;
import co.nvqa.commons.model.core.route.ArchiveRouteResponse;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import cucumber.api.java.After;
import cucumber.api.java.en.When;
import cucumber.runtime.java.guice.ScenarioScoped;
import io.restassured.http.ContentType;
import io.restassured.response.Response;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-01
 */
@ScenarioScoped
public class RoutingSteps extends BaseSteps {

    private static final String DOMAIN = "ROUTING-STEP";
    public static final String KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID = "key-list-pull-out-of-route-tracking-id";
    private static final String KEY_UNARCHIVE_ROUTE_RESPONSE = "key-unarchive-route-response";
    private static final String KEY_ARCHIVE_ROUTE_RESPONSE = "key-archive-route-response";

    @Override
    public void init() {

    }

    @When("^Operator create an empty route$")
    public void operatorCreateEmptyRoute(Map<String, String> arg1) {
        String json = toJsonCamelCase(arg1);
        Route route = fromJsonSnakeCase(json, Route.class);
        route.setComments("Created for Core API testing, created at: " + DateUtil.getTodayDateTime_YYYY_MM_DD_HH_MM_SS());
        route.setTags(Arrays.asList(1, 4));
        route.setDate(generateUTCTodayDate());
        callWithRetry(() -> {
            Route result = getRouteClient().createRoute(route);
            assertNotNull("created route", route);
            put(KEY_CREATED_ROUTE, result);
            putInList(KEY_LIST_OF_CREATED_ROUTE_ID, result.getId());
            putInList(KEY_LIST_OF_HUB_IDS, route.getHubId());
            putInList(KEY_LIST_OF_ZONE_IDS, route.getZoneId());
            put(KEY_CREATED_ROUTE_ID, result.getId());
        }, "create empty route");
    }

    @When("^Operator add order to driver \"([^\"]*)\" route$")
    public void operatorAddOrderToRoute(String type) {
        callWithRetry(() -> {
            String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
            long routeId = get(KEY_CREATED_ROUTE_ID);
            AddParcelToRouteRequest request = new AddParcelToRouteRequest();
            request.setRouteId(routeId);
            request.setTrackingId(trackingId);
            request.setType(type);
            getRouteClient().addParcelToRoute(routeId, request);
            NvLogger.success(DOMAIN, String.format("order %s added to %s route id %d", trackingId, type, routeId));
        }, "add parcel to route");
    }

    @When("^Operator add all orders to driver \"([^\"]*)\" route$")
    public void operatorAddMultipleOrdersToRoute(String type) {
        List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
        trackingIds.forEach(e -> {
            put(KEY_CREATED_ORDER_TRACKING_ID, e);
            operatorAddOrderToRoute(type);
        });
    }

    @When("^Operator delete driver route$")
    public void operatorDeleteRoute() {
        callWithRetry(() -> {
            long routeId = get(KEY_CREATED_ROUTE_ID);
            getRouteClient().deleteRoute(routeId);
            NvLogger.success(DOMAIN, String.format("route %d is successfully deleted", routeId));
        }, "delete driver route");
    }

    @When("^Operator delete multiple driver routes$")
    public void operatorDeleteMultipleRoute() {
        callWithRetry(() -> {
            List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);
            getRouteClient().deleteMultipleRoutes(routeIds);
            NvLogger.success(DOMAIN, String.format("route %s is successfully deleted", Arrays.toString(routeIds.toArray())));
        }, "delete multiple routes");
    }

    @When("^Operator delete driver route with status code \"([^\"]*)\"$")
    public void operatorDeleteRouteUnSuccessFully(int statusCode) {
        long routeId = get(KEY_CREATED_ROUTE_ID);
        callWithRetry(() -> {
            Response response = getRouteClient().deleteRouteAndGetRawResponse(routeId);
            response.then().assertThat().contentType(ContentType.JSON);
            response.then().assertThat().statusCode(statusCode);
            NvLogger.success(DOMAIN, String.format("route %d is not allowed to be deleted", routeId));
        }, "delete driver route unsuccessfully");
    }

    @When("^Operator archives driver route$")
    public void operatorArchiveRoute() {
        long routeId = get(KEY_CREATED_ROUTE_ID);
        callWithRetry(() -> {
            getRouteClient().archiveRouteV2(routeId);
        }, "archive driver route");

        NvLogger.success(DOMAIN, String.format("route %d is successfully archived", routeId));
    }

    @When("^Operator unarchives driver route with status code (\\d+)$")
    public void operatorUnArchiveRouteV2(int statusCode) {
        long routeId = get(KEY_CREATED_ROUTE_ID, 89L);
        callWithRetry(() -> {
            Response r = getRouteClient().unarchiveRouteV2AndGetRawResponse(routeId);
            assertEquals("status code", statusCode, r.getStatusCode());
            if(statusCode == HttpConstants.RESPONSE_200_SUCCESS){
                assertTrue("response message", r.getBody().asString().equalsIgnoreCase("{\"new_route_status\":\"IN_PROGRESS\"}"));
            }
            put(KEY_UNARCHIVE_ROUTE_RESPONSE, r);
        }, "unarchive driver route v2");
    }

    @When("^Operator verify unarchive route response with proper error message : Route \"([^\"]*)\"$")
    public void verifyBadUnarchivedRoute(String message){
        long routeId = get(KEY_CREATED_ROUTE_ID, 89L);
        Response r = get(KEY_UNARCHIVE_ROUTE_RESPONSE);
        assertTrue("response message", r.getBody().asString().contains(String.format("Route with id=%d %s", routeId, message)));
    }

    @When("^Operator archives multiple driver routes$")
    public void operatorArchiveMultipleRoutes() {
        List<Long> routes = get(KEY_LIST_OF_CREATED_ROUTE_ID);
        long[] request = routes.stream().mapToLong(e -> e).toArray();
        callWithRetry(() -> {
            ArchiveRouteResponse response = getRouteClient().archiveRoutes(request);
            boolean found = response.getArchivedRouteIds().containsAll(routes);
            assertTrue("archived route found", found);
        }, "archive driver route");

        NvLogger.successf("multiple route ids %s are archived", Arrays.toString(routes.toArray()));
    }

    @When("^Operator archives invalid driver route$")
    public void operatorArchiveRouteInvalid() {
        long routeId = get(KEY_CREATED_ROUTE_ID, 0L);
        callWithRetry(() -> {
            ArchiveRouteResponse response = getRouteClient().archiveRoute(routeId);
            boolean found = response.getUnarchivedRouteIds().stream().anyMatch(e -> e.equals(routeId));
            assertTrue("unarchived route found", found);
        }, "archive driver route");

        NvLogger.success(DOMAIN, String.format("route %d is unarchived", routeId));
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
            String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
            Order order = OrderDetailHelper.getOrderDetails(trackingId);
            getRouteClient().pullOutWaypointFromRoute(order.getId(), type.toUpperCase());
            putInList(KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID, trackingId);
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

    @When("^Operator verify archive route response with proper error message : Route \"([^\"]*)\"$")
    public void operatorVerifyArchiveV2Route(String message) {
        callWithRetry(() -> {
            long routeId = get(KEY_CREATED_ROUTE_ID, 1234L);
            Response response = get(KEY_ARCHIVE_ROUTE_RESPONSE);
            assertTrue("response message", response.getBody().asString().contains(String.format("Route with id=%d %s", routeId, message)));

        }, "verify archive driver route v2");
    }

    private String generateUTCTodayDate() {
        ZonedDateTime startDateTime = DateUtil.getStartOfDay(DateUtil.getDate());
        return DateUtil
                .displayDateTime(startDateTime.withZoneSameInstant(ZoneId.of("UTC")));
    }

    @After("@ArchiveDriverRoutes")
    public void cleanCreatedRoute() {
        List<Long> routeIds = get(KEY_LIST_OF_CREATED_ROUTE_ID);

        try {
            if (routeIds != null) {
                routeIds.forEach(e ->
                        callWithRetry(() -> getRouteClient().archiveRouteV2(e)
                                , "try to archive created routes"));
            }
        } catch (Throwable t) {
            NvLogger.warn("Failed to archive route(s)");
        }
    }
}
