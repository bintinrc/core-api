@ForceSuccessOrder @order-details
Feature: Order Details

  Scenario: Operator RTS Order With Status = Completed
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    When Operator RTS invalid state Order
      | request | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103088                                        |
      | message     | An order with status 'Completed' can't be RTS |
      | application | core                                          |
      | description | INVALID_OPERATION                             |
    Then Operator verify that order status-granular status is "Completed"-"Completed"

  Scenario: Operator RTS Order With Status = Returned To Sender
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    When Operator RTS invalid state Order
      | request | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103099                         |
      | message     | Order is already an RTS order! |
      | application | core                           |
      | description | ORDER_ALREADY_RTS              |
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"

  Scenario: Operator RTS Order With Status = Cancelled
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    When Operator RTS invalid state Order
      | request | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103088                                        |
      | message     | An order with status 'Cancelled' can't be RTS |
      | application | core                                          |
      | description | INVALID_OPERATION                             |
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"

  Scenario: Do Not Allow Force Success On Hold Order with Active PETS Ticket
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator update order granular status to = "On Hold"
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    When Operator force success invalid state Order
    Then Operator verify response code is 403 with error message details as follow
      | code        | 103087                                                                     |
      | message     | Order has active PETS ticket. Please resolve PETS ticket to update status. |
      | application | core                                                                       |
      | description | FORBIDDEN_EXCEPTION                                                        |
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And Operator checks that "FORCE_SUCCESS" event is NOT published
