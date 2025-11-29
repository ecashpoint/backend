<?php

declare(strict_types=1);

namespace App\Controller\Mail;

use App\Service\SendMailService;
use Pimple\Psr11\Container;

abstract class Base{

    protected Container $container;

    public function __construct(Container $container)
    {
        $this->container = $container;
    }

    protected function getSendMailService()
    {
            return $this->container->get('sendMailService');
    }
}

?>