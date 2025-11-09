<?php

declare(strict_types=1);

namespace App\Service;

use App\Service\KeycloakService;
use App\Service\KongGatewayService;

final class UserService
{
    private KeycloakService $keycloakService;

    private KongGatewayService $kongGatewayService;

    public function __construct()
    {
        $this->keycloakService = new KeycloakService();
        $this->kongGatewayService = new KongGatewayService();
    }

    public function login(array $data){
        $user = json_decode((string) json_encode($data), false);

        $access_token = $this->keycloakService->getTokenGateway($user->username , $user->password);
        if(!$access_token){
            throw new \Exception('Error getting token for user in Keycloak');
        }
        return $access_token;
    }

    public function authenticateUser(array $data)
    {
        $user = json_decode((string) json_encode($data), false);

        $authorization =  $this->keycloakService->getToken();

        $this->keycloakService->create_user($user, $authorization['access_token']);

        $id_user =  $this->keycloakService->assignate_role_user($user->username, $authorization['access_token'] , $user->rol);
        //create user a kong
        if(!$id_user){
            throw new \Exception('Error assigning role to user in Keycloak');
        }
        //obtener token con nuevas credenciales
        $access_token = $this->keycloakService->getTokenGateway($user->username , $user->password);
        if(!$access_token){
            throw new \Exception('Error getting token for new user in Keycloak');
        }
        $user_create = $this->kongGatewayService->createUserKong($user, $id_user , $access_token['access_token']);
    
        return $user_create;
    }
}


?>