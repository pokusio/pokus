# Secrethub setup

* Ok, at `secrethub signup`, I created a user `pokusbot`, and a workspace `pokus-devspace`.  So there exist only two namespaces into wichi I can create repos, `pokusbot`, and `pokus-devspace` :

```bash
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub repo init 'pokus-devspace/dddddd'
Creating repository...
Create complete! The repository pokus-devspace/dddddd is now ready to use.
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub repo rm 'pokus-devspace/dddddd'
[DANGER ZONE] This action cannot be undone. This will permanently remove the pokus-devspace/dddddd repository, all its secrets and all associated service accounts. Please type in the full path of the repository to confirm: pokus-devspace/dddddd
Removing repository...
Removal complete! The repository pokus-devspace/dddddd has been permanently removed.
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub account inspect
{
    "Username": "pokusbot",
    "FullName": "pokusbot",
    "Email": "jean.baptiste.lasselle.pokus@gmail.com",
    "CreatedAt": "2020-08-08T22:16:41+02:00",
    "PublicAccountKey": "LS0tLS1CRUdJTiBSU0EgUFVCTElDIEtFWS0tLS0tCk1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBd0pzM0tzMlJBZzBoS0dIbW5ocWIKa01iVjNyZm53VDVzRWlZdlhWcldrTFFjcit4dERwQTFCaGlCS2xuUERYRFVJbldKNWNMQitrUHoxWmcxUU1MaAp0WUl5UUZpOFd0ZVV1N2d4ZFk4dFp5Q1lpSERzSDVzWVNDQ25tZUxhTmc1bDMyNUtCbWNBZHVsc3Jnc2UvQ2lyCjZMV3VITGJzRTBlTXBRaEdmYzEvTlZTZG1EejRiQkUwQ0lDMWU0Y1crSmJWREEzMWhhUnRDYUc5emxVLzBlY1kKczNFWGt5QzB0b3c3eVhCMHorYUFrMzZqNGNXVGpSaFZIbEt6Y1gxL1V1akVtL3drVkZ0ODBMazBLUGtiVk1NMQpPeWFsNHFsejlKeXVxOXZMNzdicElhUnV3bE1IUXVrdHQrai8vZjNEYkpYc2J3N041ODVxYmtYT1JkMUVDYlNFCmhSWnlRY2tESU9sVll6ZHpITXd2MThOamlCZVJYNDBPTjh4ZTJvM2FrVXVwQW5UMzlPZVdEd1YxK1pZRjlWRTQKZnNBd25NNUpNcnMwTUNiV1lJRWc4U014QVUyejk3dEd4MWZqK3E4VjJNVjNRT2FPS3hGUTRHYU54SnFyZTRaVApyOTByWE9pcHRPaDNPeVEzKytsajlONzB4alFpZDdEVmF2elUyTERyR1kvUU40cVQzc3IreW11UWJ0RUxuUGlUClJoRVNOelRqT3pYclRqbk5RMkRxSmJMSFcyZTBSOEc4eFRvRWk2MWl6dmV1U0FVMnRxcjhORXREQ3FrelRwbDIKalRHd0oxRWNsKzFiMVJyQUN3eGFIYmF5Ui9jR1gvUGduamxTN3Nsc0xYYVlhRi8rVUwwR2lSeXMyaFJ5VG9ROApGdnVLVGsxbERCSjk2NFZnSjhqWjdsY0NBd0VBQVE9PQotLS0tLUVORCBSU0EgUFVCTElDIEtFWS0tLS0tCg=="
}
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub repo rm 'pokusbot/dddddd'
Encountered an error: Repo 'pokusbot/dddddd' not found (server.repo_not_found)
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub repo init 'pokusbot/dddddd'
Creating repository...
Create complete! The repository pokusbot/dddddd is now ready to use.
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub repo rm 'pokusbot/dddddd'
[DANGER ZONE] This action cannot be undone. This will permanently remove the pokusbot/dddddd repository, all its secrets and all associated service accounts. Please type in the full path of the repository to confirm: pokusbot/dddddd
Removing repository...
Removal complete! The repository pokusbot/dddddd has been permanently removed.
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$
```

* Right, so I have to create a pok-us-io org or workspace, and then I can create secret repos there

```bash
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub org init
Before initializing a new organization, we need to know a few things about your organization. Please answer the questions below, followed by an [ENTER]

The name you would like to use for your organization: pok-us-io
A short description so your teammates will recognize the organization (max. 144 chars): The org in which all secrets for the Pokus Project will be created

Creating organization...
Creation complete! The organization pok-us-io is now ready to use.
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub org ls
NAME            REPOS  USERS  CREATED
pok-us-io       0      1      4 seconds ago
pokus-devspace  0      1      About an hour ago
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$
```

* And now I can init the repo :

```bash
# pok-us-io/api/staging/docker/quay/botoken
# pok-us-io/api/staging/docker/quay/botusername

# create the repository
secrethub repo init pok-us-io/api
# /staging/docker/quay
secrethub mkdir --parents pok-us-io/api/staging/docker/quay

echo "pok-us-io+pokusbot" | secrethub write pok-us-io/api/staging/docker/quay/botoken
echo "BYGREGREGREGEGERGERGERGERGERGERGERGERGERGERGERERGERGERGERGR4" | secrethub write pok-us-io/api/staging/docker/quay/botusername


```

* Indeed :

```bash
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub org ls
NAME            REPOS  USERS  CREATED
pok-us-io       0      1      4 seconds ago
pokus-devspace  0      1      About an hour ago
jbl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ secrethub repo init pok-us-io/api
Creating repository...
Create complete! The repository pok-us-io/api is now ready to use.
jibl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ echo "BYGREGREGREGEGERGERGERGERGERGERGERGERGERGERGERERGERGERGERGR4" | secrethub write pok-us-io/api/staging/docker/quay/botoken
Writing secret value...
Write complete! The given value has been written to pok-us-io/api/staging/docker/quay/botoken:2
jibl@poste-devops-jbl-16gbram:~/apicurio-studio/distro/docker-compose$ echo "pok-us-io+pokusbot" | secrethub write pok-us-io/api/staging/docker/quay/botusername
Writing secret value...
Write complete! The given value has been written to pok-us-io/api/staging/docker/quay/botusername:2

```
* Okay, last thing, I need the read only secret (not the one from my `~/.secrethub/credential` file) to give to `Circle CI` :

```bash
# SO the idea is that you get a token with read access to all secrets in the mentioned repo  (here 'pok-us-io/api')
secrethub service init --permission read pok-us-io/api
```
* And in Circle CI, (in what Circle CI calls a context ) I create and Env variable of name `SECRETHUB_CREDENTIAL` with that token value that I got (with read only access)
