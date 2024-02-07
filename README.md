# Secure Rsync Deploy

This GitHub Action deploys files from a local directory on GitHub Actions to a folder on a remote server using rsync over SSH.

## Inputs

- `DEPLOY_KEY` _(required)_ — The private key part of an SSH key pair. Using [GitHub deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys) are recommended. The public key part of the SSH key should be added to the `~/.ssh/authorized_keys` file on the server that receives the deployment. The private key should be stored as an Actions secret in your GitHub repo, environment, or organization. 

- `HOST` _(required)_ — Remote host name or IP address (e.g. example.com or 101.186.66.124). Using a [GitHub Actions configuration variable](https://docs.github.com/en/actions/learn-github-actions/variables#using-the-vars-context-to-access-configuration-variable-values) is recommended.

- `USER` _(required)_ — The username to use on the remote server. Using a [GitHub Actions configuration variable](https://docs.github.com/en/actions/learn-github-actions/variables#using-the-vars-context-to-access-configuration-variable-values) is recommended.

- `REMOTE_PATH` _(required)_ — The file path on the remote server that should be synced. For example: `/var/www/html/`. Using a [GitHub Actions configuration variable](https://docs.github.com/en/actions/learn-github-actions/variables#using-the-vars-context-to-access-configuration-variable-values) is recommended.

- `LOCAL_PATH` _(optional)_ — The local folder to be synced, relative to the GitHub workspace. Defaults to the GitHub workspace directory.

- `FLAGS` _(optional)_ — Provide any initial rsync options. The default flags are `--archive --checksum --compress --delete-after --force --recursive -verbose`.

- `OPTIONS` _(optional)_ — Provide any additional rsync options. The default options are `--include-from=.distinclude --exclude-from=.distignore --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r`. This means that, **by default, you will need a `.distinclude` and a `.distignore` file in the root of your project**. These files can contain an include/exclude pattern on each line.

## Example Usage

### Basic Example

This example excludes all optional values and uses variables and secrets to customize the configuration. All changes are deployed whenever code is pushed to the `main` branch.

```yml
name: Deploy to production

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: wp-forge/secure-rsync-deploy@1.0.0
        with:
          USER: ${{ vars.SERVER_USER }}
          HOST: ${{ vars.SERVER_HOST }}
          REMOTE_PATH: ${{ vars.SERVER_PATH }}
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}

```

### Advanced Example

This example includes all optional values and uses variables and secrets to customize the required options. All changes are deployed whenever a new release is published on GitHub.


```yml
name: Deploy to production

on:
  release:
    types:
      - published

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: wp-forge/secure-rsync-deploy@1.0.0
        with:
          FLAGS: -aczrv --delete
          OPTIONS: --exclude=/.* --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r
          LOCAL_PATH: /dist/
          USER: ${{ vars.SERVER_USER }}
          HOST: ${{ vars.SERVER_HOST }}
          REMOTE_PATH: ${{ vars.SERVER_PATH }}
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}

```

## REMINDER!
A misconfiguration could result in a loss of files on the remote server. Please backup your remote files before testing or imlementing this action! 

Also, be sure to check the options (including the defaults) to make sure you are happy with them.