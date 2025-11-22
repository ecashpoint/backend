package de.ecashpoint.users.service;

import java.util.List;

import de.ecashpoint.users.constant.Constants;
import de.ecashpoint.users.entity.User;
import de.ecashpoint.users.repository.UserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;

@ApplicationScoped
public class UserService {
    
    @Inject
    UserRepository userRepository;

    public List<User> getAllUsers() {
        return userRepository.listAll();
    }

    public User getUserByAuthId(String id) {
        return userRepository.find("auth_id", id).firstResultOptional().orElseThrow(() -> 
            new NotFoundException("Usuario no encontrado con ID de autenticación: " + id)
        );
    }

    public User findById(Long id) {
        return userRepository.findByIdOptional(id)
            .orElseThrow(() -> new NotFoundException("Usuario no encontrado con ID: " + id));
    }

    public void updated(User user , String authId){
        User existingUser = userRepository.find("auth_id", authId).firstResultOptional().orElseThrow(() -> 
            new NotFoundException("Usuario no encontrado con ID de autenticación: " + authId)
        );

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
                Response.Status.CONFLICT
            );
        }

        if(userRepository.existByDocument(user.document)){
            throw new WebApplicationException(
                Constants.EXCEPTION_EXIST_DOCUMENT + user.document
            );
        }

        if(userRepository.existByPhone(user.phone)){
            throw new WebApplicationException(
                Constants.EXCEPTION_EXIST_PHONE + user.phone
            );
        }
        
        userRepository.persist(user);
        return user;
    }

    

    @Transactional
    public void delete(Long id) {
        User user = findById(id);
        userRepository.delete(user);
    }
}
