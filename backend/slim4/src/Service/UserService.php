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

    public function authenticateUser(array $data)
    {
        $user = json_decode((string) json_encode($data), false);

        $authorization =  $this->keycloakService->getToken();

        $this->keycloakService->create_user($user, $authorization['access_token']);

        $id_user =  $this->keycloakService->assignate_role_user($user->username, $authorization['access_token'] , $user->rol);
        //create user a kong
        $user_create = $this->kongGatewayService->createUserKong($user, $id_user);
        
        return $user_create;
    }
}


?>