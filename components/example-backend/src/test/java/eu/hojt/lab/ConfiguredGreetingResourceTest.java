package eu.hojt.lab;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.junit.QuarkusTestProfile;
import io.quarkus.test.junit.TestProfile;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
@TestProfile(ConfiguredGreetingResourceTest.ConfiguredGreetingProfile.class)
class ConfiguredGreetingResourceTest {
    @Test
    void returnsConfiguredGreetingMessage() {
        given()
          .when().get("/api/greeting")
          .then()
             .statusCode(200)
             .contentType("application/json")
             .body("message", is("Configured greeting"));
    }

    public static class ConfiguredGreetingProfile implements QuarkusTestProfile {
        @Override
        public Map<String, String> getConfigOverrides() {
            return Map.of("greeting.message", "Configured greeting");
        }
    }
}
