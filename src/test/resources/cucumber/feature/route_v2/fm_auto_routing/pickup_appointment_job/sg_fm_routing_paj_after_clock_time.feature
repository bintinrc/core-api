@routing-sg @DeletePickupAppointmentJob @fm-routing-paj-sg-1
Feature: SG - FM Automated Routing - Pickup Appointment Job

  https://studio.cucumber.io/projects/208144/test-plan/folders/2930485


  Scenario Outline: SG - Auto Route PAJ - Date = Today, Creation = After End Clock Time - <Note>
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    Then DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_WAYPOINT_ID} |
      | seqNo         | null              |
      | routeId       | null              |
      | status        | Pending           |
      | routingZoneId | <zone_id>         |
    Examples:
      | Note                      | zone_id            | shipper_id                         | address_id                         |
      | Pickup Type: FM Dedicated | {fm-paj-zone-id-1} | {fm-paj-shipper-id-1-fm-dedicated} | {fm-paj-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-paj-zone-id-1} | {fm-paj-shipper-id-1-truck}        | {fm-paj-address-id-1-truck}        |


  Scenario Outline: SG - Auto Route PAJ - Date = Today, Creation = After End Clock Time & Run Manual Cron Job, Driver has Existing Route
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":<zone_id>, "hubId":<hub_id>, "driverId":<driver_id> } |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id_1> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id_2> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    And API Route - Operator run FM PAJ auto route cron job for date "{date: 0 days next, yyyy-MM-dd}"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 0                                  |
      | hubId    | <hub_id>                           |
      | zoneId   | <zone_id>                          |
      | driverId | <driver_id>                        |
    # Verify 1st PAJ is routed to existing waypoint
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
    # Verify 2nd PAJ is routed to existing waypoint
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
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
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[2].id}             |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And API Control - Operator get pickup appointment job search details:
      | getPaJobSearchRequest | {"limit":500,"query":{"pickup_ready_datetime":{"lower_bound":"{date: 0 days next, YYYY-MM-dd}T00:00:00+08:00"},"pickup_appointment_job_id":{"in":[{KEY_CONTROL_CREATED_PA_JOBS[2].id}]}}} |
    And API Control - Operator verify pickup appointment job search details:
      | pickupAppointmentJobId | {KEY_CONTROL_CREATED_PA_JOBS[2].id} |
      | waypointId             | {KEY_WAYPOINT_ID}                   |
      | routeId                | {KEY_LIST_OF_CREATED_ROUTES[1].id}  |
      | routingZoneId          | <zone_id>                           |
      | driverId               | <driver_id>                         |
    Examples:
      | driver_id         | zone_id            | hub_id                         | shipper_id                         | address_id_1                       | address_id_2                |
      | {fm-paj-driver-1} | {fm-paj-zone-id-1} | {fm-paj-hub-id-1-fm-dedicated} | {fm-paj-shipper-id-1-fm-dedicated} | {fm-paj-address-id-1-fm-dedicated} | {fm-paj-address-id-1-truck} |


  Scenario Outline: SG - Auto Route PAJ - Date = Today, Creation = After End Clock Time & Run Manual Cron Job, Driver has No Routes - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    And API Route - Operator run FM PAJ auto route cron job for date "{date: 0 days next, yyyy-MM-dd}"
    And DB Route - get latest route_logs record for driver id "<driver_id>"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 0                                  |
      | hubId    | <hub_id>}                          |
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


  Scenario Outline: SG - Auto Route PAJ - Date = Today, No Driver Assigned for the Zone, Creation = After End Clock Time & Run Manual Cron Job - <Note>
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    And API Route - Operator run FM PAJ auto route cron job for date "{date: 0 days next, yyyy-MM-dd}"
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
      | Pickup Type: FM Dedicated | {fm-paj-zone-id-2} | {fm-paj-shipper-id-2-fm-dedicated} | {fm-paj-address-id-2-fm-dedicated} |
      | Pickup Type: Truck        | {fm-paj-zone-id-2} | {fm-paj-shipper-id-2-truck}        | {fm-paj-address-id-2-truck}        |



  Scenario Outline: SG - Auto Route PAJ - Order Create Flow, Date = Today, Creation = After End Clock Time & Run Manual Cron Job, Driver has No Routes - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-paj-shipper-5-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | shipperClientSecret | {fm-paj-shipper-5-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type": "Parcel", "service_level": "Standard", "from":<pickup_address>, "parcel_job": { "pickup_address_id": "<pickup_address_id>", "pickup_address": <pickup_address>, "dimensions": { "height": 2.7, "length": 2.8, "width": 1 }, "is_pickup_required": true, "pickup_date": "{date: 0 days next, yyyy-MM-dd}", "pickup_timeslot": { "start_time": "09:00", "end_time": "22:00" }, "delivery_start_date": "{date: 0 days next, yyyy-MM-dd}", "delivery_timeslot": { "start_time": "09:00", "end_time": "22:00" } } } |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And DB Control - get pickup appointment job id from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Route - Operator run FM PAJ auto route cron job for date "{date: 0 days next, yyyy-MM-dd}"
    And DB Route - get latest route_logs record for driver id "<driver_id>"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 0                                  |
      | hubId    | <hub_id>                           |
      | zoneId   | <zone_id>                          |
      | driverId | <driver_id>                        |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOB_IDS[1]}"
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
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOB_IDS[1]}             |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And API Control - Operator get pickup appointment job search details:
      | getPaJobSearchRequest | {"limit":500,"query":{"pickup_ready_datetime":{"lower_bound":"{date: 0 days next, YYYY-MM-dd}T00:00:00+08:00"},"pickup_appointment_job_id":{"in":[{KEY_CONTROL_CREATED_PA_JOB_IDS[1]}]}}} |
    And API Control - Operator verify pickup appointment job search details:
      | pickupAppointmentJobId | {KEY_CONTROL_CREATED_PA_JOB_IDS[1]} |
      | waypointId             | {KEY_WAYPOINT_ID}                   |
      | routeId                | {KEY_LIST_OF_CREATED_ROUTES[1].id}  |
      | routingZoneId          | <zone_id>                           |
      | driverId               | <driver_id>                         |
    Examples:
      | Note                      | driver_id         | zone_id            | hub_id                         | pickup_address_id                          | pickup_address                                                                                                                                                                                                                                                                        |
      | Pickup Type: FM Dedicated | {fm-paj-driver-5} | {fm-paj-zone-id-5} | {fm-paj-hub-id-5-fm-dedicated} | {fm-paj-address-id-5-fm-dedicated-ext-ref} | { "name": "binti v4.1", "phone_number": "+65189189", "email": "binti@test.co", "address": { "address1": "4 Tuas Link 2", "address2": "#20-25", "country": "SG", "postcode": "638553", "latitude": 1.3368734948599406, "longitude": 103.63925100926828 } }                             |
      | Pickup Type: Truck        | {fm-paj-driver-5} | {fm-paj-zone-id-5} | {fm-paj-hub-id-5-truck}        | {fm-paj-address-id-5-truck-ext-ref}        | { "name": "PajAutoFmRoutingSgTruck", "phone_number": "+6581234567", "email": "PajAutoFmRoutingSg@shop.co", "address": { "address1": "4 Tuas Link 2", "address2": "#20-25", "country": "SG", "postcode": "638553", "latitude": 1.3368734948599406, "longitude": 103.63925100926828 } } |


  Scenario Outline: SG - Auto Route PAJ - Order Create Flow, Date = Today, Creation = After End Clock Time & Run Manual Cron Job, Driver has Existing Route - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":<zone_id>, "hubId":<hub_id>, "driverId":<driver_id> } |
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-paj-shipper-5-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | shipperClientSecret | {fm-paj-shipper-5-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type": "Parcel", "service_level": "Standard", "from":<pickup_address>, "parcel_job": { "pickup_address_id": "<pickup_address_id>", "pickup_address": <pickup_address>, "dimensions": { "height": 2.7, "length": 2.8, "width": 1 }, "is_pickup_required": true, "pickup_date": "{date: 0 days next, yyyy-MM-dd}", "pickup_timeslot": { "start_time": "09:00", "end_time": "22:00" }, "delivery_start_date": "{date: 0 days next, yyyy-MM-dd}", "delivery_timeslot": { "start_time": "09:00", "end_time": "22:00" } } } |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And DB Control - get pickup appointment job id from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Route - Operator run FM PAJ auto route cron job for date "{date: 0 days next, yyyy-MM-dd}"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 0                                  |
      | hubId    | <hub_id>                           |
      | zoneId   | <zone_id>                          |
      | driverId | <driver_id>                        |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOB_IDS[1]}"
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
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOB_IDS[1]}             |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And API Control - Operator get pickup appointment job search details:
      | getPaJobSearchRequest | {"limit":500,"query":{"pickup_ready_datetime":{"lower_bound":"{date: 0 days next, YYYY-MM-dd}T00:00:00+08:00"},"pickup_appointment_job_id":{"in":[{KEY_CONTROL_CREATED_PA_JOB_IDS[1]}]}}} |
    And API Control - Operator verify pickup appointment job search details:
      | pickupAppointmentJobId | {KEY_CONTROL_CREATED_PA_JOB_IDS[1]} |
      | waypointId             | {KEY_WAYPOINT_ID}                   |
      | routeId                | {KEY_LIST_OF_CREATED_ROUTES[1].id}  |
      | routingZoneId          | <zone_id>                           |
      | driverId               | <driver_id>                         |
    Examples:
      | Note                      | driver_id         | zone_id            | hub_id                         | pickup_address_id                          | pickup_address                                                                                                                                                                                                                                                                        |
      | Pickup Type: FM Dedicated | {fm-paj-driver-5} | {fm-paj-zone-id-5} | {fm-paj-hub-id-5-fm-dedicated} | {fm-paj-address-id-5-fm-dedicated-ext-ref} | { "name": "binti v4.1", "phone_number": "+65189189", "email": "binti@test.co", "address": { "address1": "4 Tuas Link 2", "address2": "#20-25", "country": "SG", "postcode": "638553", "latitude": 1.3368734948599406, "longitude": 103.63925100926828 } }                             |
      | Pickup Type: Truck        | {fm-paj-driver-5} | {fm-paj-zone-id-5} | {fm-paj-hub-id-5-truck}        | {fm-paj-address-id-5-truck-ext-ref}        | { "name": "PajAutoFmRoutingSgTruck", "phone_number": "+6581234567", "email": "PajAutoFmRoutingSg@shop.co", "address": { "address1": "4 Tuas Link 2", "address2": "#20-25", "country": "SG", "postcode": "638553", "latitude": 1.3368734948599406, "longitude": 103.63925100926828 } } |


  Scenario Outline: SG - Auto Route PAJ - Date = Tomorrow, Creation = After End Clock Time & Run Manual Cron Job - <Note>
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 1 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 1 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    Then DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Route - Operator run FM PAJ auto route cron job for date "{date: 0 days next, yyyy-MM-dd}"
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_WAYPOINT_ID} |
      | seqNo         | null              |
      | routeId       | null              |
      | status        | Pending           |
      | routingZoneId | <zone_id>         |
    And API Control - Operator get pickup appointment job search details:
      | getPaJobSearchRequest | {"limit":500,"query":{"pickup_ready_datetime":{"lower_bound":"{date: 1 days next, YYYY-MM-dd}T00:00:00+08:00"},"pickup_appointment_job_id":{"in":[{KEY_CONTROL_CREATED_PA_JOBS[1].id}]}}} |
    And API Control - Operator verify pickup appointment job search details:
      | pickupAppointmentJobId | {KEY_CONTROL_CREATED_PA_JOBS[1].id} |
      | waypointId             | {KEY_WAYPOINT_ID}                   |
      | routeId                | null                                |
      | routingZoneId          | <zone_id>                           |
      | driverId               | null                                |
    Examples:
      | Note                      | zone_id            | shipper_id                         | address_id                         |
      | Pickup Type: FM Dedicated | {fm-paj-zone-id-1} | {fm-paj-shipper-id-1-fm-dedicated} | {fm-paj-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-paj-zone-id-1} | {fm-paj-shipper-id-1-truck}        | {fm-paj-address-id-1-truck}        |


  Scenario Outline: SG - Auto Route PAJ - Date = Today, Pickup Type = Hybrid, Creation = After End Clock Time & Run Manual Cron Job
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":<shipper_id>, "from":{ "addressId":<address_id> }, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{date: 0 days next, YYYY-MM-dd}T09:00:00+08:00", "latest":"{date: 0 days next, YYYY-MM-dd}T22:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"}} |
    Then DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Route - Operator run FM PAJ auto route cron job for date "{date: 0 days next, yyyy-MM-dd}"
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
      | zone_id            | shipper_id                   | address_id                   |
      | {fm-paj-zone-id-3} | {fm-paj-shipper-id-3-hybrid} | {fm-paj-address-id-3-hybrid} |