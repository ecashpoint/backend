package de.ecashpoint.users.entity;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.stream.Collectors;

import com.fasterxml.jackson.annotation.JsonProperty;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User extends PanacheEntity {

    @Column(unique = true, nullable = false , length = 50)
    public String code;

    @Column(unique = true, nullable = false , length = 50)
    public String father;

    @Column(unique = true, nullable = false , length = 100)
    public String email;

    @Column(name = "first_name", nullable = false , length = 100)
    public String firstName;

    @Column(name = "last_name", nullable = false , length = 100)
    public String lastName;

    @Column( nullable = false , length = 100)
    public String indicative;

    @Column( nullable = false , length = 20)
    public String phone;

    @Column( nullable = true, length = 20 , unique = true)
    public String document;

    @Column( nullable = true , length = 10 )
    public String dv;

    @Column(name = "created_at", nullable = false)
    @JsonProperty("createdAt")
    public LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    @JsonProperty("updatedAt")
    public LocalDateTime updatedAt;
    
    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        code = generateRamdonCode();
    }
    
    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }

    private String generateRamdonCode(){
        String caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789ÄÖÜäöüß";
        SecureRandom random = new SecureRandom();
        return random.ints(6 , 0 , caracteres.length())
                     .mapToObj(caracteres::charAt)
                     .map(Object::toString)
                     .collect(Collectors.joining());
    }




}
