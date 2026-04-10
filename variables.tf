# Massdriver Variables

variable "md_metadata" {
  type        = any
  description = "Massdriver metadata object, must include name_prefix."
}

variable "message" {
  type        = string
  description = "Message to include in the alarm description."
}

variable "sns_topic_arn" {
  type        = string
  description = "Massdriver alarm channel SNS topic ARN."
}

variable "display_name" {
  type        = string
  description = "Short name to display in the Massdriver UI."
}

# Alarm Configuration

variable "alarm_name" {
  type        = string
  description = "The descriptive name for the alarm. Must be unique within the AWS account."
}

variable "comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified statistic and threshold. Valid values: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold."
}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "threshold" {
  type        = number
  description = "The value against which the specified statistic is compared."
}

# Simple Metric Mode
# Set these for a standard CloudWatch alarm on a single metric.
# Conflicts with metric_queries.

variable "metric_name" {
  type        = string
  default     = null
  description = "The name for the alarm's associated metric. Required for simple metric alarms, conflicts with metric_queries."
}

variable "namespace" {
  type        = string
  default     = null
  description = "The namespace for the alarm's associated metric. Required when metric_name is set."
}

variable "period" {
  type        = number
  default     = null
  description = "The period in seconds over which the specified statistic is applied. Required when metric_name is set."
}

variable "statistic" {
  type        = string
  default     = null
  description = "The statistic to apply to the alarm's associated metric. Valid values: SampleCount, Average, Sum, Minimum, Maximum. Required when metric_name is set, conflicts with extended_statistic."
}

variable "dimensions" {
  type        = map(string)
  default     = null
  description = "The dimensions for the alarm's associated metric."
}

# Expression Mode
# Set these for an alarm based on a metric math expression.
# Conflicts with metric_name, namespace, period, and statistic.

variable "metric_queries" {
  type = map(object({
    expression  = optional(string)
    label       = optional(string)
    return_data = optional(bool)
    metric = optional(object({
      metric_name = string
      namespace   = string
      period      = number
      stat        = string
      unit        = optional(string)
      dimensions  = optional(map(string))
    }))
  }))
  default     = null
  description = "Map of metric query ID to metric query config for expression-based alarms. Conflicts with metric_name, namespace, period, and statistic. See the aws_cloudwatch_metric_alarm docs for the metric_query structure."
}

variable "display_metric_key" {
  type        = string
  default     = null
  description = "Required when using metric_queries. The key in metric_queries whose metric should be displayed in the Massdriver UI."
}
