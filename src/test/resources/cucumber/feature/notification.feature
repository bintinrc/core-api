@DeleteReservationAndAddress @ArchiveDriverRoutes @notification
Feature: Notification

  Scenario: Send Successful Delivery Webhook on Force Success from Edit Order
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When Operator force success order
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  Scenario: Send Successful Delivery Webhook on Force Success from Route Manifest
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  Scenario: Send Successful Delivery Webhook on Customer Collection of DP Order
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "SUCCESS" Parcel "DELIVERY"
    And DB Operator gets DP Job ID by Barcode
    And API Operator do the DP Success for From Driver Flow
    And DB Operator gets Customer Unlock Code Based on Tracking ID
    And API DP do the Customer Collection from dp with ID = "{dp-id}"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  Scenario Outline: Send Successful Delivery Webhook with COD - Single Force Success - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 500.20   |
    And Operator search for created order
    When API Operator force succeed created order with cod collected = "<codCollected>"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
    Examples:
      | Note              | codCollected |
      | COD Collected     | true         |
      | COD not Collected | false        |

  Scenario Outline: Send Successful Delivery Webhook with COD - Admin Force Success Route Manifest - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 45.0     |
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order by tracking id to driver "DD" route
    When Operator admin manifest force success waypoint with cod collected : "<codCollected>"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
    Examples:
      | Note              | codCollected |
      | COD Collected     | true         |
      | COD not Collected | false        |

  Scenario Outline: Send Successful Delivery Webhook with COD - Bulk Force Success - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 150      |
    And Operator search for created order
    When Operator bulk force success all orders with cod collected : "<codCollected>"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
    Examples:
      | Note              | codCollected |
      | COD Collected     | true         |
      | COD not Collected | false        |

  Scenario: Send Successful Delivery Webhook with COD - Bulk Force Success
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When Operator bulk force success all orders with cod collected : "false"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  Scenario: Send Route Start Webhook Notification (uid:1d621734-5703-41e5-9c91-5aac51abf358)
    Given Shipper id "{shipper-4-id}" subscribes to "On Vehicle for Delivery" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Operator get info of hub details string id "{sorting-hub-id}"
    And Driver Starts the route
    Then Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Shipper gets webhook request for event "On Vehicle for Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "On Vehicle for Delivery"

  Scenario: Send First Attempt Delivery Fail & First Pending Reschedule Webhook on Driver Fails Delivery Order
    Given Shipper id "{shipper-4-id}" subscribes to "First Attempt Delivery Fail" webhook
    Given Shipper id "{shipper-4-id}" subscribes to "Pending Reschedule" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    And Driver "FAIL" Parcel "DELIVERY"
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule"

  Scenario: Send First Attempt Delivery Fail & Second Pending Reschedule Webhook on Driver Fails Rescheduled Delivery Order
    Given Shipper id "{shipper-4-id}" subscribes to "First Attempt Delivery Fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    And Driver "FAIL" Parcel "DELIVERY"
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    When API Operator reschedule failed delivery order
    And Operator search for "DELIVERY" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    Given Shipper id "{shipper-4-id}" subscribes to "Pending Reschedule" webhook
    And Driver "FAIL" Parcel "DELIVERY"
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule"

  Scenario: Send First Attempt Delivery Fail & First Pending Reschedule Webhook on Global Inbound Rescheduled Delivery Order
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    Given Shipper id "{shipper-4-id}" subscribes to "First Attempt Delivery Fail" webhook
    Given Shipper id "{shipper-4-id}" subscribes to "Pending Reschedule" webhook
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    And Driver "FAIL" Parcel "DELIVERY"
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    When API Operator reschedule failed delivery order
    And Operator search for "DELIVERY" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    Given Shipper id "{shipper-4-id}" subscribes to "Arrived at Sorting Hub" webhook
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Sort - Operator get hub  details of hub id "{sorting-hub-id}"
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub"

  Scenario: Send Successful Delivery Webhook with COD - Driver Success Delivery with COD
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50.67    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    And Driver "SUCCESS" Parcel "DELIVERY"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
