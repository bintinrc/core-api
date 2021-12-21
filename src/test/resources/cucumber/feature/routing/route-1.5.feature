@ForceSuccessOrder @DeleteReservationAndAddress @routing @route-1.5-refactor @routing-refactor
Feature: Route 1.5

  Scenario: Unmerge waypoint with multiple transactions (uid:a7196db7-0635-45a8-a9d5-e201740e95b8)
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
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    Then DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all waypoints.route_id & seq_no is NULL
