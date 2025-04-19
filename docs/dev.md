# Developer Documentation

## Ops

This app is made to run with Docker.

The App code itself is in the `app` directory. There is a generic `Dockerfile` for Ruby.
For production there is a `prod.Dockerfile`.
Environment variables `SECRET_KEY_BASE=...` (random secret) and `RAILS_ENV=production` are required.

The `docker-compose.yml` contains services separated using profiles for dev and prod.
The `docker-compose.yml` assumes that Traefik is used as a reverse proxy.

Our app on it's own can only serve http, not https.

## Dev

### User Provisioning

User accounts for the roles employee and intern are no longer created using fixtures. Instead, they are provisioned via database migrations. The required credentials are securely passed through environment variables.

Environment Variables:

- EMPLOYEE_USERNAME – Username for the employee role
- EMPLOYEE_PASSWORD – Password for the employee role

- INTERN_USERNAME – Username for the intern role
- INTERN_PASSWORD – Password for the intern role

Ensure these variables are defined in the .env file or passed as Docker build arguments during the build process. The current implementation references the .env file.

The migration will fail safely if any required variables are missing or invalid. This ensures proper setup and avoids inconsistent data.

### Run in dev mode

In `app/`

```shell
docker compose --profile dev up --build
```

Listens on `http://localhost:3000`

### Run shell in the container

```shell
docker compose --profile bash run bash
```

In bash shell run `rubocop -a` to auto-correct linting errors.
Add one or more paths to only check those files or directories.

### Styling

We use Tailwind which is configured in `app/config/tailwind.config.js` and `app/app/assets/stylesheets/application.tailwind.css`.
`app/app/assets/stylesheets/application.css` is not used.
We wanted to keep everything in one place.

### I18n

We currently support two languages: German and English.
If you want to add a language, add a yml file with the language code to the `app/config/locales/` directory and add it to `app/config/application.rb`:

```ruby
config.i18n.available_locales = [ :en, :de ]
```

We have a ruby script in `app/scripts/check_locale_keys.rb` that checks if all translation keys are the same in every internationalization.
