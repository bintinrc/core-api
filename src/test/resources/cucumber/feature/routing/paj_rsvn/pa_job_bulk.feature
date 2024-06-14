@ArchiveDriverRoutes @CancelCreatedReservations @DeletePickupAppointmentJob @ReleaseShipperAddress @routing2 @pa-job
Feature: Pickup Appointment Job Bulk Routing

  @DeletePickupAppointmentJob @ReleaseShipperAddress @HighPriority
  Scenario: PUT /pickup-appointment-jobs/route-bulk - Route All Unrouted PA Jobs
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[1].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[2].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[3].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[3].id}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator bulk add pickup jobs to the route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id},{KEY_CONTROL_CREATED_PA_JOBS[3].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "overwrite": false} |
    #  Verification for Job 1
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
   # Verification for Job 2
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[2].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    #  Verification for Job 3
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[3].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[3].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |


  @DeletePickupAppointmentJob @ReleaseShipperAddress @HighPriority
  Scenario: PUT /pickup-appointment-jobs/route-bulk - Update All Routed PA Jobs to a New Route
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[1].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[2].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[3].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator bulk add pickup jobs to the route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id},{KEY_CONTROL_CREATED_PA_JOBS[3].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "overwrite": false} |
    # Create new route
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator bulk add pickup jobs to the route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id},{KEY_CONTROL_CREATED_PA_JOBS[3].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[2].id}, "overwrite": true} |
    #  Verification for Job 1
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                                               |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 2                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |
   # Verification for Job 2
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[2].id}                                                               |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 2                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |
    #  Verification for Job 3
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[3].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[3].id}                                                               |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 2                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @DeletePickupAppointmentJob @ReleaseShipperAddress @HighPriority
  Scenario: PUT /pickup-appointment-jobs/route-bulk - Partial Success Route PA Jobs
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[1].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[2].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId": {KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[3].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - wait until job_waypoints table is populated for job id "{KEY_CONTROL_CREATED_PA_JOBS[3].id}"
    # PA Job 1 is already routed to Route 1
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                   |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    # PA Job 2 is already routed to Route 2 and Forced Success
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[2].id}                                   |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id},"overwrite":false} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And API Core - Operator force success waypoint via route manifest:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | waypointId | {KEY_WAYPOINT_ID}                  |
    # Try to Bulk Add all Pickup Jobs to Route 3
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator bulk add pickup jobs to the route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id},{KEY_CONTROL_CREATED_PA_JOBS[3].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[3].id}, "overwrite": false} |
    And API Core - Operator verifies response of bulk add pickup jobs to route
      | expectedSuccessfulJobs | [{"id":{KEY_CONTROL_CREATED_PA_JOBS[3].id},"status": "Ready for Routing"}]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | expectedFailedJobs     | [{"id":{KEY_CONTROL_CREATED_PA_JOBS[2].id},"error":{"code":103088,"messages":["PA job is already routed to route {KEY_LIST_OF_CREATED_ROUTES[2].id}"],"application":"core","description":"INVALID_OPERATION","data":{"message":"PA job is already routed to route {KEY_LIST_OF_CREATED_ROUTES[2].id}"},"nvErrorCode":"SERVER_ERROR_EXCEPTION"}}, {"id":{KEY_CONTROL_CREATED_PA_JOBS[1].id},"error":{"code":103088,"messages":["PA job is already routed to route {KEY_LIST_OF_CREATED_ROUTES[1].id}"],"application":"core","description":"INVALID_OPERATION","data":{"message":"PA job is already routed to route {KEY_LIST_OF_CREATED_ROUTES[1].id}"},"nvErrorCode":"SERVER_ERROR_EXCEPTION"}}] |
    #  Verification for Job 1 (should be still routed to Route 1)
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
   # Verification for Job 2 (should still be routed to Route 2 and Success)
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Success                            |
    #  Verification for Job 3 (Should be routed to Route 3)
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[3].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[3].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[3].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[3].id}} |

  @DeletePickupAppointmentJob @ReleaseShipperAddress @HighPriority
  Scenario: PUT /pickup-appointment-jobs/route-bulk - Add PA Jobs to a Route that has been started
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | v4OrderRequest      | { "service_type":"Return","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "236890","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"PICKUP"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                              |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 1                                  |
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[1].id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    Given DB Shipper - get unique shipper address for shipper id: "{shipper-5-id}"
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{KEY_SHIPPER_LIST_OF_SHIPPER_ADDRESSES[2].id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-2-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-2-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And API Core - Operator bulk add pickup jobs to the route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "overwrite": false} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 4                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[2].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[2].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 4                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
