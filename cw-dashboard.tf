resource "aws_cloudwatch_dashboard" "ecs_memory_dashboard" {
  dashboard_name = "ECSMemoryDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "log_insights",
        x = 0,
        y = 0,
        width = 24,
        height = 6,
        properties = {
          query = "fields @timestamp, @message | parse @message /MemoryUtilized: (?<MemoryUtilized>\\d+), MemoryReserved: (?<MemoryReserved>\\d+), ContainerId: (?<ContainerId>[^\\s]+)/ | filter MemoryUtilized > 0 | filter MemoryReserved > 0 | stats max(MemoryUtilized / MemoryReserved * 100) as MaxMemoryUtilization by bin(5m) | sort @timestamp desc | limit 1",
          region = "us-east-1",
          title = "Max Memory Utilization"
        }
      }
    ]
  })
}
