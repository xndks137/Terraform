# 서비스 역할 생성
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project_name}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# 파이프라인 정책
resource "aws_iam_role_policy" "pipeline_policy" {
  name = "${var.project_name}-pipeline-policy"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "devicefarm:ListProjects",
          "devicefarm:ListDevicePools",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:CreateUpload",
          "devicefarm:ScheduleRun"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudformation:ValidateTemplate"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ecr:DescribeImages"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codepipeline/${var.project_name}",
          "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codepipeline/${var.project_name}:log-stream:*"
        ]
      }
    ]
  })
}

# 아티팩트 저장을 위한 S3 버킷
resource "aws_s3_bucket" "artifact_store" {
  bucket        = "${var.project_name}-artifact-store-${random_string.suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 랜덤 문자열 생성 (S3 버킷 이름 충돌 방지)
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# GitHub 연결
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project_name}-github-connection"
  provider_type = "GitHub"
}

# CodeBuild 프로젝트
resource "aws_codebuild_project" "docker_build" {
  name         = "${var.project_name}-docker-build"
  description  = "Docker build project for ${var.project_name}"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.account_id
    }

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_name}"
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.container_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.buildspec_path)
  }
}

# CodeBuild 역할
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# CodeBuild 정책
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:*",
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Pipeline
resource "aws_codepipeline" "pipeline" {
  name          = "${var.project_name}-pipeline"
  pipeline_type = "V2"
  role_arn      = aws_iam_role.pipeline_role.arn
  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        tags {
          includes = ["stable-*"]
        }
      }
    }
  }
  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = var.github_repo_name
        BranchName           = var.github_branch_name
        DetectChanges        = true
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.docker_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
