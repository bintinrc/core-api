package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.others.RequestBinClient;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.model.core.batch_update_pod.BlobData;
import co.nvqa.commons.model.core.batch_update_pod.FailedParcels;
import co.nvqa.commons.model.core.batch_update_pod.JobUpdate;
import co.nvqa.commons.model.core.batch_update_pod.ProofDetails;
import co.nvqa.commons.model.core.hub.Hub;
import co.nvqa.commons.model.driver.Job;
import co.nvqa.commons.model.driver.JobV5;
import co.nvqa.commons.model.driver.builder.JobBuilder;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.model.requestbin.Bin;
import co.nvqa.commons.model.requestbin.BinRequest;
import co.nvqa.commons.model.shipper.v2.Webhook;
import co.nvqa.commons.model.shipper.v2.WebhookRequest;
import co.nvqa.commons.util.JsonUtils;
import co.nvqa.commons.util.NvLogger;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.guice.ScenarioScoped;

import java.time.Instant;
import java.util.*;
import org.apache.commons.lang3.StringUtils;
import org.assertj.core.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Binti Cahayati on 2020-10-08
 */
@ScenarioScoped
public class BatchUpdatePodsSteps extends BaseSteps {

  private static final Logger LOGGER = LoggerFactory.getLogger(BatchUpdatePodsSteps.class);

  private static String PICKUP_JOB_MODE = "PICK_UP";
  private static String DELIVERY_JOB_MODE = "DELIVERY";
  private static String ACTION_MODE_FAIL = "FAIL";
  private static String ACTION_MODE_SUCCESS = "SUCCESS";
  private static String URL_IMAGE = "https://cdn.ninjavan.co/sg/pods/signature_3f2fa65d-1fec-4546-9efe-4703cb081aa0.png";
  private static String IMEI = "41e74ed6b321e2f9";
  private static String KEY_LIST_OF_WEBHOOK_REQUEST = "key-list-of-webhook-request";
  public static String KEY_LIST_OF_PARTIAL_SUCCESS_TID = "key-list-partial-success-tid";
  public static String KEY_LIST_OF_PARTIAL_FAIL_TID = "key-list-partial-fail-tid";
  private static String KEY_MAP_PROOF_WEBHOOK_DETAILS = "key-proof-webhook-details";
  private static String KEY_PROOF_RESERVATION_REQUEST = "key-proof-reservation-request";
  private static String KEY_WEBHOOK_POD_TYPE = "key-webhook-pod-type";
  private RequestBinClient binClient;

  @Override
  public void init() {
    this.binClient = new RequestBinClient();
  }

  @Given("^API Batch Update Job Request to Success All Created Orders \"([^\"]*)\" with pod type \"([^\"]*)\"$")
  public void apiBatchJobUpdateOrdersSuccess(String transactionType, String podType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(transactionType);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_SUCCESS, PICKUP_JOB_MODE,
            false, podType);
      } else {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_SUCCESS, DELIVERY_JOB_MODE,
            false, podType);
      }
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("^API Batch Update Job Request to Success All Created Orders \"([^\"]*)\" with NO Proof Details$")
  public void apiBatchJobUpdateOrdersSuccessNoPods(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(transactionType);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionJobRequestWithoutPods(trackingIds, PICKUP_JOB_MODE);
      } else {
        request = createTransactionJobRequestWithoutPods(trackingIds, DELIVERY_JOB_MODE);
      }
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("^API Batch Update Proof Request to Success All Created Orders \"([^\"]*)\"$")
  public void apiBatchProofsUpdateOrdersSuccess(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_SUCCESS,
            PICKUP_JOB_MODE, false);
      } else {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_SUCCESS,
            DELIVERY_JOB_MODE, false);
      }
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("^API Batch Update Job Request to Fail All Created Orders \"([^\"]*)\"$")
  public void apiBatchJobUpdateOrdersFail(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(transactionType);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_FAIL, PICKUP_JOB_MODE, false,
            WebhookRequest.Pod.POD_TYPE_RECIPIENT);
      } else {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_FAIL, DELIVERY_JOB_MODE,
            false, WebhookRequest.Pod.POD_TYPE_RECIPIENT);
      }
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("^API Batch Update Proof Request to Fail All Created Orders \"([^\"]*)\"$")
  public void apiBatchProofsUpdateOrdersFail(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_FAIL,
            PICKUP_JOB_MODE, false);
      } else {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_FAIL,
            DELIVERY_JOB_MODE, false);
      }
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("^API Batch Update Job Request to \"([^\"]*)\" All Orders under the reservation$")
  public void apiBatchJobUpdateReservationAllOrders(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationJobRequest(trackingIds, reservationId, action,
          action);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("^API Batch Update Job Request to \"([^\"]*)\" All Return Orders under the reservation$")
  public void apiBatchJobUpdateReservationAllReturnOrders(String action) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    List<OrderRequestV4> orderRequest = get(OrderCreateSteps.KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    String normalTid = orderRequest.stream()
        .filter(e -> e.getServiceType().equalsIgnoreCase("Parcel"))
        .findAny().orElseThrow(() -> new NvTestRuntimeException("cant find order response"))
        .getTrackingNumber();
    trackingIds.remove(normalTid);
    put(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID, trackingIds);
    apiBatchJobUpdateReservationAllOrders(action);
  }

  @Given("^API Batch Update Proof Request to \"([^\"]*)\" All Orders under the reservation$")
  public void apiBatchProofsUpdateReservationAllOrders(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationUpdateProofRequest(reservationId, trackingIds,
          action);
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("^Operator get proof details for \"([^\"]*)\" transaction of \"([^\"]*)\" orders$")
  public void dbOperatorVerifiesTransactionBlobCreatedReturn(String action, String type) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    List<JobUpdate> reservationProof = get(KEY_UPDATE_PROOFS_REQUEST);
    List<JobUpdate> request = createTransactionUpdateProofRequest(trackingIds, action,
        PICKUP_JOB_MODE, false);
    request.forEach(e -> {
      ProofDetails temp = reservationProof.get(0).getProofDetails();
      e.getProofDetails().setName(temp.getName());
      e.getProofDetails().setContact(temp.getContact());
      if (action.equalsIgnoreCase(ACTION_MODE_FAIL)) {
        e.getJob().setFailureReasonId(temp.getFailedParcels().get(0).getFailureReasonId());
        e.getJob().setFailureReason(temp.getFailedParcels().get(0).getFailureReason());
      }
    });
    put(KEY_UPDATE_PROOFS_REQUEST, request);
  }

  @Given("^API Batch Update Proof Request to Partial Success & Fail Orders under the reservation$")
  public void apiBatchProofsUpdateReservationPartialSuccess() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationPartialSuccessProofRequest(reservationId);
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("^API Batch Update Proof Request to \"([^\"]*)\" Reservation without any Parcel$")
  public void apiBatchProofsUpdateReservationNoOrders(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationUpdateProofRequest(reservationId,
          new ArrayList<>(), action);
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("^API Batch Update Job Request to Partial Success Orders under the reservation$")
  public void apiBatchJobUpdateReservationPartialOrders() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationPartialSuccessJobRequest(trackingIds,
          reservationId);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("^API Batch Update Job Request to \"([^\"]*)\" Reservation without any Parcel$")
  public void apiBatchJobUpdateReservationWithoutOrder(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationJobWithoutParcelRequest(reservationId, action);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("^API Batch Update Proof Request to Partial Success Orders \"([^\"]*)\"$")
  public void apiBatchJobUpdatePartialSuccessProofs(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionPartialSuccesProofRequest(trackingIds, PICKUP_JOB_MODE);
      } else {
        request = createTransactionPartialSuccesProofRequest(trackingIds, DELIVERY_JOB_MODE);
      }
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("^API Batch Update Job Request to Partial Success Orders \"([^\"]*)\"$")
  public void apiBatchJobUpdatePartialSuccessOrders(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(transactionType);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionPartialSuccessJobRequest(trackingIds, PICKUP_JOB_MODE);
      } else {
        request = createTransactionPartialSuccessJobRequest(trackingIds, DELIVERY_JOB_MODE);
      }
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("^Shipper id \"([^\"]*)\" subscribes to \"([^\"]*)\" webhook$")
  public void shipperSubscribeWebhook(long shipperGlobalId, String eventName) {
    callWithRetry(() -> {
      List<Webhook> webhooks = Arrays
          .asList(getShipperClient().getWebhookSubscription(shipperGlobalId));
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
            webhook = new Webhook(e, Webhook.WEBHOOK_METHOD, bin.getEndpoint(),
                "1.2");
          } else {
            webhook = new Webhook(e, Webhook.WEBHOOK_METHOD, bin.getEndpoint(),
                Webhook.VERSION_1_1);
          }
          getShipperClient().createWebhookSubscription(shipperGlobalId, webhook);
          NvLogger.successf("webhook event %s subscribed to %s", e, bin.getEndpoint());
        }
      });
    }, "subscribe webhook event: " + eventName, 30);
  }

  @Then("^Shipper gets webhook request for event \"([^\"]*)\"$")
  public void shipperPeekItsWebhook(String event) {
    Bin bin = get(Bin.KEY_CREATED_BIN + event);
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      List<BinRequest> requests = Arrays.asList(binClient.retrieveBinContent(bin.getMessage()));
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

  @Then("^Verify for \"([^\"]*)\" Orders, Shipper gets webhook event \"([^\"]*)\"$")
  public void verifyPartialWebhookStatus(String actionMode, String webhookEvent) {
    List<String> trackingIds;
    if (actionMode.equalsIgnoreCase(ACTION_MODE_SUCCESS)) {
      trackingIds = get(BatchUpdatePodsSteps.KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    } else {
      trackingIds = get(BatchUpdatePodsSteps.KEY_LIST_OF_PARTIAL_FAIL_TID);
    }
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      shipperPeekItsWebhook(webhookEvent);
    });
  }

  @Then("^Shipper gets webhook request for event \"([^\"]*)\" for all orders$")
  public void shipperPeekItsWebhookAllOrders(String event) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      shipperPeekItsWebhook(event);
    });
  }

  @Then("^Verify NO \"([^\"]*)\" event sent for all orders$")
  public void verifyNoWebhookSent(String event) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(o -> {
      Bin bin = get(Bin.KEY_CREATED_BIN + event);
      callWithRetry(() -> {
        List<BinRequest> requests = Arrays.asList(binClient.retrieveBinContent(bin.getMessage()));
        boolean found = requests.stream().anyMatch(e ->
            JsonUtils.fromJsonSnakeCase(e.getBody(), WebhookRequest.class).getStatus()
                .equalsIgnoreCase(event)
                && JsonUtils.fromJsonSnakeCase(e.getBody(), WebhookRequest.class).getTrackingId()
                .equalsIgnoreCase(o));
        assertTrue(String.format("no %s webhook sent for %s", event, o), !found);
      }, "get webhooks requests", 30);
    });
  }

  @Then("^Shipper verifies webhook request payload has correct details for status \"([^\"]*)\"$")
  public void shipperverifiesWebhookPayload(String status) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    Map<String, WebhookRequest> webhookRequest = get(KEY_LIST_OF_WEBHOOK_REQUEST + status);
    WebhookRequest request = webhookRequest.get(trackingId);
    OrderRequestV4 order = get(KEY_ORDER_CREATE_REQUEST);
    callWithRetry(() -> {
          assertEquals("status", status.toLowerCase(), request.getStatus().toLowerCase());
          assertEquals("tracking id", trackingId.toLowerCase(), request.getTrackingId().toLowerCase());
          Webhook.WebhookStatus webhookStatus = Webhook.WebhookStatus.fromString(status);
          Pickup pickup = get(KEY_CREATED_RESERVATION);
          Map<String, ProofDetails> proofDetails = get(KEY_MAP_PROOF_WEBHOOK_DETAILS);
          switch (webhookStatus) {
            case SUCCESSFUL_DELIVERY:
              if (proofDetails == null) {
                Assertions.assertThat(request.getPod()).as("pod field is null").isNull();
              } else {
                checkDeliverySuccesPod(request, trackingId);
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
                checkDeliverySuccesPod(request, trackingId);
              }
            case CANCELLED:
              String comment = get(KEY_CANCELLATION_REASON);
              Assertions.assertThat(request.getComments()).as("cancel comment equal")
                  .isEqualTo(comment);
            case ON_VEHICLE_DELIVERY:
              Hub hubInfo = get(KEY_HUB_INFO);
              if (hubInfo != null) {
                String hubName = StringUtils.lowerCase(
                    f("%s-%s-%s", hubInfo.getCountry(), hubInfo.getCity(), hubInfo.getShortName()));
                Assertions.assertThat(StringUtils.lowerCase(request.getComments())).as("comment equal")
                    .isEqualTo(hubName);
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
            case ARRIVED_AT_SORTING_HUB:
              final Hub hub = get(KEY_HUB_INFO);
              final int attemptCounts = get(KEY_DRIVER_FAIL_ATTEMPT_COUNT);
              if (hub != null) {
                String hubName = StringUtils.lowerCase(
                    f("%s-%s-%s", hub.getCountry(), hub.getCity(), hub.getShortName()));
                Assertions.assertThat(StringUtils.lowerCase(request.getComments())).as("comment equal")
                    .isEqualTo(hubName);
                Assertions.assertThat(request.getDeliveryAttempts()).as("delivery attempt count equal")
                    .isEqualTo(attemptCounts);
              }
              break;
          }
        },
        f("verify webhook payload %s", trackingId), 30);
  }

  @Given("^Verify blob data is correct$")
  public void dbOperatorVerifiesBlobData() {
    List<JobUpdate> proofRequest = get(KEY_UPDATE_PROOFS_REQUEST);
    Map<Long, String> blobDataMap = get(KEY_LIST_OF_BLOB_DATA);
    callWithRetry(() -> {
      proofRequest.forEach(e -> {
        BlobData blobData = fromJsonSnakeCase(blobDataMap.get(e.getJob().getId()), BlobData.class);
        ProofDetails proofDetails = e.getProofDetails();
        assertEquals("name", proofDetails.getName().toLowerCase(),
            blobData.getName().toLowerCase());
        assertEquals("contact", proofDetails.getContact(), blobData.getContact());
        String signCoordinates = proofDetails.getLongitude() + "," + proofDetails.getLatitude();
        assertEquals("sign coordinates", signCoordinates, blobData.getSignCoordinates());
        assertEquals("imei", proofDetails.getImei(), blobData.getImei());
        assertEquals("url", proofDetails.getSignatureImageUrl(), blobData.getUrl());
        if (e.getJob().getAction().equalsIgnoreCase(ACTION_MODE_FAIL)) {
          assertEquals("failure reason id", e.getJob().getFailureReasonId(),
              blobData.getFailureReasonId());
          assertTrue("failure reason translations",
              blobData.getFailureReasonTranslations().contains(e.getJob().getFailureReason()));
        }
        if (e.getJob().getType().equalsIgnoreCase("RESERVATION")) {
          assertNull("status", blobData.getStatus());
          if (e.getJob().getAction().equalsIgnoreCase(ACTION_MODE_FAIL)) {
            assertEquals("comments",
                e.getJob().getFailureReason() + ". " + e.getProofDetails().getComments(),
                blobData.getComments());
          } else {
            assertTrue("scanned parcels contains scanned tracking ids",
                blobData.getScannedParcels().containsAll(e.getProofDetails().getTrackingIds()));
            assertEquals("received parcels", e.getProofDetails().getPickupQuantity(),
                blobData.getReceivedParcels());
          }
          return;
        }
        assertEquals("status", e.getJob().getAction(), blobData.getStatus());
        Pickup pickup = get(KEY_CREATED_RESERVATION);
        if (pickup == null) {
          assertEquals("verification method", "NO_VERIFICATION", blobData.getVerificationMethod());
        } else {
          assertNull("verification method", blobData.getVerificationMethod());
        }
      });
    }, "check blob data");
  }

  @Then("^Shipper verifies webhook request payload has correct details for status \"([^\"]*)\" with NO Pod details$")
  public void shipperverifiesWebhookPayloadNoPod(String status) {
    shipperverifiesWebhookPayload(status);
  }

  @Then("^Shipper verifies webhook request payload has correct details for status \"([^\"]*)\" for all orders$")
  public void shipperverifiesWebhookPayloadAllOrders(String status) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    trackingIds.forEach(e -> {
      put(KEY_CREATED_ORDER_TRACKING_ID, e);
      shipperverifiesWebhookPayload(status);
    });
  }

  @Given("Shipper id {string} removes webhook subscriptions")
  public void shipperRemoveWebhookSubs(String shipperGlobalId) {
    callWithRetry(() -> cleanWebhookSubs(Long.valueOf(shipperGlobalId)), "remove webhook subs");
  }

  private JobV5 createTransactionJob(String trackingId, String action, String jobMode,
      boolean withCod) {

    Order order = OrderDetailHelper.getOrderDetails(trackingId);
    if (Objects.isNull(order)) {
      NvLogger.infof("null order: " + trackingId);
    }
    put(KEY_CREATED_ORDER, order);
    Transaction transaction;
    if (jobMode.equalsIgnoreCase(PICKUP_JOB_MODE)) {
      transaction = order.getTransactions().get(0);
    } else {
      transaction = order.getTransactions().get(1);
    }

    long jobId = transaction.getId();

    JobV5 job = new JobBuilder().setAction(action)
        .setId(jobId)
        .setMode(jobMode)
        .setType(Job.TYPE_TRANSACTION)
        .createBatchUpdateJob();
    if (action.equalsIgnoreCase(ACTION_MODE_FAIL)) {

      if (jobMode.equalsIgnoreCase(PICKUP_JOB_MODE)) {
        job.setFailureReasonId(TestConstants.PICKUP_FAILURE_REASON_ID);
        job.setFailureReason(TestConstants.PICKUP_FAILURE_REASON);
      } else {
        job.setFailureReasonId(TestConstants.DELIVERY_FAILURE_REASON_ID);
        job.setFailureReason(TestConstants.DELIVERY_FAILURE_REASON);
      }
    }
    if (withCod) {
      job.setCod(order.getCod().getGoodsAmount());
    }
    return job;
  }

  private co.nvqa.commons.model.driver.Order createTransactionOrder(String trackingId,
      String action, String jobMode) {
    Order order = OrderDetailHelper.getOrderDetails(trackingId);
    put(KEY_CREATED_ORDER, order);
    co.nvqa.commons.model.driver.Order jobOrder = new co.nvqa.commons.model.driver.Order();
    jobOrder.setId(order.getId());
    jobOrder.setTrackingId(trackingId);
    jobOrder.setParcelSize(order.getParcelSize());
    jobOrder.setParcelWeight(order.getWeight());
    if (action.equalsIgnoreCase(ACTION_MODE_FAIL)) {
      if (jobMode.equalsIgnoreCase(PICKUP_JOB_MODE)) {
        jobOrder.setFailureReasonId(TestConstants.PICKUP_FAILURE_REASON_ID);
        jobOrder.setFailureReason(TestConstants.PICKUP_FAILURE_REASON);
      } else {
        jobOrder.setFailureReasonId(TestConstants.DELIVERY_FAILURE_REASON_ID);
        jobOrder.setFailureReason(TestConstants.DELIVERY_FAILURE_REASON);
      }
    }
    jobOrder.setAction(action);

    return jobOrder;
  }

  private List<JobUpdate> createTransactionJobRequest(List<String> trackingIds, String jobAction,
      String jobMode, boolean withCod, String podType) {
    List<JobUpdate> result = new ArrayList<>();
    trackingIds.forEach(e -> {
      JobUpdate temp = new JobUpdate();
      temp.setToUpdateJob(true);
      temp.setCommitDate(Instant.now().toEpochMilli());
      temp.setJob(createTransactionJob(e, jobAction, jobMode, withCod));
      temp.setParcel(createTransactionOrder(e, jobAction, jobMode));
      temp.setProofWebhookDetails(createProofWebhookDetails(podType, jobMode));
      result.add(temp);
    });
    return result;
  }

  private List<JobUpdate> createTransactionJobRequestWithoutPods(List<String> trackingIds,
      String jobMode) {
    List<JobUpdate> result = new ArrayList<>();
    trackingIds.forEach(e -> {
      JobUpdate temp = new JobUpdate();
      temp.setToUpdateJob(true);
      temp.setCommitDate(Instant.now().toEpochMilli());
      temp.setJob(createTransactionJob(e, ACTION_MODE_SUCCESS, jobMode, false));
      temp.setParcel(createTransactionOrder(e, ACTION_MODE_SUCCESS, jobMode));
      result.add(temp);
    });
    return result;
  }

  private List<JobUpdate> createTransactionPartialSuccessJobRequest(List<String> trackingIds,
      String jobMode) {
    int halfIndex = trackingIds.size() / 2;
    List<String> failedTrackingIds = trackingIds.subList(0, halfIndex);
    put(KEY_LIST_OF_PARTIAL_FAIL_TID, failedTrackingIds);
    List<String> successTrackingIds = trackingIds.subList(halfIndex, trackingIds.size());
    put(KEY_LIST_OF_PARTIAL_SUCCESS_TID, successTrackingIds);
    List<JobUpdate> result = new ArrayList<>();
    result.addAll(
        createTransactionJobRequest(successTrackingIds, ACTION_MODE_SUCCESS, jobMode, false,
            WebhookRequest.Pod.POD_TYPE_RECIPIENT));
    result.addAll(createTransactionJobRequest(failedTrackingIds, ACTION_MODE_FAIL, jobMode, false,
        WebhookRequest.Pod.POD_TYPE_RECIPIENT));
    return result;
  }

  private List<JobUpdate> createTransactionPartialSuccesProofRequest(List<String> trackingIds,
      String jobMode) {
    List<String> failedTrackingIds = get(KEY_LIST_OF_PARTIAL_FAIL_TID);
    List<String> successTrackingIds = get(KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    List<JobUpdate> result = new ArrayList<>();
    result.addAll(
        createTransactionUpdateProofRequest(successTrackingIds, ACTION_MODE_SUCCESS, jobMode,
            false));
    result.addAll(
        createTransactionUpdateProofRequest(failedTrackingIds, ACTION_MODE_FAIL, jobMode, false));
    return result;
  }

  private JobV5 createReservationJob(long jobId, String action) {

    Integer failureReasonId = TestConstants.RESERVATION_FAILURE_REASON_ID;
    String failureReasonString = TestConstants.RESERVATION_FAILURE_REASON;

    JobV5 job = new JobBuilder().setAction(action)
        .setId(jobId)
        .setMode(Job.MODE_PICKUP)
        .setStatus(Job.STATUS_PENDING)
        .setType(Job.TYPE_RESERVATION)
        .createBatchUpdateJob();
    if (action.equalsIgnoreCase(ACTION_MODE_FAIL)) {
      job.setFailureReason(failureReasonString);
      job.setFailureReasonId(failureReasonId);
    }

    return job;
  }

  private co.nvqa.commons.model.driver.Order createReservationOrder(String trackingId,
      String action) {
    Order order = OrderDetailHelper.getOrderDetails(trackingId);
    put(KEY_CREATED_ORDER, order);
    co.nvqa.commons.model.driver.Order job = new co.nvqa.commons.model.driver.Order();
    job.setId(order.getId());
    job.setTrackingId(trackingId);
    job.setAllowReschedule(false);

    Integer failureReasonId = TestConstants.RESERVATION_VALID_FAILURE_REASON_ID;
    if (action.equalsIgnoreCase(ACTION_MODE_FAIL)) {
      job.setFailureReasonId(failureReasonId);
    }
    job.setAction(action);
    return job;
  }

  private List<JobUpdate> createReservationJobRequest(List<String> trackingIds, long rsvnId,
      String jobAction, String orderAction) {
    List<JobUpdate> result = new ArrayList<>();
    trackingIds.forEach(e -> {
      JobUpdate temp = new JobUpdate();
      temp.setToUpdateJob(true);
      temp.setCommitDate(Instant.now().toEpochMilli());
      temp.setJob(createReservationJob(rsvnId, jobAction));
      temp.setParcel(createReservationOrder(e, orderAction));
      temp.setProofWebhookDetails(
          createProofWebhookDetails(WebhookRequest.Pod.POD_TYPE_RECIPIENT, PICKUP_JOB_MODE));
      result.add(temp);
    });
    return result;
  }

  private List<JobUpdate> createReservationJobWithoutParcelRequest(long rsvnId, String jobAction) {
    List<JobUpdate> result = new ArrayList<>();
    JobUpdate temp = new JobUpdate();
    temp.setToUpdateJob(true);
    temp.setCommitDate(Instant.now().toEpochMilli());
    temp.setJob(createReservationJob(rsvnId, jobAction));
    result.add(temp);
    return result;
  }

  private List<JobUpdate> createReservationPartialSuccessJobRequest(List<String> trackingIds,
      long rsvnId) {
    int halfIndex = trackingIds.size() / 2;
    List<String> failedTrackingIds = trackingIds.subList(0, halfIndex);
    put(KEY_LIST_OF_PARTIAL_FAIL_TID, failedTrackingIds);
    List<String> successTrackingIds = trackingIds.subList(halfIndex, trackingIds.size());
    put(KEY_LIST_OF_PARTIAL_SUCCESS_TID, successTrackingIds);
    List<JobUpdate> result = new ArrayList<>();
    result.addAll(createReservationJobRequest(successTrackingIds, rsvnId, ACTION_MODE_SUCCESS,
        ACTION_MODE_SUCCESS));
    result.addAll(createReservationJobRequest(failedTrackingIds, rsvnId, ACTION_MODE_SUCCESS,
        ACTION_MODE_FAIL));
    return result;
  }

  private List<JobUpdate> createReservationPartialSuccessProofRequest(long rsvnId) {
    List<String> failedTrackingIds = get(KEY_LIST_OF_PARTIAL_FAIL_TID);
    List<String> successTrackingIds = get(KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    List<JobUpdate> result = new ArrayList<>();
    JobUpdate temp = new JobUpdate();
    temp.setCommitDate(Instant.now().toEpochMilli());
    temp.setJob(createReservationJob(rsvnId, ACTION_MODE_SUCCESS));
    temp.setProofDetails(
        createReservationProofDetailsPartialSuccess(failedTrackingIds, successTrackingIds));
    result.add(temp);
    return result;
  }

  private ProofDetails createProofWebhookDetails(String type, String jobMode) {
    ProofDetails result = new ProofDetails();
    Order order = get(KEY_CREATED_ORDER);
    result.setSignatureImageUrl(URL_IMAGE);
    String name;
    String contact;
    if (type.equalsIgnoreCase(WebhookRequest.Pod.POD_TYPE_RECIPIENT)) {
      put(KEY_WEBHOOK_POD_TYPE, WebhookRequest.Pod.POD_TYPE_RECIPIENT);
      name = order.getToName();
    } else {
      put(KEY_WEBHOOK_POD_TYPE, WebhookRequest.Pod.POD_TYPE_SUBSTITUTE);
      name = WebhookRequest.Pod.POD_TYPE_SUBSTITUTE + "-" + order.getTrackingId();
    }

    if (jobMode.equalsIgnoreCase(DELIVERY_JOB_MODE)) {
      contact = order.getToContact();
    } else {
      contact = order.getFromContact();
    }

    result.setName(name);
    result.setContact(contact);
    putInMap(KEY_MAP_PROOF_WEBHOOK_DETAILS, order.getTrackingId(), result);
    put(KEY_PROOF_RESERVATION_REQUEST, result);
    return result;
  }

  private ProofDetails createProofDetails(String trackingId) {
    Map<String, ProofDetails> proofDetailsMap = get(KEY_MAP_PROOF_WEBHOOK_DETAILS);
    ProofDetails result = proofDetailsMap.get(trackingId);
    result.setLatitude(1.3856817);
    result.setLongitude(103.8450433);
    List<String> temp = new ArrayList<>();
    temp.add(trackingId);
    result.setTrackingIds(temp);
    result.setImei(IMEI);
    return result;
  }

  private ProofDetails createReservationProofDetails(List<String> trackingIds, String jobAction) {
    ProofDetails result = get(KEY_PROOF_RESERVATION_REQUEST);

    if (result == null) {
      OrderRequestV4 order = get(KEY_ORDER_CREATE_REQUEST);
      result = new ProofDetails();
      result.setName(order.getFrom().getName());
      result.setContact(order.getFrom().getPhoneNumber());
      result.setSignatureImageUrl(URL_IMAGE);
    }
    result.setLatitude(1.3856817);
    result.setLongitude(103.8450433);
    result.setImei(IMEI);

    if (jobAction.equalsIgnoreCase(ACTION_MODE_FAIL)) {
      result.setFailureReason(TestConstants.RESERVATION_FAILURE_REASON);
      result.setFailureReasonId(TestConstants.RESERVATION_FAILURE_REASON_ID);
      result.setComments("Failed with reason id " + TestConstants.RESERVATION_FAILURE_REASON_ID);
      List<FailedParcels> failedParcels = new ArrayList<>();
      if (!trackingIds.isEmpty()) {
        result.setPickupQuantity(0);
        trackingIds.forEach(e -> {
          long orderId = OrderDetailHelper.searchOrder(e).getId();
          FailedParcels temp = new FailedParcels();
          temp.setFailureReasonId(TestConstants.PICKUP_FAILURE_REASON_ID);
          temp.setFailureReason(TestConstants.PICKUP_FAILURE_REASON);
          temp.setOrderId(orderId);
          failedParcels.add(temp);
        });
      }
      result.setFailedParcels(failedParcels);

    } else {
      int pickupQuantity = trackingIds.size();
      if (pickupQuantity == 0) {
        //to default unmanifested pickup
        pickupQuantity = 5;
      }
      result.setPickupQuantity(pickupQuantity);

    }
    result.setTrackingIds(trackingIds);
    return result;
  }

  private ProofDetails createReservationProofDetailsPartialSuccess(List<String> failedTrackingIds,
      List<String> successTrackingIds) {
    ProofDetails result = get(KEY_PROOF_RESERVATION_REQUEST);
    result.setLatitude(1.3856817);
    result.setLongitude(103.8450433);
    result.setImei(IMEI);

    List<FailedParcels> failedParcels = new ArrayList<>();
    failedTrackingIds.forEach(e -> {
      long orderId = OrderDetailHelper.searchOrder(e).getId();
      FailedParcels temp = new FailedParcels();
      temp.setFailureReasonId(TestConstants.RESERVATION_VALID_FAILURE_REASON_ID);
      temp.setOrderId(orderId);
      failedParcels.add(temp);
    });
    result.setFailedParcels(failedParcels);
    result.setPickupQuantity(successTrackingIds.size());
    result.setTrackingIds(successTrackingIds);

    return result;
  }

  private List<JobUpdate> createTransactionUpdateProofRequest(List<String> trackingIds,
      String jobAction, String jobMode, boolean witCod) {
    List<JobUpdate> result = new ArrayList<>();
    trackingIds.forEach(e -> {
      JobUpdate temp = new JobUpdate();
      temp.setCommitDate(Instant.now().toEpochMilli());
      temp.setJob(createTransactionJob(e, jobAction, jobMode, witCod));
      temp.setProofDetails(createProofDetails(e));
      result.add(temp);
    });
    return result;
  }

  private List<JobUpdate> createReservationUpdateProofRequest(long rsvnId, List<String> trackingIds,
      String jobAction) {
    List<JobUpdate> result = new ArrayList<>();
    JobUpdate temp = new JobUpdate();
    temp.setCommitDate(Instant.now().toEpochMilli());
    temp.setJob(createReservationJob(rsvnId, jobAction));
    temp.setProofDetails(createReservationProofDetails(trackingIds, jobAction));
    result.add(temp);
    return result;
  }

  private void getTransactionWaypointId(String transactionType) {
    String trackingId = get(KEY_CREATED_ORDER_TRACKING_ID);
    co.nvqa.commons.model.core.Order order = OrderDetailHelper.getOrderDetails(trackingId);
    put(KEY_CREATED_ORDER, order);
    Transaction transaction = OrderDetailHelper
        .getTransaction(order, transactionType, Transaction.STATUS_PENDING);
    put(KEY_WAYPOINT_ID, transaction.getWaypointId());
  }

  private void checkDeliverySuccesPod(WebhookRequest webhookRequest, String trackingId) {
    Map<String, ProofDetails> proofDetails = get(KEY_MAP_PROOF_WEBHOOK_DETAILS);
    String podType = get(KEY_WEBHOOK_POD_TYPE);
    ProofDetails podDetails = proofDetails.get(trackingId);
    if (podDetails != null) {
      Assertions.assertThat(webhookRequest.getPod().getName().toLowerCase()).as("name equal")
          .isEqualTo(podDetails.getName().toLowerCase());
      Assertions.assertThat(webhookRequest.getPod().getContact().toLowerCase()).as("contact equal")
          .isEqualTo(podDetails.getContact().toLowerCase());
      Assertions.assertThat(Boolean.parseBoolean(webhookRequest.getPod().getLeftInSafePlace()))
          .as("left_in_safe_place = false").isFalse();
      Assertions.assertThat(webhookRequest.getPod().getUri().toLowerCase()).as("url equal")
          .isEqualTo(podDetails.getSignatureImageUrl().toLowerCase());
      Assertions.assertThat(webhookRequest.getPod().getType().toLowerCase())
          .as(f("type is %s", podType))
          .isEqualTo(podType.toLowerCase());
    }
  }

  private void cleanWebhookSubs(long shipperId) {
    try {
      Webhook[] webhooks = getShipperClient().getWebhookSubscription(shipperId);
      Arrays.asList(webhooks)
          .forEach(e -> getShipperClient().removeWebhookSubscription(shipperId, e.getId()));
      NvLogger.infof("webhook subscription cleared");
    } catch (Throwable t) {
      NvLogger.warn("Failed to clean webhook subs");
    }
  }
}
