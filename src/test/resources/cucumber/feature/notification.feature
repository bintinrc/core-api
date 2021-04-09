@DeleteReservationAndAddress @ArchiveDriverRoutes @notification
Feature: Notification

  Scenario: Send Successful Delivery Webhook on Force Success from Edit Order (uid:ed820a8f-35e0-4cd4-b775-0891905e25df)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When Operator force success order
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  Scenario: Send Successful Delivery Webhook on Force Success from Route Manifest (uid:06bb32b5-d5a1-46f0-bd0c-204c1ad9a530)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id} |
      | hub_id     | {sorting-hub-id}             |
      | vehicle_id | {vehicle-id}                 |
      | zone_id    | {zone-id}                    |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  Scenario: Send Successful Delivery Webhook on Customer Collection of DP Order (uid:bbf64882-2f0d-482f-8d1b-6413b1b02fa5)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id} |
      | hub_id     | {sorting-hub-id}             |
      | vehicle_id | {vehicle-id}                 |
      | zone_id    | {zone-id}                    |
    And Operator add order to driver "DD" route
    When Driver authenticated to login with username "{route-monitoring-driver-username}" and password "{route-monitoring-driver-password}"
    And Driver Starts the route
    And Driver "SUCCESS" Parcel "DELIVERY"
    And DB Operator gets DP Job ID by Barcode
    And API Operator do the DP Success for From Driver Flow
    And DB Operator gets Customer Unlock Code Based on Tracking ID
    And API DP do the Customer Collection from dp with ID = "{dp-id}"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
