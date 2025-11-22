package de.ecashpoint.users.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity; 
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "agenda_servicio")
public class AgendaServicio extends PanacheEntity {


    @OneToOne
    @JoinColumn(name = "item_id", unique = true)
    public Item item;

    public Integer duracionMinutos;

    public Boolean requiereProfesional = false;

    @Column(columnDefinition = "jsonb")
    public String reglasAgenda;
}

