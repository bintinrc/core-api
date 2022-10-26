@ForceSuccessOrder @ArchiveDriverRoutes @DeleteReservationAndAddress @ArchiveDriverRoutes @routing @route-unarchive
Feature: Unarchive Route

  @route-unarchive
  Scenario: Operator Unarchive Driver Route Successfully - Empty Route
    Given Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Operator unarchives driver route with status code 200
    Then DB Operator verifies route status = IN_PROGRESS & archived = 0

  @route-unarchive
  Scenario: Operator Unarchive Driver Route Successfully - Route has Waypoints
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper creates multiple orders : 3 orders
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Operator unarchives driver route with status code 200
    Then DB Operator verifies route status = IN_PROGRESS & archived = 0

  @route-unarchive
  Scenario: Operator Unarchive NON-archived Route
    Given Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator unarchives driver route with status code 200

  @route-unarchive
  Scenario: Operator Unarchive Invalid Route Id
    When Operator unarchives driver route with status code 404
    Then Operator verify unarchive route response with proper error message : "The requested route '[:routeId=%s]' not found"
