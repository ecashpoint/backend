package de.ecashpoint.users.service.Dto;

public class ConfigurarItemEcommerceRequest {

    public Long itemId;
    public Long ecommerceId;
    public Double precioPersonalizado;
    public Boolean visible;
    public Integer stockPersonalizado;
    public String configAdicional; // JSON
}

