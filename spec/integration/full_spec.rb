# frozen_string_literal: true

require 'spec_helper'

describe 'full' do
  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(
      role: :full,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'ECR repository' do
    subject(:repository) { ecr_repository(repository_name) }

    let(:region) { var(role: :full, name: 'region') }
    let(:repository_name) { var(role: :full, name: 'repository_name') }

    it { is_expected.to exist }

    it 'exposes the registry ID as an output' do
      expected_registry_id = repository.registry_id
      actual_registry_id = output(role: :full, name: 'registry_id')

      expect(actual_registry_id).to(eq(expected_registry_id))
    end

    it 'exposes the repository URL as an output' do
      expected_repository_url = repository.repository_uri
      actual_repository_url = output(role: :full, name: 'repository_url')

      expect(actual_repository_url).to(eq(expected_repository_url))
    end
  end
end
