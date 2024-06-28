output "jenkins_url" {
  value = join ("", ["http://", aws_instance.jenkins_server.public_dns, ":", "8080"])
}