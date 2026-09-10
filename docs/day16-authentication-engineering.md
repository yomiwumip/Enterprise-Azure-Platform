CONTOSO HOLDINGS — DAY 16
Enterprise Authentication Engineering: Entra ID, SAML, OIDC and Okta

Project: Enterprise Azure Platform

Day: 16

Theme: Enterprise Authentication Engineering

Role: Cloud Engineer / IAM Engineer / Platform Engineer / DevOps / SRE

Environment: Microsoft Azure / Microsoft Entra ID / Okta / Terraform / GitHub

Document Type: Engineering runbook and implementation record

Evidence Standard: Verified implementation and session evidence only

1. Production Scenario

Contoso Holdings requires secure enterprise authentication supporting employee authentication, Multifactor Authentication (MFA), Single Sign-On (SSO), Security Assertion Markup Language (SAML), OpenID Connect (OIDC), OAuth 2.0, application authentication, workload authentication, controlled authorization, troubleshooting, monitoring and audit evidence.

Authentication is a critical security boundary. Successful authentication does not automatically grant authorization to every application or Azure resource.

IDENTITY → AUTHENTICATION → AUTHORIZATION → APPLICATION / RESOURCE

2. Activity Tile

Activity Tile: Enterprise Authentication Engineering

Role: Cloud Engineer / IAM Engineer / Platform Engineer / DevOps / SRE

Purpose: Design, configure, troubleshoot and document enterprise authentication using Microsoft Entra ID and Okta.

Change: Configure and validate SAML and OIDC authentication flows, MFA, application assignments, authentication logging and IAM authorization operations.

Why it matters: Authentication controls protect enterprise users, applications and workloads.

Environment: Microsoft Azure, Microsoft Entra ID, Okta, Terraform and GitHub.

Risk / Cost: Controlled test identities and applications were used. No production authentication policy was weakened.

Success Evidence: Entra authentication baseline; MFA inspection; SAML implementation and forensics; OIDC authorization; OAuth 2.0; Okta assignment and logs; IAM ticket resolution; Terraform parity; security review.

Stage: Day 16 Authentication Engineering and IAM Operations.

3. Authentication Architecture

                         ENTERPRISE IDENTITY
                                |
             +------------------+------------------+
             |                                     |
             v                                     v
        ENTRA ID                                  OKTA
             |                                     |
             v                                     v
       AUTHENTICATION                         AUTHENTICATION
             |                                     |
       +-----+-----+                         OIDC / SSO
       |           |
       v           v
      MFA         SSO
       |
       v
 APPLICATIONS / AZURE RESOURCES

Authentication establishes identity. Authorization determines what that identity can access and at what scope.

4. Microsoft Entra Authentication Baseline

Test identity: IAM IaC Test Employee

Object ID: 5dde1c4c-f907-43ba-ac7c-71966d6f6a11

Portal path: Azure Portal → Microsoft Entra ID → Users → IAM IaC Test Employee → Authentication.

Microsoft Authenticator was configured as the usable authentication method.

Microsoft Authenticator notification was observed.

iPhone 14 Pro Max was shown as the usable authentication method.

System-preferred MFA was enabled.

No non-usable authentication methods were observed.

Successful authentication events were observed in Microsoft Entra sign-in logs.

5. Conditional Access

Conditional Access was assessed but could not be implemented because sufficient Microsoft Entra licensing was unavailable.

Status: 🟡 Licensing limitation

This is documented as a limitation, not represented as an implemented control.

6. Single Sign-On

SSO allows an authenticated identity to access an application without independently establishing a separate application credential each time.

User → Identity Provider (IdP) → Authentication → Assertion / Token → Service Provider (SP) → Application Session

7. SAML Implementation

Microsoft Entra SAML test application: CONTOSO-SAML-SSO-TEST

Entity ID: https://samltoolkit.azurewebsites.net

SP-initiated Login URL: https://samltoolkit.azurewebsites.net/SAML/Login/22328

Assertion Consumer Service (ACS) URL: https://samltoolkit.azurewebsites.net/SAML/Consume/22328

Entra Basic SAML configuration was aligned with the toolkit.

The IAM test employee was assigned to the application.

8. SAML Assertion Forensics

Response status: Success

Issuer matched the tenant issuer

Destination matched the registered ACS

InResponseTo was present

XML digital signature was present

RSA-SHA256 signature was observed

X.509 certificate was used

NameID format was emailAddress

NameID aligned with the User Principal Name (UPN)

Audience/conditions were valid

Authentication-related claims were present

The authentication method reference observed was Password. A separate email-address claim was not present because the test user's mail attribute was not populated.

9. Controlled SAML Failure and Recovery

The NameID source was deliberately changed from the working identity identifier to the user's display name. The SAML Toolkit authentication failed. The original configuration was restored and authentication recovered.

Working Authentication → Controlled Change → Failure → Identify Changed Assertion Value → Restore → Recovery

Production lesson: compare the failing assertion with the application's expected identifier before making unrelated changes.

10. SAML Certificate Lifecycle

Verified certificate thumbprint: 94720D74FA38B11832E69D4F5784E128C1CD47ED

Verified expiration: 5 September 2029

Certificate notification email was configured.

Metadata was available.

Production lifecycle should include ownership, expiry monitoring, renewal, rollover and validation.

11. Provisioning, Authentication and SCIM

Authentication answers who the user is. Provisioning determines whether an application account should be created, updated or removed. System for Cross-domain Identity Management (SCIM) provides a standard provisioning mechanism.

Identity Source → Provisioning → Application Account → Authentication → Application Access

The SAML test application reported that automatic provisioning was not supported.

12. SAML versus OIDC

Area

SAML

OIDC

Purpose

Authentication / SSO

Authentication / identity

Format

XML

JSON / JWT

Common use

Enterprise SSO

Modern applications

Authentication result

SAML assertion

ID token

Authorization

Usually separate

OAuth 2.0 access token

13. Entra OIDC Application

Application: CONTOSO-OIDC-TEST

Type: Web; single tenant

Client ID: 5d4a49f8-dd4d-4934-99d0-bf8e1ec98067

Redirect URI: http://localhost:3000/auth/callback

Implicit Access tokens and ID tokens were not enabled.

The authorization-code model used state, nonce and Proof Key for Code Exchange (PKCE).

14. OIDC Authorization

User → Application → Authorization Endpoint → Microsoft Entra Authentication → Authorization Code → Token Endpoint → Tokens

Response type: code

Redirect URI

state

nonce

openid

profile

email

PKCE using S256

State protects the authorization transaction. Nonce binds the authentication response to the transaction. PKCE protects the authorization-code exchange.

15. OIDC Authorization Evidence

A correctly constructed authorization request reached Microsoft Entra and returned an authorization code. The localhost callback displayed connection refused because no local application was listening on port 3000. This was not an authentication failure at Microsoft Entra.

Authorization-code values were treated as sensitive and were not reused after exposure.

16. OIDC Failure Engineering

An expired authorization code produced invalid_grant. A mismatched PKCE verifier also produced invalid_grant.

invalid_grant → expired code / reused code / redirect mismatch / PKCE mismatch

The throwaway localhost token-exchange exercise was intentionally not extended after the core authorization and failure behaviour had been demonstrated.

17. OIDC Discovery

Discovery metadata was inspected and established the issuer, authorization endpoint, token endpoint, JSON Web Key Set (JWKS) endpoint, supported scopes, supported claims and signing algorithms.

18. ID Token

An ID token communicates authentication and identity information to the OIDC client.

Typical claims: iss, sub, aud, exp, iat, nonce, name, preferred_username

Validation should include issuer, audience, expiry, signature, nonce and subject.

19. Access Token

An access token represents authorization to access a protected resource.

ID Token → Client identity / authentication context
Access Token → Protected API authorization

20. Protected API and Scopes

Protected API: CONTOSO-PROTECTED-API-TEST

Application ID: 1db4ff55-a138-4d8b-9684-1f17c0cf702e

Application ID URI: api://1db4ff55-a138-4d8b-9684-1f17c0cf702e

Delegated scope: access_as_user

The client was granted the protected API delegated scope and Microsoft Graph User.Read delegated permission.

21. OAuth 2.0

OAuth 2.0 is an authorization framework. OIDC adds an identity/authentication layer.

Delegated permissions: application acts on behalf of a signed-in user.

Application permissions: application acts as itself.

Least privilege requires review of API, permission type, scope, consent and application identity.

22. Authentication versus Authorization Errors

Error

Meaning

Examples

401

Authentication problem

Missing, expired or invalid token

403

Authorization problem

Insufficient scope or RBAC permission

23. Okta Authentication Engineering

Okta organisation: integrator-2241342.okta.com

Application: CONTOSO-OKTA-OIDC-TEST

Type: Web

Client ID: 0oa17cxw9nk0twnqV698

OpenID Connect

Authorization Code

Refresh Token

Client Credentials

Exact redirect URI

Client-secret authentication

Group-based application assignment

The client secret was deliberately excluded from this document and source control.

24. Okta Group-Based Assignment

Group: CONTOSO-OKTA-OIDC-TEST-USERS

Test employee: IAM OIDC Test Employee

IAM OIDC Test Employee → CONTOSO-OKTA-OIDC-TEST-USERS → CONTOSO-OKTA-OIDC-TEST

25. Okta Login Initiation

Login initiated by was configured as App Only. This supports direct Service Provider-initiated authentication. The absence of an application tile in My Apps was therefore expected. Application visibility and application assignment are separate controls.

26. Okta Authorization Failure

An initial authorization request returned access_denied with user_not_assigned.

eventType: app.oauth2.authorize
outcome: FAILURE
reason: user_not_assigned

The event showed the correct application identifier, redirect URI, requested scopes and transaction context. The group/application assignment was reconciled, after which authorization successfully issued an authorization code.

27. Okta System Log

Event type

Actor

Application identifier

Outcome

Failure reason

Redirect URI

Requested scopes

Response type

Transaction identifiers

Timestamp

Production troubleshooting should establish who, which application, what event, when, outcome, failure reason, configuration and transaction before changing configuration.

28. Azure Authentication Logs

Microsoft Entra sign-in logs were reviewed for the test identity and authentication applications. Successful events returned error code 0. Logs allowed application, user, outcome, Conditional Access evaluation and correlation information to be identified.

An expected 50140 event was observed during an interrupted sign-in flow. Authentication errors must therefore be interpreted in context.

29. Production IAM Access Ticket

Ticket: Developer cannot access the Finance test resource group. Required access: read-only access to Finance test environment.

User: IAM IaC Test Employee

Finance group: CONTOSO-IAM-FINANCE

Finance group object ID: dfcfbcea-0ab8-49aa-a5c7-7ea75a21ec19

Target Resource Group: rg-contoso-finops-lab-uks-001

Existing Finance authorization: Reader at Resource Group scope.

Investigation found the employee was not initially a member of the approved Finance group.

Smallest safe fix: add the employee to the existing Finance group. No direct user RBAC assignment was created.

IAM IaC Test Employee → CONTOSO-IAM-FINANCE → Reader → rg-contoso-finops-lab-uks-001

Membership was verified successfully.

30. Terraform / IaC Parity

resource "azuread_group_member" "day15_finance_employee" {
  group_object_id  = azuread_group.day15_finance.object_id
  member_object_id = "5dde1c4c-f907-43ba-ac7c-71966d6f6a11"
}

Correct Terraform import identifier format: {GroupObjectID}/member/{MemberObjectID}

Terraform formatting and validation succeeded. Terraform Plan refreshed the Finance membership and returned: No changes. Your infrastructure matches the configuration.

This established Portal → Entra ID → Terraform configuration/state parity.

31. Security Review

Least privilege: group-based authorization preferred over direct user RBAC.

Exact redirect URI: wildcard redirects were not used.

PKCE: used for the OIDC authorization-code flow.

State and nonce: included in the OIDC request.

Token validation: issuer, audience, signature and expiry are critical.

Secrets: passwords, client secrets and tokens were excluded from source control.

Certificate lifecycle: SAML certificate expiry reviewed.

Conditional Access: licensing limitation explicitly documented.

Logging: Entra and Okta authentication evidence reviewed.

Group-based access: used for Azure and Okta application access.

32. Reliability and Operations

Authentication is an availability dependency. Production monitoring should include authentication failure rates, application-specific failures, certificate expiry, token validation failures, identity-provider health, Conditional Access changes, application configuration changes, group membership changes and privileged-access changes.

USER REPORT → IDENTIFY USER → IDENTIFY APPLICATION → CHECK LOGS → IDENTIFY ERROR → CHECK CONFIGURATION → CHECK AUTHORIZATION → SMALLEST SAFE FIX → VERIFY → DOCUMENT

33. Compliance and Governance

Day 16 supports central authentication, MFA, group-based authorization, audit logging, controlled application access, certificate lifecycle management, documented limitations and Git-based engineering evidence.

A production identity governance model should additionally include Privileged Identity Management (PIM), access reviews, joiner/mover/leaver automation, break-glass account governance, Conditional Access, security monitoring, incident response and credential rotation.

34. Cost Review

No compute workload was introduced by the authentication exercises. Microsoft Entra and Okta licensing can have commercial implications. Temporary test resources and identities must be cleaned up when no longer required.

35. Testing Matrix

Test

Purpose

Result

Positive

Authentication and access

Successful Entra, SAML and Okta evidence

Negative

Controlled failure

SAML, OIDC and Okta failures investigated

Permission

Authorization

Finance Reader group model verified

Configuration

Terraform

Validation succeeded

Repeatability

No unintended change

Terraform Plan returned no changes

Safe failure

Security boundary

OIDC, PKCE and SAML failures observed

Drift

IaC parity

Terraform state/configuration aligned

36. Known Limitations

Conditional Access could not be deployed because tenant licensing was insufficient.

The localhost OIDC token-exchange exercise was not extended beyond the demonstrated authorization and failure objectives.

http://localhost:3000/auth/callback is suitable only for the controlled development test and must not be a production redirect.

Okta uses client-secret authentication for the test application; the secret is intentionally excluded.

37. Failure and Root-Cause Catalogue

SAML NameID: changing the NameID source to display name caused failure; restoring the correct identifier recovered authentication.

OIDC expired code: invalid_grant resulted from an expired authorization code.

OIDC PKCE mismatch: invalid_grant resulted from a verifier that did not correspond to the original challenge.

Okta user_not_assigned: assignment relationship was reconciled and the next authorization succeeded.

Conditional Access: implementation was blocked by tenant licensing.

38. Production Troubleshooting Principles

IDENTITY → APPLICATION → AUTHENTICATION METHOD → REQUEST → TOKEN / ASSERTION → LOG → FAILURE → ROOT CAUSE → SMALLEST SAFE FIX → VERIFY → DOCUMENT

The operating principle is to identify the actual authentication or authorization control that failed rather than applying broad configuration changes.

39. Portfolio Evidence — Situation, Task, Action, Result

Situation: Contoso required stronger enterprise authentication capability spanning Microsoft Entra ID and Okta while maintaining secure authorization and operational troubleshooting.

Task: Configure and investigate authentication mechanisms, validate MFA and logs, troubleshoot controlled failures and demonstrate how authentication integrates with authorization and Infrastructure as Code.

Action: Configured and tested Microsoft Entra SAML, inspected assertions, demonstrated NameID failure and recovery, reviewed certificate lifecycle, configured OIDC authorization-code flow with state, nonce and PKCE, investigated expired-code and PKCE failures, configured a protected API scope, configured Okta OIDC and group-based assignment, investigated System Log evidence, reviewed Azure authentication logs, and resolved the Finance IAM ticket through approved group membership before reconciling it into Terraform.

Result: Demonstrated enterprise SSO, MFA, SAML, OIDC, OAuth 2.0, PKCE, authentication logging, controlled failure recovery, group-based authorization, Terraform parity and evidence-based IAM troubleshooting.

40. Interview Evidence

Why is authentication different from authorization?

Authentication establishes who the identity is. Authorization determines what that identity is permitted to access and at what scope.

Why is PKCE important?

PKCE binds the authorization-code exchange to the client transaction and reduces the risk that an intercepted authorization code can be redeemed by an attacker.

Why should redirect URIs be exact?

They determine where authorization responses are returned. Broad redirects can expand the attack surface.

Why investigate logs before changing configuration?

Logs provide identity, application, transaction and error context required for the smallest safe change.

How did you troubleshoot the Okta failure?

The System Log showed app.oauth2.authorize with user_not_assigned. I verified and reconciled the group/application assignment.

What was the Finance access solution?

The existing Finance group already had Reader access. The employee was missing membership, so I added the employee to the approved group instead of granting direct RBAC.

What did Terraform prove?

Terraform showed the live Entra membership matched the declared configuration and managed state by returning No changes.

What would you do if a production plan proposed a large destroy?

Stop the deployment, inspect state ownership and exact replacement/destruction reasons, and do not apply an unexplained destructive plan.

41. Day 16 Completion Evidence

Entra authentication baseline — COMPLETE

MFA inspection — COMPLETE

Conditional Access assessment — LICENSING LIMITATION

SSO — COMPLETE

SAML configuration — COMPLETE

SAML assertion forensics — COMPLETE

SAML failure and recovery — COMPLETE

SAML certificate lifecycle — COMPLETE

Provisioning / SCIM — COMPLETE

OIDC application and authorization — COMPLETE

PKCE and authorization-code failure analysis — COMPLETE

ID token / access token / claims — COMPLETE

OAuth 2.0 and protected API scope — COMPLETE

Okta OIDC application — COMPLETE

Okta group-based assignment — COMPLETE

Okta System Log investigation — COMPLETE

Azure authentication log review — COMPLETE

Finance IAM ticket — COMPLETE

Terraform parity and drift check — COMPLETE

Security review — COMPLETE

Portfolio/interview evidence — COMPLETE

42. Day 16 Engineering Lessons

Authentication is a security and availability control plane.

Logs are primary engineering evidence.

ID tokens and access tokens have different purposes.

Claims such as issuer, audience, subject, nonce and expiry matter.

Exact redirect URIs and federated trust reduce attack surface.

Group-based authorization scales better than direct individual permissions.

Portal changes should be reconciled into the authoritative Infrastructure as Code model.

Known limitations should be documented rather than hidden.

Identify the actual failure, apply the smallest safe fix, verify and move forward.

43. Final Day 16 Summary

Day 16 extended the enterprise platform from identity and authorization engineering into authentication engineering. The work connected Microsoft Entra ID, Okta, MFA, SSO, SAML, OIDC, OAuth 2.0, authentication logs, authorization, Terraform and operational troubleshooting into one production-oriented identity model.

IDENTITY → AUTHENTICATION → MFA / SSO → APPLICATION → AUTHORIZATION → RBAC / OAUTH SCOPES → RESOURCE → LOGGING / AUDIT → INCIDENT RESPONSE

Core principle: identify the actual authentication or authorization control that failed, apply the smallest safe fix, verify the result and preserve the evidence.

44. Git Delivery Target

Repository: yomiwip/Enterprise-Azure-Platform

Documentation file: docs/day16-authentication-engineering.md

The Day 16 commit must contain only the Day 16 documentation. The existing Day 15 Finance Terraform change and untracked Okta discovery JSON must remain separate.

Recommended flow: feature branch → review → validation → commit → push → Pull Request → merge to develop.

45. Prerequisites and Required Access

This runbook assumes a controlled enterprise test environment and does not require production credentials.

Required capabilities:

- Microsoft Entra administrative access appropriate to the configuration being changed.
- Access to the test Entra identities and groups.
- Access to the test SAML and OIDC applications.
- Okta administrative access for the test organisation.
- Git access to the Enterprise Azure Platform repository.
- Terraform installed at the repository's supported version.
- Azure CLI authenticated using an approved administrator or engineering identity.

Access must follow least privilege. Do not use personal credentials, shared administrator credentials, client secrets, passwords or tokens as documentation examples.

Before making a change, confirm the target tenant, subscription, application, resource group and environment.

45. Prerequisites and Required Access
46. Identity and Access Matrix

Identity: IAM IaC Test Employee
Purpose: Authentication and application-access testing
Access model: Assigned to approved test applications and groups
Scope: Controlled test environment

Identity: Finance group — CONTOSO-IAM-FINANCE
Purpose: Group-based Azure authorization
Role: Reader
Scope: rg-contoso-finops-lab-uks-001

Identity: GitHub Actions deployment identity
Purpose: Automated Infrastructure as Code deployment
Access model: Federated workload identity and scoped Azure permissions
Scope: Defined by the platform deployment design

Okta administrator
Purpose: Configure and troubleshoot the Okta test application
Access: Administrative access required only for configuration and investigation

Access principle:

IDENTITY → GROUP / APPLICATION ASSIGNMENT → ROLE / SCOPE → RESOURCE

Do not replace an approved group-based access model with direct individual permissions unless the architecture explicitly requires it.

47. Operational Procedures

Authentication issue:

1. Identify the affected user.
2. Identify the affected application.
3. Identify whether the failure occurs during authentication or authorization.
4. Review the relevant Entra or Okta logs.
5. Capture the error code, outcome, timestamp and transaction/correlation identifier.
6. Check application assignment and group membership.
7. Check SAML assertion or OIDC request/token behaviour where applicable.
8. Identify the smallest failed control.
9. Apply the smallest safe change.
10. Re-test.
11. Record the result and evidence.

Azure Finance access:

1. Confirm the user requires Finance test access.
2. Confirm the approved Finance group.
3. Confirm the group has Reader at the Finance resource-group scope.
4. Check user membership.
5. Add the user to the approved group only when authorised.
6. Verify membership.
7. Verify effective access.
8. Document the ticket and change.

SAML operation:

1. Confirm Entity ID.
2. Confirm Assertion Consumer Service (ACS) URL.
3. Confirm sign-on URL.
4. Confirm application assignment.
5. Inspect the assertion when authentication fails.
6. Validate issuer, destination, audience, NameID, signature and conditions.
7. Check certificate validity.
8. Restore the last known-good configuration if a controlled change causes failure.

OIDC operation:

1. Confirm client application and redirect URI.
2. Confirm authorization-code flow.
3. Confirm state and nonce are present.
4. Confirm Proof Key for Code Exchange (PKCE) is used.
5. Review authorization and token endpoint behaviour.
6. Inspect relevant logs and error responses.
7. Never reuse an exposed authorization code, token or secret.

Okta operation:

1. Confirm application assignment.
2. Confirm group membership.
3. Confirm Login initiated by configuration.
4. Review System Log.
5. Identify the event type and failure reason.
6. Correlate application, user and transaction information.
7. Apply the smallest safe assignment or configuration correction.
8. Re-test.

48. Authentication Troubleshooting Runbook

If authentication fails:

Check identity
→ Check application
→ Check assignment
→ Check authentication request
→ Check assertion/token
→ Check logs
→ Identify root cause
→ Apply smallest safe fix
→ Verify

401 — Authentication problem

Typical causes:
- Missing token
- Expired token
- Invalid token
- Failed authentication

Action:
Inspect the authentication transaction and token validation requirements before changing authorization.

403 — Authorization problem

Typical causes:
- Missing application permission
- Insufficient OAuth 2.0 scope
- Missing Azure Role-Based Access Control (RBAC) permission
- Missing group membership

Action:
Check the identity's effective authorization and scope before modifying authentication configuration.

SAML NameID failure:

Check the NameID value against the application's expected identifier.

OIDC invalid_grant:

Check whether the authorization code is expired, reused, associated with the wrong redirect URI or paired with an incorrect PKCE verifier.

Okta user_not_assigned:

Check the user's application assignment and group/application assignment relationship. Confirm the System Log event before making changes.

Conditional Access limitation:

Do not represent Conditional Access as implemented where tenant licensing does not support the required capability. Record the limitation and required licensing separately.

49. Rollback and Recovery

Authentication changes must have a known rollback path.

SAML:

Restore the previous known-good identifier or assertion configuration. Re-test SP-initiated authentication.

OIDC:

Restore the previous known-good application configuration. Do not attempt to recover or reuse an exposed authorization code.

Okta:

Restore the previous application assignment or configuration state. Re-test the authorization flow and review the System Log.

Azure IAM:

If an incorrect group membership change was made, remove the user from the group after confirming the removal is authorised and appropriate. Verify effective access has been removed.

Terraform:

Never apply an unexplained destructive plan.

If Terraform proposes unexpected changes:

1. Stop.
2. Review the plan.
3. Identify state ownership.
4. Identify configuration differences.
5. Determine whether the change is intentional.
6. Correct the configuration or state safely.
7. Re-run validation and plan.
8. Apply only an understood and approved change.

50. Certificate and Credential Operations

SAML certificate lifecycle:

Monitor certificate expiry before the expiration date.

Operational sequence:

Identify certificate owner
→ Check expiry
→ Prepare replacement
→ Validate replacement
→ Configure rollover
→ Test authentication
→ Monitor
→ Retire old certificate
→ Document

The verified Day 16 test certificate expires on 5 September 2029.

Client secrets, passwords, authorization codes and tokens are sensitive information.

They must never be:

- committed to Git;
- placed in the runbook;
- pasted into tickets;
- included in screenshots;
- included in Pull Requests;
- shared in chat.

Where workload authentication is required, prefer federated or managed identity mechanisms over long-lived secrets where supported by the architecture.

51. Monitoring and Incident Response

Authentication should be treated as a security and availability dependency.

Monitor:

- Authentication failure rate.
- Application-specific authentication failures.
- SAML assertion failures.
- OIDC authorization failures.
- Token validation failures.
- Certificate expiry.
- Application assignment changes.
- Group membership changes.
- Privileged-access changes.
- Authentication policy changes.
- Identity-provider service health.

Microsoft Entra:

Review sign-in logs and relevant audit activity.

Okta:

Review System Log events and correlate user, application, transaction and outcome.

Incident investigation sequence:

USER REPORT
→ IDENTIFY USER
→ IDENTIFY APPLICATION
→ CHECK LOGS
→ IDENTIFY ERROR
→ CHECK CONFIGURATION
→ CHECK AUTHORIZATION
→ APPLY SMALLEST SAFE FIX
→ VERIFY
→ DOCUMENT

Evidence should include timestamps, correlation or transaction identifiers, affected identity, application, error code, outcome, root cause and corrective action.

52. Change Management and Git Workflow

Authentication configuration changes should be reviewed and traceable.

Standard workflow:

Feature branch
→ Implement change
→ Format / validate
→ Review diff
→ Test
→ Pull Request
→ Review
→ CI checks
→ Approved deployment
→ Verify
→ Document
→ Merge

Infrastructure as Code changes must use the repository's Terraform workflow.

Before applying Terraform:

- Inspect the configuration.
- Run format checks.
- Run validation.
- Review the plan.
- Identify resources to be created, changed or destroyed.
- Confirm permissions and dependencies.
- Confirm the scope and expected cost.
- Stop if destructive changes are unexplained.

Portal changes must be reconciled into the authoritative Infrastructure as Code model where the capability is managed through Terraform.

53. Production Safety Rules

Never:

- Disable security controls merely to make a test pass.
- Add wildcard redirect URIs.
- Grant broad administrative permissions when a narrower role exists.
- Grant direct user RBAC when an approved group model exists.
- Commit secrets.
- Reuse exposed tokens or authorization codes.
- Apply an unexplained destructive Terraform plan.
- Make Conditional Access changes without understanding tenant-wide impact.
- Change production authentication configuration solely to troubleshoot a test issue.

Always:

- Inspect before changing.
- Use least privilege.
- Use controlled test identities.
- Record evidence.
- Make the smallest safe change.
- Verify the result.
- Document failures and recovery.
- Clean up temporary resources.
- Review security and operational impact.

54. Handover Checklist

A new engineer taking ownership should be able to confirm:

[ ] Tenant and subscription are known.
[ ] Test identities are known.
[ ] Application identifiers are documented.
[ ] Application assignments are documented.
[ ] Group-based access model is documented.
[ ] SAML Entity ID is documented.
[ ] SAML ACS URL is documented.
[ ] OIDC redirect URI is documented.
[ ] OIDC security controls are documented.
[ ] Okta application assignment is documented.
[ ] Entra authentication logs are identified.
[ ] Okta System Log is identified.
[ ] Known failure modes are documented.
[ ] Rollback procedures are documented.
[ ] Certificate lifecycle is documented.
[ ] Secrets are excluded from documentation and Git.
[ ] Terraform ownership is identified.
[ ] Destructive-plan safety is documented.
[ ] Licensing limitations are documented.
[ ] Monitoring requirements are documented.
[ ] Incident investigation sequence is documented.
[ ] Git change workflow is documented.

Handover principle:

The runbook must provide enough verified information for another competent engineer to understand, operate, troubleshoot and safely change the capability without relying on undocumented tribal knowledge.
