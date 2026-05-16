# Repairs / completes chatwoot_v4 rollout for existing accounts without triggering
# Account validations (CaptainFeaturable store_accessor on settings).
#
# Complements 20250416182131_flip_chatwoot_v4_default_feature_flag_installation_config.rb
# which may fail on older code paths; this migration is idempotent and safe to re-run.
class SafelyEnableChatwootV4ForExistingAccounts < ActiveRecord::Migration[7.0]
  def up
    config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
    if config&.value.present?
      features = config.value.map do |f|
        f['name'] == 'chatwoot_v4' ? f.merge('enabled' => true) : f
      end
      config.value = features
      config.save!
    end

    Account.find_in_batches(batch_size: 100) do |accounts|
      accounts.each do |account|
        next if account.feature_enabled?('chatwoot_v4')

        account.enable_features('chatwoot_v4')
        account.update_column(:feature_flags, account.feature_flags)
      end
    end

    GlobalConfig.clear_cache
  end
end
