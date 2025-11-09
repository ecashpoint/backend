<?php

declare(strict_types=1);

namespace App\Controller\User;

use App\CustomResponse as Response;
use Fig\Http\Message\StatusCodeInterface;
use Psr\Http\Message\ServerRequestInterface as Request;

final class Login extends Base
{
    public function __invoke(Request $request, Response $response): Response
    {
        $input = (array) $request->getParsedBody();

        $access_token = $this->getUserService()->login($input);
        
        return $response->withJson($access_token);
    }
}