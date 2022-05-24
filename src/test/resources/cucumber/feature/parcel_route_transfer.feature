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
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
      | to_create_route  | true             |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"

    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints.route_id & seq_no is populated correctly

    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And DB Operator verifies inbound_scans record for all orders with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly

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
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
      | to_create_route  | true             |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"

    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly

    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly

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

    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly

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
    And Operator search for all created orders
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

    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record for all orders with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly

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
    And Operator search for created order
    And Operator add order to driver "DD" route
    And Operator force "FAIL" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
      | to_create_route  | true             |
    And Operator search for "DELIVERY" transaction with status "FAIL"

    And DB Operator verifies transaction routed to new route id
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly

    And DB Operator verifies route_monitoring_data record
    And Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly

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

    And DB Operator verifies route_monitoring_data record
    And Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly

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

  Scenario: Driver Not Allowed to Route Transfer Marketplace Sort Order - RTS = 0 (uid:af38bd8c-0656-4a7a-81b5-cfa7844002f3)
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-v4-marketplace-sort-client-id}     |
      | shipperV4ClientSecret | {shipper-v4-marketplace-sort-client-secret} |
    When API Shipper create V4 order using data below:
      | generateFromAndTo | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | v4OrderRequest    | { "service_type":"Marketplace Sort","requested_tracking_number":"{shipper-v4-marketplace-sort-prefix}{{6-random-digits}}","sort":{"to_3pl":"{3pl-sort}"},"marketplace":{"seller_id": "seller-ABC01","seller_company_name":"ABC Shop"},"service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then Verify Parcel Route Transfer Failed Orders with message : "Marketplace Sort Order"
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And DB Operator verifies transaction route id is null
    And Operator checks that "ROUTE_TRANSFER_SCAN" event is NOT published

  Scenario: Driver Route Transfer Marketplace Sort Order - RTS = 1 (uid:21425816-4891-4f21-b416-a83e9e25566b)
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-v4-marketplace-sort-client-id}     |
      | shipperV4ClientSecret | {shipper-v4-marketplace-sort-client-secret} |
    When API Shipper create V4 order using data below:
      | generateFromAndTo | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | v4OrderRequest    | { "service_type":"Marketplace Sort","requested_tracking_number":"{shipper-v4-marketplace-sort-prefix}{{6-random-digits}}","sort":{"to_3pl":"{3pl-sort}"},"marketplace":{"seller_id": "seller-ABC01","seller_company_name":"ABC Shop"},"service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly

    And DB Operator verifies all route_monitoring_data records
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly

  Scenario: Driver Not Allowed to Route Transfer Parcel to Past Date Route (uid:22437d8b-1443-4e99-9367-777dfadc4043)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route with past date
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Route with past date
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103100                                          |
      | message     | Not allowed to transfer to routes before today! |
      | application | core                                            |
      | description | INVALID_ROUTE_DATE                              |

  Scenario: Driver Route Transfer Parcel - Route has Assigned Delivery Waypoint
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order by tracking id to driver "DD" route
    And Shipper creates multiple orders : 3 orders
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    When Driver Transfer Parcel to Another Driver
      | to_driver_id            | {driver-2-id}    |
      | to_driver_hub_id        | {sorting-hub-id} |
      | to_exclude_routed_order | true             |
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies all waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies all route_monitoring_data records
    When Operator gets only eligible parcel for route transfer
    Then Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And Operator checks that for all orders, "ROUTE_TRANSFER_SCAN" event is published
    And Operator checks that for all orders, "DRIVER_INBOUND_SCAN" event is published
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And DB Operator verifies inbound_scans record for all orders with type "4" and correct route_id
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-2-username}" and "{driver-2-password}"
    And Verify that waypoints are shown on driver "{driver-2-id}" list route correctly
