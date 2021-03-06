require_dependency 'bookie/operation'
require_dependency 'user/avatar/proxy/default'

class User < ApplicationRecord
  module Avatar
    class Destroy < Bookie::Operation
      step :proxy!
      step :destroy!
      step :destroy_images!

      def proxy!(options, model:, **)
        options['proxy'] = Proxy::Default.new(model)
      end

      def destroy!(options, model:, **)
        model.destroy
      end

      def destroy_images!(options, proxy:, **)
        proxy.image(&:destroy!)
      end
    end
  end
end
