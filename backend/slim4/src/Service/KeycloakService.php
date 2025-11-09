<?php

declare(strict_types=1);

namespace App\Service;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

final class KeycloakService
{
    private array $tokens;

    private Client $client;

    public function __construct()
    {
        $this->tokens = array(
            'url_keycloak' => $_SERVER['URL_KEYCLOAK'] , 
            'keycloak_user' => $_SERVER['KEYCLOAK_USER'] , 
            'keycloak_pass' => $_SERVER['KEYCLOAK_PASSWORD'],
            'endpoint_token' => $_SERVER['ENDPOINT_TOKEN'],
            'endpoint_create_user' => $_SERVER['ENDPOINT_CREATE_USER'],
            'client_id_admin' => $_SERVER['CLIENT_ID_ADMIN'],            
            'kong_client' => $_SERVER['KONG_CLIENT'],
            'client_secret' => $_SERVER['CLIENT_SECRET']
        );
        $this->init();
    }

    public function init(): void
    {
        $this->client = new Client([
            'base_uri' => $this->getKeycloakUrl(),
            'timeout'  => 5.0,
        ]);
    }

    public function getTokenGateway($user , $password){
        try {
            //code...
            $response = $this->client->post('/realms/microservices/protocol/openid-connect/token',[
                "headers" => [
                    'Content-Type' => 'application/x-www-form-urlencoded'
                ],
                "form_params" => [
                    'grant_type' => 'password',
                    'client_id' => $this->getClientId(),
                    'client_secret' => $this->getClientSecret(),
                    'username' => $user,
                    'password' => $password
                ]
                ]);
            $data = json_decode($response->getBody()->getContents(), true);
            return $data;
        } catch (ClientException $e){

            throw new \Exception('Error creating Kong user: ' . $e->getMessage());
        }
    }

    public function getClientSecret(){
        return $this->tokens['client_secret'];
    }

    public function getClientId(){
        return $this->tokens['kong_client'];
    }

    public function getToken()
    {
        try{
            $body = $this->getAuhtBody();
            $response = $this->client->post($this->tokens['endpoint_token'], $body);
            $data = json_decode($response->getBody()->getContents(), true);
            return $data;
        }catch(ClientException $e){
            throw new \Exception('Error getting Keycloak token: ' . $e->getMessage());
        }
    }

    public function getAuhtBody(): array
    {
        return [
            'form_params' => [
                'grant_type' => 'password',
                'client_id' => $this->tokens['client_id_admin'],
                'username' => $this->getKeycloakUser(),
                'password' => $this->getKeycloakPassword(),
            ]
        ];
    }

    public function create_user(object $data, string $accessToken)
    {
        try{
            $response = $this->client->post($this->tokens['endpoint_create_user'], [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json',   
                ],
                'json' => $this->get_body_create_user((object)$data)
            ]);
           // El ID del usuario viene en el header Location
            $location = $response->getHeader('Location')[0] ?? '';
            $userId = basename($location);

            if (empty($userId)) {
                throw new \Exception('Could not retrieve user ID from response');
            }

            return $userId;
        }catch(ClientException $e){
            $statusCode = $e->getResponse()->getStatusCode();
            $errorBody = json_decode($e->getResponse()->getBody()->getContents(), true);

            // 409 Conflict - Usuario ya existe
            if ($statusCode === 409) {
                /*return [
                    'success' => false,
                    'error' => 'USER_EXISTS',
                    'message' => 'El usuario ya existe en echaspoint',
                    'details' => $errorBody['errorMessage'] ?? 'User already exists'
                ];*/
                throw new \Exception('User already exists in ecashpoint' , 409);
            }

            // 400 Bad Request - Datos inválidos
            if ($statusCode === 400) {
                /*return [
                    'success' => false,
                    'error' => 'INVALID_DATA',
                    'message' => 'Datos de usuario inválidos',
                    'details' => $errorBody['errorMessage'] ?? 'Invalid user data'
                ];*/
                throw new \Exception('Invalid user data provided' , 400);
            }
            throw new \Exception('Error creating Keycloak user: ' . ($errorBody['errorMessage'] ?? $e->getMessage()));
        }
    }

    public function assignate_role_user($username , $accessToken , $roleName)
    {
        //to do
        try {
            $response = $this->client->get('/admin/realms/microservices/users?username=' . $username, [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json',
                    ]
                ]
            );
            $data = json_decode($response->getBody()->getContents(), true);
            $userId = $data[0]['id'];
            //get role id
            $responseRole = $this->client->get('/admin/realms/microservices/roles', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json'
                        ]]);
            $roles = json_decode($responseRole->getBody()->getContents(), true); 
            //buscar por nombre del rol in $dataRole
            $filteredRoles = array_filter($roles, function ($role) use ($roleName) {
                return $role['name'] === $roleName;
            });
            if (empty($filteredRoles)) {
                throw new \Exception("Role '{$roleName}' not found in Keycloak");
            }

            $role = reset($filteredRoles);

            $this->client->post('/admin/realms/microservices/users/' . $userId . '/role-mappings/realm', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json',
                ],
                'json' => [  // Debe estar aquí, fuera de headers
                    [
                        'id' => $role['id'],
                        'name' => $role['name']
                    ]
                ]
            ]);

        return $userId;

        } catch(ClientException $e){
            throw new \Exception('Error assingate rol: ' . $e->getMessage());
        }
    }

    public function get_body_create_user($data): array
    {
        return [
                'username' => $data->username,
                'enabled' => true,
                'credentials' => [
                    [
                        'type' => 'password',
                        'value' => $data->password,
                        'temporary' => false
                    ]
                ],
                'firstName' => $data->firstName ?? '',
                'lastName' => $data->lastName ?? '',
                'email' => $data->email
        ];
    }


    public function getKeycloakUser(): string
    {
        return $this->tokens["keycloak_user"] ?: '';
    }

    public function getKeycloakPassword(): string
    {
        return $this->tokens["keycloak_pass"] ?: '';
    }

    public function getKeycloakUrl(): string
    {
        return $this->tokens['url_keycloak'] ?: '';
    }
}


?>