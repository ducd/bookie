module Settings
  class AccountsController < ApplicationController

    # GET /settings/account
    def show
      result = run User::Settings::Account::Show

      User::Settings::Account::Endpoint::Show.(result) do |m|
        m.success { render_show(result) }
        m.unauthorized { redirect_to(root_url) }
      end
    end

    # PATCH /settings/account
    def update
      result = run User::Settings::Account::Update::Account

      User::Settings::Account::Endpoint::Update.(result) do |m|
        m.success { redirect_to(settings_account_url, anchor: nil) }
        m.unauthorized { redirect_to(root_url) }
        m.invalid { render_show(result) }
      end
    end

    # PATCH /settings/account/password
    def update_password
      result = run User::Settings::Account::Update::Password

      User::Settings::Account::Endpoint::Update.(result) do |m|
        m.success { redirect_to(settings_account_url, anchor: nil) }
        m.unauthorized { redirect_to(root_url) }
        m.invalid { render_show(result) }
      end
    end

    # DELETE /settings/account
    def destroy
      result = run User::Settings::Account::Destroy

      User::Settings::Account::Endpoint::Destroy.(result) do |m|
        m.success { redirect_to(root_url, anchor: nil) }
        m.unauthorized { redirect_to(root_url, anchor: nil) }
        m.invalid { render_show(result) }
      end
    end

    private

    def render_show(result)
      render_concept('user/settings/account/cell/show', result['model'], {
        account_contract: result['contract.account'],
        password_contract: result['contract.password'],
        destroy_contract: result['contract.destroy'],
      })
    end
  end
end
