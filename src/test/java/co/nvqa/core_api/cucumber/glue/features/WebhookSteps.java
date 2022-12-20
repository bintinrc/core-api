package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.others.RequestBinClient;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.batch_update_pod.ProofDetails;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.model.requestbin.Bin;
import co.nvqa.commons.model.requestbin.BinRequest;
import co.nvqa.commons.model.shipper.v2.Webhook;
import co.nvqa.commons.model.shipper.v2.WebhookRequest;
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
    callWithRetry(() -> {
      List<Webhook> webhooks = Arrays
          .asList(getShipperClient().getWebhookSubscription(Long.parseLong(shipperGlobalId)));
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
          getShipperClient().createWebhookSubscription(Long.parseLong(shipperGlobalId), webhook);
          LOGGER.info("webhook event {} subscribed to {}", e,
              bin.getEndpoint(TestConstants.NV_SYSTEM_ID));
        }
      });
    }, "subscribe webhook event: " + eventName, 30);
  }

  @Then("Shipper gets webhook request for event {string}")
  public void shipperPeekItsWebhook(String event) {
    Bin bin = get(Bin.KEY_CREATED_BIN + event);
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      List<BinRequest> requests = Arrays.asList(binClient.retrieveBinContent(bin.getKey()));
      List<String> jsonLists = new ArrayList<>();
      requests.forEach(e -> jsonLists.add(e.getBody()));
      String json = jsonLists.stream().filter(e -> e.contains(event) && e.contains(trackingId))
          .findAny().orElseThrow(() -> new NvTestRuntimeException(
              f("cant find webhook %s for %s", event, trackingId)));
      WebhookRequest webhookRequest = JsonUtils
          .fromJsonSnakeCase(json, WebhookRequest.class);
      LOGGER.info(f("webhook event = %s found for %s", event, webhookRequest.getTrackingId()));
      putInMap(KEY_LIST_OF_WEBHOOK_REQUEST + event, webhookRequest.getTrackingId(), webhookRequest);
    }, "get webhooks requests", 30);
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
    trackingIds.forEach(o -> {
      Bin bin = get(Bin.KEY_CREATED_BIN + event);
      callWithRetry(() -> {
        List<BinRequest> requests = Arrays.asList(binClient.retrieveBinContent(bin.getKey()));
        boolean found = requests.stream().anyMatch(e ->
            JsonUtils.fromJsonSnakeCase(e.getBody(), WebhookRequest.class).getStatus()
                .equalsIgnoreCase(event)
                && JsonUtils.fromJsonSnakeCase(e.getBody(), WebhookRequest.class).getTrackingId()
                .equalsIgnoreCase(o));
        Assertions.assertThat(!found).as(String.format("no %s webhook sent for %s", event, o))
            .isTrue();
      }, "get webhooks requests", 30);
    });
  }

  @Then("Shipper verifies webhook request payload has correct details for status {string}")
  public void shipperVerifiesWebhookPayload(String status) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Map<String, WebhookRequest> webhookRequest = get(KEY_LIST_OF_WEBHOOK_REQUEST + status);
    WebhookRequest request = webhookRequest.get(trackingId);
    put(KEY_WEBHOOK_PAYLOAD, request);
    OrderRequestV4 order = get(KEY_ORDER_CREATE_REQUEST);
    callWithRetry(() -> {
          Assertions.assertThat(request.getStatus().toLowerCase()).as(f("status is %s", status))
              .isEqualTo(status.toLowerCase());
          Assertions.assertThat(request.getTrackingId().toLowerCase()).as("tracking id is correct")
              .isEqualTo(trackingId.toLowerCase());
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
              if (order.getParcelJob().getCashOnDelivery() != null) {
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
                String hubName = StringUtils.lowerCase(
                    f("%s-%s", hub.getCountry(), hub.getCity()));
                Assertions.assertThat(request.getComments()).as("comment contains hub name")
                    .containsIgnoringCase(
                        hubName);
              }
            }
            break;
            case RTS_ON_VEHICLE_DELIVERY: {
              Hub hub = get(KeysStorage.KEY_HUB_DETAILS, Hub.class);
              if (hub != null) {
                String hubName = StringUtils.lowerCase(
                    f("%s-%s", hub.getCountry(), hub.getCity()));
                Assertions.assertThat(request.getComments()).as("comment contains hub name")
                    .containsIgnoringCase(
                        hubName);
              }
            }
            break;
            case DELIVERY_FAIL_FIRST_ATTEMPT:
              Assertions.assertThat(StringUtils.lowerCase(request.getComments())).as("comment equal")
                  .isEqualTo(StringUtils.lowerCase(TestConstants.DELIVERY_FAILURE_REASON));
              break;
            case PENDING_RESCHEDULE:
              final Integer attemptCount = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT);
              Assertions.assertThat(StringUtils.lowerCase(request.getComments())).as("comment equal")
                  .isEqualTo(StringUtils.lowerCase(TestConstants.DELIVERY_FAILURE_REASON));
              if (attemptCount != null) {
                Assertions.assertThat(request.getDeliveryAttempts()).as("delivery attempt count equal")
                    .isEqualTo(attemptCount);
              }
              break;
            case ARRIVED_AT_SORTING_HUB: {
              Hub hub = get(KeysStorage.KEY_HUB_DETAILS, Hub.class);
              final int attemptCounts = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT);
              if (hub != null) {
                String hubName = StringUtils.lowerCase(
                    f("%s-%s-%s", hub.getCountry(), hub.getCity(), hub.getShortName()));
                Assertions.assertThat(request.getComments()).as("comment contains hub name")
                    .isEqualToIgnoringCase(hubName);
                Assertions.assertThat(request.getDeliveryAttempts()).as("delivery attempt count equal")
                    .isEqualTo(attemptCounts);
              }
            }
            break;
            case PARCEL_MEASUREMENTS_UPDATE: {
              final Double oldWeight = get(KEY_EXPECTED_OLD_WEIGHT, 0.1);
              final Double newWeight = get(KEY_EXPECTED_NEW_WEIGHT);
              Assertions.assertThat(request.getPreviousMeasurements().getMeasuredWeight())
                  .as("old weigh equal")
                  .isEqualTo(oldWeight);
              Assertions.assertThat(request.getNewMeasurements().getMeasuredWeight())
                  .as("new weigh equal")
                  .isEqualTo(newWeight);
            }
            break;
            case PARCEL_WEIGHT: {
              final Double oldWeight = get(KEY_EXPECTED_OLD_WEIGHT, 0.1);
              final Double newWeight = get(KEY_EXPECTED_NEW_WEIGHT);
              Assertions.assertThat(Double.valueOf(request.getPreviousWeight())).as("old weigh equal")
                  .isEqualTo(oldWeight);
              Assertions.assertThat(Double.valueOf(request.getNewWeight())).as("new weigh equal")
                  .isEqualTo(newWeight);
            }
          }
        },
        f("verify webhook payload %s", trackingId), 30);
  }

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
    callWithRetry(() -> cleanWebhookSubs(Long.parseLong(shipperGlobalId)), "remove webhook subs");
  }

  private void cleanWebhookSubs(Long shipperId) {
    try {
      Webhook[] webhooks = getShipperClient().getWebhookSubscription(shipperId);
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
      Assertions.assertThat(webhookRequest.getPod().getName().toLowerCase()).as("name equal")
          .isEqualTo(podDetails.getName().toLowerCase());
      Assertions.assertThat(webhookRequest.getPod().getContact().toLowerCase()).as("contact equal")
          .isEqualTo(podDetails.getContact().toLowerCase());
      Assertions.assertThat(Boolean.parseBoolean(webhookRequest.getPod().getLeftInSafePlace()))
          .as("left_in_safe_place = false").isFalse();
      if (podDetails.getSignatureImageUrl() != null) {
        Assertions.assertThat(webhookRequest.getPod().getUri().toLowerCase()).as("url equal")
            .isEqualTo(podDetails.getSignatureImageUrl().toLowerCase());
      } else {
        Assertions.assertThat(webhookRequest.getPod().getUri()).as("url not null")
            .isNotNull();
      }
      Assertions.assertThat(webhookRequest.getPod().getType().toLowerCase())
          .as(f("type is %s", podType))
          .isEqualTo(podType.toLowerCase());
    }
  }
}
