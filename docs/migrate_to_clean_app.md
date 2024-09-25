# Upgrade Decidim with clean_app

# For the first time

It's necessary to synchronize the migrations with the clean_app to avoid duplicates.

For it:

## 1. Get clean_app schema migrations

```
pg_dump --host localhost --username postgres --table public.schema_migrations database_clean_app > schema_migrations.sql
```

## 2. Get schema_migrations form **clean_app**

It's important that you only have in this table the migrations of the version you want to synchronize.

Example schema_migrations:
```
COPY public.schema_migrations (version) FROM stdin;
20190619145257
....
20210618114893
20210618114894
20210618114895
20210618114896
\.
```

## 3. Delete migrations from **project**

You must leave in the code the migrations that are from other gems such as term_customizer, verifiers, modules, etc. To find those migrations you can run:

```bash
$ ls -lah db/migrate/ |grep -v ".decidim.rb"|grep -v "decidim_proposals.rb"|grep -v "decidim_meetings.rb"|grep -v "decidim_forms.rb"|grep -v "decidim_consultations.rb"|grep -v "decidim_initiatives.rb"|grep -v "decidim_blogs.rb"|grep -v "decidim_sortitions.rb"|grep -v "decidim_debates.rb"|grep -v "decidim_accountability.rb"|grep -v "decidim_budgets.rb"|grep -v "decidim_assemblies.rb"|grep -v "decidim_participatory_processes.rb"|grep -v "decidim_conferences.rb"|grep -v "decidim_comments"|grep -v "decidim_surveys"|grep -v "decidim_admin.rb"|grep -v "decidim_verifications.rb"|grep -v "decidim_pages.rb"|grep -v "decidim_system.rb"
```


## 4. Delete migrations from schema_migrations table **project**

Now we will have to remove the entries from the schema_migrations table from our database. 

You only have to delete from the schema those migrations that are from Decidim. If they are specific migrations to the project, as modules do not have to remove them.

This is so that when it's deployed in production the database is not destroyed.

SQL query for delete migrations:

`delete from schema_migrations where version >= 'xxxxxxxxxx';`


## 5. Execute query of step 2 in **database project**

```
psql -h localhost -U username database_project -f schema_migrations.sql
```

## 6. Pull changes from **clean_app**

`git pull clean_app 0.2X-stable --allow-unrelated-histories`

Now you will have all migrations synchronized with the clean_app.

Solve conflicts and....

## 7. Run db:migrate 🤞


# For the next times

1. Use the included `bin/rake clean_app:sync`
2. Solve conflicts
3. That's all!
