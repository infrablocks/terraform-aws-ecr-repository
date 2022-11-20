# frozen_string_literal: true

require 'spec_helper'

describe 'ECR repository policy' do
  let(:region) do
    var(role: :root, name: 'region')
  end
  let(:repository_name) do
    var(role: :root, name: 'repository_name')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'does not create an ECR repository policy' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy'))
    end
  end

  describe 'when allow_in_account_lambda_access is true and ' \
           'allow_cross_account_lambda_access is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_access = true
        vars.allow_cross_account_lambda_access = false
        vars.allowed_cross_account_lambda_access_accounts = %w[
          176145454894
          879281328474
        ]
      end
    end

    it 'creates an ECR repository policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .once)
    end

    it 'allows the lambda service to pull images in account' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'LambdaECRImageRetrievalPolicy',
                  Effect: 'Allow',
                  Principal: {
                    Service: 'lambda.amazonaws.com'
                  },
                  Action: %w[
                    ecr:BatchGetImage
                    ecr:GetDownloadUrlForLayer
                  ]
                )
              ))
    end

    it 'does not allow the lambda service to create lambdas for images ' \
       'in the repository from other accounts' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'CrossAccountPermission',
                      Effect: 'Allow',
                      Principal: a_hash_including(
                        AWS: contain_exactly(
                          'arn:aws:iam::176145454894:root',
                          'arn:aws:iam::879281328474:root'
                        )
                      ),
                      Action: %w[
                        ecr:BatchGetImage
                        ecr:GetDownloadUrlForLayer
                      ]
                    )
                  ))
    end

    it 'does not allow the lambda service to pull images in the repository ' \
       'from other accounts' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'LambdaECRImageCrossAccountRetrievalPolicy',
                      Effect: 'Allow',
                      Principal: {
                        Service: 'lambda.amazonaws.com'
                      },
                      Action: %w[
                        ecr:BatchGetImage
                        ecr:GetDownloadUrlForLayer
                      ],
                      Condition: a_hash_including(
                        StringLike: a_hash_including(
                          'aws:sourceARN': contain_exactly(
                            "arn:aws:lambda:#{region}:176145454894:function:*",
                            "arn:aws:lambda:#{region}:879281328474:function:*"
                          )
                        )
                      )
                    )
                  ))
    end
  end

  describe 'when allow_in_account_lambda_access is false and ' \
           'allow_cross_account_lambda_access is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_access = false
        vars.allow_cross_account_lambda_access = true
        vars.allowed_cross_account_lambda_access_accounts = %w[
          176145454894
          879281328474
        ]
      end
    end

    it 'creates an ECR repository policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .once)
    end

    it 'does not allow the lambda service to pull images in account' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'LambdaECRImageRetrievalPolicy',
                      Effect: 'Allow',
                      Principal: {
                        Service: 'lambda.amazonaws.com'
                      },
                      Action: %w[
                        ecr:BatchGetImage
                        ecr:GetDownloadUrlForLayer
                      ]
                    )
                  ))
    end

    it 'allows the lambda service to create lambdas for images ' \
       'in the repository from other accounts' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'CrossAccountPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: contain_exactly(
                      'arn:aws:iam::176145454894:root',
                      'arn:aws:iam::879281328474:root'
                    )
                  ),
                  Action: %w[
                    ecr:BatchGetImage
                    ecr:GetDownloadUrlForLayer
                  ]
                )
              ))
    end

    it 'allows the lambda service to pull images in the repository ' \
       'from other accounts' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'LambdaECRImageCrossAccountRetrievalPolicy',
                  Effect: 'Allow',
                  Principal: {
                    Service: 'lambda.amazonaws.com'
                  },
                  Action: %w[
                    ecr:BatchGetImage
                    ecr:GetDownloadUrlForLayer
                  ],
                  Condition: a_hash_including(
                    StringLike: a_hash_including(
                      'aws:sourceARN': contain_exactly(
                        "arn:aws:lambda:#{region}:176145454894:function:*",
                        "arn:aws:lambda:#{region}:879281328474:function:*"
                      )
                    )
                  )
                )
              ))
    end
  end

  describe 'when allow_in_account_lambda_access is true and ' \
           'allow_cross_account_lambda_access is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_access = true
        vars.allow_cross_account_lambda_access = true
        vars.allowed_cross_account_lambda_access_accounts = %w[
          176145454894
          879281328474
        ]
      end
    end

    it 'creates an ECR repository policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .once)
    end

    it 'allows the lambda service to pull images in account' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'LambdaECRImageRetrievalPolicy',
                  Effect: 'Allow',
                  Principal: {
                    Service: 'lambda.amazonaws.com'
                  },
                  Action: %w[
                    ecr:BatchGetImage
                    ecr:GetDownloadUrlForLayer
                  ]
                )
              ))
    end

    it 'allows the lambda service to create lambdas for images ' \
       'in the repository from other accounts' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'CrossAccountPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: contain_exactly(
                      'arn:aws:iam::176145454894:root',
                      'arn:aws:iam::879281328474:root'
                    )
                  ),
                  Action: %w[
                    ecr:BatchGetImage
                    ecr:GetDownloadUrlForLayer
                  ]
                )
              ))
    end

    it 'allows the lambda service to pull images in the repository ' \
       'from other accounts' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'LambdaECRImageCrossAccountRetrievalPolicy',
                  Effect: 'Allow',
                  Principal: {
                    Service: 'lambda.amazonaws.com'
                  },
                  Action: %w[
                    ecr:BatchGetImage
                    ecr:GetDownloadUrlForLayer
                  ],
                  Condition: a_hash_including(
                    StringLike: a_hash_including(
                      'aws:sourceARN': contain_exactly(
                        "arn:aws:lambda:#{region}:176145454894:function:*",
                        "arn:aws:lambda:#{region}:879281328474:function:*"
                      )
                    )
                  )
                )
              ))
    end
  end

  describe 'when allow_in_account_lambda_access is false and ' \
           'allow_cross_account_lambda_access is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_access = false
        vars.allow_cross_account_lambda_access = false
      end
    end

    it 'does not create an ECR repository policy' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy'))
    end
  end
end
