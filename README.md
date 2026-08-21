<div align="center">

# 🔑 IAM Cross-Account Access & Identity Governance

**Least Privilege · Trust Policies · Multi-Account Identity Architecture**

![Status](https://img.shields.io/badge/status-portfolio_case_study-blue)
![Domain](https://img.shields.io/badge/domain-IAM%20Governance-informational)
![Framework](https://img.shields.io/badge/frameworks-ISO%2027001%20A.9%20%7C%20NIST%20800--53%20AC--2%2FAC--6%20%7C%20CIS%20AWS%201.x-success)

*A fictional GRC case study simulating cross-account identity governance for a cloud payment processor.*

</div>

---

## 📌 At a Glance

| | |
|---|---|
| **GRC Domain** | Identity & Access Management Governance, Least Privilege, Trust Policies |
| **Role Simulated** | IAM Security Specialist / GRC Governance Analyst |
| **Frameworks Mapped** | ISO 27001 A.9 · NIST SP 800-53 AC-2/AC-6 · CIS AWS Benchmark 1.x |
| **Scenario** | *Apex Cloud Financial Systems (ApexPay)* — Cross-Account Governance |
| **Project Type** | Fictional Portfolio Case Study |

### 📂 Key Deliverables

| Deliverable | Description | Link |
|---|---|---|
| 🏗️ IAM Governance (Terraform) | Cross-account role infrastructure | [`terraform/main.tf`](./terraform/main.tf) |
| 📋 IAM Policy Governance Standard | Trust policy & least-privilege standard | [`docs/iam_governance_policy.md`](./docs/iam_governance_policy.md) |
| 🔎 Quarterly Access Review Evidence | Access recertification artifacts | [`evidence/QUARTERLY_ACCESS_REVIEW_EVIDENCE.md`](./evidence/QUARTERLY_ACCESS_REVIEW_EVIDENCE.md) |
| 💬 Auditor Challenge Q&A | Defends design decisions under scrutiny | [`docs/auditor_qa_iam.md`](./docs/auditor_qa_iam.md) |

---

## 🎯 Overview

IAM is not a beginner topic — which is exactly why it's such a strong portfolio signal. Real organizations are multi-account by default. This project implements **cross-account access the way it's actually done in production**: temporary credentials, scoped trust policies, and an audit trail for every assumption — never a shared long-lived key.

---

## 🏗️ Architecture Diagram

<p align="center">
  <img src="new add/org_architecture.svg" alt="ApexPay AWS Organization Cross-Account Architecture" width="850">
</p>

| Account | Purpose |
|---|---|
| **Security / Admin** (`111111111111`) | Central hub — where security engineers authenticate and assume roles into other accounts |
| **Workload** (`222222222222`) | Production/application environment, holds `SecurityAuditRole` |
| **Logging** (`333333333333`) | Dedicated log archive (see Project 5), holds `LogArchiveRole` |
| **Dev/Test** (`444444444444`) | Lower environment, holds `DevAccessRole` |

---

## 🔄 The Role Assumption Flow

<p align="center">
  <img src="new add/role_assumption_flow.svg" alt="Cross-Account Role Assumption Sequence Diagram" width="850">
</p>

1. User/role authenticates in the Security Account **with MFA**
2. Calls `sts:AssumeRole` with a Role ARN, ExternalId, and session name
3. The Workload Account's trust policy evaluates the request — checking account, ExternalId, and MFA presence
4. Temporary credentials are issued
5. Credentials are used for up to **1 hour**, then expire automatically

---

## 🧩 Roles Implemented

| Role | Purpose | Permissions | Trust |
|---|---|---|---|
| `SecurityAuditRole` | Read-only security review | `SecurityAudit`, `ViewOnly` | Security Account only |
| `IncidentResponseRole` | Active incident handling | EC2, VPC, IAM read + limited write | Security Account + MFA |
| `DeploymentRole` | CI/CD deployments | Scoped to specific services | CI/CD pipeline role only |

---

## 🛠️ Implementation Steps

### Step 1 — The Trust Relationship

Every trust policy explicitly names **who** can assume the role and **under what conditions** — no wildcards, no implicit trust.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111111111111:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "UniqueSecretValue"
        },
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
```

> `ExternalId` closes the [confused-deputy problem](https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html); the MFA condition means a leaked credential alone still isn't enough to assume the role.

### Step 2 — The Permission Policy (Least Privilege)

| ❌ Overprivileged | ✅ Least Privilege |
|---|---|
| `"Action": "ec2:*"`, `"Resource": "*"` | `"Action": ["ec2:DescribeInstances", "ec2:DescribeVpcs", "ec2:DescribeSubnets"]`, `"Resource": "*"` |

Scope to exactly the API calls the role needs to do its job — nothing broader "just in case."

### Step 3 — The Assuming Role's Permission

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::222222222222:role/SecurityAuditRole",
        "arn:aws:iam::333333333333:role/LogArchiveRole"
      ]
    }
  ]
}
```

> Roles are **explicitly enumerated** in `Resource` — never a wildcard. If a new role needs to be assumable, it gets added deliberately, not inherited by accident.

---

## ⚖️ Why Role Assumption Over Long-Lived Credentials?

| | Long-Lived Keys | Role Assumption |
|---|---|---|
| Expiration | ❌ Never expire | ✅ Temporary (1–12 hours) |
| Rotation | ❌ Manual | ✅ Automatic |
| Auditability | ❌ Hard to trace | ✅ Every assumption logged in CloudTrail |
| MFA | ❌ Not supported | ✅ Can be required as a condition |
| Secrets management | ❌ Shared secrets to protect | ✅ Nothing to leak — credentials are ephemeral |

---

## 📈 How Would This Scale?

<p align="center">
  <img src="new add/scaling_ous.svg" alt="Scaling Cross-Account Access with AWS Organizations OUs" width="850">
</p>

At scale — 20, 100+ accounts — individual role-by-role setup breaks down. The pattern becomes:

- **AWS Organizations** to group accounts into OUs (Prod, Dev, Sandbox)
- **Service Control Policies (SCPs)** to set guardrails no account can override
- **CloudFormation StackSets / Terraform modules** to deploy consistent roles across every account automatically

---

## 🧨 Blast Radius: Why Scoping Matters

<p align="center">
  <img src="new add/blast_radius_comparison.svg" alt="Blast Radius Comparison — Over-Privileged vs Properly Scoped Role" width="900">
</p>

The entire argument for least privilege in one picture: an over-privileged role, once compromised, gives an attacker the keys to the whole account — deletion, exfiltration, backdoors, cross-account pivoting, and log tampering. A properly scoped role gives them almost nothing.

---

## 🔍 Detection: What to Monitor

CloudTrail events worth alerting on:

- `AssumeRole` from unexpected source IPs
- `AssumeRole` failures (possible brute-force attempts)
- Role assumption outside business hours
- Cross-account access from unapproved accounts
- Changes to trust policies

---

## ✅ Deliverables Checklist

- [x] Terraform code for cross-account role setup
- [x] Trust policies with proper conditions
- [x] Permission policies following least privilege
- [x] Documentation explaining design decisions
- [x] Diagram showing account relationships
- [x] Write-up on scaling considerations
- [x] Monitoring/alerting recommendations

---

## ❓ Questions Answered in This Documentation

1. Why role assumption instead of long-lived credentials?
2. How would this scale to 20 or 100 accounts?
3. What risks exist if a role is over-privileged?
4. How would misuse be detected?
5. What happens if the Security Account itself is compromised?

---

## 📚 Further Reading

- [AWS Cross-Account Access](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [The Confused Deputy Problem](https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html)
- [AWS Organizations Best Practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html)

---

<div align="center">

**This project signals maturity.** It shows an understanding of how modern cloud environments are actually structured — and why IAM mistakes are so dangerous.

</div>
