@ForceSuccessOrders @ArchiveDriverRoutes @DeletePickupAppointmentJob @batch-update-pods-paj
Feature: Batch Update PODs - PAJ

  @happy-path @HighPriority
  Scenario: Driver picks up all X number of Normal parcels in One Pickup Appointment Job
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {shipper-5-address-id-2} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                       |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_CREATED_ROUTE_ID},"overwrite":false} |
    When API Batch Update Job Request to "SUCCESS" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to "SUCCESS" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @update-rsvn @HighPriority
  Scenario: Driver Picks Up All X number of Return Parcels in One Pickup Appointment Job
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {shipper-5-address-id-2} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                       |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_CREATED_ROUTE_ID},"overwrite":false} |
    When API Batch Update Job Request to "SUCCESS" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to "SUCCESS" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    And Operator get proof details for "SUCCESS" transaction of "Return" orders
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @update-rsvn @HighPriority
  Scenario: Driver success Pickup Appointment Job without scanning any parcel
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {shipper-5-address-id-2} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                       |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_CREATED_ROUTE_ID},"overwrite":false} |
    When API Batch Update Job Request to "SUCCESS" PAJ without any Parcel
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify NO "En-route to Sorting Hub" event sent for all orders
    And Verify NO "Successful Pickup" event sent for all orders
    When API Batch Update Proof Request to "SUCCESS" PAJ without any Parcel
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |

  @update-rsvn @HighPriority
  Scenario: Driver Successes the Pickup Appointment Job with X number of Parcels but Fails Y number of Parcels (Partial Success)
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub, Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 4 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {shipper-5-address-id-2} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                       |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_CREATED_ROUTE_ID},"overwrite":false} |
    When API Batch Update Job Request to Partial Success Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that "Success" orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify that "Fail" orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify for "Success" Orders, Shipper gets webhook event "En-route to Sorting Hub"
    And Verify for "Success" Orders, Shipper gets webhook event "Successful Pickup"
    And Verify for "Failed" Orders, Shipper gets webhook event "Pickup fail"
    When API Batch Update Proof Request to Partial Success & Fail Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |

  @update-rsvn @HighPriority
  Scenario: Driver fails the Pickup Appointment Job and fail all X number of normal parcels under a Pickup Appointment Job
    Given Shipper id "{shipper-4-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {shipper-5-address-id-2} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                       |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_CREATED_ROUTE_ID},"overwrite":false} |
    When API Batch Update Job Request to "FAIL" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Fail              |
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to "FAIL" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |

  @update-rsvn @HighPriority
  Scenario: Driver fails the Pickup Appointment Job and fail all X number of return parcels under a Pickup Appointment Job
    Given Shipper id "{shipper-4-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {shipper-5-address-id-2} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                       |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_CREATED_ROUTE_ID},"overwrite":false} |
    And Shipper creates multiple "Return" orders
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    When API Batch Update Job Request to "FAIL" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Fail              |
    And Operator verify that all orders status-granular status is "Pickup_fail"-"Pickup_fail"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to "FAIL" All Orders under the PAJ
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @happy-path @update-rsvn @HighPriority
  Scenario: Driver fails the Pickup Appointment Job without failing any parcel
    Given Shipper id "{shipper-4-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {shipper-5-address-id-2} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                       |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_CREATED_ROUTE_ID},"overwrite":false} |
    When API Batch Update Job Request to "FAIL" PAJ without any Parcel
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Fail              |
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify NO "Pickup fail" event sent for all orders
    When API Batch Update Proof Request to "FAIL" PAJ without any Parcel
      | reservationId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId    | {KEY_WAYPOINT_ID}                   |
      | routeId       | {KEY_CREATED_ROUTE_ID}              |
      | jobType       | PICKUP_APPOINTMENT                  |
