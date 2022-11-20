# frozen_string_literal: true

require 'spec_helper'

describe 'ECR repository policy' do
  let(:region) do
    var(role: :root, name: 'region')
  end
  let(:repository_name) do
    var(role: :root, name: 'repository_name')
  end

  def test_role_1_arn
    @test_role_1_arn ||= output(role: :prerequisites, name: 'test_role_1_arn')
  end

  def test_role_2_arn
    @test_role_2_arn ||= output(role: :prerequisites, name: 'test_role_2_arn')
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is true, ' \
           'allow_cross_account_lambda_pull_access is false, and ' \
           'allow_role_based_pull_access is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = true
        vars.allow_cross_account_lambda_pull_access = false
        vars.allow_role_based_pull_access = false
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
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
                  Sid: 'InAccountLambdaPullPermission',
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

    it 'does not allow the specified roles to pull images ' \
       'from the repository' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'AWSPrincipalPullPermission',
                      Effect: 'Allow',
                      Principal: a_hash_including(
                        AWS: a_collection_including(
                          test_role_1_arn,
                          test_role_2_arn
                        )
                      ),
                      Action: %w[
                        ecr:BatchGetImage
                        ecr:GetDownloadUrlForLayer
                      ]
                    )
                  ))
    end

    it 'does not allow the specified lambda accounts to pull images ' \
       'from the repository' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'AWSPrincipalPullPermission',
                      Effect: 'Allow',
                      Principal: a_hash_including(
                        AWS: a_collection_including(
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
                      Sid: 'CrossAccountLambdaPullPermission',
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is false, ' \
           'allow_cross_account_lambda_pull_access is true, and ' \
           'allow_role_based_pull_access is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = false
        vars.allow_cross_account_lambda_pull_access = true
        vars.allow_role_based_pull_access = false
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
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
                      Sid: 'InAccountLambdaPullPermission',
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

    it 'does not allow the specified roles to pull images ' \
       'from the repository' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'AWSPrincipalPullPermission',
                      Effect: 'Allow',
                      Principal: a_hash_including(
                        AWS: a_collection_including(
                          test_role_1_arn,
                          test_role_2_arn
                        )
                      ),
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
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
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
                  Sid: 'CrossAccountLambdaPullPermission',
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is false, ' \
           'allow_cross_account_lambda_pull_access is false, and ' \
           'allow_role_based_pull_access is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = false
        vars.allow_cross_account_lambda_pull_access = false
        vars.allow_role_based_pull_access = true
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
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
                      Sid: 'InAccountLambdaPullPermission',
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

    it 'allows the specified roles to pull images ' \
       'from the repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'AWSPrincipalPullPermission',
                      Effect: 'Allow',
                      Principal: a_hash_including(
                        AWS: a_collection_including(
                          test_role_1_arn,
                          test_role_2_arn
                        )
                      ),
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
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
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
                  Sid: 'CrossAccountLambdaPullPermission',
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is true, ' \
           'allow_cross_account_lambda_pull_access is true, and ' \
           'allow_role_based_pull_access is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = true
        vars.allow_cross_account_lambda_pull_access = true
        vars.allow_role_based_pull_access = false
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
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
                  Sid: 'InAccountLambdaPullPermission',
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

    it 'does not allow the specified roles to pull images ' \
       'from the repository' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'AWSPrincipalPullPermission',
                      Effect: 'Allow',
                      Principal: a_hash_including(
                        AWS: a_collection_including(
                          test_role_1_arn,
                          test_role_2_arn
                        )
                      ),
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
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
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
                  Sid: 'CrossAccountLambdaPullPermission',
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is true, ' \
           'allow_cross_account_lambda_pull_access is false, and ' \
           'allow_role_based_pull_access is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = true
        vars.allow_cross_account_lambda_pull_access = false
        vars.allow_role_based_pull_access = true
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
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
                  Sid: 'InAccountLambdaPullPermission',
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

    it 'allows the specified roles to pull images ' \
       'from the repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
                  .with_attribute_value(
                    :policy,
                    a_policy_with_statement(
                      Sid: 'AWSPrincipalPullPermission',
                      Effect: 'Allow',
                      Principal: a_hash_including(
                        AWS: a_collection_including(
                          test_role_1_arn,
                          test_role_2_arn
                        )
                      ),
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
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
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
                  Sid: 'CrossAccountLambdaPullPermission',
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is false, ' \
           'allow_cross_account_lambda_pull_access is true, and ' \
           'allow_role_based_pull_access is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = false
        vars.allow_cross_account_lambda_pull_access = true
        vars.allow_role_based_pull_access = true
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
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
                  Sid: 'InAccountLambdaPullPermission',
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

    it 'allows the specified roles to pull images ' \
       'from the repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
                      test_role_1_arn,
                      test_role_2_arn
                    )
                  ),
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
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
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
                  Sid: 'CrossAccountLambdaPullPermission',
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is true, ' \
           'allow_cross_account_lambda_pull_access is true, and ' \
           'allow_role_based_pull_access is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = true
        vars.allow_cross_account_lambda_pull_access = true
        vars.allow_role_based_pull_access = true
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
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
                  Sid: 'InAccountLambdaPullPermission',
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

    it 'allows the specified roles to pull images ' \
       'from the repository' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecr_repository_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
                      test_role_1_arn,
                      test_role_2_arn
                    )
                  ),
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
                  Sid: 'AWSPrincipalPullPermission',
                  Effect: 'Allow',
                  Principal: a_hash_including(
                    AWS: a_collection_including(
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
                  Sid: 'CrossAccountLambdaPullPermission',
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

  describe 'when ' \
           'allow_in_account_lambda_pull_access is false, ' \
           'allow_cross_account_lambda_pull_access is false, and ' \
           'allow_role_based_pull_access is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.allow_in_account_lambda_pull_access = false
        vars.allow_cross_account_lambda_pull_access = false
        vars.allow_role_based_pull_access = false
        vars.allowed_cross_account_lambda_pull_access_account_ids = %w[
          176145454894
          879281328474
        ]
        vars.allowed_role_based_pull_access_role_arns = [
          test_role_1_arn,
          test_role_2_arn
        ]
      end
    end

    it 'does not create an ECR repository policy' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_ecr_repository_policy'))
    end
  end
end
