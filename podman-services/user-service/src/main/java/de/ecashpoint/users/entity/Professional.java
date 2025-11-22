package de.ecashpoint.users.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity; 
import jakarta.persistence.Table;

@Entity
@Table(name = "profesional")
public class Professional extends PanacheEntity {
    

    public String nombre;

    @Column(columnDefinition = "jsonb")
    public String especialidades;
}