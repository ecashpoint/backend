package de.ecashpoint.users.service;
 
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

import de.ecashpoint.users.entity.EmailRequest;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.MediaType;

@RegisterRestClient(configKey = "email-api")
public interface IEmailApiclient {
    
    @POST
    @Path("/mail/registration")
    @Consumes(MediaType.APPLICATION_JSON)
    void sendEmail(EmailRequest emailRequest);

}

