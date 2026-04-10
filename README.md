# AWS Metric Alarm Terraform module

Terraform module that creates a [Massdriver](https://www.massdriver.cloud/)-integrated AWS CloudWatch metric alarm. Supports both simple metric alarms and metric math expression-based alarms in a single module.

This module is designed to be used alongside [`terraform-massdriver-aws-alarm-channel`](https://github.com/massdriver-cloud/terraform-massdriver-aws-alarm-channel), which creates the SNS topic that alarm notifications are published to.

## Features

- Creates a CloudWatch metric alarm with SNS actions for alarm and OK states
- Supports simple single-metric alarms (`metric_name`, `namespace`, `period`, `statistic`)
- Supports metric math expression alarms (`metric_queries`) for complex multi-metric conditions
- Validates inputs at plan time to enforce mutual exclusivity between the two modes
- Registers the alarm with Massdriver for UI visibility via `massdriver_package_alarm`

## Usage

### Simple metric alarm

```hcl
module "alarm_channel" {
  source = "massdriver-cloud/aws-alarm-channel/massdriver"

  md_metadata = var.md_metadata
}

module "cpu_alarm" {
  source = "massdriver-cloud/aws-metric-alarm/massdriver"

  alarm_name   = "${var.md_metadata.name_prefix}-cpu-high"
  display_name = "CPU High"
  message      = "CPU utilization exceeded threshold"

  sns_topic_arn = module.alarm_channel.sns_topic_arn
  md_metadata   = var.md_metadata

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 80

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"
  period      = 300
  statistic   = "Average"
  dimensions  = { InstanceId = "i-0123456789abcdef0" }
}
```

### Expression-based alarm

```hcl
module "error_rate_alarm" {
  source = "massdriver-cloud/aws-metric-alarm/massdriver"

  alarm_name   = "${var.md_metadata.name_prefix}-error-rate"
  display_name = "Error Rate"
  message      = "Error rate exceeded threshold"

  sns_topic_arn = module.alarm_channel.sns_topic_arn
  md_metadata   = var.md_metadata

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = 5

  display_metric_key = "errors"
  metric_queries = {
    errors = {
      expression  = "(error_count / request_count) * 100"
      label       = "Error Rate"
      return_data = true
    }
    error_count = {
      label = "Errors"
      metric = {
        metric_name = "5XXError"
        namespace   = "AWS/ApiGateway"
        period      = 300
        stat        = "Sum"
        dimensions  = { ApiName = "my-api" }
      }
    }
    request_count = {
      label = "Requests"
      metric = {
        metric_name = "Count"
        namespace   = "AWS/ApiGateway"
        period      = 300
        stat        = "Sum"
        dimensions  = { ApiName = "my-api" }
      }
    }
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.40.0 |
| <a name="provider_massdriver"></a> [massdriver](#provider\_massdriver) | 1.3.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [massdriver_package_alarm.package_alarm](https://registry.terraform.io/providers/massdriver-cloud/massdriver/latest/docs/resources/package_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_name"></a> [alarm\_name](#input\_alarm\_name) | The descriptive name for the alarm. Must be unique within the AWS account. | `string` | n/a | yes |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | The arithmetic operation to use when comparing the specified statistic and threshold. Valid values: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold. | `string` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | The dimensions for the alarm's associated metric. | `map(string)` | `null` | no |
| <a name="input_display_metric_key"></a> [display\_metric\_key](#input\_display\_metric\_key) | Required when using metric\_queries. The key in metric\_queries whose metric should be displayed in the Massdriver UI. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Short name to display in the Massdriver UI. | `string` | n/a | yes |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold. | `number` | n/a | yes |
| <a name="input_md_metadata"></a> [md\_metadata](#input\_md\_metadata) | Massdriver metadata object, must include name\_prefix. | `any` | n/a | yes |
| <a name="input_message"></a> [message](#input\_message) | Message to include in the alarm description. | `string` | n/a | yes |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | The name for the alarm's associated metric. Required for simple metric alarms, conflicts with metric\_queries. | `string` | `null` | no |
| <a name="input_metric_queries"></a> [metric\_queries](#input\_metric\_queries) | Map of metric query ID to metric query config for expression-based alarms. Conflicts with metric\_name, namespace, period, and statistic. See the aws\_cloudwatch\_metric\_alarm docs for the metric\_query structure. | <pre>map(object({<br>    expression  = optional(string)<br>    label       = optional(string)<br>    return_data = optional(bool)<br>    metric = optional(object({<br>      metric_name = string<br>      namespace   = string<br>      period      = number<br>      stat        = string<br>      unit        = optional(string)<br>      dimensions  = optional(map(string))<br>    }))<br>  }))</pre> | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for the alarm's associated metric. Required when metric\_name is set. | `string` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the specified statistic is applied. Required when metric\_name is set. | `number` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | Massdriver alarm channel SNS topic ARN. | `string` | n/a | yes |
| <a name="input_statistic"></a> [statistic](#input\_statistic) | The statistic to apply to the alarm's associated metric. Valid values: SampleCount, Average, Sum, Minimum, Maximum. Required when metric\_name is set, conflicts with extended\_statistic. | `string` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | The value against which the specified statistic is compared. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_metric_alarm_arn"></a> [cloudwatch\_metric\_alarm\_arn](#output\_cloudwatch\_metric\_alarm\_arn) | The ARN of the CloudWatch metric alarm. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Massdriver, Inc.](https://www.massdriver.cloud/)

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.
