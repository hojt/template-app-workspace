package eu.hojt.lab;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/api/greeting")
public class GreetingResource {

    @ConfigProperty(
        name = "greeting.message",
        defaultValue = "Hello from Quarkus"
    )
    String greetingMessage;

    @ConfigProperty(
        name = "greeting.secret",
        defaultValue = "no-secret"
    )
    String greetingSecret;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public GreetingResponse greeting() {
        return new GreetingResponse(
            greetingMessage,
            !"no-secret".equals(greetingSecret)
        );
    }

    public record GreetingResponse(
        String message,
        boolean secretConfigured
    ) {
    }
}
