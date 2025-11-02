output "web_url" {
  value       = "http://${aws_instance.web.public_ip}"
  description = "Public URL of the Nginx server"
}
