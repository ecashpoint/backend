<?php

declare(strict_types=1);

namespace App\Controller\User;

use App\Service\UserService;
use Pimple\Psr11\Container;

abstract class Base{

    protected Container $container;

    public function __construct(Container $container)
    {
        $this->container = $container;
    }

    protected function getUserService()
    {
            return $this->container->get('userService');
    }
}

?>