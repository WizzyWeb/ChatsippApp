# frozen_string_literal: true

FactoryBot.define do
  factory :dashboard_app do
    sequence(:title) { |n| "Dashboard App #{n}" }
    content { [{ type: 'frame', url: 'https://chatshippo.com' }] }
    user
    account
  end
end
