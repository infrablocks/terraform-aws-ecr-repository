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

    it 'makes image tags immutable' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :image_tag_mutability, 'IMMUTABLE'
              ))
    end

    it 'does not set force delete on the repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :force_delete, false
              ))
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

  describe 'when repository_image_tag_mutability is "MUTABLE"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.repository_image_tag_mutability = 'MUTABLE'
      end
    end

    it 'makes image tags mutable' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :image_tag_mutability, 'MUTABLE'
              ))
    end
  end

  describe 'when repository_image_tag_mutability is "IMMUTABLE"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.repository_image_tag_mutability = 'IMMUTABLE'
      end
    end

    it 'makes image tags immutable' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :image_tag_mutability, 'IMMUTABLE'
              ))
    end
  end

  describe 'when repository_force_delete is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.repository_force_delete = true
      end
    end

    it 'sets force delete on the repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :force_delete, true
              ))
    end
  end

  describe 'when repository_force_delete is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.repository_force_delete = false
      end
    end

    it 'does not set force delete on the repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :force_delete, false
              ))
    end
  end
end
