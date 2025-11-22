package de.ecashpoint.users.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity; 
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "profesional_agenda")
public class ProfessionalAgenda extends PanacheEntity {
    

    @ManyToOne
    @JoinColumn(name = "profesional_id")
    public Professional profesional;

    @ManyToOne
    @JoinColumn(name = "item_id")
    public Item item;

    @Column(columnDefinition = "jsonb")
    public String horarios;
}
