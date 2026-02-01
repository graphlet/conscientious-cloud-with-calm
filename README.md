# Conscientious Cloud: A Practitioner's Journey

> **From "Ship It" to "Ship It Right"** — Real-world patterns for cloud architecture governance, security controls, and infrastructure compliance.

---

## About This Project

This repository documents a series of Medium articles exploring the practical challenges cloud engineers face when evolving from rapid deployment to production-grade, compliant infrastructure. It's not about theory or vendor pitches—it's about the actual journey from working code to defensible architecture.

As cloud practitioners, we've all been there: spinning up infrastructure that works, shipping features fast, and then facing the inevitable questions from security, compliance, and operations teams. _"How do we know this is secure? Can we audit our architecture? What happens when we need to prove compliance?"_

This is the story of bridging that gap—using real Azure infrastructure, actual Terraform code, and architectural modeling that scales beyond documentation drift.

## What You'll Find Here

### Article Series: Building Conscientious Cloud Infrastructure

Each article in this series tackles a specific challenge with working code, deployed infrastructure, and lessons learned:

1. **[Ship It to Ship It Right](articles/01-ship-it-to-ship-it-right/)** — Moving from basic Azure App Service deployment to architecture-level security controls  
   _Topics: encryption-at-rest, encryption-in-transit, key management, HTTPS enforcement, TLS security_

2. _(Future articles coming soon)_

### Working Code & Infrastructure

This isn't a collection of gists or toy examples. Each article includes:

- **Baseline infrastructure** (`terraform/00-baseline/`) — Where we started: functional but basic
- **Architecture models** (`calm/architectures/`) — Formal definitions with embedded security controls
- **Control-compliant infrastructure** (`terraform/02-compliant/`) — Generated code that satisfies architectural requirements
- **Deployed resources** — Live Azure infrastructure demonstrating the concepts

### The Architectural Modeling Approach

Rather than documenting architecture in static diagrams or wikis that drift from reality, we use **[FINOS CALM](https://calm.finos.org)** (Common Architecture Language Model)—a JSON-based, machine-readable specification language.

Why CALM? Because:

- **Architecture as Code**: Define security controls at the design level, not as Terraform comments
- **Bidirectional Flow**: Reverse-engineer existing infrastructure OR generate compliant code from architecture
- **Compliance Validation**: Prove deployed resources satisfy architectural requirements
- **Vendor Agnostic**: Works across clouds and frameworks

Think of it as the contract between what architects intend and what engineers deploy.

## Quick Start

Want to explore the working examples?

### Prerequisites

- Azure CLI (`az`) with an active subscription
- Terraform >= 0.14.9
- CALM CLI: `npm install -g @finos/calm-cli` ([docs](https://www.npmjs.com/package/@finos/calm-cli))
- Node.js (for CALM tooling)

### Try It Yourself

```bash
# 1. Clone and navigate
git clone <repository-url>
cd conscientious-cloud-with-calm/articles/01-ship-it-to-ship-it-right

# 2. Authenticate with Azure
az login
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"

# 3. Validate the architecture model
calm validate -a calm/architectures/01-controls.architecture.json -f pretty

# 4. Deploy control-compliant infrastructure
cd terraform/02-compliant
terraform init
terraform apply

# 5. Verify security controls are deployed
terraform output
```

You'll deploy:

- Azure Key Vault (with RBAC, soft delete, purge protection)
- Storage Account (infrastructure encryption, TLS 1.2 enforcement)
- App Service (HTTPS-only, managed identity, Key Vault integration)

## The Journey: From Baseline to Governed

### Stage 1: Ship It (Baseline)

_5 resources, no formal security controls_

We started with working infrastructure—a Node.js web app on Azure App Service. It ran. It served traffic. But could we audit it? Prove compliance? Not really.

### Stage 2: Model It (Architecture Definition)

_Reverse-engineered CALM architecture with 2 node-level controls_

We formalized what we'd built into an architecture model. Now our infrastructure had a specification—a contract between design and deployment.

### Stage 3: Govern It (Control-Compliant)

_8 resources, 5 comprehensive security controls (3 architecture-level + 2 node-level)_

We elevated security requirements from node-specific settings to architecture-level controls. Then we regenerated Terraform that **automatically** satisfied those controls. The result:

- Encryption-in-transit everywhere (TLS 1.2+)
- Encryption-at-rest for all persistent storage (AES-256)
- Centralized key management (Azure Key Vault with RBAC)
- HTTPS enforcement across all services
- TLS 1.2 minimum protocol enforcement

**The key insight**: Define controls once at the architecture level, generate compliant infrastructure automatically.

## Implemented Security Controls

| Control                 | What It Does                      | How It's Enforced                                                          |
| ----------------------- | --------------------------------- | -------------------------------------------------------------------------- |
| `encryption-in-transit` | All network traffic uses TLS 1.2+ | `https_only = true`, `minimum_tls_version = "1.2"`                         |
| `encryption-at-rest`    | All data encrypted with AES-256   | `infrastructure_encryption_enabled = true`                                 |
| `key-management`        | Centralized secrets with RBAC     | Key Vault with `rbac_authorization_enabled`, soft delete, purge protection |
| `https-enforcement`     | HTTP requests redirected to HTTPS | `https_only = true`, `ftps_state = "Disabled"`                             |
| `tls-security`          | Minimum TLS 1.2 protocol          | `minimum_tls_version = "1.2"`, `scm_minimum_tls_version = "1.2"`           |

## Who This Is For

- **Cloud Engineers** building production infrastructure who need to satisfy security requirements without starting from scratch
- **Solution Architects** looking for patterns to bridge design intent and deployed reality
- **Security Teams** wanting to validate compliance programmatically rather than through spreadsheets
- **Platform Engineers** building governance guardrails for development teams
- **Anyone** tired of architecture documentation that's out of date before the ink dries

## Technology Stack

- **Azure**: Cloud platform (Key Vault, App Service, Storage)
- **Terraform**: Infrastructure as code
- **FINOS CALM 1.1**: Architecture modeling language ([GitHub](https://github.com/finos/calm))
- **CALM CLI**: Validation and generation tooling
- **GitHub Copilot + CALM Chatmode**: AI-assisted architecture development (`.github/chatmodes/CALM.chatmode.md`)

## Learn More

- 📖 [FINOS CALM Documentation](https://calm.finos.org)
- 🔧 [CALM CLI Reference](https://www.npmjs.com/package/@finos/calm-cli)
- 💬 [CALM GitHub Discussions](https://github.com/finos/calm/discussions)
- 🔐 [Azure Security Best Practices](https://docs.microsoft.com/azure/security/)

## Article Series

Follow along as we tackle real-world cloud architecture challenges:

1. **Ship It to Ship It Right** — Architecture-level security controls for Azure infrastructure
2. _(More coming soon — subscribe on Medium to follow the series)_

---

## Contributing

Found an issue? Have a suggestion? Contributions and discussions welcome—open an issue or PR.

## License

[Specify your license here]

---

**Built by practitioners, for practitioners.**  
_Because shipping code is the start, not the finish line._
