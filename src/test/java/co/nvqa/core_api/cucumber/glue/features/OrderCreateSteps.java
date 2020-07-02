package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.order_create.OrderCreateClientV4;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.core_api.cucumber.glue.AbstractSteps;
import co.nvqa.core_api.cucumber.glue.support.AuthHelper;
import co.nvqa.core_api.cucumber.glue.support.OrderCreateHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import cucumber.api.java.en.Given;
import cucumber.runtime.java.guice.ScenarioScoped;

import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-01
 */
@ScenarioScoped
public class OrderCreateSteps extends AbstractSteps {
    private static final String  DOMAIN = "ORDER-CREATION-STEPS";

    @Override
    public void init(){

    }

    private OrderCreateClientV4 orderCreateClientV4;

    @Given("^Shipper authenticates using client id \"([^\"]*)\" and client secret \"([^\"]*)\"$")
    public void shipperAuthenticate(String clientId, String clientSecret) {
        orderCreateClientV4 = new OrderCreateClientV4(TestConstants.API_BASE_URL, AuthHelper.getShipperToken(clientId, clientSecret));
    }

    @Given("^Shipper create order with parameters below$")
    public void shipperCreateOrder(Map<String, String> source){
        OrderRequestV4 request = OrderCreateHelper.generateOrderV4(source);
        OrderRequestV4 result = orderCreateClientV4.createOrder(request, "4.1");
        NvLogger.success(DOMAIN, "order created tracking id: " + result.getTrackingNumber());
        put(KEY_CREATED_ORDER_TRACKING_ID, result.getTrackingNumber());
    }
}
