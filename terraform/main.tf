# Terraform Cross-Account IAM Role Governance
# Organization: Apex Cloud Financial Systems (ApexPay)
# Security Control: Least Privilege & ExternalId Trust Enforcement

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "security_account_id" {
  type        = string
  description = "AWS Account ID of the centralized Security Audit Account"
  default     = "987654321098"
}

variable "external_id" {
  type        = string
  description = "Unique External ID for Third-Party / Security Cross-Account Assumption"
  default     = "ApexPay-SecAudit-ExtID-2026-v1"
}

# Cross-Account ReadOnly Security Audit Role in Production Account
resource "aws_iam_role" "cross_account_auditor" {
  name = "ApexPay-CrossAccount-SecurityAuditor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.security_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

# Attach SecurityAudit Managed Policy
resource "aws_iam_role_policy_attachment" "security_audit_attach" {
  role       = aws_iam_role.cross_account_auditor.name
  policy_arn = "arn:aws:policy/SecurityAudit"
}
