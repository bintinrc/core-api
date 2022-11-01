@ForceSuccessOrder @ArchiveDriverRoutes @DeleteReservationAndAddress @routing @route-1.5-refactor @routing-refactor
Feature: Route 1.5

  Scenario: Unmerge waypoint with multiple transactions
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper creates multiple orders : 3 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And Operator merge transactions on Zonal Routing
    And API Operator verifies Delivery transactions of following orders have same waypoint id:
      | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
    When Operator unmerge transactions
    Then API Operator verifies Delivery transactions of following orders have different waypoint id:
      | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    Then DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all waypoints.route_id & seq_no is NULL
