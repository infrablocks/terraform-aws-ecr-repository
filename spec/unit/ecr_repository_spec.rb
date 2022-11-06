# frozen_string_literal: true

require 'spec_helper'

describe 'ECR repository' do
  let(:repository_name) do
    var(role: :root, name: 'repository_name')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates an ECR repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .once)
    end

    it 'uses the provided repository name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(:name, repository_name))
    end

    it 'outputs the registry ID' do
      expect(@plan)
        .to(include_output_creation(name: 'registry_id'))
    end

    it 'outputs the repository URL' do
      expect(@plan)
        .to(include_output_creation(name: 'repository_url'))
    end
  end
end
