package de.ecashpoint.users.entity;
 
import com.fasterxml.jackson.annotation.JsonIgnore;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated; 
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "network_social")
public class NetworksSocial extends PanacheEntity{
    
    
    @ManyToOne
    @JoinColumn(name = "ecommerce_id", nullable = false)
    @JsonIgnore
    public Ecommerce ecommerce;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    public TypeNetWork name;

    public String url;

    public enum TypeNetWork{
        X,
        FACEBOOK,
        INSTAGRAM,
        TIKTOK
    }
}
