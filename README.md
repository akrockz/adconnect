# coreservices-adconnect

## What is this?

This creates a Microsoft AD Service in the specified account. Run this locally, or via lambda if you wish. Keep in mind this is not an ephemeral deployment and very few modificaitons can be made after the initial deployment.

- Edit config.yaml with your desired properties for a directory service
- `export PIPELINE_ENVIRONMENT=` nonprod | prod
- run adManagedAd.main()
- A secret will be created in the account with the name "{Portfolio}-{App}-{Branch}-{Secretname}"
- That secret is for joining and managing the AD domain

Note: Creation can take 40 minutes. As such, I have not included a wait.

## Cross Account Sharing

Once the directory is created and in the "Active" state, you can use `shareDirectoryService.main('DirectoryId')` and config.yaml to share the directory to the required accounts.

Note: you can not use ORGANIZATION to share unless you have provisioned this service in the master account, which you can not do because the master account has no VPCs.

Once shared, you need to find the account specific share ID for each account, you can then use acceptSharedDirectory.main('shareId') to accept that connection.

## TODO

* acceptSharedDirectory to provide a list of ready to accept directories
* Rename files according to python conventions (https://www.python.org/dev/peps/pep-0008/#package-and-module-names)
* Throw exceptions (e.g. ValueError) rather than exit()
