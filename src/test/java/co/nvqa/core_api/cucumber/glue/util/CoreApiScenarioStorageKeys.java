package co.nvqa.core_api.cucumber.glue.util;

public interface CoreApiScenarioStorageKeys {

  //dp
  String KEY_DP_SHIPPER_LEGACY_ID = "KEY_DP_SHIPPER_LEGACY_ID";

  String KEY_LIST_OF_WEBHOOK_REQUEST = "KEY_LIST_OF_WEBHOOK_REQUEST";
  String KEY_WEBHOOK_PAYLOAD = "KEY_WEBHOOK_PAYLOAD";
  String KEY_LIST_OF_PARTIAL_SUCCESS_TID = "KEY_LIST_OF_PARTIAL_SUCCESS_TID";
  String KEY_LIST_OF_PARTIAL_FAIL_TID = "KEY_LIST_OF_PARTIAL_FAIL_TID";
  String KEY_MAP_PROOF_WEBHOOK_DETAILS = "KEY_MAP_PROOF_WEBHOOK_DETAILS";
  String KEY_PROOF_RESERVATION_REQUEST = "KEY_PROOF_RESERVATION_REQUEST";
  String KEY_WEBHOOK_POD_TYPE = "KEY_WEBHOOK_POD_TYPE";


  // driver steps key
  String KEY_LIST_OF_CREATED_JOB_ORDERS = "KEY_LIST_OF_CREATED_JOB_ORDERS";
  String KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS = "KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS";
  String KEY_DRIVER_WAYPOINT_DETAILS = "KEY_DRIVER_WAYPOINT_DETAILS";
  String KEY_LIST_OF_DRIVER_JOBS = "KEY_LIST_OF_DRIVER_JOBS";
  String KEY_DRIVER_SUBMIT_POD_REQUEST = "KEY_DRIVER_SUBMIT_POD_REQUEST";
  String WAYPOINT_TYPE_RESERVATION = "RESERVATION";
  String KEY_BOOLEAN_DRIVER_FAILED_VALID = "KEY_BOOLEAN_DRIVER_FAILED_VALID";
  String KEY_NINJA_DRIVER_ID = "KEY_NINJA_DRIVER_ID";

  // order create steps
  String KEY_SHIPPER_V4_ACCESS_TOKEN = "KEY_SHIPPER_V4_ACCESS_TOKEN";
  String KEY_LIST_OF_ORDER_TAG_IDS = "KEY_LIST_OF_ORDER_TAG_IDS";
  String KEY_LIST_OF_PRIOR_TRACKING_IDS = "KEY_LIST_OF_PRIOR_TRACKING_IDS";
  String KEY_API_RAW_RESPONSE = "KEY_API_RAW_RESPONSE";
  String KEY_UPDATE_STATUS_REASON = "KEY_UPDATE_STATUS_REASON";
  String KEY_ORDER_CREATE_REQUEST = "KEY_ORDER_CREATE_REQUEST";
  String KEY_LIST_OF_CREATED_ORDER_TRACKING_ID = "KEY_LIST_OF_CREATED_ORDER_TRACKING_ID";
  String KEY_CREATED_ORDER_TRACKING_ID = "KEY_CREATED_ORDER_TRACKING_ID";

  //  orders
  String KEY_CREATED_ORDER = "KEY_CREATED_ORDER";
  String KEY_LIST_OF_CREATED_ORDER = "KEY_LIST_OF_CREATED_ORDER";
  String KEY_CREATED_ORDER_ID = "KEY_CREATED_ORDER_ID";
  String KEY_LIST_OF_CREATED_ORDER_ID = "KEY_LIST_OF_CREATED_ORDER_ID";


  String KEY_LIST_OF_ORDER_CREATE_RESPONSE = "KEY_LIST_OF_ORDER_CREATE_RESPONSE";
  String KEY_LIST_OF_ORDER_CREATE_REQUEST = "KEY_LIST_OF_ORDER_CREATE_REQUEST";
  String KEY_LIST_OF_PICKUP_ADDRESS_STRING = "KEY_LIST_OF_PICKUP_ADDRESS_STRING";
  String KEY_PICKUP_ADDRESS_STRING = "KEY_PICKUP_ADDRESS_STRING";

  //rsvn
  String KEY_LIST_OF_RESERVATION_TRACKING_IDS = "KEY_LIST_OF_RESERVATION_TRACKING_IDS";
  String KEY_INITIAL_RESERVATION_ADDRESS = "KEY_INITIAL_RESERVATION_ADDRESS";
  String KEY_CREATED_RESERVATION = "KEY_CREATED_RESERVATION";

  //route monitoring
  String KEY_ROUTE_MONITORING_RESULT = "KEY_ROUTE_MONITORING_RESULT";
  String KEY_TOTAL_EXPECTED_WAYPOINT = "KEY_TOTAL_EXPECTED_WAYPOINT";
  String KEY_TOTAL_EXPECTED_PENDING_PRIORITY = "KEY_TOTAL_EXPECTED_PENDING_PRIORITY";
  String KEY_TOTAL_EXPECTED_INVALID_FAILED = "KEY_TOTAL_EXPECTED_INVALID_FAILED";
  String KEY_TOTAL_EXPECTED_VALID_FAILED = "KEY_TOTAL_EXPECTED_VALID_FAILED";
  String KEY_TOTAL_EXPECTED_EARLY = "KEY_TOTAL_EXPECTED_EARLY";
  String KEY_LIST_RESERVATION_REQUEST_DETAILS = "KEY_LIST_RESERVATION_REQUEST_DETAILS";

  // route
  String KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID = "KEY_LIST_OF_PULL_OUT_OF_ROUTE_TRACKING_ID";
  String KEY_ROUTE_EVENT_SOURCE = "KEY_ROUTE_EVENT_SOURCE";
  String KEY_UNARCHIVE_ROUTE_RESPONSE = "KEY_UNARCHIVE_ROUTE_RESPONSE";
  String KEY_ARCHIVE_ROUTE_RESPONSE = "KEY_ARCHIVE_ROUTE_RESPONSE";
  String KEY_DELETE_ROUTE_RESPONSE = "KEY_DELETE_ROUTE_RESPONSE";
  String KEY_CREATED_ROUTE_ID = "KEY_CREATED_ROUTE_ID";
  String KEY_CREATED_ROUTE = "KEY_CREATED_ROUTE";

  //  transactions
  String KEY_TRANSACTION_DETAILS = "KEY_TRANSACTION_DETAILS";
  String KEY_TRANSACTION_ID = "KEY_TRANSACTION_ID";
  String KEY_LIST_OF_TRANSACTION_IDS = "KEY_LIST_OF_TRANSACTION_IDS";
  String KEY_LIST_OF_TRANSACTION_DETAILS = "KEY_LIST_OF_TRANSACTION_DETAILS";

  //  waypoints
  String KEY_LIST_OF_WAYPOINT_IDS = "KEY_LIST_OF_WAYPOINT_IDS";
  String KEY_MAP_OF_WAYPOINT_IDS_ORDER = "KEY_MAP_OF_WAYPOINT_IDS_ORDER";
  String KEY_DELIVERY_WAYPOINT_ID = "KEY_DELIVERY_WAYPOINT_ID";

  //  inbound & order action steps
  String KEY_DIMENSION_CHANGES_REQUEST = "KEY_DIMENSION_CHANGES_REQUEST";

  //  others
  String KEY_CANCELLATION_REASON = "KEY_CANCELLATION_REASON";
  String KEY_DRIVER_FAIL_ATTEMPT_COUNT = "KEY_DRIVER_FAIL_ATTEMPT_COUNT";
  String KEY_ORDER_EVENTS = "KEY_ORDER_EVENTS";
  String KEY_LIST_OF_ORDER_EVENTS = "KEY_LIST_OF_ORDER_EVENTS";

  //  batch update pods
  String KEY_WAYPOINT_ID = "KEY_WAYPOINT_ID";
  String KEY_UPDATE_PROOFS_REQUEST = "KEY_UPDATE_PROOFS_REQUEST";

  // LEGACY
  @Deprecated
  String KEY_LIST_OF_CREATED_RESERVATIONS = "KEY_LIST_OF_CREATED_RESERVATIONS";
  @Deprecated
  String KEY_LIST_OF_CREATED_ROUTE_ID = "KEY_LIST_OF_CREATED_ROUTE_ID";
  @Deprecated
  String KEY_FAILURE_REASON_ID = "KEY_FAILURE_REASON_ID";
  @Deprecated
  String KEY_FAILURE_REASON_CODE_ID = "KEY_FAILURE_REASON_CODE_ID";
  @Deprecated
  String KEY_LIST_OF_HUB_IDS = "KEY_LIST_OF_HUB_IDS";
  @Deprecated
  String KEY_LIST_OF_ZONE_IDS = "KEY_LIST_OF_ZONE_ID";
  @Deprecated
  String KEY_ROUTE_SOURCE_BY_INBOUND = "KEY_ROUTE_SOURCE_BY_INBOUND";
}
