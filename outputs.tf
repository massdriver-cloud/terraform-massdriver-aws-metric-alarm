output "cloudwatch_metric_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.alarm.arn
  description = "The ARN of the CloudWatch metric alarm."
}
