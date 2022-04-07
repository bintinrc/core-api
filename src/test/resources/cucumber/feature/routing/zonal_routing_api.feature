@ForceSuccessOrder @ArchiveDriverRoutes @DeleteReservationAndAddress @routing @zonal-routing-api @routing-refactor
Feature: Zonal Routing API

  Scenario: Zonal Routing API - Create Driver Route & Assign Waypoints (uid:a7196db7-0635-45a8-a9d5-e201740e95b8)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Then DB Operator verifies created dummy waypoints
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all route_monitoring_data records
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly

  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Add Unrouted Waypoints to Route (uid:a7196db7-0635-45a8-a9d5-e201740e95b8)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator edit route from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
    Then DB Operator verifies created dummy waypoints
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all route_monitoring_data records
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly

  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Edit Waypoint Sequence (uid:a7196db7-0635-45a8-a9d5-e201740e95b8)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator edit route from Zonal Routing API
      | driver_id        | {driver-id}  |
      | vehicle_id       | {vehicle-id} |
      | to_edit_sequence | true         |
    Then DB Operator verifies created dummy waypoints
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all route_monitoring_data records
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly
    And Verify waypoints.seq_no & driver list waypoint ordering is correct

  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Remove Waypoints From Route (uid:a7196db7-0635-45a8-a9d5-e201740e95b8)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies created dummy waypoints
    When Operator edit route by removing waypoints from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
    # check for still routed waypoint
    Then DB Operator verifies transaction routed to new route id
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies route_monitoring_data record
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
  # check for removed waypoints
    Then DB Operator verifies all transactions route id is null
    And DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all waypoints.route_id & seq_no is NULL
    And DB Operator verifies all route_waypoint route id is hard-deleted
    And DB Operator verifies all route_monitoring_data is hard-deleted
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that driver "{driver-id}" list route showing only routed waypoints

  Scenario: Zonal Routing Edit Route API - Bulk Edit Waypoints Inside Multiple Routes - Move Routed Waypoints to Another Route (uid:a7196db7-0635-45a8-a9d5-e201740e95b8)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies created dummy waypoints
    When API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And Operator edit route by moving to another route from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
  # check for still routed waypoint
    And DB Operator verifies routed waypoint remains in old route
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint
  # check for moved waypoints to another route
    And DB Operator verifies waypoint moved to another route
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly
    And Verify that waypoints are not shown on previous driver list route
    And DB Operator verifies waypoints.seq_no is the same as route_waypoint.seq_no for each waypoint

  Scenario: Add Merged Unrouted Waypoint to a Route from Zonal Routing Edit Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And DB Operator get routes dummy waypoints
    When Operator edit route by removing merged waypoints from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
    And Operator add order to driver "DELIVERY" route
    And Operator gets only eligible routed orders
#    verify remaining unrouted order
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
#    verify routed orders
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all route_waypoint records
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies all waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies all route_monitoring_data records
    And Operator checks that for all orders, "ADD_TO_ROUTE" event is published
