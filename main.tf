locals {
  is_expression = var.metric_queries != null

  # Resolve display values for massdriver_package_alarm based on alarm mode
  display_metric_name = local.is_expression ? var.metric_queries[var.display_metric_key].metric.metric_name : var.metric_name
  display_namespace   = local.is_expression ? var.metric_queries[var.display_metric_key].metric.namespace : var.namespace
  display_statistic   = local.is_expression ? try(var.metric_queries[var.display_metric_key].metric.stat, null) : var.statistic
  display_dimensions  = local.is_expression ? try(var.metric_queries[var.display_metric_key].metric.dimensions, {}) : coalesce(var.dimensions, {})
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name = var.alarm_name

  # Smuggle name_prefix back to Massdriver so alarms appear on the correct manifest in the UI
  alarm_description = jsonencode({
    name_prefix = var.md_metadata.name_prefix
    message     = var.message
  })

  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  threshold           = var.threshold

  # Simple metric mode — these are null (omitted) when using metric_queries
  metric_name = var.metric_name
  namespace   = var.namespace
  period      = var.period
  statistic   = var.statistic
  dimensions  = var.dimensions

  # Expression mode
  dynamic "metric_query" {
    for_each = local.is_expression ? var.metric_queries : {}
    content {
      id          = metric_query.key
      expression  = try(metric_query.value.expression, null)
      label       = metric_query.value.label
      return_data = metric_query.value.return_data

      dynamic "metric" {
        for_each = metric_query.value.metric != null ? toset(["metric"]) : toset([])
        content {
          metric_name = metric_query.value.metric.metric_name
          namespace   = metric_query.value.metric.namespace
          period      = metric_query.value.metric.period
          stat        = try(metric_query.value.metric.stat, null)
          unit        = try(metric_query.value.metric.unit, null)
          dimensions  = try(metric_query.value.metric.dimensions, {})
        }
      }
    }
  }

  actions_enabled = true
  alarm_actions   = [var.sns_topic_arn]
  ok_actions      = [var.sns_topic_arn]

  lifecycle {
    precondition {
      condition     = (var.metric_queries != null) != (var.metric_name != null)
      error_message = "Specify either metric_queries (for expression-based alarms) or metric_name (for simple metric alarms), but not both and not neither."
    }
    precondition {
      condition     = var.metric_name == null || (var.namespace != null && var.period != null && var.statistic != null)
      error_message = "When metric_name is set, namespace, period, and statistic are also required."
    }
    precondition {
      condition     = var.metric_queries == null || (var.metric_name == null && var.namespace == null && var.period == null && var.statistic == null)
      error_message = "When metric_queries is set, do not set metric_name, namespace, period, or statistic."
    }
    precondition {
      condition     = var.metric_queries == null || var.display_metric_key != null
      error_message = "display_metric_key is required when using metric_queries."
    }
  }
}

resource "massdriver_package_alarm" "package_alarm" {
  display_name      = var.display_name
  cloud_resource_id = aws_cloudwatch_metric_alarm.alarm.arn
  metric {
    name       = local.display_metric_name
    namespace  = local.display_namespace
    statistic  = local.display_statistic
    dimensions = local.display_dimensions
  }
}
