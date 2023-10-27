{
    "StartAt": "glue-task",
    "States": {
      "glue-task": {
        "Next": "postupdate-task",
        "Retry": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "MaxAttempts": 1
          }
        ],
        "Catch": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "ResultPath": "$.ErrorMessage",
            "Next": "error-task"
          }
        ],
        "Type": "Task",
        "ResultPath": null,
        "Resource": "arn:aws:states:::glue:startJobRun.sync",
        "Parameters": {
          "JobName": "glue_uw1_da099_mfgottestperm_standardization_ddkdatadev",
          "Arguments": {
            "--DATASET.$": "$.body.dataset",
            "--PEH_ID.$": "$.body.peh_id",
            "--SOURCE_TYPE": "flat_file_json",
            "--SOURCE_LOCATIONS_LIST_S3_LOC.$": "$.body.source_locations_list_s3_loc",
            "--SOURCE_APP_PREPROCESS": "N",
            "--SOURCE_APP_PREPROCESS_TYPE": "NA",
            "--SOURCE_APP_POSTPROCESS": "N",
            "--SOURCE_APP_POSTPROCESS_TYPE": "N",
            "--SOURCE_DATA_QUALITY": "N",
            "--SOURCE_FILE_COMPRESSION": "N",
            "--SOURCE_FILE_FORMAT": "ndjson",
            "--SOURCE_FILE_DELIMITER": "",
            "--SOURCE_INFER_SCHEMA": "Y",
            "--USE_SQS": "N",
            "--DATASET_LEVEL": "2",
            "--TARGET_LOCATION": "s3a://ddkdatadev-****-poc-standardized-usw1/mfg_ot_test_perm/",
            "--TARGET_FILE_FORMAT": "parquet",
            "--TARGET_PARTITION_KEY": "N",
            "--TARGET_PRIMARY_KEY": "",
            "--TARGET_APPEND_FLAG": "N",
            "--TARGET_CATALOG_DB_NAME": "ddk_ot_test_perm_stdd_data",
            "--DATA_PIPELINE_JOB_ID": "da099",
            "--SCHEDULE_TYPE": "time_based",
            "--SCHEDULE_MIN": "15",
            "--FILE_BATCH_SIZE": "5000",
            "--MAX_SFN_INVOCATIONS": "1",
            "--ENVIRONMENT": "QAS",
            "--APPLICATION": "POC",
            "--DIVISION": "Shared Services",
            "--PROJECT_ID": "ddkdatadev",
            "--BUSINESS_OWNER": "",
            "--L1_TECHNICAL_OWNER": "mureddy@amazon.com",
            "--COST_CENTER": "",
            "--FUNCTIONS": "POC",
            "--conf": "spark.hadoop.fs.s3a.server-side-encryption-algorithm=AES256"
          },
          "Timeout": 60,
          "NotificationProperty": {
            "NotifyDelayAfter": 5
          }
        }
      },
      "postupdate-task": {
        "Next": "crawl-task",
        "Retry": [
          {
            "ErrorEquals": [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException"
            ],
            "IntervalSeconds": 2,
            "MaxAttempts": 6,
            "BackoffRate": 2
          }
        ],
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "arn:aws:lambda:us-west-1:****:function:lambda_uw1_da099_mfgottestperm_postupdate_ddkdatadev",
          "Payload": {
            "body.$": "$.body",
            "status": "COMPLETED"
          }
        }
      },
      "crawl-task": {
        "Next": "success",
        "Catch": [
          {
            "ErrorEquals": [
              "Glue.CrawlerRunningException"
            ],
            "ResultPath": null,
            "Next": "success"
          }
        ],
        "Type": "Task",
        "ResultPath": null,
        "Resource": "arn:aws:states:::aws-sdk:glue:startCrawler",
        "Parameters": {
          "Name": "crawl_uw1_da099_mfgottestperm_standardization_ddkdatadev"
        }
      },
      "success": {
        "Type": "Succeed"
      },
      "error-task": {
        "Next": "error-notification",
        "Retry": [
          {
            "ErrorEquals": [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException"
            ],
            "IntervalSeconds": 2,
            "MaxAttempts": 6,
            "BackoffRate": 2
          }
        ],
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "arn:aws:lambda:us-west-1:****:function:lambda_uw1_da099_mfgottestperm_postupdate_ddkdatadev",
          "Payload": {
            "body.$": "$.body",
            "error.$": "States.StringToJson($.ErrorMessage.Cause)",
            "status": "FAILED"
          }
        }
      },
      "error-notification": {
        "Next": "failed",
        "Type": "Task",
        "Resource": "arn:aws:states:::sns:publish",
        "Parameters": {
          "TopicArn": "arn:aws:sns:us-west-1:****:sns_uw1_da099_mfgottestperm_failures_ddkdatadev",
          "Message": {
            "ErrorMessage.$": "$.Payload.error.ErrorMessage",
            "PipelineExecution.$": "$.Payload.body.peh_id",
            "Environment.$": "$.Payload.body.environment"
          }
        }
      },
      "failed": {
        "Type": "Fail"
      }
    }
  }
