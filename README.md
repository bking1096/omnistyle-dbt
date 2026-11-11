# OmniStyle Retail Group - Fivetran + dbt Setup Guide

Quick 5-minute setup to connect this real **dbt** project into your Fivetran trial so Act 5 runs `dbt run` + `dbt test` live into Snowflake (`FIVETRAN.OMNISTYLE_ANALYTICS`).

---

## Step 1: Verify Snowflake Permissions (Done!)
Confirmed via `SHOW GRANTS ON DATABASE FIVETRAN;`: `ACCOUNTADMIN` already holds `OWNERSHIP` on `DATABASE FIVETRAN`, so your Fivetran Snowflake destination can create and populate `FIVETRAN.OMNISTYLE_ANALYTICS` with **no extra SQL needed right now**.

*(Optional note for production discussions: in production you would swap the trial role for a scoped `FIVETRAN_ROLE` with grants on its target database and warehouse.)*

---

## Step 2: Push `omnistyle-dbt/` to a GitHub Repository
1. Create a new empty repository on GitHub (public or private, e.g. `omnistyle-dbt`, with **no README** initialized).
2. Run in terminal inside `/Users/benking/Documents/agy2-projects/omnistyle-dbt`:
   ```bash
   git init -b main
   git add .
   git commit -m "Initial OmniStyle dbt analytics project"
   git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/omnistyle-dbt.git
   git push -u origin main
   ```

---

## Step 3: Connect dbt Project in Fivetran (Tab 1)
1. In Fivetran left sidebar -> **Transformations** -> **Add transformation** -> select your **Snowflake** destination.
2. Hover over **dbt** -> click **Connect project**.
3. Copy the **Public Key** shown on the Fivetran setup screen.
4. In GitHub repo -> **Settings -> Deploy keys -> Add deploy key** -> paste the key (title: `Fivetran`, read-only is fine) -> save.
5. Back in Fivetran setup form:
   * **Git repository URL (SSH format!):** `git@github.com:<YOUR_GITHUB_USERNAME>/omnistyle-dbt.git`
   * **Connection method:** `Directly`
   * **Default Schema Name:** `OMNISTYLE_ANALYTICS`
   * **dbt Version:** Pick latest **`1.10` / `1.11` / `1.12`** (keep `Automatically use latest patch version` ON).
6. Click **Save & Test** -> **Done**.

---

## Step 4: Create the Demo Job in Fivetran Transformations
1. Under **Transformations**, click **Add transformation** (or **Create job** under your connected `dbt` project).
2. Name the job: **`OmniStyle Black Friday Analytics`**
3. **Schedule:** Choose **Custom schedule** (e.g. `Every 6 hours`) so it **never blocks** `Sync 1` or `Sync 2` during Acts 3 & 4, and gives you a crisp **`Run now`** button in **Act 5**!
   *(In Act 5 you can also hover/show the `Integrated` radio button so Mike & Eoin see that in prod it fires automatically the exact millisecond `omnistyle_prod` finishes syncing!)*
4. Add **2 Steps**:
   * Step 1: `dbt run`
   * Step 2: `dbt test`
5. Click **Save**, then click **`Run now`** once right now to verify green checkmarks across all 4 models + tests, and verify in Snowflake:
   ```sql
   SELECT * FROM FIVETRAN.OMNISTYLE_ANALYTICS.MART_BLACK_FRIDAY_CAMPAIGN_PERFORMANCE;
   SELECT * FROM FIVETRAN.OMNISTYLE_ANALYTICS.MART_CUSTOMER_ACTIVATION_COHORTS;
   ```
