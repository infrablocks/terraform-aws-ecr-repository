# frozen_string_literal: true

require 'spec_helper'

describe 'ECR repository' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
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

    it 'enables image scanning on push' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                [:image_scanning_configuration, 0, :scan_on_push], true
              ))
    end

    it 'includes the component as a tag' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Component: component
                )
              ))
    end

    it 'includes the repository name as a tag' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Name: repository_name
                )
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

  describe 'when repository_image_scanning_scan_on_push is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.repository_image_scanning_scan_on_push = true
      end
    end

    it 'enables image scanning on push' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                [:image_scanning_configuration, 0, :scan_on_push], true
              ))
    end
  end

  describe 'when repository_image_scanning_scan_on_push is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.repository_image_scanning_scan_on_push = false
      end
    end

    it 'disables image scanning on push' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                [:image_scanning_configuration, 0, :scan_on_push], false
              ))
    end
  end

  describe 'when tags provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.tags = {
          Tag1: 'value1',
          Tag2: 'value2'
        }
      end
    end

    it 'includes the component as a tag' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Component: component
                )
              ))
    end

    it 'includes the repository name as a tag' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Name: repository_name
                )
              ))
    end

    it 'includes the provided tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Tag1: 'value1',
                  Tag2: 'value2'
                )
              ))
    end
  end
end
