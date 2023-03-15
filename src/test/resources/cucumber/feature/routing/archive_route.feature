@ForceSuccessOrder @DeleteReservationAndAddress @routing @route-archive
Feature: Archive Route

  @route-archive
  Scenario: Operator Archive Driver Route Successfully - Empty Route
    Given Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator archives routes below:
      | {KEY_CREATED_ROUTE_ID} |
    Then DB Operator verifies route status is archived
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Archived route is not shown on his list routes

  @route-archive @happy-path
  Scenario: Operator Archive Driver Route Successfully - Status = PENDING
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel                      |
      | service_level                 | Standard                    |
      | requested_tracking_number     | <requested_tracking_number> |
      | parcel_job_is_pickup_required | false                       |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    When API Core - Operator archives routes below:
      | {KEY_CREATED_ROUTE_ID} |
    Then DB Operator verifies route status is archived
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Archived route is not shown on his list routes

  @route-archive
  Scenario: Operator Archive Driver Route Successfully - Status = IN_PROGRESS
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    And Driver Starts the route
    When API Core - Operator archives routes below:
      | {KEY_CREATED_ROUTE_ID} |
    Then DB Operator verifies route status is archived
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    And Archived route is not shown on his list routes

  @route-archive
  Scenario: Operator not Allowed to Archive an already Archived Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    When API Core - Operator archives routes below:
      | {KEY_CREATED_ROUTE_ID} |
    Then DB Operator verifies route status is archived
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Archived route is not shown on his list routes
    When API Core - Operator archives routes below:
      | {KEY_CREATED_ROUTE_ID} |
    Then DB Operator verifies route status is archived
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Archived route is not shown on his list routes

  @route-archive
  Scenario: Operator not Allowed to Archive Driver Invalid Route Id - Deleted Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator delete driver route
    When API Core - Operator archives invalid route with data below:
      | routeId | {KEY_CREATED_ROUTE_ID} |
      | status  | 404                    |
    Then Operator verify route response with proper error message below:
      | message | The requested route '[:routeId=%s]' not found |
      | routeId | {KEY_CREATED_ROUTE_ID}                        |

  @route-archive
  Scenario: Operator not Allowed to Archive Driver Invalid Route Id - Route Not Found
    When API Core - Operator archives invalid route with data below:
      | routeId | 89  |
      | status  | 404 |
    Then Operator verify route response with proper error message below:
      | message | The requested route '[:routeId=%s]' not found |
      | routeId | 89                                            |
