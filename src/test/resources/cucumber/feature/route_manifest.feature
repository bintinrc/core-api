@ForceSuccessOrder @DeleteReservationAndAddress @ArchiveDriverRoutes @route-manifest
Feature: Route Manifest

  Scenario Outline: Admin Manifest Force Finish a Reservation Tied to Normal Orders - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper creates a reservation tied to Normal orders
      |service_type                  | Parcel                 |
      |service_level                 | <service_level>        |
      |parcel_job_is_pickup_required | true                   |
    And Operator Search for Created Pickup for Shipper "{route-monitoring-shipper-legacy-id}" with status "PENDING"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    When Operator admin manifest force "<action>" reservation
    Then Operator verify that reservation status is "<action>"
    And DB Operator verifies waypoint status is "<action>"
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Operator verify all "PICKUP" transactions status is "<txn_status>"

    Examples:
      | Note      | hiptest-uid                              | service_level |action  |txn_status|
      | FAIL      | uid:ec3d61a9-eb96-4f30-b027-7549f94a6c5d | Standard      |FAIL    |PENDING   |
      | SUCCESS   | uid:0b39277e-63a2-48fd-bee3-b57ab71780d6 | Standard      |SUCCESS |PENDING   |


  Scenario Outline: Admin Manifest Force Finish a DP Reservation - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper creates multiple "Parcel" orders
      |service_type                  | Parcel                 |
      |service_level                 | <service_level>        |
      |parcel_job_is_pickup_required | false                  |
    And DP user authenticated to login with username "{dp-username}" and password "{dp-user-password}"
    And DP user lodge in as SEND order to dp id "{dp-id}"
    And Operator search for created DP reservation with status "PENDING"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    When Operator admin manifest force "<action>" reservation
    Then Operator verify that reservation status is "<action>"
    And DB Operator verifies waypoint status is "<action>"
    And Operator verify that all orders status-granular status is "<status>"-"<granular_status>"
    And Operator verify all "PICKUP" transactions status is "<txn_status>"

    Examples:
      | Note      | hiptest-uid                              | service_level |action  |txn_status|status  |granular_status                              |
      | FAIL      | uid:084c00c4-fc31-4807-9406-564b9112a566 | Standard      |FAIL    |PENDING   |Pending |Pending_Pickup_At_Distribution_Point         |
      | SUCCESS   | uid:5eb51442-b8d4-4a28-b474-8f49fac986c4 | Standard      |SUCCESS |SUCCESS   |Transit |Enroute_to_Sorting_Hub                       |
