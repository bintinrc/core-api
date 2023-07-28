@routing-sg @DeletePickupAppointmentJob @fm-routing-paj-sg
Feature: SG - FM Automated Routing - Pickup Appointment Job

  https://studio.cucumber.io/projects/208144/test-plan/folders/2930485


  Scenario Outline: SG - Auto Route PAJ - Date = Today, Creation = Within Start & End Clock Time, Driver has No Routes - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    And DB Route - get latest route_logs record for driver id "<driver_id>"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | status   | 0                                        |
      | hubId    | <hub_id>                                 |
      | zoneId   | <zone_id>                                |
      | driverId | <driver_id>                              |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_WAYPOINT_ID}                  |
      | seqNo         | not null                           |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status        | Routed                             |
      | routingZoneId | <zone_id>                          |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And API Control - Operator get pickup appointment job search details:
      | getPaJobSearchRequest | {"limit":500,"query":{"pickup_ready_datetime":{"lower_bound":"{date: 0 days next, YYYY-MM-dd}T00:00:00+08:00"},"pickup_appointment_job_id":{"in":[{KEY_CONTROL_CREATED_PA_JOBS[1].id}]}}} |
    And API Control - Operator verify pickup appointment job search details:
      | pickupAppointmentJobId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId             | {KEY_WAYPOINT_ID}                   |
      | routeId                | {KEY_LIST_OF_CREATED_ROUTES[1].id}  |
      | routingZoneId          | <zone_id>                           |
      | driverId               | <driver_id>                         |
    Examples:
      | Note                      | driver_id         | zone_id            | hub_id                         | shipper_id                         | address_id                         |
      | Pickup Type: FM Dedicated | {fm-paj-driver-1} | {fm-paj-zone-id-1} | {fm-paj-hub-id-1-fm-dedicated} | {fm-paj-shipper-id-1-fm-dedicated} | {fm-paj-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-paj-driver-1} | {fm-paj-zone-id-1} | {fm-paj-hub-id-1-truck}        | {fm-paj-shipper-id-1-truck}        | {fm-paj-address-id-1-truck}        |


  Scenario Outline: SG - Auto Route PAJ - Date = Today, Creation = Within Start & End Clock Time, Driver has Existing Route - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{fm-paj-zone-id-1}, "hubId":{fm-paj-hub-id-1-fm-dedicated}, "driverId":{fm-paj-driver-1} } |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 0                                  |
      | hubId    | <hub_id>                           |
      | zoneId   | <zone_id>                          |
      | driverId | <driver_id>                        |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_WAYPOINT_ID}                  |
      | seqNo         | not null                           |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status        | Routed                             |
      | routingZoneId | <zone_id>                          |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And API Control - Operator get pickup appointment job search details:
      | getPaJobSearchRequest | {"limit":500,"query":{"pickup_ready_datetime":{"lower_bound":"{date: 0 days next, YYYY-MM-dd}T00:00:00+08:00"},"pickup_appointment_job_id":{"in":[{KEY_CONTROL_CREATED_PA_JOBS[1].id}]}}} |
    And API Control - Operator verify pickup appointment job search details:
      | pickupAppointmentJobId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId             | {KEY_WAYPOINT_ID}                   |
      | routeId                | {KEY_LIST_OF_CREATED_ROUTES[1].id}  |
      | routingZoneId          | <zone_id>                           |
      | driverId               | <driver_id>                         |
    Examples:
      | Note                      | driver_id         | zone_id            | hub_id                         | shipper_id                         | address_id                         |
      | Pickup Type: FM Dedicated | {fm-paj-driver-1} | {fm-paj-zone-id-1} | {fm-paj-hub-id-1-fm-dedicated} | {fm-paj-shipper-id-1-fm-dedicated} | {fm-paj-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-paj-driver-1} | {fm-paj-zone-id-1} | {fm-paj-hub-id-1-truck}        | {fm-paj-shipper-id-1-truck}        | {fm-paj-address-id-1-truck}        |


  Scenario Outline: SG - Auto Route PAJ - Date = Today, No Driver Assigned for the Zone, Creation = Within Start & End Clock Time - <Note>
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    Then DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_WAYPOINT_ID} |
      | seqNo         | null              |
      | routeId       | null              |
      | status        | Pending           |
      | routingZoneId | <zone_id>         |
    And API Control - Operator get pickup appointment job search details:
      | getPaJobSearchRequest | {"limit":500,"query":{"pickup_ready_datetime":{"lower_bound":"{date: 0 days next, YYYY-MM-dd}T00:00:00+08:00"},"pickup_appointment_job_id":{"in":[{KEY_CONTROL_CREATED_PA_JOBS[1].id}]}}} |
    And API Control - Operator verify pickup appointment job search details:
      | pickupAppointmentJobId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId             | {KEY_WAYPOINT_ID}                   |
      | routeId                | null                                |
      | routingZoneId          | <zone_id>                           |
      | driverId               | null                                |
    Examples:
      | Note                      | zone_id            | shipper_id                         | address_id                         |
      | Pickup Type: FM Dedicated | {fm-paj-zone-id-3} | {fm-paj-shipper-id-3-fm-dedicated} | {fm-paj-address-id-3-fm-dedicated} |
      | Pickup Type: Truck        | {fm-paj-zone-id-3} | {fm-paj-shipper-id-3-truck}        | {fm-paj-address-id-3-truck}        |
