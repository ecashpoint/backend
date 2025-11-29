package de.ecashpoint.users.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
 

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import io.quarkus.hibernate.orm.panache.PanacheQuery;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity; 
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name="ecommerces")
public class Ecommerce extends PanacheEntity{
    
    @Column(unique = false, nullable = false , length = 100, name="auth_id")
    public String authId;

    @Column(unique = false , nullable = false , length = 125 , name = "ecommerce_name")
    public String ecommerceName;
    
    @Column(unique = false , nullable = false , length = 175 , name = "ecommerce_address")
    public String ecommerceAddress;

    @Column(unique = false , nullable = false , length = 25 , name = "ecommerce_nit")
    public String ecommerceNit;

    @Column(unique = false , nullable = false , length = 4 , name = "ecommerce_dv")
    public String ecommerceDv;

    @Column(unique = false , nullable = false , length = 4 , name = "ecommerce_percentege")
    public Double ecommercePercentage;

    @Column(unique = false , nullable = false , length = 15 , name = "ecommerce_phone")
    public String ecommercePhone;

    @Column(unique = false , nullable = false , length = 125 , name = "ecommerce_email")
    public String ecommerceEmail;

    @Column(unique = false , nullable = false , length = 15 , name = "ecommerce_whatsapp")
    public String ecommerceWhatsapp;
  
    @Column(unique = false , nullable = false , length = 10 , name = "ecommerce_status")
    public boolean ecommerceStatus;

    @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
        name="ecommerce_category",
        joinColumns = @JoinColumn(name="ecommerce_id"),
        inverseJoinColumns = @JoinColumn(name="category_id")
    )
    public Set<Category> categories = new HashSet<>();

    @OneToMany(mappedBy = "ecommerce", cascade = CascadeType.ALL, orphanRemoval = true)
    public List<NetworksSocial> redes;

    @Column(name = "created_at")
    public LocalDateTime createdAt;

    @Column(name = "updated_at")
    public LocalDateTime updatedAt;

    

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }

    


}
