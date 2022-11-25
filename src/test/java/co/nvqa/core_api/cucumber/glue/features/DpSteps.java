package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.dp.DpClient;
import co.nvqa.commons.model.auth.PasswordAuth;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.dp.LodgeInRequest;
import co.nvqa.commons.model.dp.ReturnRequest;
import co.nvqa.commons.util.StandardTestUtils;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import java.util.List;

/**
 * @author Binti Cahayati on 2020-09-02
 */

@ScenarioScoped
public class DpSteps extends BaseSteps {


  private DpClient dpClient;

  @Override
  public void init() {

  }

  @Given("DP user authenticated to login with username {string} and password {string}")
  public void dpUserLogin(String username, String password) {
    dpClient = new DpClient(TestConstants.API_BASE_URL);
    callWithRetry(() ->
        dpClient.authenticate(new PasswordAuth(username, password)), "dp user login");
  }

  @Given("DP user lodge in the return dp order to dp id {string}")
  public void dpUserLodgeInReturnOrder(String dpId) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() ->
            trackingIds.forEach(e -> {
              ReturnRequest request = createDpReturnOrderRequest(e);
              request.setDpId(Long.valueOf(dpId));
              dpClient.createReceiptAndReturnFullyIntegrated(request);
            })
        , "create dp return order");
  }

  @Given("DP user lodge in as SEND order to dp id {string}")
  public void dpUserLodgeInSendOrder(String dpId) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() ->
            trackingIds.forEach(e -> {
              LodgeInRequest request = createLodgeInRequest(e);
              request.setDpId(Long.valueOf(dpId));
              dpClient.createReceiptAndLodgeIn(request);
            })
        , "create lodge in dp order");
  }

  private ReturnRequest createDpReturnOrderRequest(String trackingId) {
    ReturnRequest result = new ReturnRequest();
    callWithRetry(() -> {
      Order order = OrderDetailHelper.getOrderDetails(trackingId);
      result.setTrackingId(trackingId);
      result.setStampId(StandardTestUtils.generateStampId());
      result.setFromName(order.getFromName());
      result.setFromContact(order.getFromContact());
      result.setToEmail(order.getToEmail());
      result.setToName(order.getToName());
      result.setToContact(order.getToContact());
      result.setToEmail(order.getToEmail());
      result.setOrderId(order.getId());
      result.setShipperId(order.getShipper().getId());
      result.setToAddress1(order.getToAddress1());
      result.setToAddress2(order.getToAddress2());
    }, "create return dp order request");
    return result;
  }

  private LodgeInRequest createLodgeInRequest(String trackingId) {
    LodgeInRequest result = new LodgeInRequest();
    callWithRetry(() -> {
      Order order = OrderDetailHelper.getOrderDetails(trackingId);
      result.setTrackingId(trackingId);
      result.setShipperId(order.getShipper().getId());
      put(KEY_DP_SHIPPER_LEGACY_ID, order.getShipper().getId());
    }, "create lodge in dp order request");
    return result;
  }
}
