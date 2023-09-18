@ArchiveDriverRoutes @CancelCreatedReservations @DeletePickupAppointmentJob @routing2 @pa-job
Feature: Zonal Routing API

  @DeletePickupAppointmentJob @happy-path
  Scenario: PUT /pickup-appointment-jobs/:paJobId/route - Route Unrouted PA Job Waypoint
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                   |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePickupAppointmentJob
  Scenario: PUT /pickup-appointment-jobs/:paJobId/route - Update Routed PA Job to a New Route
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
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
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                                               |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 2                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @DeletePickupAppointmentJob
  Scenario: POST /routes - Zonal Routing API - Create Driver Route & Assign PA Job Waypoint
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePickupAppointmentJob
  Scenario: PUT /routes - Zonal Routing Edit Route API - Add Unrouted PA Job Waypoints to Route
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePickupAppointmentJob
  Scenario: PUT /routes - Zonal Routing Edit Route API - Move Routed PA Job Waypoints to Another Route
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[2].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                                               |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 2                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @DeletePickupAppointmentJob @CancelCreatedReservations
  Scenario: PUT /routes - Zonal Routing Edit Route API - Remove PA Job Waypoints From Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}, {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}]} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID} |
      | seqNo   | null              |
      | routeId | null              |
      | status  | Pending           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | seqNo    | null              |
      | routeId  | null              |
      | status   | Pending           |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_WAYPOINT_ID} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 3                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePickupAppointmentJob @happy-path
  Scenario: PUT /pickup-appointment-jobs/:paJobId/unroute - Unroute PA Job Waypoint
    When API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    When API Core - Operator remove pickup job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}" from route
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID} |
      | seqNo   | null              |
      | routeId | null              |
      | status  | Pending           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | seqNo    | null              |
      | routeId  | null              |
      | status   | Pending           |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_WAYPOINT_ID} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 3                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePickupAppointmentJob
  Scenario: PUT /pickup-appointment-jobs/:paJobId/route - Add PA Job to a Route that has been started
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                   |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 1                                  |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
      | userId     | 586867                                          |
      | userName   | core-api driver-routing-3                       |
      | type       | 4                                               |
      | pickupType | 2                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-2-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-2-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    When API Core - Operator add pickup job to the route using data below:
      | jobId                      | {KEY_CONTROL_CREATED_PA_JOBS[2].id}                                   |
      | addPickupJobToRouteRequest | {"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[2].id}"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
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

  @DeletePickupAppointmentJob
  Scenario: PUT /routes - Zonal Routing Edit Route API - Add PA Job to a Route that has been started
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 1                                  |
    Given API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
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