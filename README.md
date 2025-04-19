# ∃Link – Project and Expert Management Platform

∃Link is a web application designed for managing projects and keeping track of expert profiles. It enables invited experts to maintain their profiles and be booked for projects that match their qualifications. Developed as part of the "Laboratory for Software Development and Project Skills" course (4th semester), this project focused on real-world usability, and team-based agile development.
 
- ∃Link was developed on behalf of the non-profit organization **Fiti e. V.** as the project stakeholder.


## Documentation

To ensure smooth onboarding and further development, we provide two comprehensive guides:

- [User Documentation](/docs/user.md)  
  For users who want to understand the system functionality and interface.

- [Developer Documentation](/docs/dev.md)  
  For developers who want to contribute or extend the system.

Please **start with the documentation** before using or extending the system!

## CI/CD

Note: The [.gitlab-ci.yml](.gitlab-ci.yml) file included in this repository is used exclusively for GitLab CI/CD pipelines.
It is ignored on GitHub and serves documentation purposes only, to reflect our original development environment and deployment strategy.

## License
This project is licensed under the [GNU Affero General Public License v3.0 (AGPL-3.0)](LICENSE).

## Developer Guide

All development-related code is located in the `app/` directory.

### Start in Development Mode

```shell
docker compose --profile dev up --build
```

The app will be available at `http://localhost:3000`

<br>

### Start bash shell

```shell
docker compose --profile bash run bash
```
Inside the bash shell run:

```bash
rubocop -a 
```
This will auto-correct linting errors.
Add file paths as needed to target specific files or directories.

<br>

### Test - Start Ruby bash shell

```shell
docker compose -f test-compose.yml up --build
```

This will start a Ruby bash shell for running tests.

<br>

### Production Mode

In `app/`

```shell
docker compose up --build
```

The app will be served at http://localhost:3000

<br>
