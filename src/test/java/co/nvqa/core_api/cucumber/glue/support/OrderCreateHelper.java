package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.commons.cucumber.glue.AddressFactory;
import co.nvqa.commons.model.core.Address;
import co.nvqa.commons.model.core.Dimension;
import co.nvqa.commons.model.order_create.v4.*;
import co.nvqa.commons.model.order_create.v4.job.ParcelJob;
import co.nvqa.commons.support.DateUtil;
import co.nvqa.commons.support.RandomUtil;
import co.nvqa.commons.support.ReflectionUtil;
import co.nvqa.commons.util.JsonUtils;
import co.nvqa.commons.util.NvCountry;
import co.nvqa.commons.util.NvTestRuntimeException;
import co.nvqa.commons.util.StandardTestUtils;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.ZonedDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * @author Binti Cahayati on 2020-07-01
 */
public class OrderCreateHelper {

    private static final String TYPE_SHIPPER = "shipper";
    private static final String TYPE_CUSTOMER = "customer";

    public static OrderRequestV4 generateOrderV4(Map<String, String> source) {
        final ObjectMapper mapper = JsonUtils.getDefaultSnakeCaseMapper();
        OrderRequestV4 result;
        ParcelJob parcelJob;
        try{
            final String mapAsJson = mapper.writeValueAsString(source);
            result = mapper.readValue(mapAsJson, OrderRequestV4.class);

            final String PREFIX_PARCEL_JOB = "parcel_job_";

            Map<String, String> jobMap = source.entrySet().stream()
                    .filter(e -> e.getKey().contains(PREFIX_PARCEL_JOB))
                    .collect(Collectors.toMap( e -> e.getKey().substring(PREFIX_PARCEL_JOB.length()), Map.Entry::getValue));
            String jobJson = mapper.writeValueAsString(jobMap);
            parcelJob = mapper.readValue(jobJson, ParcelJob.class);

        } catch (Exception e) {
            throw new NvTestRuntimeException("Unable to deserialize order v4 general object", e);
        }
        result.setRequestedTrackingNumber(generateRequestedTrackingId());
        String uniqueId = generateUniqueId();
        parcelJob.setPickupAddressId(uniqueId);
        parcelJob.setPickupDate(DateUtil.displayDate(DateUtil.getDate()));
        parcelJob.setPickupTimeslot(generateValidRandomTimeSlot());
        parcelJob.setPickupInstruction("Core API Auto - Pickup instructions-"+uniqueId);
        parcelJob.setDeliveryStartDate(DateUtil.displayDate(DateUtil.getDate().plusDays(1L)));
        parcelJob.setDeliveryTimeslot(generateValidRandomTimeSlot());
        parcelJob.setDeliveryInstruction("Core API Auto - Delivery instructions-"+uniqueId);
        parcelJob.setDimensions(generateRandomDimensions());
        ReflectionUtil.nullifyFieldWithNullString(parcelJob);result.setTo(createUserDetail(TYPE_CUSTOMER, uniqueId));
        result.setFrom(createUserDetail(TYPE_SHIPPER, uniqueId));
        result.setParcelJob(parcelJob);
        ReflectionUtil.nullifyFieldWithNullString(result);
        return result;
    }

    private static UserDetail createUserDetail(String type, String uniqueId) {
        UserDetail result = new UserDetail();
        String contact = NvCountry.fromString(TestConstants.COUNTRY_CODE).getCountryCallingCode()+generateRandomNumber(8);
        String name;
        if(type.equalsIgnoreCase(TYPE_SHIPPER)){
            name = "CA-Shipper-";
        } else{
            name = "CA-Customer-";
        }
        result.setName(name+uniqueId);
        result.setEmail(name+ RandomUtil.randomString(3)+"@ninjavan.co");
        result.setPhoneNumber(contact);
        Address address = AddressFactory.getRandomAddress();
        address.setAddress2(address.getAddress2()+"-"+uniqueId);
        result.setAddress(createMapFromAddress(address));
        return result;
    }

    private static String generateRandomNumber(int length) {
        final Random rnd = new Random(Calendar.getInstance().getTimeInMillis());
        StringBuilder sb = new StringBuilder();
        for(int i = 0; i < length; i++) {
            sb.append((char)('0' + rnd.nextInt(10)));
        }
        return sb.toString();
    }

    private static String generateUniqueId(){
        ZonedDateTime zdt = DateUtil.getDate();
        long currentMillis = zdt.toInstant().toEpochMilli();
        String uniqueString = RandomUtil.randomString(256);
        return uniqueString.substring(0,13) + "-" + String.valueOf(currentMillis).substring(2, 11);
    }

    private static boolean isAllNull(Map<String, String> map) {
        for (Map.Entry<String, String> e : map.entrySet()) {
            if (!e.getValue().equalsIgnoreCase("NULL")) {
                return false;
            }
        }
        return true;
    }

    private static Map<String, String> createMapFromAddress(Address address){
        return JsonUtils.convertValueToMapSnakeCase(address, String.class, String.class);
    }

    private static Dimension generateRandomDimensions(){
        Dimension dimension = new Dimension();
        dimension.setWeight((double) StandardTestUtils.randomInt(1, 5));
        dimension.setWidth((double) StandardTestUtils.randomInt(20, 50));
        dimension.setHeight((double) StandardTestUtils.randomInt(30, 60));
        dimension.setLength((double) StandardTestUtils.randomInt(40, 70));
        return dimension;
    }

    private static Timeslot generateValidRandomTimeSlot(){
        List<Timeslot> timeslots = new ArrayList<>();
        Stream.of(Timeslot.ValidTimeSlot.values())
                .filter(e -> !e.equals(Timeslot.ValidTimeSlot.INVALID_TIMESLOT))
                .forEach(e -> timeslots.add(new Timeslot(e.getStartTime(), e.getEndTime())));

        Timeslot timeslot = timeslots.get(new Random().nextInt(timeslots.size()));
        timeslot.setTimezone(TestConstants.DEFAULT_TIMEZONE);
        return timeslot;
    }

    private static String generateRequestedTrackingId(){
        ZonedDateTime zdt = DateUtil.getDate();
        long currentMillis = zdt.toInstant().toEpochMilli();
        return String.valueOf(currentMillis).substring(2, 11);
    }
}