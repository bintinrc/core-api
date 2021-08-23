@DeleteReservationAndAddress @ArchiveDriverRoutes @parcel-route-transfer
Feature: Parcel Route Transfer

  @routing-refactor
  Scenario: Driver Route Transfer Parcel - No Driver Route Available for the Driver, Unrouted Delivery (uid:fc7d3611-01fd-442a-bdf0-cde62c2460e1)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper creates multiple orders : 3 orders
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
      | to_create_route  | true             |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    Then DB Operator verifies created dummy waypoints
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And DB Operator verifies inbound_scans record for all orders with type "4" and correct route_id

  @routing-refactor
  Scenario: Driver Route Transfer Parcel - No Driver Route Available for the Driver, Routed Delivery (uid:4f8348c7-6b73-4e1a-9563-c8c4d4534a11)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add all orders to driver "DD" route
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
      | to_create_route  | true             |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    Then DB Operator verifies created dummy waypoints
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id

  @routing-refactor
  Scenario: Driver Route Transfer Parcel - Driver Route Available for the Driver, Unrouted Delivery (uid:f132d051-4ba0-4042-ae79-e83ea1beead6)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id

  @routing-refactor
  Scenario: Driver Route Transfer Parcel - Driver Route Available for the Driver, Routed Delivery (uid:1b362123-7a95-45d9-aa63-4037d236a017)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper creates multiple orders : 3 orders
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add all orders to driver "DD" route
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies all waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record for all orders with type "4" and correct route_id

  @routing-refactor
  Scenario: Driver Route Transfer Parcel - No Driver Route Available for the Driver, Routed Fail Delivery (uid:48ae2613-9747-4cae-a581-80e9b79d9070)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "FAIL" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
      | to_create_route  | true             |
    And Operator search for "DELIVERY" transaction with status "FAIL"
    Then DB Operator verifies created dummy waypoints
    And DB Operator verifies transaction routed to new route id
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies route_monitoring_data record
    And Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id

  @routing-refactor
  Scenario: Driver Route Transfer Parcel - Driver Route Available for the Driver, Routed Fail Delivery (uid:3a4ad2dd-8073-45d0-a42d-e9b79787aa1f)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "FAIL" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then DB Operator verifies transaction routed to new route id
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies route_monitoring_data record
    And Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id

  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Completed (uid:9efcbcf9-5e97-4ec4-90e3-bde7dd41aa79)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper creates multiple orders : 2 orders
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for all created orders
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And Operator force success all orders
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then Verify Parcel Route Transfer Failed Orders with message : "Completed"
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And DB Operator verifies all transactions route id is null
    And Operator checks that "ROUTE_TRANSFER_SCAN" event is NOT published

  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Cancelled (uid:cac31db7-be90-45e0-8b54-6b0859c25617)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And API Operator cancel created order
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then Verify Parcel Route Transfer Failed Orders with message : "Cancelled"
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And DB Operator verifies transaction route id is null
    And Operator checks that "ROUTE_TRANSFER_SCAN" event is NOT published

  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Returned to Sender (uid:e7c20dcc-dcf6-42fd-8dfd-b1e0011cf490)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then Verify Parcel Route Transfer Failed Orders with message : "Returned to Sender"
    And Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And DB Operator verifies transaction route id is null
    And Operator checks that "ROUTE_TRANSFER_SCAN" event is NOT published
