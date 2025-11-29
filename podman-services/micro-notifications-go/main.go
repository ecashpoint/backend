package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type WelcomeEmailRequest struct {
	Email    string `json:"email"`
	Nombre   string `json:"nombre"`
	Apellido string `json:"apellido"`
}

type EmailService struct {
	smtpHost     string
	smtpPort     string
	smtpUser     string
	smtpPassword string
	smtpFrom     string
}

func NewEmailService() *EmailService {
	return &EmailService{
		smtpHost:     getEnv("SMTP_HOST", "smtp.gmail.com"),
		smtpPort:     getEnv("SMTP_PORT", "587"),
		smtpUser:     getEnv("SMTP_USER", ""),
		smtpPassword: getEnv("SMTP_PASSWORD", ""),
		smtpFrom:     getEnv("SMTP_FROM", "noreply@tuempresa.com"),
	}
}

func (es *EmailService) SendWelcomeEmail(req WelcomeEmailRequest) error {
	// Simular procesamiento asíncrono
	go func() {
		log.Printf("Procesando email de bienvenida para: %s", req.Email)
		
		// Renderizar plantilla HTML
		htmlBody := es.renderWelcomeTemplate(req)
		
		// Enviar email
		err := es.sendEmail(req.Email, "¡Bienvenido a nuestra plataforma!", htmlBody)
		if err != nil {
			log.Printf("Error enviando email a %s: %v", req.Email, err)
			// Aquí podrías implementar reintentos o cola de fallos
		} else {
			log.Printf("Email de bienvenida enviado exitosamente a: %s", req.Email)
		}
	}()
	
	return nil
}

func (es *EmailService) renderWelcomeTemplate(req WelcomeEmailRequest) string {
	return fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }
        .footer { text-align: center; margin-top: 30px; color: #777; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>¡Bienvenido, %s!</h1>
        </div>
        <div class="content">
            <h2>Hola %s %s,</h2>
            <p>Estamos emocionados de tenerte con nosotros. Tu cuenta ha sido creada exitosamente.</p>
            <p>Ahora puedes comenzar a disfrutar de todos nuestros servicios y beneficios exclusivos.</p>
            <a href="https://tuempresa.com/dashboard" class="button">Comenzar Ahora</a>
            <p style="margin-top: 30px;">Si tienes alguna pregunta, no dudes en contactarnos.</p>
        </div>
        <div class="footer">
            <p>&copy; 2024 Tu Empresa. Todos los derechos reservados.</p>
            <p>Este es un email automático, por favor no respondas a este mensaje.</p>
        </div>
    </div>
</body>
</html>
`, req.Nombre, req.Nombre, req.Apellido)
}

func (es *EmailService) sendEmail(to, subject, htmlBody string) error {
	// Importar gopkg.in/gomail.v2 en producción
	// Por ahora simulamos el envío
	time.Sleep(100 * time.Millisecond) // Simular latencia de SMTP
	
	log.Printf("Email enviado a: %s, Asunto: %s", to, subject)
	
	// Código real con gomail:
	/*
	m := gomail.NewMessage()
	m.SetHeader("From", es.smtpFrom)
	m.SetHeader("To", to)
	m.SetHeader("Subject", subject)
	m.SetBody("text/html", htmlBody)

	d := gomail.NewDialer(es.smtpHost, 587, es.smtpUser, es.smtpPassword)
	d.TLSConfig = &tls.Config{InsecureSkipVerify: false}

	if err := d.DialAndSend(m); err != nil {
		return err
	}
	*/
	
	return nil
}

func handleWelcomeEmail(es *EmailService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var req WelcomeEmailRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			log.Printf("Error decodificando request: %v", err)
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		// Validación básica
		if req.Email == "" || req.Nombre == "" {
			http.Error(w, "Email y nombre son requeridos", http.StatusBadRequest)
			return
		}

		// Enviar email de forma asíncrona (no esperamos respuesta)
		if err := es.SendWelcomeEmail(req); err != nil {
			log.Printf("Error procesando email: %v", err)
		}

		// Responder inmediatamente con 202 Accepted
		w.WriteHeader(http.StatusAccepted)
		json.NewEncoder(w).Encode(map[string]string{
			"status":  "accepted",
			"message": "Email de bienvenida en proceso",
		})
	}
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"status": "healthy",
		"service": "notification-service",
	})
}

func loggingMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Printf("-> %s %s", r.Method, r.URL.Path)
		next(w, r)
		log.Printf("<- %s %s (took %v)", r.Method, r.URL.Path, time.Since(start))
	}
}

func main() {
	port := getEnv("PORT", "8082")
	emailService := NewEmailService()

	mux := http.NewServeMux()
	mux.HandleFunc("/api/notifications/welcome", loggingMiddleware(handleWelcomeEmail(emailService)))
	mux.HandleFunc("/health", healthCheck)

	log.Printf("🚀 Notification Service iniciado en puerto %s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}