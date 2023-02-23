@ArchiveDriverRoutes @routing @pa-job
Feature: Zonal Routing API

  @DeletePickupAppointmentJob
  Scenario: PUT /pickup-appointment-jobs/:paJobId/route - Route Unrouted PA Job Waypoint
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId":1547535}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                  |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | 397                                             |
      | userName   | AUTOMATION EDITED                               |
      | userEmail  | qa@ninjavan.co                                  |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePickupAppointmentJob
  Scenario: PUT /pickup-appointment-jobs/:paJobId/route - Update Routed PA Job to a New Route
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId":1547535}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                   |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                  |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id},"overwrite":true} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | 397                                             |
      | userName   | AUTOMATION EDITED                               |
      | userEmail  | qa@ninjavan.co                                  |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                                               |
      | userId     | 397                                                                                               |
      | userName   | AUTOMATION EDITED                                                                                 |
      | userEmail  | qa@ninjavan.co                                                                                    |
      | type       | 2                                                                                                 |
      | pickupType | 2                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |