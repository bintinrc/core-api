@routing @wip
Feature: Routing
  Scenario Outline: Operator Add Parcel to Driver Route - <Note> - <hiptest-uid> - "<route_type>"
    When Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    And Shipper create order with parameters below
    |service_type                  | <service_type>                  |
    |service_level                 | <service_level>                 |
    |requested_tracking_number     | <requested_tracking_number>     |
    |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    When Routing Operator does authentication
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route

    Examples:
      | Note     | hiptest-uid                              |route_type | service_type | service_level | requested_tracking_number |parcel_job_is_pickup_required|
      | Pickup   | uid:cb335201-b86a-4373-ac57-de37c724c6e1 |PP         | Return       | Standard      | {{tracking_id}}           |true                         |
      | Delivery | uid:ad5982ad-1289-4255-95e3-707890c0b533 |DD         | Parcel       | Standard      | {{tracking_id}}           |false                        |
