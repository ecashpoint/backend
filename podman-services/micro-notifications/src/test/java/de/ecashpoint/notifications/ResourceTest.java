package de.ecashpoint.notifications;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
class ResourceTest {
    @Test
    void testHelloEndpoint() {
        given()
          .when().get("/notifications")
          .then()
             .statusCode(200)
             .body(is("Hello RESTEasy"));
    }

}