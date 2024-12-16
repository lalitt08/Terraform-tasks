output "vpcid" {
    value       = aws_vpc.Myvpc.id
}
output "publicsubnetid" {
    value       = aws_subnet.Publicsubnet1.id
}
output "publicsubnet2id" {
    value       = aws_subnet.Publicsubnet2.id
}
output "privatesubnet1id" {
    value       = aws_subnet.Privatesubnet1.id
}
output "privatesubnet2id" {
    value       = aws_subnet.Privatesubnet2.id
}
output "frontendsecurity" {
    value       = aws_security_group.frontendCG.id
}
output "backendsecurity" {
    value       = aws_security_group.backendCG.id
}
output "databasesecurity" {
    value       = aws_security_group.databaseCG.id
}
output "frontendec2" {
    value       = aws_instance.frontend_instance.id
}
output "backendec2" {
    value       = aws_instance.backend_instance.id
}
output "databaseec2" {
    value       = aws_instance.database_instance.id
}
output "frontendautoscalling" {
    value       = aws_autoscaling_group.frontendASG.id
}
output "backendautoscalling" {
    value       = aws_autoscaling_group.backendASG.id
}