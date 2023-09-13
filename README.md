# CI-github101

## Workflows
- Go compile and test CI will run on every commit on every branch.
- Terraform deployment CI will only run when pushing to dev/staging/main branch, or, when opening a pull request targeting to merge to dev/staging/main branch


## Authentication
### At local
Sometimes the authentication does not work because the project is wrong.  
Since there is only 1 Google SDK (`gcloud`) on the local system, which you can view the file content by running
```shell
cat ~/.config/gcloud/configurations/config_default
```
When you run the below script to change project, because this is a system-wide setting, changes will affect all instances where gcloud is used, including different IDEs, shells, or even scripts running on your machine.
```shell
gcloud config set project project-abc # set default project value
```

Hence, we need to make sure that you have set the correct project by running e.g.
```shell
gcloud config get-value project # get default project value
```

### At Github CLI runner
#### Create a gcp-credentials.json file 
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
- Go to the corresponding repository -> Settings -> Secrets and variables -> New Repository Secret
- Set the secret name as `GOOGLE_CREDENTIALS`
- Copy the value from running below script as the value for the secret name `GOOGLE_CREDENTIALS`:
```shell
cat gcp-credentials.json
```