# Auditor Challenge Q&A: IAM Cross-Account Governance
**GRC Domain:** Identity & Access Management  
**Framework Mapping:** ISO 27001 A.9, SOC 2 CC6.1, CIS AWS 1.x  

---

### Q1: What is the "Confused Deputy" problem in AWS cross-account role assumption, and how does your Terraform policy prevent it?
**Answer:** The Confused Deputy problem occurs when a third-party vendor (the deputy) that has cross-account access to multiple AWS clients is tricked by Attacker A into using its access role to read Client B's private AWS resources. In our `main.tf`, we enforce a mandatory `sts:ExternalId` condition block. The vendor must pass a unique, secret UUID specific to ApexPay when calling `sts:AssumeRole`. Because Attacker A does not know ApexPay's secret `ExternalId`, the AWS STS service rejects unauthorized cross-tenant role assumptions.

---

### Q2: How do you enforce least privilege when developers request administrator access to debug production issues?
**Answer:** We do not grant static `AdministratorAccess` to individual user accounts. Instead:
1. Developers operate with Read-Only permissions in production.
2. Temporary elevated access requires invoking our **Break-Glass Emergency Access Role** (Project 06) with ticket-backed justification and MFA.
3. Access automatically expires after 1 hour, and all actions are logged to an immutable CloudTrail bucket.
