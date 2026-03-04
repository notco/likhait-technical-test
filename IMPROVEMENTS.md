# Project Improvements

This document tracks improvements and fixes made to the project.

## Docker Configuration

### Backend Dockerfile - Missing System Dependencies

**Issue:** The backend Docker build was failing during `bundle install` with the following error:
```
An error occurred while installing psych (5.3.1), and Bundler cannot continue.
```

**Root Cause:** The `psych` gem (YAML parser used by Ruby) requires the `libyaml-dev` system package to compile its native extension. This dependency was missing from the Dockerfile.

**Solution:** Added `libyaml-dev` to the list of installed packages in the Dockerfile.

**File Changed:** `backend/Dockerfile`
```dockerfile
# Before
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential ca-certificates default-mysql-client default-libmysqlclient-dev git && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# After
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential ca-certificates default-mysql-client default-libmysqlclient-dev git libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
```

**Date:** 2026-03-04

---

### Backend Docker - Rails Command Not Found

**Issue:** The backend container was failing with:
```
sh: 3: rails: not found
```

**Root Cause:** Gems are installed in `vendor/bundle` (as configured in the Dockerfile), but Rails commands were being run without `bundle exec`. When gems are installed in a custom path, you must use `bundle exec` to run commands with the correct gem paths.

**Solution:** Added `bundle exec` prefix to all Rails commands in docker-compose.yml.

**File Changed:** `docker-compose.yml`
```yaml
# Before
command: >
  sh -c "
    bundle install &&
    rails db:migrate &&
    rails db:seed &&
    rails server -b 0.0.0.0
  "

# After
command: >
  sh -c "
    bundle install &&
    bundle exec rails db:migrate &&
    bundle exec rails db:seed &&
    bundle exec rails server -b 0.0.0.0
  "
```

**Date:** 2026-03-04

---

### Database Schema - Missing Columns in init.sql

**Issue:** The backend was failing during `db:seed` with:
```
ActiveModel::UnknownAttributeError: unknown attribute 'date' for Expense
ActiveRecord::NotNullViolation: Column 'payer_name' cannot be null
```

**Root Cause:** The database schema in `db/init.sql` didn't match the Rails migration and seed file expectations. The `expenses` table was missing the `date` column that the seed file tried to use, and the `payer_name` column was NOT NULL but the seed file didn't provide values for it. Note that the initial 15 expenses seeded in `init.sql` already have `payer_name` values populated (e.g., 'John Doe', 'Jane Smith'), so the `payer_name` column cannot be removed entirely - it must remain in the schema but be made nullable.

**Solution:** Added the `date` column to the expenses table in `init.sql` and made both `date` and `payer_name` nullable. This allows the Rails seed file to create expenses without these values while preserving the `payer_name` data from the initial SQL seeds.

**File Changed:** `db/init.sql`
```sql
# Before
CREATE TABLE IF NOT EXISTS expenses (
  ...
  category_id INT NOT NULL,
  payer_name VARCHAR(100) NOT NULL,
  ...

# After
CREATE TABLE IF NOT EXISTS expenses (
  ...
  date DATE,
  category_id INT NOT NULL,
  payer_name VARCHAR(100),
  ...
```

**Date:** 2026-03-04

---

### Frontend Docker - Missing Rollup Native Binaries

**Issue:** The frontend container was failing with:
```
Error: Cannot find module @rollup/rollup-linux-arm64-musl
```

**Root Cause:** Vite uses Rollup which requires platform-specific native binaries as optional dependencies. npm has a known bug (https://github.com/npm/cli/issues/4828) where optional dependencies are not always installed correctly during `npm install`, especially in Docker builds. The `@rollup/rollup-linux-arm64-musl` package (required for Alpine Linux on ARM64) was not being installed.

**Solution:** Explicitly install the required Rollup native binary after the main `npm install` in the Dockerfile.

**File Changed:** `frontend/Dockerfile`
```dockerfile
# Before
RUN npm install

# After
RUN npm install && \
    npm install --no-save @rollup/rollup-linux-arm64-musl
```

**Date:** 2026-03-04

---

### Backend Docker - Stale PID File Causing Server Exit

**Issue:** The backend container was exiting on subsequent `docker-compose up` runs with:
```
A server is already running (pid: 20, file: /rails/tmp/pids/server.pid).
```

**Root Cause:** The `/rails/tmp` directory is mounted from the host machine, so the `server.pid` file persists between container restarts. When the container stops, the PID file isn't cleaned up, causing Rails to think a server is already running when it restarts.

**Solution:** Added a command to remove the stale PID file before starting the Rails server.

**File Changed:** `docker-compose.yml`
```yaml
# Before
command: >
  sh -c "
    bundle install &&
    bundle exec rails db:migrate &&
    bundle exec rails db:seed &&
    bundle exec rails server -b 0.0.0.0
  "

# After
command: >
  sh -c "
    bundle install &&
    bundle exec rails db:migrate &&
    bundle exec rails db:seed &&
    rm -f /rails/tmp/pids/server.pid &&
    bundle exec rails server -b 0.0.0.0
  "
```

**Date:** 2026-03-04

---
