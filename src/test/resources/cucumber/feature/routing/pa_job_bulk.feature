@ArchiveDriverRoutes @CancelCreatedReservations @DeletePickupAppointmentJob @routing @pa-job
Feature: Pickup Appointment Job Bulk Routing

  @DeletePickupAppointmentJob
  Scenario: PUT /pickup-appointment-jobs/route-bulk - Route All Unrouted PA Jobs
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | 717    |
      | generateAddress | RANDOM |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId": {KEY_LIST_OF_CREATED_ADDRESSES[1].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | 717    |
      | generateAddress | RANDOM |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId": {KEY_LIST_OF_CREATED_ADDRESSES[2].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | 717    |
      | generateAddress | RANDOM |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId": {KEY_LIST_OF_CREATED_ADDRESSES[3].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator bulk add pickup jobs to the route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id},{KEY_CONTROL_CREATED_PA_JOBS[3].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "overwrite": false} |
    #  Verification for Job 1
    And DB Core - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId  | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | userId    | 397                                 |
      | userName  | AUTOMATION EDITED                   |
      | userEmail | qa@ninjavan.co                      |
      | type      | 1                                   |
   # Verification for Job 2
    And DB Core - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId  | {KEY_CONTROL_CREATED_PA_JOBS[2].id} |
      | userId    | 397                                 |
      | userName  | AUTOMATION EDITED                   |
      | userEmail | qa@ninjavan.co                      |
      | type      | 1                                   |
    #  Verification for Job 3
    And DB Core - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[3].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId  | {KEY_CONTROL_CREATED_PA_JOBS[3].id} |
      | userId    | 397                                 |
      | userName  | AUTOMATION EDITED                   |
      | userEmail | qa@ninjavan.co                      |
      | type      | 1                                   |


  @DeletePickupAppointmentJob @wip
  Scenario: PUT /pickup-appointment-jobs/route-bulk - Update All Routed PA Jobs to a New Route
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | 717    |
      | generateAddress | RANDOM |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId": {KEY_LIST_OF_CREATED_ADDRESSES[1].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | 717    |
      | generateAddress | RANDOM |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId": {KEY_LIST_OF_CREATED_ADDRESSES[2].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | 717    |
      | generateAddress | RANDOM |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId": {KEY_LIST_OF_CREATED_ADDRESSES[3].id} }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator bulk add pickup jobs to the route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id},{KEY_CONTROL_CREATED_PA_JOBS[3].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "overwrite": false} |
    # Create new route
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator bulk update routed pickup jobs to another route using data below:
      | bulkAddPickupJobToTheRouteRequest | { "ids": [{KEY_CONTROL_CREATED_PA_JOBS[1].id},{KEY_CONTROL_CREATED_PA_JOBS[2].id},{KEY_CONTROL_CREATED_PA_JOBS[3].id}], "new_route_id": {KEY_LIST_OF_CREATED_ROUTES[2].id}, "overwrite": true} |
    #  Verification for Job 1
    And DB Core - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And DB Events - verify pickup_events record:
      | pickupId  | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | userId    | 397                                 |
      | userName  | AUTOMATION EDITED                   |
      | userEmail | qa@ninjavan.co                      |
      | type      | 1                                   |
   # Verification for Job 2
    And DB Core - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And DB Events - verify pickup_events record:
      | pickupId  | {KEY_CONTROL_CREATED_PA_JOBS[2].id} |
      | userId    | 397                                 |
      | userName  | AUTOMATION EDITED                   |
      | userEmail | qa@ninjavan.co                      |
      | type      | 1                                   |
    #  Verification for Job 3
    And DB Core - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[3].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId  | {KEY_CONTROL_CREATED_PA_JOBS[3].id} |
      | userId    | 397                                 |
      | userName  | AUTOMATION EDITED                   |
      | userEmail | qa@ninjavan.co                      |
      | type      | 1                                   |
