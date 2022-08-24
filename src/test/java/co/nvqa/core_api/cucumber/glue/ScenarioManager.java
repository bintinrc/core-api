package co.nvqa.core_api.cucumber.glue;

import co.nvqa.commons.cucumber.StandardScenarioManager;
import co.nvqa.commons.util.NvLogger;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.inject.Singleton;
import io.cucumber.java.Scenario;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.restassured.RestAssured;
import io.restassured.config.ObjectMapperConfig;
import io.restassured.config.RedirectConfig;

@Singleton
public class ScenarioManager extends StandardScenarioManager {

  static {
    RestAssured.useRelaxedHTTPSValidation();
    RestAssured.config = RestAssured.config()
        .objectMapperConfig(new ObjectMapperConfig()
            .jackson2ObjectMapperFactory(
                (cls, charset) -> {
                  ObjectMapper objectMapper = new ObjectMapper();
                  objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
                  objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
                  return objectMapper;
                }
            )).redirect(
            RedirectConfig.redirectConfig()
                .followRedirects(true)
                .and()
                .maxRedirects(20)
        );
  }

  @After
  public void afterScenario(Scenario scenario) {
    testCaseService.pushExecutionResultViaApi(scenario);
  }
}
