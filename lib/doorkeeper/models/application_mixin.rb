module Doorkeeper
  module ApplicationMixin
    extend ActiveSupport::Concern

    include OAuth::Helpers
    include Models::Scopes
    include ActiveModel::MassAssignmentSecurity if defined?(::ProtectedAttributes)

    included do
      has_many :access_grants, dependent: :delete_all, class_name: 'Doorkeeper::AccessGrant'
      has_many :access_tokens, dependent: :delete_all, class_name: 'Doorkeeper::AccessToken'

      validates :name, :secret, :uid, presence: true
      validates :uid, uniqueness: true
      validates :redirect_uri, redirect_uri: true

      before_validation :generate_uid, :generate_secret, on: :create
    end

    module ClassMethods
      def by_uid_and_secret(uid, secret)
        find_by(uid: uid.to_s, secret: secret.to_s)
      end

      def by_uid(uid)
        find_by(uid: uid.to_s)
      end
    end

    private

    def has_scopes?
      Doorkeeper.configuration.orm != :active_record ||
        Doorkeeper::Application.column_names.include?("scopes")
    end

    def generate_uid
      if uid.blank?
        self.uid = UniqueToken.generate
      end
    end

    def generate_secret
      if secret.blank?
        self.secret = UniqueToken.generate
      end
    end
  end
end
