package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.commons.client.others.RequestBinClient;
import co.nvqa.commons.model.core.Order;
import co.nvqa.commons.model.core.Pickup;
import co.nvqa.commons.model.core.Transaction;
import co.nvqa.commons.model.core.batch_update_pod.BlobData;
import co.nvqa.commons.model.core.batch_update_pod.FailedParcels;
import co.nvqa.commons.model.core.batch_update_pod.JobUpdate;
import co.nvqa.commons.model.core.batch_update_pod.ProofDetails;
import co.nvqa.commons.model.driver.Job;
import co.nvqa.commons.model.driver.JobV5;
import co.nvqa.commons.model.driver.builder.JobBuilder;
import co.nvqa.commons.model.order_create.v4.OrderRequestV4;
import co.nvqa.commons.model.requestbin.Bin;
import co.nvqa.commons.model.requestbin.BinRequest;
import co.nvqa.commons.model.shipper.v2.Webhook;
import co.nvqa.commons.model.shipper.v2.WebhookRequest;
import co.nvqa.commons.util.JsonUtils;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.commonsort.cucumber.KeysStorage;
import co.nvqa.commonsort.model.sort.Hub;
import co.nvqa.core_api.cucumber.glue.BaseSteps;
import co.nvqa.core_api.cucumber.glue.support.OrderDetailHelper;
import co.nvqa.core_api.cucumber.glue.support.TestConstants;
import io.cucumber.guice.ScenarioScoped;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;
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

  private static final String PICKUP_JOB_MODE = "PICK_UP";
  private static final String DELIVERY_JOB_MODE = "DELIVERY";
  private static final String ACTION_MODE_FAIL = "FAIL";
  private static final String ACTION_MODE_SUCCESS = "SUCCESS";
  private static final String URL_IMAGE = "https://cdn.ninjavan.co/sg/pods/signature_3f2fa65d-1fec-4546-9efe-4703cb081aa0.png";
  private static final String IMEI = "41e74ed6b321e2f9";

  @Override
  public void init() {
  }

  @Given("API Batch Update Job Request to Success All Created Orders {string} with pod type {string}")
  public void apiBatchJobUpdateOrdersSuccess(String transactionType, String podType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(transactionType);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_SUCCESS, PICKUP_JOB_MODE,
            false, podType, false);
      } else {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_SUCCESS, DELIVERY_JOB_MODE,
            false, podType, false);
      }
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Job Request to Success COD Delivery")
  public void apiBatchJobUpdateOrdersCodSuccess() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(Transaction.TYPE_DELIVERY);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createTransactionJobRequest(trackingIds, ACTION_MODE_SUCCESS,
          DELIVERY_JOB_MODE,
          true, WebhookRequest.Pod.POD_TYPE_RECIPIENT, false);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Job Request to fail and reschedule Delivery")
  public void apiBatchJobUpdateOrderReschedule() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(Transaction.TYPE_DELIVERY);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createTransactionJobRequest(trackingIds, ACTION_MODE_FAIL,
          DELIVERY_JOB_MODE,
          false, WebhookRequest.Pod.POD_TYPE_RECIPIENT, true);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Job Request to Success All Created Orders {string} with NO Proof Details")
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
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Proof Request to Success All Created Orders {string}")
  public void apiBatchProofsUpdateOrdersSuccess(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_SUCCESS,
            PICKUP_JOB_MODE);
      } else {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_SUCCESS,
            DELIVERY_JOB_MODE);
      }
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update proofs", 30);
  }

  @Given("API Batch Update Job Request to Fail All Created Orders {string}")
  public void apiBatchJobUpdateOrdersFail(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      getTransactionWaypointId(transactionType);
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_FAIL, PICKUP_JOB_MODE, false,
            WebhookRequest.Pod.POD_TYPE_RECIPIENT, false);
      } else {
        request = createTransactionJobRequest(trackingIds, ACTION_MODE_FAIL, DELIVERY_JOB_MODE,
            false, WebhookRequest.Pod.POD_TYPE_RECIPIENT, false);
      }
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Proof Request to Fail All Created Orders {string}")
  public void apiBatchProofsUpdateOrdersFail(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_FAIL,
            PICKUP_JOB_MODE);
      } else {
        request = createTransactionUpdateProofRequest(trackingIds, ACTION_MODE_FAIL,
            DELIVERY_JOB_MODE);
      }
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update proofs", 30);
  }

  @Given("API Batch Update Job Request to {string} All Orders under the reservation")
  public void apiBatchJobUpdateReservationAllOrders(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationJobRequest(trackingIds, reservationId, action,
          action);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Job Request to {string} All Return Orders under the reservation")
  public void apiBatchJobUpdateReservationAllReturnOrders(String action) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    List<OrderRequestV4> orderRequest = get(KEY_LIST_OF_ORDER_CREATE_RESPONSE);
    String normalTid = orderRequest.stream()
        .filter(e -> e.getServiceType().equalsIgnoreCase("Parcel"))
        .findAny().orElseThrow(() -> new NvTestRuntimeException("cant find order response"))
        .getTrackingNumber();
    trackingIds.remove(normalTid);
    put(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID, trackingIds);
    apiBatchJobUpdateReservationAllOrders(action);
    put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
  }

  @Given("API Batch Update Proof Request to {string} All Orders under the reservation")
  public void apiBatchProofsUpdateReservationAllOrders(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationUpdateProofRequest(reservationId, trackingIds,
          action);
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("Operator get proof details for {string} transaction of {string} orders")
  public void dbOperatorVerifiesTransactionBlobCreatedReturn(String action, String type) {
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    List<JobUpdate> reservationProof = get(KEY_UPDATE_PROOFS_REQUEST);
    List<JobUpdate> request = createTransactionUpdateProofRequest(trackingIds, action,
        PICKUP_JOB_MODE);
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

  @Given("API Batch Update Proof Request to Partial Success & Fail Orders under the reservation")
  public void apiBatchProofsUpdateReservationPartialSuccess() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationPartialSuccessProofRequest(reservationId);
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("API Batch Update Proof Request to {string} Reservation without any Parcel")
  public void apiBatchProofsUpdateReservationNoOrders(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationUpdateProofRequest(reservationId,
          new ArrayList<>(), action);
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update proofs", 30);
  }

  @Given("API Batch Update Job Request to Partial Success Orders under the reservation")
  public void apiBatchJobUpdateReservationPartialOrders() {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationPartialSuccessJobRequest(trackingIds,
          reservationId);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Job Request to {string} Reservation without any Parcel")
  public void apiBatchJobUpdateReservationWithoutOrder(String action) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    Pickup pickup = get(KEY_CREATED_RESERVATION);
    long reservationId = pickup.getReservationId();
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request = createReservationJobWithoutParcelRequest(reservationId, action);
      getBatchUpdatePodClient().batchUpdatePodJobs(routeId, waypointId, request);
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Proof Request to Partial Success Orders {string}")
  public void apiBatchJobUpdatePartialSuccessProofs(String transactionType) {
    long routeId = get(KEY_CREATED_ROUTE_ID);
    List<String> trackingIds = get(KEY_LIST_OF_CREATED_ORDER_TRACKING_ID);
    callWithRetry(() -> {
      long waypointId = get(KEY_WAYPOINT_ID);
      List<JobUpdate> request;
      if (transactionType.equalsIgnoreCase(Transaction.TYPE_PICKUP)) {
        request = createTransactionPartialSuccessProofRequest(trackingIds, PICKUP_JOB_MODE);
      } else {
        request = createTransactionPartialSuccessProofRequest(trackingIds, DELIVERY_JOB_MODE);
      }
      put(KEY_UPDATE_PROOFS_REQUEST, request);
      getBatchUpdatePodClient().batchUpdatePodProofs(routeId, waypointId, request);
    }, "batch update jobs", 30);
  }

  @Given("API Batch Update Job Request to Partial Success Orders {string}")
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
      put(KEY_UPDATE_STATUS_REASON, "BATCH_POD_UPDATE");
    }, "batch update proofs", 30);
  }

  @Given("Verify blob data is correct")
  public void dbOperatorVerifiesBlobData() {
    List<JobUpdate> proofRequest = get(KEY_UPDATE_PROOFS_REQUEST);
    Map<Long, String> blobDataMap = get(KEY_LIST_OF_BLOB_DATA);
    callWithRetry(() -> {
      proofRequest.forEach(e -> {
        BlobData blobData = fromJsonSnakeCase(blobDataMap.get(e.getJob().getId()), BlobData.class);
        ProofDetails proofDetails = e.getProofDetails();
        Assertions.assertThat(blobData.getName().toLowerCase()).as("name")
            .isEqualTo(proofDetails.getName().toLowerCase());
        Assertions.assertThat(blobData.getContact()).as("contact")
            .isEqualTo(proofDetails.getContact());
        String signCoordinates = proofDetails.getLongitude() + "," + proofDetails.getLatitude();
        Assertions.assertThat(blobData.getSignCoordinates()).as("sign coordinates")
            .isEqualTo(signCoordinates);
        Assertions.assertThat(blobData.getImei()).as("imei").isEqualTo(proofDetails.getImei());
        Assertions.assertThat(blobData.getUrl()).as("url")
            .isEqualTo(proofDetails.getSignatureImageUrl());
        if (e.getJob().getAction().equalsIgnoreCase(ACTION_MODE_FAIL)) {
          Assertions.assertThat(blobData.getFailureReasonId()).as("failure reason id")
              .isEqualTo(e.getJob().getFailureReasonId());
          Assertions.assertThat(
              blobData.getFailureReasonTranslations().contains(e.getJob().getFailureReason()))
              .as("failure reason translations").isTrue();
        }
        if (e.getJob().getType().equalsIgnoreCase("RESERVATION")) {
          Assertions.assertThat(blobData.getStatus()).as("Status is null").isNull();
          if (e.getJob().getAction().equalsIgnoreCase(ACTION_MODE_FAIL)) {
            Assertions.assertThat(blobData.getComments()).as("comments").isEqualTo(
                e.getJob().getFailureReason() + ". " + e.getProofDetails().getComments());
          } else {
            Assertions.assertThat(
                blobData.getScannedParcels().containsAll(e.getProofDetails().getTrackingIds()))
                .as("scanned parcels contains scanned tracking ids").isTrue();
            Assertions.assertThat(blobData.getReceivedParcels()).as("received parcels")
                .isEqualTo(e.getProofDetails().getPickupQuantity());
          }
          return;
        }
        Assertions.assertThat(blobData.getStatus()).as("status is correct")
            .isEqualTo(e.getJob().getAction());
        Pickup pickup = get(KEY_CREATED_RESERVATION);
        if (pickup == null) {
          Assertions.assertThat(blobData.getVerificationMethod()).as("no verification method")
              .isEqualTo("NO_VERIFICATION");
        } else {
          Assertions.assertThat(blobData.getVerificationMethod()).as("Verification method is null")
              .isNull();
        }
      });
    }, "check blob data");
  }

  private JobV5 createTransactionJob(String trackingId, String action, String jobMode,
      boolean withCod, boolean allowReschedule) {

    Order order = OrderDetailHelper.getOrderDetails(trackingId);
    if (Objects.isNull(order)) {
      LOGGER.info("null order: " + trackingId);
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
    job.setAllowReschedule(allowReschedule);
    if (action.equalsIgnoreCase(ACTION_MODE_FAIL)) {

      if (jobMode.equalsIgnoreCase(PICKUP_JOB_MODE)) {
        job.setFailureReasonId(TestConstants.PICKUP_FAILURE_REASON_ID);
        job.setFailureReason(TestConstants.PICKUP_FAILURE_REASON);
        job.setFailureReasonCodeId(TestConstants.PICKUP_FAILURE_REASON_CODE_ID);
      } else {
        job.setFailureReasonId(TestConstants.DELIVERY_FAILURE_REASON_ID);
        job.setFailureReason(TestConstants.DELIVERY_FAILURE_REASON);
        job.setFailureReasonCodeId(TestConstants.DELIVERY_FAILURE_REASON_CODE_ID);
      }
      put(KEY_FAILURE_REASON_ID, job.getFailureReasonId());
      put(KEY_FAILURE_REASON_CODE_ID, job.getFailureReasonCodeId());
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
      String jobMode, boolean withCod, String podType, boolean allowReschedule) {
    List<JobUpdate> result = new ArrayList<>();
    trackingIds.forEach(e -> {
      JobUpdate temp = new JobUpdate();
      temp.setToUpdateJob(true);
      temp.setCommitDate(Instant.now().toEpochMilli());
      temp.setJob(createTransactionJob(e, jobAction, jobMode, withCod, allowReschedule));
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
      temp.setJob(createTransactionJob(e, ACTION_MODE_SUCCESS, jobMode, false, false));
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
            WebhookRequest.Pod.POD_TYPE_RECIPIENT, false));
    result.addAll(createTransactionJobRequest(failedTrackingIds, ACTION_MODE_FAIL, jobMode, false,
        WebhookRequest.Pod.POD_TYPE_RECIPIENT, false));
    return result;
  }

  private List<JobUpdate> createTransactionPartialSuccessProofRequest(List<String> trackingIds,
      String jobMode) {
    List<String> failedTrackingIds = get(KEY_LIST_OF_PARTIAL_FAIL_TID);
    List<String> successTrackingIds = get(KEY_LIST_OF_PARTIAL_SUCCESS_TID);
    List<JobUpdate> result = new ArrayList<>();
    result.addAll(
        createTransactionUpdateProofRequest(successTrackingIds, ACTION_MODE_SUCCESS, jobMode
        ));
    result.addAll(
        createTransactionUpdateProofRequest(failedTrackingIds, ACTION_MODE_FAIL, jobMode));
    return result;
  }

  private JobV5 createReservationJob(long jobId, String action) {

    Integer failureReasonId = TestConstants.RESERVATION_FAILURE_REASON_ID;
    String failureReasonString = TestConstants.RESERVATION_FAILURE_REASON;
    Integer failureReasonCodeId = TestConstants.RESERVATION_FAILURE_REASON_CODE_ID;

    JobV5 job = new JobBuilder().setAction(action)
        .setId(jobId)
        .setMode(Job.MODE_PICKUP)
        .setStatus(Job.STATUS_PENDING)
        .setType(Job.TYPE_RESERVATION)
        .createBatchUpdateJob();
    if (action.equalsIgnoreCase(ACTION_MODE_FAIL)) {
      job.setFailureReason(failureReasonString);
      job.setFailureReasonId(failureReasonId);
      job.setFailureReasonCodeId(failureReasonCodeId);
      put(KEY_FAILURE_REASON_ID, failureReasonId);
      put(KEY_FAILURE_REASON_CODE_ID, failureReasonCodeId);
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

  private List<JobUpdate> createReservationJobWithoutParcelRequest(Long rsvnId, String jobAction) {
    List<JobUpdate> result = new ArrayList<>();
    JobUpdate temp = new JobUpdate();
    temp.setToUpdateJob(true);
    temp.setCommitDate(Instant.now().toEpochMilli());
    temp.setJob(createReservationJob(rsvnId, jobAction));
    result.add(temp);
    return result;
  }

  private List<JobUpdate> createReservationPartialSuccessJobRequest(List<String> trackingIds,
      Long rsvnId) {
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

  private List<JobUpdate> createReservationPartialSuccessProofRequest(Long rsvnId) {
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
      String jobAction, String jobMode) {
    List<JobUpdate> result = new ArrayList<>();
    trackingIds.forEach(e -> {
      JobUpdate temp = new JobUpdate();
      temp.setCommitDate(Instant.now().toEpochMilli());
      temp.setJob(createTransactionJob(e, jobAction, jobMode, false, false));
      temp.setProofDetails(createProofDetails(e));
      result.add(temp);
    });
    return result;
  }

  private List<JobUpdate> createReservationUpdateProofRequest(Long rsvnId, List<String> trackingIds,
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
}
