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
            'client_id_admin' => $_SERVER['CLIENT_ID_ADMIN']
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

    public function create_user(array $data, string $accessToken)
    {
        try{
            $response = $this->client->post($this->tokens['endpoint_create_user'], [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json',   
                ],
                'json' => $this->get_body_create_user((object)$data)
            ]);
            return json_decode($response->getBody()->getContents(), true);
        }catch(ClientException $e){
            throw new \Exception('Error creating Keycloak user: ' . $e->getMessage());
        }
    }

    public function assignate_role_user($username , $accessToken , $rol)
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
            $responseRole = $this->client->get('/admin/realms/microservices/roles/client', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json'
                        ]]);
            $dataRole = json_decode($responseRole->getBody()->getContents(), true); 
            //buscar por nombre del rol in $dataRole
            $resultado = array_filter($dataRole, function($role) use ($rol) {
                return $role['name'] === $rol;
            });
            $rol= reset($resultado);
            //assign role to user
            $this->client->post('/admin/realms/microservices/users/' . $userId . '/role-mappings/realm', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json',
                'json' => [
                    [
                        'id' => $roleId,
                        'name' => $rol['name']
                    ]
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
                'firstName' => $data->firstName,
                'lastName' => $data->lastName,
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