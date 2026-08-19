# Organization Policy: Identity & Access Management Governance
**Policy ID:** POL-SEC-IAM-01  
**Organization:** Apex Cloud Financial Systems (ApexPay)  
**Standard Mapping:** ISO 27001:2022 A.9, NIST SP 800-53 AC-2 / AC-6, PCI-DSS v4.0 Requirement 7  

---

## 1. Governance Requirements
1. **Least Privilege Enforcement:** IAM permissions must be tailored specifically to required job duties. Wildcard permissions (`"Action": "*"`) in production account policies are strictly prohibited.
2. **Mandatory Multi-Factor Authentication (MFA):** Interactive console logins and cross-account privileged role assumptions must mandate hardware/software MFA enforcement.
3. **Cross-Account Trust Protection:** All cross-account IAM role trust policies assumed by external vendor or secondary account principals **MUST** incorporate a non-guessable `sts:ExternalId` condition to prevent Confused Deputy attacks.
4. **Quarterly Access Recertification:** Access permissions, active API keys, and IAM role memberships must be recertified quarterly by application owners. Unused access (>90 days) will be automatically revoked.
