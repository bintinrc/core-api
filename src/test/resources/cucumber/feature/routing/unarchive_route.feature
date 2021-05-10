@ForceSuccessOrder @DeleteReservationAndAddress @ArchiveDriverRoutes @routing @route-unarchive
Feature: Unarchive Route

  @route-unarchive
  Scenario: Operator Unarchive Driver Route Successfully - Empty Route (uid:33e2b7c1-51ef-4021-b71d-122de32e10d1)
    Given Operator create an empty route
      | driver_id  | {driver-id} |
      | hub_id     | {sorting-hub-id}    |
      | vehicle_id | {vehicle-id}        |
      | zone_id    | {zone-id}           |
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Operator unarchives driver route with status code 200
    Then DB Operator verifies route status = IN_PROGRESS & archived = 0

  @route-unarchive
  Scenario: Operator Unarchive Driver Route Successfully - Route has Waypoints (uid:9621bd52-7238-4b37-a542-2e4850a5ed1e)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper creates multiple orders : 3 orders
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator create an empty route
      | driver_id  | {driver-id} |
      | hub_id     | {sorting-hub-id}    |
      | vehicle_id | {vehicle-id}        |
      | zone_id    | {zone-id}           |
    And Operator add all orders to driver "DD" route
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Operator unarchives driver route with status code 200
    Then DB Operator verifies route status = IN_PROGRESS & archived = 0

  @route-unarchive
  Scenario: Operator Unarchive NON-archived Route (uid:d0370a75-e80e-4ba2-a0a9-19007af580e4)
    Given Operator create an empty route
      | driver_id  | {driver-id} |
      | hub_id     | {sorting-hub-id}    |
      | vehicle_id | {vehicle-id}        |
      | zone_id    | {zone-id}           |
    When Operator unarchives driver route with status code 400
    Then Operator verify unarchive route response with proper error message : Route "is not archived!"

  @route-unarchive
  Scenario: Operator Unarchive Invalid Route Id (uid:27d2eaec-d712-46db-b29d-300669495267)
    When Operator unarchives driver route with status code 404
    Then Operator verify unarchive route response with proper error message : Route "not found!"
