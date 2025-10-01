# Jumpstart Pro Upgrade Guide

This file includes notes on major changes that might affect your application and require changes from you to update.

### August 28, 2025

API clients now raise `UnprocessableContent` instead of `UnprocessableEntity` errors when a 422 is received to match rfc9110.

### May 8, 2025

* Mailgun, Mailpace, and Postmark now send emails via gems. This is beneficial for a couple reasons:

1. DigitalOcean now blocks outbound SMTP by default. While it can be enabled by support, this works around that limitation by using API calls instead.
2. Sending emails via API is faster than SMTP.

This requires updating your credentials to specify API keys for these services:

```yaml
mailpace:
  api_token: "x"

mailgun:
  api_key: "x"

postmark:
  api_token: "x"
```

You'll also need to run `bundle` to install the gem for the related mail service.

### December 23, 2024

* Upgrade to TailwindCSS v4 & import maps
  This update removes the Node.js dependency as we've migrated to the `tailwindcss-rails` gem along with `importmap-rails`. This keeps Jumpstart more aligned with Rails defaults and simplifies dependencies even further.
  To continue using live reloading, we recommend `hotwire-spark` or `hotwire-livereload`.

### December 6, 2024

* [Breaking] Remove Flatpickr. Since Flatpickr isn't accessible to screen readers, we have decided to remove it in favor of the built-in `datetime_local` browser field.

### November 26, 2024

Turbo Native routes have been moved to `/hotwire` now that Jumpstart iOS and Android are using Hotwire Native.

### November 20, 2024

* Removed .nav-link class

  The `.nav-link` class is no longer required on links placed within the `_left_nav` or `_right_nav` partials.
  If you are using this class on any links in your navbar you can remove them as the CSS to handle nav links has been updated to style these links appropriately.

### November 18, 2024

* Refactored to use Hotwire Native.

  The native authentication form now embeds the normal web auth form.
  API endpoints now support cookies for authentication and native clients no longer need API tokens + cookies to interact with the backend.

### October 16, 2024

* Added a "configure your own" option for Active Job queue adapter and simplified the supported list to Async, SolidQueue and Sidekiq.

  To use another queue adapter, select the "configure your own" option and add the queue adapter to your environments.

  If you're using one of the removed queue adapters, be sure to remove it from `config/jumpstart.yml` and set it in your environments.

### September 23, 2024

* Redis has been removed in favor of SolidCable, SolidCache, and SolidQueue in Rails 8.

### June 3, 2024

`Jumpstart::Client` has been removed. We recommend switching to a Jumpstart Pro [API Client](https://github.com/jumpstart-pro/api-clients) or you can integrate with the gem(s) directly.

### December 6, 2023

NotificationTokens for Android now use "fcm" (Firebase Cloud Messaging) as the platform. If you're using this feature, you'll want to update all notification tokens in the database.

```ruby
NotificationToken.where(platform: "Android").update_all(platform: "fcm")
```

### November 22, 2023

The following methods have been renamed - `Account#impersonal?` has been renamed to `Account#team?` and `scope :impersonal` has been renamed to `scope :team`. You will need to update any references to these methods in your application.

### October 11, 2023

`config/puma.rb` has been [updated](https://github.com/rails/rails/pull/46838) to use the full processor count in production. You can customize this by setting `WEB_CONCURRENCY` env var. Heroku provides a `SENSIBLE_DEFAULTS=enabled` env var that will set `WEB_CONCURRENCY` based upon dyno size. Other hosts may need an explicit value set if they do not return the correct processor count.

### August 15, 2023

TailwindCSS Stimulus Components has been updated to v4 which greatly improves animation support.
We've also introduced UI components for modals, slideovers and tabs to make it easier to render them with the proper markup. We recommend switching modals and tabs over to the new components to automatically be updated to stay in sync with any future JavaScript changes.

### July 21, 2023

We've made a few gems optional, but still integrated in Jumpstart Pro:

* ActsAsTenant
* Oj
* Whenever

If you wish to continue using the gems, enable them in the Jumpstart Pro config at `http://localhost:3000/jumpstart#dependencies`

`pg_search` has been removed to make Jumpstart Pro more compatible with MySQL and SQLite. Add pg_search to your Gemfile to continue using it.

The `solargraph` configuration option was also removed. We now recommend [Ruby LSP](https://github.com/Shopify/ruby-lsp) which is zero-dependency in VS Code.

We've added an example rack-attack configuration. We recommend using rack-attack for blocking malicious users and bots from overwhelming your application.

### July 6, 2023

`Gemfile.jumpstart` now replaces `config/jumpstart/Gemfile`. We no longer rewrite `config/jumpstart/Gemfile` each time the Jumpstart Pro configuration changes to keep things simpler and easier to work with.
To upgrade, you will remove `config/jumpstart/Gemfile`. Gems will be automatically installed in `Gemfile.jumpstart` instead. You may need to modify this to specify versions if you had previously in the old file.
Afterwards, you can run `bundle` to confirm all the same gems and versions are installed.

### April 20, 2023

We've fixed a security issue that allows users to bypass 2FA. See [PR #656](https://github.com/jumpstart-pro/jumpstart-pro-rails/pull/656) for details.

### March 29, 2023

We renamed the `outline` CSS class to `btn-outline` to prevent conflicts with TailwindCSS's `outline` class. You will need to update any references of `outline` to `btn-outline` in your views.
We've also added a `Response` class that wraps API client responses to provide access to the original response object for status code and headers. This comes in handy when APIs use headers for pagination, rate limiting, etc.
The original [DelayedJob](https://github.com/collectiveidea/delayed_job) gem is not compatible with Rails 7. We now use the [Delayed](https://github.com/betterment/delayed) fork by Betterment when DelayedJob is chosen as the background job processor.

### February 6, 2023 - System admins

For additional security, we've made the `admin` attribute on the User model readonly.
The `admin` attribute denotes a user as a system-wide admin. The system admins have access to `/admin` and can view the entire database. This is helpful for customer support and other things.

To add or remove a system admin, you can now run the following commands:

```ruby
# Add system admin
Jumpstart.grant_system_admin! User.find_by_email("admin@example.org")

# Remove system admin
Jumpstart.revoke_system_admin! User.find_by_email("admin@example.org")
```

### February 1, 2023 - Administrate updates

We've updated Administrate to the latest version. GitHub accidentally blew away a few commits we added, so you'll want to bundle update administrate so you're on the latest sha.
Administrate has changed views to use new helper methods, so you'll also want to check out the recent commits to adjust the views we have overridden.

### September 14, 2021 - CSS & JS Bundling

Rails 7 introduces `cssbundling-rails` and `jsbundling-rails` packages. We now use the Tailwind CLI and esbuild for Javascript. It's much, much faster and configurable.
We've removed Webpacker, but you can use webpack with jsbundling-rails if you would like.

Use `bin/dev` to run the Rails server along with the CSS & JS watchers in development.

* TailwindCSS has been moved to `app/assets/application.tailwind.css`
* `tailwind.config.js` has been moved to the root
* Sass has been removed and CSS is now processed through postcss only (using the Tailwind CLI)
* Javascript packs are defined in `esbuild.config.js`
* Assets are compiled and output to the `app/assets/builds` directory and served by the asset pipeline.
* Webpacker pack tags have been replaced with asset pipeline tags

### September 4, 2021 - Pay 3 upgrade

The Pay 3.0 upgrade migrates data from the Account model to the new Pay::Customer model and reassociates charges and subscriptions. It also switches generic trials to use the new `fake_processor` in Pay.

You can skip this if you aren't using payments in your app yet.

To upgrade, you'll want to do a few things:
1. Review `20210805001857_upgrade_to_pay_v3.rb`. This migration handles all the data migration to the new tables.
2. Test the migration against your local database. Sync your production database locally to test against it.
3. Test `rails pay:payment_methods:sync_default` in development to make sure it successfully syncs the default payment method for each customer.
4. Run the migration in production
5. Run `rails pay:payment_methods:sync_default` in production to sync default payment methods.
