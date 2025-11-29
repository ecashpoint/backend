package de.ecashpoint.users.service;

import java.util.List;

import org.eclipse.microprofile.context.ManagedExecutor;
import org.eclipse.microprofile.rest.client.inject.RestClient;

import de.ecashpoint.users.constant.Constants;
import de.ecashpoint.users.entity.EmailRequest;
import de.ecashpoint.users.entity.User;
import de.ecashpoint.users.repository.UserRepository;
import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;
import jakarta.transaction.Transactional.TxType;

@ApplicationScoped
public class UserService {

    @Inject
    UserRepository userRepository;

    @Inject
    @RestClient
    IEmailApiclient emailApiClient;

    @Inject
    ManagedExecutor managedExecutor;

    public List<User> getAllUsers() {
        return userRepository.listAll();
    }

    public User getUserByAuthId(String id) {
        return userRepository.find("auth_id", id).firstResultOptional()
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado con ID de autenticación: " + id));
    }

    public User findById(Long id) {
        return userRepository.findByIdOptional(id)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado con ID: " + id));
    }

    public void updated(User user, String authId) {
        User existingUser = userRepository.find("auth_id", authId).firstResultOptional()
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado con ID de autenticación: " + authId));

        existingUser.firstName = user.firstName;
        existingUser.lastName = user.lastName;
        existingUser.email = user.email;
        existingUser.father = user.father;
        existingUser.indicative = user.indicative;
        existingUser.phone = user.phone;
        existingUser.document = user.document;
        existingUser.dv = user.dv;

        userRepository.persist(existingUser);
    }

    @Transactional
    public User create(User user) {
        // Validaciones

        if (userRepository.existsByEmail(user.email)) {
            throw new WebApplicationException(
                    Constants.EXECPTION_EXIST_MAIL + user.email,
                    Response.Status.CONFLICT);
        }

        if (userRepository.existByDocument(user.document)) {
            throw new WebApplicationException(
                    Constants.EXCEPTION_EXIST_DOCUMENT + user.document);
        }

        if (userRepository.existByPhone(user.phone)) {
            throw new WebApplicationException(
                    Constants.EXCEPTION_EXIST_PHONE + user.phone);
        }

        userRepository.persist(user);

        managedExecutor.submit(() -> {
            try {
                afterCommit(user);
            } catch (Exception e) {
                // TODO: handle exception
                Log.error("Error enviando email a " + user.email, e);

            }
        });
        return user;
    }

    @Transactional(TxType.REQUIRES_NEW)
    void afterCommit(User user) {
        // Lógica a ejecutar después de que la transacción principal se haya confirmado
        String name = user.firstName + " " + user.lastName;
        EmailRequest emailRequest = new EmailRequest(
                user.email,
                name,
                "registration");
        emailApiClient.sendEmail(emailRequest);
    }

    @Transactional
    public void delete(Long id) {
        User user = findById(id);
        userRepository.delete(user);
    }
}
