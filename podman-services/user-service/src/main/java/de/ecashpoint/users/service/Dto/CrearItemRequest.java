package de.ecashpoint.users.service.Dto;

public class CrearItemRequest {

    public String nombre;
    public String descripcion;
    public String tipo; // PRODUCTO | SERVICIO
    public String atributos; // JSON
    public Double precioBase;
    public String unidad;
}
