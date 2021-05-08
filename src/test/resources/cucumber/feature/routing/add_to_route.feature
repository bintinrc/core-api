@ForceSuccessOrder @DeleteReservationAndAddress @ArchiveDriverRoutes @add-to-route
Feature: Add to Route

  @add-parcel-to-route
  Scenario Outline: Operator Add Parcel to Driver Route Successfully - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for "<txn_type>" transaction with status "PENDING"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "<route_type>" route
    And DB Operator verifies transaction routed to new route id
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies route_monitoring_data record
    And Operator checks that "ADD_TO_ROUTE" event is published

    Examples:
      | Note     | hiptest-uid                              | txn_type | route_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | uid:d9266718-dcf6-4131-8d77-6e3f5d239173 | PICKUP   | PP         | Return       | Standard      | true                          |
      | Delivery | uid:1917f9ef-8275-4dce-8f2d-500b4fa80930 | DELIVERY | DD         | Parcel       | Standard      | false                         |
