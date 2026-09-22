package eu.hojt.lab;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
class GreetingResourceTest {
    @Test
    void testHelloEndpoint() {
        given()
          .when().get("/api/greeting")
          .then()
             .statusCode(200)
             .contentType("application/json")
             .body("message", is("Hello from Quarkus"));
    }

}
