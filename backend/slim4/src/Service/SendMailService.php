<?php
declare(strict_types=1);

namespace App\Service;

final class SendMailService
{
    /**
     * @param array<string, mixed> $data
     * @return array<string, mixed>
     */
    public function mailRegistration(array $data)
    {
        // Simulate sending an email and return a response
        // In a real implementation, you would integrate with an email service here
        $input = json_decode(json_encode($data), true);

        $emailContent = $this->template_registration($input);

        $to = filter_var($input['email'] ?? '', FILTER_VALIDATE_EMAIL);
        if ($to === false) {
           throw new \InvalidArgumentException('Invalid email address provided.');
        }       
        $headers = "MIME-Version: 1.0" . "\r\n";
        $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
        $headers .= "From: no-reply@ecashpoint.de" . "\r\n";
        $headers .= "Reply-To: no-reply@ecashpoint.de" . "\r\n";
        $headers .= "X-Mailer: PHP/" . phpversion();
    
        $sent = mail($to, "Welcome to Our Service", $emailContent, $headers);
    }

    public function template_registration( $input): string
    {
        // Simulate generating an email template for registration
        // In a real implementation, you would create a proper HTML email template here

        return "<html><body><h1>Welcome, " . htmlspecialchars($input["name"] ?? 'User') . "!</h1><p>Thank you for registering.</p></body></html>";
    }
}