<?php

declare(strict_types=1);

namespace App\Service;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

final class KongGatewayService
{
    private array $tokens;

    private Client $client;

    public function __construct()
    {
        $this->tokens = array(
            'gateway_url' => $_SERVER['GATEWAY_URL']
        );
        $this->init();
    }

    public function init(): void
    {
        $this->client = new Client([
            'base_uri' => $this->getGatewayUrl(),
            'timeout'  => 10.0,
        ]);
    }

    

    public function createUserKong(object $user, string $id_user , string $accessToken)
    {
        try{
            $response = $this->client->post('/api/users_data', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $accessToken,
                    'Content-Type' => 'application/json'
                ],
                'json' => [
                    'father' => $user->father ?? 'CASH',
                    'authId' => $id_user,
                    'email' => $user->email,
                    'firstName' => $user->firstName,
                    'lastName' => $user->lastName,
                    'indicative' => $user->indicative,
                    'phone' => $user->phone,
                    'document' => $user->document,
                    'dv' => $user->dv
                ]
            ]);
            $data = json_decode($response->getBody()->getContents(), true);
            return $data;
        }catch(ClientException $e){
            throw new \Exception('Error creating Kong user: ' . $e->getMessage());
        }
    }

    public function getGatewayUrl(): string
    {
        return $this->tokens['gateway_url'];
    }
}