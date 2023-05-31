package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.common.core.utils.CoreScenarioStorageKeys;
import co.nvqa.common.webhook.client.RequestBinClient;
import co.nvqa.common.webhook.model.requestbin.Bin;
import co.nvqa.common.webhook.model.requestbin.BinRequest;
import co.nvqa.common.webhook.model.webhook.Webhook;
import co.nvqa.common.webhook.model.webhook.WebhookRequest;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.batch_update_pod.ProofDetails;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.util.JsonUtils;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.commonsort.cucumber.KeysStorage;
import co.nvqa.commonsort.model.Hub;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.apache.commons.lang3.StringUtils;
import org.assertj.core.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@ScenarioScoped
public class WebhookSteps extends BaseSteps {

  private static final Logger LOGGER = LoggerFactory.getLogger(WebhookSteps.class);
  private static final String ACTION_MODE_SUCCESS = "SUCCESS";
  private RequestBinClient binClient;

  @Override
  public void init() {
    this.binClient = new RequestBinClient();
  }

  @Given("Shipper id {string} subscribes to {string} webhook")
  public void shipperSubscribeWebhook(String shipperGlobalId, String eventName) {
    doWithRetry(() -> {
      List<Webhook> webhooks = Arrays
          .asList(
              getShipperWebhookClient().getWebhookSubscription(Long.parseLong(shipperGlobalId)));
      List<String> events = Arrays.asList(eventName.split(", "));
      events.forEach(e -> {
        String eventTemp = StringUtils.join(e.split(" "), "-").trim();
        Bin bin = binClient.requestNewBin(shipperGlobalId + "-" + eventTemp);
        put(Bin.KEY_CREATED_BIN + e, bin);
        if (webhooks.stream().noneMatch(o -> o.getEvent().equalsIgnoreCase(e))) {
          Webhook webhook;
          if (e.equalsIgnoreCase("First Attempt Delivery Fail") ||
              e.equalsIgnoreCase("Pending Reschedule") ||
              e.equalsIgnoreCase("Arrived at Sorting Hub")) {
            webhook = new Webhook(e, Webhook.WEBHOOK_METHOD,
                bin.getEndpoint(TestConstants.NV_SYSTEM_ID),
                "1.2");
          } else {
            webhook = new Webhook(e, Webhook.WEBHOOK_METHOD,
                bin.getEndpoint(TestConstants.NV_SYSTEM_ID),
                Webhook.VERSION_1_1);
          }
          getShipperWebhookClient()
              .createWebhookSubscription(Long.parseLong(shipperGlobalId), webhook);
          LOGGER.info("webhook event {} subscribed to {}", e,
              bin.getEndpoint(TestConstants.NV_SYSTEM_ID));
        }
      });
    }, "subscribe webhook event: " + eventName);
  }

  @Then("Shipper gets webhook request for event {string}")
  public void shipperPeekItsWebhook(String event) {
//    TODO move trackingId as step parameter
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    shipperPeekItsWebhook(event, trackingId);
  }

  @Then("Shipper gets webhook request for event {string} and tracking id {string}")
  public void shipperPeekItsWebhook(String event, String tid) {
    Bin bin = get(Bin.KEY_CREATED_BIN + event);
    String trackingId = resolveValue(tid);
    doWithRetry(() -> {
      List<BinRequest> requests = Arrays.asList(binClient.retrieveBinContent(bin.getKey()));
      List<String> jsonLists = new ArrayList<>();
      requests.forEach(e -> jsonLists.add(e.getBody()));
      String json = jsonLists.stream().filter(e -> e.contains(event) && e.contains(trackingId))
          .findAny().orElseThrow(() -> new NvTestRuntimeException(
              f("cant find webhook %s for %s", event, trackingId)));
      WebhookRequest webhookRequest = fromJsonSnakeCase(json, WebhookRequest.class);
      LOGGER.info(f("webhook event = %s found for %s", event, webhookRequest.getTrackingId()));
      putInMap(KEY_LIST_OF_WEBHOOK_REQUEST + event, webhookRequest.getTrackingId(), webhookRequest);
    }, "get webhooks requests");
  }

  @Then("Verify for {string} Orders, Shipper gets webhook event {string}")
  public void verifyPartialWebhookStatus(String actionMode, String webhookEvent) {
    List<String> trackingIds;
    if (actionMode.equalsIgnoreCase(ACTION_MODE_SUCCESS)) {
      trackingIds = get(KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    } else {
      trackingIds = get(KEY_LIST_OF_PARTIAL_FAIL_TID);
    }
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      shipperPeekItsWebhook(webhookEvent);
    });
  }

  @Then("Shipper gets webhook request for event {string} for all orders")
  public void shipperPeekItsWebhookAllOrders(String event) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      shipperPeekItsWebhook(event);
    });
  }

  @Then("Verify NO {string} event sent for all orders")
  public void verifyNoWebhookSent(String event) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(o ->
        verifyNoWebhookSentForOrder(event, o));
  }

  @Then("Verify NO {string} event sent for order {string}")
  public void verifyNoWebhookSentForOrder(String event, String tid) {
    String trackingId = resolveValue(tid);
    Bin bin = get(Bin.KEY_CREATED_BIN + event);
    doWithRetry(() -> {
      List<BinRequest> requests = Arrays.asList(binClient.retrieveBinContent(bin.getKey()));
      boolean found = requests.stream().anyMatch(e ->
          JsonUtils.fromJsonSnakeCase(e.getBody(), WebhookRequest.class).getStatus()
              .equalsIgnoreCase(event)
              && JsonUtils.fromJsonSnakeCase(e.getBody(), WebhookRequest.class).getTrackingId()
              .equalsIgnoreCase(resolveValue(trackingId)));
      Assertions.assertThat(!found)
          .as(String.format("no %s webhook sent for %s", event, trackingId))
          .isTrue();
    }, "get webhooks requests");
  }

  @Then("Shipper verifies webhook request payload has correct details for status {string}")
  public void shipperVerifiesWebhookPayload(String status) {
    //    TODO move trackingId as step parameter
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    shipperVerifiesWebhookPayload(status, trackingId);
  }

  @Then("Shipper verifies webhook request payload has correct details for status {string} and tracking id {string}")
  public void shipperVerifiesWebhookPayload(String status, String tid) {
    String trackingId = resolveValue(tid);
    Map<String, WebhookRequest> webhookRequest = get(KEY_LIST_OF_WEBHOOK_REQUEST + status);
    WebhookRequest request = webhookRequest.get(trackingId);
    put(KEY_WEBHOOK_PAYLOAD, request);
    OrderRequestV4 order = get(KEY_ORDER_CREATE_REQUEST);
    doWithRetry(() -> {
          Assertions.assertThat(request.getStatus()).as(f("status is %s", status))
              .isEqualToIgnoringCase(status);
          Assertions.assertThat(request.getTrackingId()).as("tracking id is correct")
              .isEqualToIgnoringCase(trackingId);
          Webhook.WebhookStatus webhookStatus = Webhook.WebhookStatus.fromString(status);
          Pickup pickup = get(KEY_CREATED_RESERVATION);
          Map<String, ProofDetails> proofDetails = get(KEY_MAP_PROOF_WEBHOOK_DETAILS);
          switch (webhookStatus) {
            case SUCCESSFUL_DELIVERY:
              final Long dpJobId = get(KEY_DP_JOB_ID);
              if (proofDetails == null || dpJobId != null) {
                Assertions.assertThat(request.getPod()).as("pod field is null").isNull();
              } else {
                checkDeliverySuccessPod(request, trackingId);
              }
              if (order != null && order.getParcelJob().getCashOnDelivery() != null) {
                Double cod = order.getParcelJob().getCashOnDelivery();
                Assertions.assertThat(request.getCodCollected()).as("cod_collected field equal")
                    .isEqualTo(cod);
              }
              break;
            case SUCCESSFUL_PICKUP:
              //to exclude POD on Pickup with Normal Order
              if ((pickup != null && order.getServiceType().equalsIgnoreCase("Parcel"))
                  || proofDetails == null) {
                Assertions.assertThat(request.getPod()).as("pod field is null").isNull();
              } else {
                checkDeliverySuccessPod(request, trackingId);
              }
            case CANCELLED:
              String comment = get(KEY_CANCELLATION_REASON);
              Assertions.assertThat(request.getComments()).as("cancel comment equal")
                  .isEqualTo(comment);
            case ON_VEHICLE_DELIVERY: {
              Hub hub = get(KeysStorage.KEY_HUB_DETAILS, Hub.class);
              if (hub != null) {
                String hubName = f("%s-%s", hub.getCountry(), hub.getCity());
                Assertions.assertThat(request.getComments()).as("comment contains hub name")
                    .containsIgnoringCase(
                        hubName);
              }
            }
            break;
            case RTS_ON_VEHICLE_DELIVERY: {
              Hub hub = get(KeysStorage.KEY_HUB_DETAILS, Hub.class);
              if (hub != null) {
                String hubName = f("%s-%s", hub.getCountry(), hub.getCity());
                Assertions.assertThat(request.getComments()).as("comment contains hub name")
                    .containsIgnoringCase(
                        hubName);
              }
            }
            break;
            case DELIVERY_FAIL_FIRST_ATTEMPT:
              Assertions.assertThat(request.getComments()).as("comment equal")
                  .isEqualToIgnoringCase(TestConstants.DELIVERY_FAILURE_REASON);
              break;
            case PENDING_RESCHEDULE:
              final Integer attemptCount = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT);
              Assertions.assertThat(request.getComments()).as("comment equal")
                  .isEqualToIgnoringCase(TestConstants.DELIVERY_FAILURE_REASON);
              if (attemptCount != null) {
                Assertions.assertThat(request.getDeliveryAttempts()).as("delivery attempt count equal")
                    .isEqualTo(attemptCount);
              }
              break;
            case ARRIVED_AT_SORTING_HUB: {
              Hub hub = get(KeysStorage.KEY_HUB_DETAILS, Hub.class);
              if (hub != null) {
                final int attemptCounts = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT);
                String hubName = f("%s-%s-%s", hub.getCountry(), hub.getCity(), hub.getShortName());
                Assertions.assertThat(request.getComments()).as("comment contains hub name")
                    .isEqualToIgnoringCase(hubName);
                Assertions.assertThat(request.getDeliveryAttempts()).as("delivery attempt count equal")
                    .isEqualTo(attemptCounts);
              }
            }
            break;
            case PARCEL_MEASUREMENTS_UPDATE: {
              final Double oldWeight = get(CoreScenarioStorageKeys.KEY_EXPECTED_OLD_WEIGHT, 0.1);
              final Double newWeight = get(CoreScenarioStorageKeys.KEY_SAVED_ORDER_WEIGHT);
              Assertions.assertThat(request.getPreviousMeasurements().getMeasuredWeight())
                  .as("old weigh equal")
                  .isEqualTo(oldWeight);
              if (newWeight != 0) {
                Assertions.assertThat(request.getNewMeasurements().getMeasuredWeight())
                    .as("new weigh equal")
                    .isEqualTo(newWeight);
              } else {
                Assertions.assertThat(request.getNewMeasurements().getMeasuredWeight())
                    .as("new weigh equal")
                    .isEqualTo(oldWeight);
              }
            }
            break;
            case PARCEL_WEIGHT: {
              final Double oldWeight = get(CoreScenarioStorageKeys.KEY_EXPECTED_OLD_WEIGHT, 0.1);
              final Double newWeight = get(CoreScenarioStorageKeys.KEY_SAVED_ORDER_WEIGHT);
              Assertions.assertThat(Double.valueOf(request.getPreviousWeight())).as("old weigh equal")
                  .isEqualTo(oldWeight);
              Assertions.assertThat(Double.valueOf(request.getNewWeight())).as("new weigh equal")
                  .isEqualTo(newWeight);
            }
          }
        },
        f("verify webhook payload %s", trackingId));
  }

  @Then("Verify webhook request payload has correct details")

  @Then("Shipper verifies webhook request payload has correct details for status {string} with NO Pod details")
  public void shipperVerifiesWebhookPayloadNoPod(String status) {
    shipperVerifiesWebhookPayload(status);
  }

  @Then("Shipper verifies webhook request payload has correct details for status {string} for all orders")
  public void shipperVerifiesWebhookPayloadAllOrders(String status) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      shipperVerifiesWebhookPayload(status);
    });
  }

  @Given("Shipper id {string} removes webhook subscriptions")
  public void shipperRemoveWebhookSubs(String shipperGlobalId) {
    doWithRetry(() -> cleanWebhookSubs(Long.parseLong(shipperGlobalId)), "remove webhook subs");
  }

  private void cleanWebhookSubs(Long shipperId) {
    try {
      Webhook[] webhooks = getShipperWebhookClient().getWebhookSubscription(shipperId);
      Arrays.asList(webhooks)
          .forEach(e -> getShipperClient().removeWebhookSubscription(shipperId, e.getId()));
      LOGGER.info("webhook subscription cleared");
    } catch (Throwable t) {
      LOGGER.warn("Failed to clean webhook subs");
    }
  }

  private void checkDeliverySuccessPod(WebhookRequest webhookRequest, String trackingId) {
    Map<String, ProofDetails> proofDetails = get(KEY_MAP_PROOF_WEBHOOK_DETAILS);
    String podType = get(KEY_WEBHOOK_POD_TYPE, "RECIPIENT");
    ProofDetails podDetails = proofDetails.get(trackingId);
    if (podDetails != null) {
      Assertions.assertThat(webhookRequest.getPod().getName()).as("name equal")
          .isEqualToIgnoringCase(podDetails.getName());
      Assertions.assertThat(webhookRequest.getPod().getContact()).as("contact equal")
          .isEqualToIgnoringCase(podDetails.getContact());
      Assertions.assertThat(Boolean.parseBoolean(webhookRequest.getPod().getLeftInSafePlace()))
          .as("left_in_safe_place = false").isFalse();
      if (podDetails.getSignatureImageUrl() != null) {
        Assertions.assertThat(webhookRequest.getPod().getUri()).as("url equal")
            .isEqualToIgnoringCase(podDetails.getSignatureImageUrl());
      } else {
        Assertions.assertThat(webhookRequest.getPod().getUri()).as("url not null")
            .isNotNull();
      }
      Assertions.assertThat(webhookRequest.getPod().getType())
          .as(f("type is %s", podType))
          .isEqualToIgnoringCase(podType);
    }
  }
}
