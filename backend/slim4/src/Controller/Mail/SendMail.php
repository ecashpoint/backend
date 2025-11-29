<?php

declare(strict_types=1);

namespace   App\Controller\Mail;
use App\CustomResponse as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

final class SendMail extends Base
{
    /**
     * @param array<string> $args
     */
    public function __invoke(
        Request $request,
        Response $response,
        array $args
    ): Response {
        $data = (array) $request->getParsedBody();

         $this->getSendMailService()->mailRegistration($data);

        return $response->withJson("");
    }
}


?>