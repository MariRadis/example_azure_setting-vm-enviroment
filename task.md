🔧 1. Technical Quality & Best Practices
✅ Clean, Modular, Reusable Terraform Code
Use variables.tf, outputs.tf, and main.tf separation.

Parameterize VM size, image, region, project, and tags.

Use locals for naming consistency and terraform.tfvars for environment-specific values.

✅ Use Remote State & Locking (Team-readiness)
Show backend "gcs" (or s3) usage for remote state storage.

Include state locking and environment isolation (e.g., one bucket per environment).

✅ Networking & Accessibility
Create necessary resources like VPC, subnet, firewall rules, NAT gateway.

Ensure the VM is reachable (has external IP or IAP setup).

Output the VM IP or connection string (terraform output).

🔄 2. Dependency & Lifecycle Management
✅ Resource Dependencies
Use depends_on only when implicit dependencies don’t cover it.

Use module outputs to pass IDs between resources.

✅ VM Managed by Terraform
Avoid terraform import unless necessary; prefer fully managed lifecycle.

Avoid manual changes; emphasize infrastructure-as-code fidelity.

👥 3. Team-Readiness & Collaboration
✅ Folder & Module Structure
Use /modules/vm, /envs/dev, /envs/prod or similar patterns.

Keep environment-specific values separate from logic.

✅ Documentation & Maintainability
Include README.md with usage instructions.

Use descriptive resource names and tag resources (e.g., created_by, env, project).

🤖 4. Automation & CI/CD Readiness
✅ Terraform Commands & Workflow
terraform fmt, terraform validate, terraform plan, terraform apply, terraform destroy.

Use pre-commit hooks, or GitHub Actions workflow for CI (terraform fmt, validate, plan PR check).

✅ Explain Automation Options
Suggest using GitHub Actions / GitLab CI / Jenkins to deploy infra on merge.

Mention tools like Terragrunt, Atlantis, or Spacelift for large-scale automation.

📚 5. Demonstrated Understanding
Show that you:

Know why a certain VM type was used (cost/performance fit).

Can reuse the same code in other environments by changing only variables.

Understand the risks and benefits of Terraform:

✅ Pros: reproducibility, automation, auditability

❌ Cons: state drift, learning curve, shared state conflicts if not managed properly



------


✅ Hands-On Task Questions
Why was the selected VM size chosen?

Were the necessary resources created to make the VM reachable (e.g., firewall rules, external IP, network setup)?

Is the Terraform code parameterized so it can be reused in different environments (e.g., dev, staging, prod)?

How can I ensure that the VM is managed through Terraform and not manually altered?

How should the code be adapted to work in a team setup (e.g., remote state, locking, collaboration)?

How can I ensure that dependent resources are created in the correct order?

How can this code be executed automatically? Which Terraform commands make sense at which stage?

What are the advantages and disadvantages of using Terraform?

✅ DevOps Understanding Questions
What does DevOps mean to you?

What DevOps tooling have you used so far? If yes, how did you work with it?

Which tools have you used for monitoring and logging applications and infrastructure?

What is the difference between monitoring, alerting, and logging?

What role does communication play in the daily routine of a DevOps team?

------

ands On Task Fragen:

Warum wurde die vorhanden VM Sitze gewählt?
Wurden nötige Ressourcen erstellt, damit die VM erreichbar ist?
Ist der Terraform Code parametrisiert, damit der Code in unterschiedlichen Environments wiederverwendet wurde?
Wie kann ich sicherstellen, dass die VM über Terraform verwaltet wird?
Wie muss der Code angepasst werden, damit er in einem Team Setup funktioniert?
Wie kann sichergestellt werden, dass Resourcen die voneinander Abhängig sind in der richtigen Reihenfolge erstellt
werden?
Wie kann dieser Code automatisiert ausgeführt werden? Welche Terraform Commands können wann Sinn machen?
Welche Vor- und Nachteile hat die Verwendung von Terraform?
DevOps Verständnis Fragen:

Was bedeutet DevOps für dich?
Welches DevOps Tooling hast du bisher verwendet? Falls ja wie hast du damit gearbeitet?
Welche Tools hast du verwendet um Applikationen und Infrastruktur zu monitoren und loggen?
Was ist der Unterschied zwischen Monitoring, Alerting und Logging?
Welche Rolle spielt Kommunikation in einem Alltag eines DevOps Teams?


-------

