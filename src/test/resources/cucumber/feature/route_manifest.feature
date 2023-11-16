@ForceSuccessOrders  @ArchiveDriverRoutes @route-manifest
Feature: Route Manifest

  @HighPriority
  Scenario: Admin Manifest Force Success Merged Waypoint of DP Orders on Route Manifest
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper creates multiple orders : 3 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for all created orders
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_LIST_OF_CREATED_ORDER[1].id},"dp_id":{dp-id},"drop_off_date":"{date: 0 days next, yyyy-MM-dd}"} |
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_LIST_OF_CREATED_ORDER[2].id},"dp_id":{dp-id},"drop_off_date":"{date: 0 days next, yyyy-MM-dd}"} |
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_LIST_OF_CREATED_ORDER[3].id},"dp_id":{dp-id},"drop_off_date":"{date: 0 days next, yyyy-MM-dd}"} |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that all orders status-granular status is "Transit"-"Arrived_At_Distribution_Point"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[1]} |
      | status   | Success                       |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[2]} |
      | status   | Success                       |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[3]} |
      | status   | Success                       |
