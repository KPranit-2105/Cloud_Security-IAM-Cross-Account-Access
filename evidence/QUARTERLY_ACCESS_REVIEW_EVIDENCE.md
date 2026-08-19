# Evidence Item EVD-IAM-01: Quarterly Access Review Log
**Review Cycle:** Q2 2026  
**Review Date:** July 1, 2026  
**Reviewer:** Lead GRC Analyst / IAM Governance Committee  
**Classification:** **SIMULATED EVIDENCE FOR PORTFOLIO DEMONSTRATION**  

---

## Access Recertification Matrix

| IAM Principal | Account ID / Type | Last Active Date | Access Granted | Recertification Decision | Manager Sign-off | Action Taken |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `dev-jdoe` | Prod User | 2026-06-28 | `AdministratorAccess` | **REJECTED (Overprivileged)** | Jane Smith (Dev Manager) | Revoked Admin policy; assigned `Dev-ReadOnly-Policy`. |
| `apexpay-sec-auditor` | Cross-Account Role | 2026-06-30 | `SecurityAudit` | **APPROVED** | Alex Vance (CISO) | Retained with `ExternalId` condition. |
| `temp-contractor-01` | Prod User | 2026-03-12 (>90 Days) | `PowerUserAccess` | **REVOKED (Inactive)** | Mark Davis (Ops Lead) | User account disabled and access keys deleted. |
