@ForceSuccessOrder @order-details @delivery-verification-method
Feature: Delivery Verification Method

  @update-verification-method
  Scenario: DO NOT Allow to Change Delivery Verification Method of Order Tagged to DP (uid:790dc171-e624-4606-b78d-ae7d073f7e98)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103092                          |
      | message     | Delivery is tagged to DP        |
      | application | core                            |
      | description | WAYPOINT_ROUTED_TO_DP_EXCEPTION |

  @update-verification-method
  Scenario Outline: DO NOT Allow to Change Delivery Verification Method of Order with NO ATL - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                             | Parcel   |
      | service_level                            | Standard |
      | parcel_job_is_pickup_required            | false    |
      | parcel_job_allow_doorstep_dropoff        | false    |
      | parcel_job_enforce_delivery_verification | true     |
      | parcel_job_delivery_verification_mode    | <method> |
    And Operator search for created order
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103062                            |
      | message     | Invalid verification mode         |
      | application | core                              |
      | description | INVALID_REQUEST_PAYLOAD_EXCEPTION |

    Examples:
      | Note                                   | method         | hiptest-uid                              |
      | delivery verification = SIGNATURE      | SIGNATURE      | uid:736186d1-8418-43cd-836e-f552b68aac3e |
      | delivery verification = AGE            | AGE            | uid:c9678118-9a5b-47dd-ad68-7bcc3d233ef0 |
      | delivery verification = IDENTIFICATION | IDENTIFICATION | uid:1943e648-14bd-4b48-a7de-a43e6377e631 |

  @update-verification-method
  Scenario: DO NOT Allow to Change Delivery Verification Method of RTS Order (uid:3cd9e3b0-a576-4c1e-b098-09513ea85702)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103099                   |
      | message     | Order is in an end state |
      | application | core                     |
      | description | ORDER_ALREADY_RTS        |

  @update-verification-method
  Scenario: DO NOT Allow to Change Delivery Verification Method for High Value Shipper (uid:140795fb-0905-4992-ba1d-6db8a807348d)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103080                                                  |
      | message     | Cannot update delivery mechanism for high value shipper |
      | application | core                                                    |
      | description | BAD_REQUEST_EXCEPTION                                   |

  @update-verification-method
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Completed (uid:a38d0d53-e63d-4061-abe2-88ab1c1438aa)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |

  @update-verification-method
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Cancelled (uid:69e77074-370a-4c8b-9186-a29d68330408)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |

  @update-verification-method
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Returned to Sender (uid:b0a51f09-ad5b-43af-9d5e-ff971ee912b7)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |

  @update-verification-method
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Arrived at Distribution Point (uid:d2d4e7a1-9959-4623-a2f3-bfcc4db11106)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |

  @validate-verification-method
  Scenario: Validate ATL for Order Tagged to DP (uid:158376d9-af19-4ef8-a6df-9f77d53df76a)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

  @validate-verification-method
  Scenario Outline: Validate ATL for Order with NO ATL - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                             | Parcel   |
      | service_level                            | Standard |
      | parcel_job_is_pickup_required            | false    |
      | parcel_job_allow_doorstep_dropoff        | false    |
      | parcel_job_enforce_delivery_verification | true     |
      | parcel_job_delivery_verification_mode    | <method> |
    And Operator search for created order
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

    Examples:
      | Note                                   | method         | hiptest-uid                              |
      | delivery verification = SIGNATURE      | SIGNATURE      | uid:f76c0adb-2d32-4ae9-abc8-95d5338ee72e |
      | delivery verification = AGE            | AGE            | uid:cc9c5e0b-88ed-41d8-9f53-96eb912154e8 |
      | delivery verification = IDENTIFICATION | IDENTIFICATION | uid:8b8552dc-af46-445a-93af-bff76b246b35 |

  @validate-verification-method
  Scenario: Validate ATL for RTS Order (uid:160f1bfa-5594-460b-b2e1-cf1aab113ae0)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

  @validate-verification-method
  Scenario: Validate ATL for High Value Shipper Order (uid:fb2120a0-a6b5-4b7f-a5f1-bdb91e372766)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

  @validate-verification-method
  Scenario: Validate ATL for Terminal State Order - Completed (uid:f66498f9-3628-447a-ad01-db18930c7e0c)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

  @validate-verification-method
  Scenario: Validate ATL for Terminal State Order - Cancelled (uid:b8c87dda-5638-4805-821b-a884f258cb2d)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

  @validate-verification-method
  Scenario: Validate ATL for Terminal State Order - Returned to Sender (uid:9be3e5fe-fc73-4401-a2a5-63da56c8b7d5)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

  @validate-verification-method
  Scenario: Validate ATL for Terminal State Order - Arrived at Distribution Point (uid:a01527f7-2b70-41e6-85f8-8c7cffd47ff0)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    When Operator validate order for ATL
    Then Operator verify that response returns "false"

  @validate-verification-method
  Scenario Outline: Validate ATL Order with Delivery Verification Method - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                             | Parcel   |
      | service_level                            | Standard |
      | parcel_job_is_pickup_required            | false    |
      | parcel_job_allow_doorstep_dropoff        | true     |
      | parcel_job_enforce_delivery_verification | false    |
      | parcel_job_delivery_verification_mode    | <Note>   |
    And Operator search for created order
    When Operator validate order for ATL
    Then Operator verify that response returns "true"

    Examples:
      | Note | hiptest-uid                              |
      | OTP  | uid:d3d0226f-d4f5-4483-a7bd-49e4c3d0f08e |
      | NONE | uid:c521fe2f-34c1-45b7-8f30-1ff056f93bdb |
