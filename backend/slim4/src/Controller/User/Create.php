<?php

declare(strict_types=1);

namespace App\Controller\User;

use App\CustomResponse as Response;
use Fig\Http\Message\StatusCodeInterface;
use Psr\Http\Message\ServerRequestInterface as Request;

final class Create extends Base
{
    public function __invoke(Request $request, Response $response): Response
    {
        $input = (array) $request->getParsedBody();

        $create = $this->getUserService()->authenticateUser($input);
        
        return $response->withJson($create);
    }
}