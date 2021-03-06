require_dependency 'bookie/cell'

class User < ApplicationRecord
  module Settings
    module Account
      module Cell
        class AvatarForm < Bookie::Cell

          private

          def contract
            options.fetch(:contract)
          end

          def url
            settings_account_avatar_path
          end

          def id
            'avatar-form'
          end
        end
      end
    end
  end
end
