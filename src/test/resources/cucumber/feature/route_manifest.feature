@ForceSuccessOrder @DeleteReservationAndAddress @ArchiveDriverRoutes @route-manifest
Feature: Route Manifest

  Scenario Outline: Admin Manifest Force Finish a Reservation Tied to Normal Orders - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates a reservation tied to Normal orders
      | service_type                  | Parcel          |
      | service_level                 | <service_level> |
      | parcel_job_is_pickup_required | true            |
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "PENDING"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route the Reservation Pickup
    When Operator admin manifest force "<action>" reservation
    Then Operator verify that reservation status is "<action>"
    And DB Operator verifies waypoint status is "<action>"
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Operator verify all "PICKUP" transactions status is "<txn_status>"

    Examples:
      | Note    | hiptest-uid                              | service_level | action  | txn_status |
      | Fail    | uid:ec3d61a9-eb96-4f30-b027-7549f94a6c5d | Standard      | FAIL    | PENDING    |
      | Success | uid:0b39277e-63a2-48fd-bee3-b57ab71780d6 | Standard      | SUCCESS | PENDING    |

  Scenario Outline: Admin Manifest Force Finish a DP Reservation - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple "Parcel" orders
      | service_type                  | Parcel          |
      | service_level                 | <service_level> |
      | parcel_job_is_pickup_required | false           |
    And DP user authenticated to login with username "{dp-user-username}" and password "{dp-user-password}"
    And DP user lodge in as SEND order to dp id "{dp-id}"
    And Operator search for created DP reservation with status "PENDING"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route the Reservation Pickup
    When Operator admin manifest force "<action>" reservation
    Then Operator verify that reservation status is "<action>"
    And DB Operator verifies waypoint status is "<action>"
    And Operator verify that all orders status-granular status is "<status>"-"<granular_status>"
    And Operator verify all "PICKUP" transactions status is "<txn_status>"

    Examples:
      | Note    | hiptest-uid                              | service_level | action  | txn_status | status  | granular_status                      |
      | Fail    | uid:084c00c4-fc31-4807-9406-564b9112a566 | Standard      | FAIL    | PENDING    | Pending | Pending_Pickup_At_Distribution_Point |
      | Success | uid:db316b2b-20c2-4b66-bba3-69f23a1ada7c | Standard      | SUCCESS | SUCCESS    | Transit | Enroute_to_Sorting_Hub               |

  Scenario: Admin Manifest Force Success Merged Waypoint of DP Orders on Route Manifest (uid:90638cd2-87ea-4c39-926c-b0da87c0ab8b)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper creates multiple orders : 3 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for all created orders
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And API Operator assign delivery multiple waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add all orders to driver "DD" route
    And Operator merge transaction waypoints
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that all orders status-granular status is "Transit"-"Arrived_At_Distribution_Point"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And DB Operator verifies all waypoints status is "SUCCESS"
