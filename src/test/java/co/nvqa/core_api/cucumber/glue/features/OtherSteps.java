package co.nvqa.core_api.cucumber.glue.features;

import co.nvqa.core_api.cucumber.glue.BaseSteps;
import io.cucumber.java.en.Then;

public class OtherSteps extends BaseSteps {

  @Override
  public void init() {

  }

  @Then("pause for {int} seconds")
  public void operatorWaitsForSeconds(int arg0) {
    pause(arg0 * 1000L);
  }
}
