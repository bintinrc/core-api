@ForceSuccessOrder @DeleteReservationAndAddress @ArchiveDriverRoutes @routing @route-archive
Feature: Archive Route

  @route-archive
  Scenario: Operator Archive Driver Route Successfully - Empty Route (uid:6274cf87-9e6d-4087-912c-937093311538)
    Given Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator archives driver route with status code 204
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Archived route is not shown on his list routes

  @route-archive
  Scenario: Operator Archive Driver Route Successfully - Status = PENDING (uid:8a99328a-9070-4fe4-9a51-a40ff025975c)
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
    And Operator archives driver route with status code 204
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Archived route is not shown on his list routes

  @route-archive
  Scenario: Operator Archive Driver Route Successfully - Status = IN_PROGRESS (uid:33dfaebd-6ce1-4022-abc3-8c443db4e72e)
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
    When Driver authenticated to login with username "{driver-username}" and password "{driver-password}"
    And Driver Starts the route
    When Operator archives driver route with status code 204
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{driver-username}" and password "{driver-password}"
    And Archived route is not shown on his list routes

  @route-archive
  Scenario: Operator not Allowed to Archive an already Archived Route (uid:0d211076-23da-4e20-ba06-c41fc1b122e3)
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
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Archived route is not shown on his list routes
    When Operator archives driver route with status code 400
    Then Operator verify archive route response with proper error message : Route "is already archived!"

  @route-archive
  Scenario: Operator not Allowed to Archive Driver Invalid Route Id - Deleted Route  (uid:10fd732f-6326-4e7d-9ad2-6ec0da9ef4e8)
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
    When Operator delete driver route
    And Operator archives driver route with status code 404
    Then Operator verify archive route response with proper error message : Route "not found!"

  @route-archive
  Scenario: Operator not Allowed to Archive Driver Invalid Route Id - Route Not Found (uid:547956f4-da74-462e-9a14-ce8ed59a3a67)
    Given Operator archives driver route with status code 404
    Then Operator verify archive route response with proper error message : Route "not found!"
