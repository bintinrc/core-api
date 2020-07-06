package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.driver.DriverClient;
import co.nvqa.commons.model.core.route.Route;
import co.nvqa.commons.model.driver.DriverLoginRequest;
import co.nvqa.commons.model.driver.RouteResponse;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import cucumber.api.java.en.Given;
import cucumber.runtime.java.guice.ScenarioScoped;
import org.junit.Assert;

import java.util.List;

/**
 * @author Binti Cahayati on 2020-07-03
 */
@ScenarioScoped
public class DriverSteps  extends BaseSteps {
    private DriverClient driverClient;

    @Override
    public void init(){

    }

    @Given("^Driver authenticated to login with username \"([^\"]*)\" and password \"([^\"]*)\"$")
    public void driverLogin(String username, String password){
        driverClient = new DriverClient(TestConstants.API_BASE_URL);
        driverClient.authenticate(new DriverLoginRequest(username, password));
    }

    @Given("^Deleted route is not shown on his list routes$")
    public void driverRouteNotShown(){
        List<Long> routes = get(KEY_LIST_OF_CREATED_ROUTE_ID);
        RouteResponse routeResponse = driverClient.getRoutes();
        List<co.nvqa.commons.model.driver.Route> result = routeResponse.getRoutes();
        routes.stream().forEach(e -> {
            boolean found = result.stream().anyMatch( o -> o.getId().equals(e));
            Assert.assertFalse("route found", found);
        });
    }

    @Given("^Archived route is not shown on his list routes$")
    public void archivedDriverRouteNotShown(){
       driverRouteNotShown();
    }

    @Given("^Driver Starts the route$")
    public void driverStartRoute(){
        Route route = get(KEY_CREATED_ROUTE);
        long routeId = route.getId();
        driverClient.startRoute(routeId);
    }
}
