@ArchiveDriverRoutes @parcel-route-transfer @NVQA-13557
Feature: Parcel Route Transfer

  @routing-refactor @happy-path @HighPriority
  Scenario: Driver Route Transfer Parcel - No Driver Route Available for the Driver, Unrouted Delivery
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
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[3] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 2
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 3
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                           |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]}             |
      | routeId          | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
      | routeEventSource | ROUTE_TRANSFER                                |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]}             |
      | routeId          | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
      | routeEventSource | ROUTE_TRANSFER                                |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                           |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]}             |
      | routeId          | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
      | routeEventSource | ROUTE_TRANSFER                                |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]}             |
      | routeId          | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
      | routeEventSource | ROUTE_TRANSFER                                |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                           |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]}             |
      | routeId          | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
      | routeEventSource | ROUTE_TRANSFER                                |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]}             |
      | routeId          | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
      | routeEventSource | ROUTE_TRANSFER                                |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[3].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @routing-refactor @HighPriority
  Scenario: Driver Route Transfer Parcel - No Driver Route Available for the Driver, Routed Delivery
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
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @routing-refactor @happy-path @HighPriority
  Scenario: Driver Route Transfer Parcel - Driver Route Available for the Driver, Unrouted Delivery
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @routing-refactor @HighPriority
  Scenario: Driver Route Transfer Parcel - Driver Route Available for the Driver, Routed Delivery
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
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[3] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 2
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 3
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[3].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @routing-refactor @HighPriority
  Scenario: Driver Route Transfer Parcel - No Driver Route Available for the Driver, Routed Fail Delivery
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator perform global inbound at hub "{sorting-hub-id}"
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
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    And Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @routing-refactor @HighPriority
  Scenario: Driver Route Transfer Parcel - Driver Route Available for the Driver, Routed Fail Delivery
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "FAIL" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |

    And Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Completed
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
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    #    check order 2
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | null                                               |
    And Operator checks that "ROUTE_TRANSFER_SCAN" event is NOT published

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Cancelled
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And API Core - cancel order "{KEY_CREATED_ORDER_ID}"
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
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And Operator checks that "ROUTE_TRANSFER_SCAN" event is NOT published

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Returned to Sender
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And API Core - Operator rts order:
      | orderId    | {KEY_CREATED_ORDER.id}                                                                                          |
      | rtsRequest | { "reason": "Return to sender: Nobody at address", "timewindow_id":1, "date":"{date: 1 days next, yyyy-MM-dd}"} |
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
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And Operator checks that "ROUTE_TRANSFER_SCAN" event is NOT published

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel to Past Date Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator perform global inbound at hub "{sorting-hub-id}"
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

  @HighPriority
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
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[3] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[4] |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    When Driver Transfer Parcel to Another Driver
      | to_driver_id            | {driver-2-id}    |
      | to_driver_hub_id        | {sorting-hub-id} |
      | to_exclude_routed_order | true             |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 2
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 3
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 4
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[4].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[4].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[4].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[4].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    Then Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[4]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[4]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[3].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[4].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @routing-refactor @HighPriority
  Scenario: Driver Route Transfer Parcel - Merged Waypoints
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper creates multiple orders : 3 orders with the same params
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
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    Then API Core - Operator verifies "Delivery" transactions of following orders have same waypoint id:
      | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
    When Driver Transfer Parcel to Another Driver
      | to_driver_id     | {driver-2-id}    |
      | to_driver_hub_id | {sorting-hub-id} |
      | to_create_route  | true             |
    Then API Core - Operator verifies "Delivery" transactions of following orders have different waypoint id:
      | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[3] |
    #    check order 1
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 2
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    #    check order 3
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}      |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
      | status   | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId}              |
    And Operator verify that all orders status-granular status is "Transit"-"On_Vehicle_For_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN               |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTE_ID[2]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | routeEventSource | ROUTE_TRANSFER                    |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[3].id}            |
      | hubId   | {hub-id}                                      |
      | type    | 4                                             |
      | routeId | {KEY_LIST_OF_DRIVER_WAYPOINT_DETAILS.routeId} |

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Resolve MISSING PETS Ticket
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                               |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                           |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                            |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{date: 1 days next, yyyy-MM-dd}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{date: 1 days next, yyyy-MM-dd}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Recovery - Operator create recovery ticket:
      | trackingId         | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | ticketType         | MISSING                               |
      | entrySource        | RECOVERY SCANNING                     |
      | investigatingParty | {DEFAULT-INVESTIGATING-PARTY}         |
      | investigatingHubId | {DEFAULT-INVESTIGATING-HUB}           |
      | orderOutcomeName   | ORDER OUTCOME (MISSING)               |
      | creatorUserId      | {DEFAULT-CREATOR-USER-ID}             |
      | creatorUserName    | {DEFAULT-CREATOR-USERNAME}            |
      | creatorUserEmail   | {DEFAULT-CREATOR-EMAIL}               |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ON_HOLD"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator parcel transfer to a new route:
      | request | { "route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "from_driver_id": null, "to_driver_id": {driver-id}, "to_driver_hub_id": {sorting-hub-id}, "orders": [ { "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "inbound_type": "VAN_FROM_NINJAVAN", "hub_id": {sorting-hub-id} } ] } |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ON_VEHICLE_FOR_DELIVERY"
    Then API Recovery - verify ticket details:
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}   |
      | ticketId   | {KEY_CREATED_RECOVERY_TICKET.ticket.id} |
      | status     | RESOLVED                                |
      | outcome    | FOUND - INBOUND                         |
    And API Core - Operator verify that "TICKET_RESOLVED" event is published for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"

