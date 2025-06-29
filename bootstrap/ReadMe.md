After you created the app registration, Azure automatically creates a service principal for it.

To find the object ID (needed for role assignment):

bash
Copy
Edit
az ad sp list --display-name github-oidc-test --query '[0].id' -o tsv