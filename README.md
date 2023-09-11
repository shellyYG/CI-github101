# CI-github101

## Workflows
- Go compile and test CI will run on every commit on every branch.
- Terraform deployment CI will only run when pushing to dev/staging/main branch, or, when opening a pull request targeting to merge to dev/staging/main branch


## Authentication
### Create a gcp-credentials.json file 
- since we can't use `gcloud auth application-default login` like at local, we need a service account key stored as a json file
- steps of creating service account key: https://cloud.google.com/iam/docs/keys-create-delete#creating
- after downloading the JSON from above name the JSON file as `gcp-credential.json`

### Make gcp-credential.json oneline
```shell
vi gcp-credential.json
1. Press `shlft+:`
2. Add the following right after the ":"
%s;\n; ;g
3. Press enter
4. Press `shlft+:` again
5. type wq! and press enter again
```

### Use the one-line JSON file as secret for the repo
Go to the corresponding repo -> Settings -> Secrets and variables -> New Repository Secret
https://github.com/shellyYG/CI-github101/settings/secrets/actions
Set the secret name as `GOOGLE_CREDENTIALS`
Value you can copy from the value of running:
```shell
cat gcp-credentials.json
```