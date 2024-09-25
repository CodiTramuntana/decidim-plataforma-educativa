# DECIDIM.CLEAN.APP

This is a clean Decidim app to use as a starting point for other Decidim app projects.

## Fork the repository

A fork is a copy of a repository. Forking a repository allows you to make changes without affecting the original project.

In the top-right corner of the page, click **Fork**.

## Keep your fork synced

To keep your fork up-to-date with the upstream repository, i.e., to upgrade decidim, you must configure a remote that points to the upstream repository in Git.

You can do it with the included rake task:

```bash
bin/rake clean_app:install
```

or do it manually:


```bash
# List the current configured remote repository for your fork.
$ git remote -v
# Specify the new remote upstream repository that will be synced with the fork.
$ git remote add clean-app https://github.com/CodiTramuntana/decidim-clean-app.git
# Verify the new decidim-clean repository you've specified for your fork.
$ git remote -v
```

Syncing a fork

You can do it with the included rake task:

```bash
# Pull from master by default
bin/rake clean_app:sync
# Or pull from a specific branch
bin/rake clean_app:sync[release/0.27-stable]
```

or do it manually:

```bash
# Create a new branch in your fork to start a PR.
$ git checkout master
# Incorporate changes from the decidim-clean repository into the current branch.
$ git pull clean-app master --allow-unrelated-histories
```

## Customize your fork

The following files should be modified:

- README.md
- package.json
- config/application.rb
- config/initializers/decidim.rb

## Testing

Run `bin/rake decidim:generate_external_test_app` to generate a dummy application to test both the application and the modules.

Require missing factories in `spec/factories.rb`

Add `require "rails_helper"` to your specs and execute them from the **root directory**, i.e.:

## Migrate an app to synchronize from clean-app

Documentation in `docs/migrate_to_clean_app.md`.
