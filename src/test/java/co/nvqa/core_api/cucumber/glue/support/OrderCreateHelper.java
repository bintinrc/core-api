package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.commons.cucumber.glue.AddressFactory;
import co.nvqa.commons.model.core.Address;
import co.nvqa.commons.model.core.Dimension;
import co.nvqa.commons.model.order_create.v4.*;
import co.nvqa.commons.model.order_create.v4.job.ParcelJob;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.support.RandomUtil;
import co.nvqa.commons.support.ReflectionUtil;
import co.nvqa.commons.util.*;
import co.nvqa.core_api.cucumber.glue.features.RouteMonitoringSteps;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * @author Binti Cahayati on 2020-07-01
 */
public class OrderCreateHelper {

  private static final String KEY_REQUESTED_TIMESLOT_TYPE = "timeslot-type";
  private static final String TYPE_SHIPPER = "shipper";
  private static final String TYPE_CUSTOMER = "customer";
  private static final List<Timeslot> TIMESLOTS;

  static {
    TIMESLOTS = new ArrayList<>();
    Stream.of(Timeslot.ValidTimeSlot.values())
        .filter(e -> !e.equals(Timeslot.ValidTimeSlot.INVALID_TIMESLOT))
        .forEach(e -> TIMESLOTS.add(new Timeslot(e.getTimeslot().get(0), e.getTimeslot().get(1))));
  }

  public static OrderRequestV4 generateOrderV4(Map<String, String> source) {
    ZonedDateTime zdt = DateUtil.getDate(ZoneId.of(StandardTestConstants.DEFAULT_TIMEZONE));
    final ObjectMapper mapper = JsonUtils.getDefaultSnakeCaseMapper();
    OrderRequestV4 result;
    ParcelJob parcelJob;
    try {
      final String mapAsJson = mapper.writeValueAsString(source);
      result = mapper.readValue(mapAsJson, OrderRequestV4.class);

      final String PREFIX_PARCEL_JOB = "parcel_job_";

      Map<String, String> jobMap = source.entrySet().stream()
          .filter(e -> e.getKey().contains(PREFIX_PARCEL_JOB))
          .collect(Collectors
              .toMap(e -> e.getKey().substring(PREFIX_PARCEL_JOB.length()), Map.Entry::getValue));
      String jobJson = mapper.writeValueAsString(jobMap);
      parcelJob = mapper.readValue(jobJson, ParcelJob.class);

    } catch (Exception e) {
      throw new NvTestRuntimeException("Unable to deserialize order v4 general object", e);
    }
    result.setRequestedTrackingNumber(generateRequestedTrackingId());
    String uniqueId = generateUniqueId();
    parcelJob.setPickupAddressId(uniqueId);
    parcelJob.setPickupDate(DateUtil.displayDate(zdt));
    Timeslot timeslot = generateValidTimeSlot(source, zdt);
    parcelJob.setPickupTimeslot(timeslot);
    parcelJob.setPickupInstruction("Core API Auto - Pickup instructions-" + uniqueId);
    parcelJob.setDeliveryStartDate(DateUtil.displayDate(zdt.plusDays(1L)));
    parcelJob.setDeliveryTimeslot(timeslot);
    parcelJob.setDeliveryInstruction("Core API Auto - Delivery instructions-" + uniqueId);
    parcelJob.setDimensions(generateRandomDimensions());
    ReflectionUtil.nullifyFieldWithNullString(parcelJob);
    result.setTo(createUserDetail(TYPE_CUSTOMER, uniqueId, source));
    result.setFrom(createUserDetail(TYPE_SHIPPER, uniqueId, source));
    result.setParcelJob(parcelJob);
    ReflectionUtil.nullifyFieldWithNullString(result);
    return result;
  }

  private static UserDetail createUserDetail(String type, String uniqueId,
      Map<String, String> source) {
    UserDetail result = new UserDetail();
    String contact = NvCountry.fromString(TestConstants.COUNTRY_CODE).getCountryCallingCode()
        + generateRandomNumber(8);
    String name;
    if (type.equalsIgnoreCase(TYPE_SHIPPER)) {
      name = "CA-Shipper-";
    } else {
      name = "CA-Customer-";
    }
    result.setName(name + uniqueId);
    result.setEmail(name + RandomUtil.randomString(3) + "@ninjavan.co");
    result.setPhoneNumber(contact);
    Address address = AddressFactory.getRandomAddress();
    if (source.get("dp-address-unit-number") != null) {
      address.setAddress1(address.getAddress1() + " " + source.get("dp-address-unit-number"));
      address.setPostcode(source.get("dp-address-postcode"));
    }
    address.setAddress2(address.getAddress2() + "-" + uniqueId);
    result.setAddress(createMapFromAddress(address));
    return result;
  }

  private static String generateRandomNumber(int length) {
    final Random rnd = new Random(Calendar.getInstance().getTimeInMillis());
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < length; i++) {
      sb.append((char) ('0' + rnd.nextInt(10)));
    }
    return sb.toString();
  }

  private static String generateUniqueId() {
    ZonedDateTime zdt = DateUtil.getDate(ZoneId.of(StandardTestConstants.DEFAULT_TIMEZONE));
    long currentMillis = zdt.toInstant().toEpochMilli();
    String uniqueString = RandomUtil.randomString(256);
    return uniqueString.substring(0, 13) + "-" + String.valueOf(currentMillis).substring(2, 11);
  }

  private static boolean isAllNull(Map<String, String> map) {
    for (Map.Entry<String, String> e : map.entrySet()) {
      if (!e.getValue().equalsIgnoreCase("NULL")) {
        return false;
      }
    }
    return true;
  }

  private static Map<String, String> createMapFromAddress(Address address) {
    return JsonUtils.convertValueToMapSnakeCase(address, String.class, String.class);
  }

  private static Dimension generateRandomDimensions() {
    Dimension dimension = new Dimension();
    dimension.setWeight((double) StandardTestUtils.randomInt(1, 3));
    dimension.setWidth((double) StandardTestUtils.randomInt(10, 20));
    dimension.setHeight((double) StandardTestUtils.randomInt(15, 25));
    dimension.setLength((double) StandardTestUtils.randomInt(20, 30));
    return dimension;
  }

  private static Timeslot generateValidTimeSlot(Map<String, String> source, ZonedDateTime zdt) {
    String timeslotType = RouteMonitoringSteps.TIMESLOT_TYPE_EARLY;
    if (source.get(KEY_REQUESTED_TIMESLOT_TYPE) != null) {
      timeslotType = source.get(KEY_REQUESTED_TIMESLOT_TYPE);
    }
    Timeslot timeslot;
    switch (timeslotType) {
      case RouteMonitoringSteps.TIMESLOT_TYPE_IMPENDING:
        timeslot = generateImpendingTimeSlot(zdt);
        break;
      case RouteMonitoringSteps.TIMESLOT_TYPE_LATE:
        timeslot = generateLateTimeSlot(zdt);
        break;
      default:
        timeslot = generateEarlyTimeSlot(zdt);
    }
    timeslot.setTimezone(TestConstants.DEFAULT_TIMEZONE);
    return timeslot;
  }

  //default Pending Waypoint Timeslot && Early Waypoint Timeslot
  private static Timeslot generateEarlyTimeSlot(ZonedDateTime zdt) {
    Timeslot timeslot = null;
    int i = 0;
    boolean found = false;
    while (!found) {
      if (i == TIMESLOTS.size() || zdt.toLocalTime()
          .isBefore(LocalTime.parse(TIMESLOTS.get(i).getEndTime()).minusHours(3L))) {
        found = true;
      }
      if (i == TIMESLOTS.size()) {
        //get latest timeslot if no timeslot meets criteria
        timeslot = TIMESLOTS.get(TIMESLOTS.size() - 1);
      } else {
        timeslot = TIMESLOTS.get(i);
      }
      i++;
    }
    return timeslot;
  }

  private static Timeslot generateLateTimeSlot(ZonedDateTime zdt) {
    Timeslot timeslot = null;
    int i = 0;
    boolean found = false;
    while (!found) {
      if (i == TIMESLOTS.size() || zdt.toLocalTime()
          .isAfter(LocalTime.parse(TIMESLOTS.get(i).getEndTime()).minusHours(3L))) {
        found = true;
      }
      if (i == TIMESLOTS.size()) {
        //get earliest timeslot if no timeslot meets criteria
        timeslot = TIMESLOTS.get(0);
      } else {
        timeslot = TIMESLOTS.get(i);
      }
      i++;
    }
    return timeslot;
  }

  private static Timeslot generateImpendingTimeSlot(ZonedDateTime zdt) {
    Timeslot timeslot = null;
    int i = 0;
    boolean found = false;
    while (!found) {
      if (zdt.toLocalTime().isAfter(LocalTime.parse(TIMESLOTS.get(i).getStartTime())) &&
          zdt.toLocalTime().isBefore(LocalTime.parse(TIMESLOTS.get(i).getEndTime()))) {
        found = true;
        timeslot = TIMESLOTS.get(i);
      }
      i++;
    }
    return timeslot;
  }

  private static String generateRequestedTrackingId() {
    ZonedDateTime zdt = DateUtil.getDate(ZoneId.of(StandardTestConstants.DEFAULT_TIMEZONE));
    long currentMillis = zdt.toInstant().toEpochMilli();
    return String.valueOf(currentMillis).substring(2, 11);
  }
}